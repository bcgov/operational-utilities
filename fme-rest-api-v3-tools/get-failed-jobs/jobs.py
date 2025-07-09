"""
Handles the creation of job objects from raw FME Flow REST API requests.

Imports:
  utils: custom Python file with common functions
  settings: custom Python file with constants
"""
import utils
import settings

def build_nmd(in_obj):
    """
    Checks values of in_obj for unexpected values. If any are found they are unpacked and
    added to the return list to be added to the job information.

    Parameters:
      in_obj (dict): NMDirectives object returned from FME Flow API request.

    Returns:
      temp_nm (list[tuple]): unpacked key value pairs from all lists within in_obj.
          If the key does not exist no tuple is added for that value.
    """
    temp_nm = []

    if in_obj.get("directives"):
        temp_nm.append(("NM Directives: Directives", str(in_obj["directives"])))
    if in_obj.get("successTopics"):
        temp_nm.append(("NM Directives: Success Topics", str(in_obj["successTopics"])))
    if in_obj.get("failureTopics"): # != settings.const['NMDirectives']['failureTopics']:
        temp_nm.append(("NM Directives: Failure Topics", str(in_obj["failureTopics"])))

    return temp_nm

def build_tmd(in_obj):
    """
    Checks values of in_obj for unexpected values. If any are found they are unpacked and
    added to the return list to be added to the job information.

    Parameters:
      in_obj (dict): TMDirectives object returned from FME Flow API request.

    Returns:
      temp_nm (list[tuple]): unpacked key value pairs from all lists within in_obj.
          If the key does not exist or if it matches the default value for its type
          no tuple is added for that value.
    """
    temp_tm = []

    rtc = in_obj.get('rtc')
    if rtc != settings.const['TMDirectives']['rtc']:
        temp_tm.append(('TM Directives: RTC', rtc))

    ttc = in_obj.get('ttc')
    if ttc != settings.const['TMDirectives']['ttc']:
        temp_tm.append(('TM Directives: TTC', ttc))

    desc = in_obj.get('description')
    if desc != settings.const['TMDirectives']['description']:
        temp_tm.append(('TM Directives: Description', desc))

    tag = in_obj.get('tag')
    if tag != settings.const['TMDirectives']['tag']:
        temp_tm.append(('TM Directives: Tag', tag))

    priority = in_obj.get('priority')
    if priority != settings.const['TMDirectives']['priority']:
        temp_tm.append(('TM Directives: Priority', priority))

    ttl = in_obj.get('ttl')
    if ttl != settings.const['TMDirectives']['ttl']:
        temp_tm.append(('TM Directives: TTL', ttl))

    return temp_tm

def build_res(in_obj):
    """
    Checks values of in_obj for unexpected values. If any are found they are unpacked and
    added to the return list to be added to the job information.

    Parameters:
      in_obj (dict): NMDirectives object returned from FME Flow API request.

    Returns:
      res (list[tuple]): unpacked key value pairs from all lists within in_obj.
          If the key does not exist or if it matches the default value for its type
          no tuple is added for that value.
    """
    res = []

    res_port = in_obj.get('requesterResultPort')
    if res_port != settings.const['result']['requesterResultPort']:
        res.append(("Result: Requester Result Port", res_port))

    feat_out = in_obj.get("numFeaturesOutput")
    if feat_out: # != settings.const['result']['numFeaturesOutput']:
        res.append(("Result: Number Features Output", feat_out))

    req_host = in_obj.get("requesterHost")
    if req_host != settings.const['result']['requesterHost']:
        res.append(("Result: Requester Host", req_host))

    priority = in_obj.get("priority")
    if priority != settings.const['result']['priority']:
        res.append(("Result: Priority", priority))

    stat_message = in_obj.get("statusMessage")
    if stat_message: # != settings.const['result']['statusMessage']:
        res.append(("Result: Status Message", stat_message))

    status = in_obj.get("status")
    if status:
        res.append(("Result: Status", status))

    return res

def get_pub_params(obj, name_li):
    """
    Given an object and a name list look through the object and return a new object with
    the name value pairs.

    Parameters:
      obj (dict): object with values to be unpacked
      name_li (list): list of keys that we are looking for

    Returns:
      ret (list): list of tuples representing values from obj that match keys within name_li
    """
    ret = []
    for param in obj:
        if param["name"] in name_li:
            ret.append(("Published Parameters: " + param["name"], param["raw"]))

    return ret

