"""
Used to query for all failed jobs to build an Excel workbook of information on those jobs.
"""
import logging
from datetime import datetime
import xlsxwriter
import settings
import fme_flow_api as fme_api
import utils
import jobs

def build_output_dir(failed):
    """
    Loops through all failed jobs to create a dictionary to hold the jobs that were running at
    the same time and the job that was running on the same engine before the failed job started.

    Parameters:
      failed (list): list of failed jobs from FME Flow REST API

    Returns:
      out (dict): Elements stored based on their start time. Has the following structure:
          {
          START_TIME_1: {
            "START_TIME": datetime object of failed job's start time,
            "END_TIME": datetime object of failed job's end time,
            "REPO": string of failed job's repository,
            "NUM_JOBS": int count of jobs that were running at the same time as the failed job,
            "NO_LOG": bool indicating if the failed job has no logs,
            "ENGINES": list of engines that were running while the failed job was running,
            "FAILED_JOB": job information for failed job,
            "RELATED_JOBS": list of job's that were running while the failed job was running,
            "PREVIOUS_JOB": job information for previous job
            }
          ...,
          {START_TIME_N: {} }
          }
    """
    out = {}
    dup = []

    # loop through failed jobs
    for failed_job in failed['items']:
        no_logs = False
        # get the start time as a string
        start = failed_job['result']['timeStarted']

        # check if the time is already in the dict, and if the ids are the same
        # we have a duplicated failed job. Add duplication to dup list
        if start in out and failed_job['id'] == out[start]['FAILED_JOB']['Job ID']:
            duplicated_failed = (failed_job, out[start]['FAILED_JOB'])
            dup.append(duplicated_failed)
            continue

        # compare the status message from this job to the error message we are expecting from
        # the no log failures. If they match set no_logs to True
        result_status_message = failed_job['result']['statusMessage'][:61]
        no_log_err = settings.const['result']['statusMessage'][:61]
        if result_status_message == no_log_err:
            no_logs = True

        # build the job dict based on the information we want
        job = jobs.build_job(failed_job)
        failed_repo = job['Repository']
        kirk_job = 0
        if failed_repo == "KIRK":
            kirk_job = 1
        out[start] = {
            "START_TIME": utils.str_to_datetime(start),
            "END_TIME": utils.str_to_datetime(failed_job['timeFinished']),
            "REPO": failed_repo,
            "NUM_JOBS": 1,
            "NO_LOG": no_logs,
            "ENGINES": [failed_job['engineName']],
            "NUM_KIRK_JOBS": kirk_job,
            "FAILED_JOB": job,
            "RELATED_JOBS": [],
            "PREVIOUS_JOB": None
        }

    # If there were any duplicated failed jobs report them
    if len(dup) > 0:
        logging.warning("Duplicated failed jobs found:")
        for cur_dup in dup:
            logging.warning("""  %s\n  - Failed Job: %s, \n  - Existing Job: %s\n""",
                           cur_dup[0]['result']['timeStarted'],
                           cur_dup[0]['id'],
                           cur_dup[1]['id'])

    return out

def clean_output(result):
    """
    Takes the dictionary of related jobs and reformats it so it is easier to see which have related
    jobs. new_dict["FAILED_NO_CONCURRENT"] will be empty if all jobs have related jobs.

    Parameters:
      result (dict): dictionary with an entry for every failed job

    Returns:
      new_dict (dict): dictionary for failed jobs with related jobs prioritized, and a new section
        for failed jobs with no jobs that ran at the same time listed below.
    """
    no_related_jobs = []
    new_dict = {}

    # loop through all objects in the dictionary
    for job in result:
        # If the related_jobs is empty and no previous job, add it to the no related jobs list
        # Else add the object as is to the new dictionary
        if result[job]['RELATED_JOBS'] == [] and result[job]['PREVIOUS_JOB'] is None:
            no_related_jobs.append(result[job]["FAILED_JOB"])
        else:
            new_dict[job] = result[job]

    new_dict["FAILED_NO_CONCURRENT"] = no_related_jobs

    return new_dict

def detail_write(sheet, row, failed_job_id, headers, to_write, job_type):
    """
    Standard write function for the rows within the details tab. Because we are writing to the
    workbook directly we dont need to return anything.

    Parameters:
      sheet (xlsxwriter workbook sheet): Sheet to write information to
      row (int): row to write to on sheet
      failed_job_id (string): represents the Job ID of the failed job
      headers ():
      to_write ():
      job_type ():
    """
    for col in headers:
        if col == "Failed/Previous/Related":
            sheet.write(row, headers.index(col), job_type)
            continue
        elif col == "Failed Job ID":
            sheet.write(row, headers.index(col), failed_job_id)
            continue
        data = to_write.get(col)
        if isinstance(data, datetime):
            date, time = (data.strftime("%b %d, %y"), data.strftime("%I:%M:%S%p"))
            if col == "Time Started":
                # write the date at the same time as the time started
                sheet.write(row, headers.index("Date"), date)
            data = time
        sheet.write(row, headers.index(col), data)

