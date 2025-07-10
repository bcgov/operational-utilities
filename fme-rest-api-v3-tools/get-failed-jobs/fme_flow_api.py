"""
Holding all functions that connect to the FME Flow API.

Imports:
  sys: Handles exiting the program in the case of unexpected behaviour
  requests: Handles request to FME Flow REST API
  utils: Custom Python file with common functions
  settings: Custom Python file with constants
  jobs: Custom Python file to create job objects
"""
import sys
import requests
import utils
import settings
import jobs

def get_jobs(limit, offset, failed=False):
    """
    Fetch another batch of jobs from the FME API.
    If failed is set this will only return failed jobs.

    Parameters:
      limit (int): The number of jobs to fetch.
      offset (int): The offset for pagination.
      failed (bool): Flag for requesting failed jobs. Default is False

    Returns:
      res.json() (dict): result of FME Flow REST API call, unpacked from json to a dict
    """
    token = utils.check_token()

    state = ""
    if failed:
        state = "completedState=failed&"
    temp_req = settings.api_token + f'{state}limit={limit}&offset={offset}'
    headers = {
        'Authorization': f'fmetoken token={token}'
    }
    try:
        # try to request jobs. If an error occurs or the timeout is hit script will exit.
        res = requests.get(url=temp_req, headers=headers, timeout=3)
    except requests.exceptions.RequestException as e:
        print(f"Error fetching jobs: {e}")
        sys.exit(1)
    if res.status_code != 200:
        print(f"Failed to fetch jobs: {res.status_code} - {res.text}")
        sys.exit(1)
    return res.json()

def get_failed():
    """
    Used to query FME Flow REST API for failed jobs, paginating results and storeing them within
    a dictionary to be parsed.

    Returns:
      failed (dict): Dictionary holding all results of failed job request, if there are more than
        limit a new request is made and the results are added as required.
    """
    limit = 1000
    offset = 0
    jobs_res = get_jobs(limit, offset, failed=True)
    failed = {}

    while jobs_res['limit'] > offset:
        if offset != 0:
            for job in jobs_res['items']:
                failed['items'].append(job)
        else:
            failed = dict(jobs_res)

        offset += limit
        get_jobs(limit, offset, failed=True)
    return failed

def get_related_jobs(out):
    """
    Used to request for all completed jobs, comparing each to the list of failed jobs. If the job
    does not have the same ID as a failed job checks start to see if the current job is related
    to any of the failed jobs. The first check determines if the current job falls within the start
    and end time range of a faild job its information is added to the failed jobs `RELATED_JOBS`
    list. If the job ran on the same engine as a failed job, the end time of current job is before
    the endtime of the failed job and one of the following is true:
      no previous job is set or the start time of this job is more recent than the set previous job
    then the current job is set as the failed jobs `PREVIOUS_JOB`.
    Requests are made to FME Flow REST API until all jobs have been parsed.

    Parameters:
      out (dict): precreated stucture of failed jobs

    Returns:
      out (dict): stucture of failed jobs with additional information on related and previous jobs
    """
    limit = 1000
    offset = 0
    jobs_res = get_jobs(limit, offset)
    total_jobs = jobs_res.get('totalCount')

    # loop through all completed jobs, sending new requests as required
    while total_jobs > offset:
        # update progress bar
        utils.print_percentage(offset, total=total_jobs)
        # for each completed job in the burrent batch
        for request in jobs_res['items']:
            # get current jobs start and end times
            req_start_datetime = utils.str_to_datetime(request['timeStarted'])
            req_end_datetime = utils.str_to_datetime(request['timeFinished'])
            # loop through each failed job
            for failed_job in out:
                # get failed jobs start and end times
                fail_end_time = out[failed_job]['END_TIME']
                fail_start_time = out[failed_job]['START_TIME']
                if out[failed_job]['FAILED_JOB']['Job ID'] == request['id']:
                    # the current job is a failed job
                    continue
                # A job is related if its start time is before the failed jobs end time
                #   and the job's end time is after the failed jobs start time
                if (req_start_datetime < fail_end_time and \
                   req_end_datetime >= fail_start_time) or \
                   req_start_datetime == fail_start_time:
                    related_job = jobs.build_job(request)
                    out[failed_job]['NUM_JOBS'] += 1
                    out[failed_job]['ENGINES'].append(request['engineName'])
                    out[failed_job]['RELATED_JOBS'].append(related_job)
                    if related_job['Repository'] == "KIRK":
                        out[failed_job]['NUM_KIRK_JOBS'] += 1
                elif out[failed_job]['FAILED_JOB']['Engine Name'] == request['engineName']:
                    test_job = jobs.build_job(request)
                    if fail_start_time > test_job['Time Finished'] and \
                       (out[failed_job]['PREVIOUS_JOB'] is None or \
                        out[failed_job]['PREVIOUS_JOB']['Time Started'] < test_job['Time Started']):
                        out[failed_job]['PREVIOUS_JOB'] = test_job

        offset += limit
        jobs_res = get_jobs(limit, offset)

    print(f"[{'#'*settings.terminal_width}] 100.00%", flush=True)
    return out