def build_job(obj):
    """
    Given a job object create a new object holding only the necessary information
    See README for more information on typical requests and how they are returned.

    Parameters:
      obj (dict): raw request data from FME Flow REST API. Detailed information on the structure
          can be found in this directories README.md.

    Returns:
      job_dir (dict): Unpacked, sanitized information from obj
    """
    # base information we always want to keep.
    job_dir = {}

    if obj.get("id"):
        job_dir['Job ID'] = obj['id']
    if obj.get('engineName'):
        job_dir['Engine Name'] = obj['engineName']
    if obj.get('timeStarted'):
        job_dir['Time Started'] = utils.str_to_datetime(obj['timeStarted'])
    if obj.get('timeFinished'):
        job_dir['Time Finished'] = utils.str_to_datetime(obj['timeFinished'])
    if obj.get('elapsedTime'):
        job_dir['Elapsed Time'] = obj['elapsedTime']
    if obj.get('cpuTime'):
        job_dir['CPU Time'] = obj['cpuTime']
    if obj.get('cpuPct'):
        job_dir['CPU Percent'] = obj['cpuPct']
    if obj.get('peakMemUsage'):
        job_dir['Peak Memory Usage'] = obj['peakMemUsage']
    if obj.get('status'):
        job_dir['Status'] = obj['status']
    if obj.get('repository'): # != settings.const['repository']:
        job_dir['Repository'] = obj['repository']
    if obj.get('numErrors'):# != settings.const['numErrors']:
        job_dir['Number Errors'] = obj['numErrors']
    if obj.get('numWarnings'): # != settings.const['numWarnings']:
        job_dir['Number Warnings'] = obj['numWarnings']
    if obj.get('numLines'): # != settings.const['numLines']:
        job_dir['Number Lines'] = obj['numLines']
    if obj.get('workspace'): # != settings.const['workspace']:
        job_dir['Workspace'] = obj['workspace']
    if obj.get('workspacePath'):
        #if obj['workspacePath'] != settings.const['workspacePath']:
        job_dir['Workspace Path'] = obj['workspacePath']
    if obj.get('sourceType'):
        #if obj['sourceType'] != settings.const['sourceType']:
        job_dir['Source Type'] = obj['sourceType']
    if obj.get('sourceName'):
        job_dir['Source Name'] = obj['sourceName']

    engine_host = obj.get('engineHost')
    if engine_host and engine_host != settings.const['engineHost']:
        job_dir['Engine Host'] = engine_host

    descp = obj.get('description')
    if descp and descp != settings.const['description']:
        job_dir['Description'] = descp

    if obj['result'].get('id') != job_dir['Job ID']:
        job_dir['Result: ID'] = obj['result']['id']

    if obj.get('userName'): # != settings.const['userName']:
        job_dir['User Name'] = obj['userName']

    params = ['KIRK_JOBLABEL', 'KIRK_JOBID', 'FME_AUTOMATION_NAME', 'KIRK_DEST_DB_KEY_OVERRIDE']
    pub_params = get_pub_params(obj['request']['publishedParameters'], params)
    for param in pub_params:
        job_dir[param[0]] = param[1]

    if obj['request'].get('TMDirectives') != settings.const['TMDirectives']:
        tmd = build_tmd(obj['request']['TMDirectives'])
        for ele in tmd:
            job_dir[ele[0]] = ele[1]

    if obj['request'].get('NMDirectives') != settings.const['NMDirectives']:
        nmd = build_nmd(obj['request']['NMDirectives'])
        for ele in nmd:
            job_dir[ele[0]] = ele[1]

    if obj['result'] != settings.const['result']:
        res = build_res(obj['result'])
        for ele in res:
            job_dir[ele[0]] = ele[1]

    # checking the time started values to see if they need to be added
    added_start_times = [job_dir.get('Time Started')]

    time_queued = obj.get('timeQueued')
    if time_queued:
        time_queued = utils.str_to_datetime(time_queued)
    if time_queued and time_queued not in added_start_times:
        job_dir['Time Queued'] = time_queued
        added_start_times.append(time_queued)

    time_requested = obj['result'].get('timeRequested')
    if time_requested:
        time_requested = utils.str_to_datetime(time_requested)
    if time_requested not in added_start_times:
        job_dir['Result: Time Requested'] = time_requested
        added_start_times.append(time_requested)

    time_submitted = obj.get('timeSubmitted')
    if time_submitted:
        utils.str_to_datetime(time_submitted)
    if time_submitted not in added_start_times:
        job_dir['Time Submitted'] = time_submitted
        added_start_times.append(time_submitted)

    res_start = obj['result'].get('timeStarted')
    if res_start:
        res_start = utils.str_to_datetime(res_start)
    if res_start not in added_start_times:
        job_dir['Result: Time Started'] = res_start

    # Checking the end times to see if they need to be added
    added_fin_times = [job_dir.get('Time Finished')]

    time_delivered = obj.get('timeDelivered')
    if time_delivered:
        time_delivered = utils.str_to_datetime(time_delivered)
    if time_delivered not in added_fin_times:
        job_dir['Time Delivered'] = time_delivered
        added_fin_times.append(time_delivered)

    res_time_fin = obj['result'].get('timeFinished')
    if res_time_fin:
        utils.str_to_datetime(res_time_fin)
    if res_time_fin not in added_fin_times:
        job_dir['Result: Time Finished'] = res_time_fin

    return job_dir