def write_to_excel(obj):
    """
    Given the object with failed jobs and their related jobs create and write to a new Excel
    sheet. There will always be at least two sheets created in the Excel file "Failed Overview"
    and "Details". If there are any values for the key `FAILED_NO_CONCURRENT` a third sheet will
    be added - "Failed Jobs no Related Jobs".

    Parameters:
      obj (dict): failed jobs dictionary with included related and previous job objects.
    """
    counter = 0
    total = len(obj)

    wb = xlsxwriter.Workbook("FailedJobs.xlsx")

    overview = wb.add_worksheet("Failed Overview")
    overview_row = 0
    overview_headers = settings.headers['overview']
    for ovw_col_num, ovw_header in enumerate(overview_headers):
        overview.write(overview_row, ovw_col_num, ovw_header)
    overview_row += 1

    details = wb.add_worksheet("Details")
    details_row = 0
    detail_headers = settings.headers['detailed']
    for det_col_num, det_header in enumerate(detail_headers):
        details.write(details_row, det_col_num, det_header)
    details_row += 1

    for date_time in obj:
        utils.print_percentage(counter, total=total)
        counter += 1

        if date_time == "FAILED_NO_CONCURRENT" and len(obj[date_time]) > 0:
            no_rel = wb.add_worksheet("Failed Jobs no Related Jobs")
            no_rel_row = 0
            for no_rel_col, det_header in enumerate(detail_headers):
                no_rel.write(no_rel_row, no_rel_col, det_header)

            no_rel_row += 1
            for job in obj[date_time]:
                detail_write(no_rel, no_rel_row, "N/A", detail_headers, job, "Failed")
            continue
        if isinstance(obj[date_time], list):
            continue

        failed_job_id = obj[date_time]["FAILED_JOB"]["Job ID"]

        # write to the overview page
        overview.write(overview_row, overview_headers.index("Failed Job ID"),\
                       failed_job_id)
        overview.write(overview_row, overview_headers.index("Repository"),\
                       obj[date_time]["REPO"])
        overview.write(overview_row, overview_headers.index("No Log Error"),\
                       obj[date_time]["NO_LOG"])
        overview.write(overview_row, overview_headers.index("Date"),\
                       obj[date_time]["START_TIME"].strftime("%b %d, %y"))
        overview.write(overview_row, overview_headers.index("Start Time"),\
                       obj[date_time]["START_TIME"].strftime("%I:%M:%S%p"))
        overview.write(overview_row, overview_headers.index("End Time"),\
                       obj[date_time]["END_TIME"].strftime("%I:%M:%S%p"))
        overview.write(overview_row, overview_headers.index("Total Jobs Running"),\
                       obj[date_time]["NUM_JOBS"])
        overview.write(overview_row, overview_headers.index("Number of KIRK Jobs Running"),\
                       obj[date_time]["NUM_KIRK_JOBS"])
        overview_row += 1

        # add failed job to details
        detail_write(details, details_row, failed_job_id, detail_headers,\
                     obj[date_time]["FAILED_JOB"], "Failed")
        details_row += 1

        # add previous job to details
        detail_write(details, details_row, failed_job_id, detail_headers,\
                     obj[date_time]["PREVIOUS_JOB"], "Previous")
        details_row += 1

        # loop through related jobs adding each
        for job in obj[date_time]["RELATED_JOBS"]:
            detail_write(details, details_row, failed_job_id, detail_headers, job, "Related")
            details_row += 1

    wb.close()
    print(f"[{'#'*settings.terminal_width}] 100.00%", flush=True)

def main():
    """
    Works through a file of failed jobs and gathers information on jobs that were running at
    the same time on other engines, and the job that previously ran on the same engine.
    Writes output to an Excel file "FailedJobs.xlsx". As the jobs are being processed info logs
    are printed to console and 2 progress bars will display.
    """
    # set up global variables
    settings.init()

    # set up logging
    log = logging.getLogger(__name__)
    logging.basicConfig(format='%(levelname)s: %(message)s', level="INFO")

    log.info("Requesting failed jobs...")

    # read the failed jobs
    fail_jobs = fme_api.get_failed()
    log.info("Failed jobs loaded.")

    # check the reported total number of failed jobs, compare the the number of failed jobs we hace
    missing_jobs = fail_jobs['totalCount'] - len(fail_jobs['items'])
    if missing_jobs > 0:
        # if we are mising any report it
        log.warning("Missing %s failed jobs", missing_jobs)

    # Set up a dictionary to hold the jobs that were running at the same time
    log.info("Configuring Output...")
    output = build_output_dir(fail_jobs)
    log.info("Output Setup")

    # Parse related jobs and add to the output
    log.info("Getting Related Jobs...")
    related_jobs = fme_api.get_related_jobs(output)
    log.info("Related Jobs Loaded.")

    cleaned = clean_output(related_jobs)

    log.info("Writing to Excel...")
    write_to_excel(cleaned)
    log.info("Complete.")

if __name__ == "__main__":
    main()
