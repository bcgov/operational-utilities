"""
Used to hold all "global" variables and constants that may be required by other scripts.
"""
import os

def init():
    """
    Any global variables set here can be imported with this file, then accessed with dot notation

    Globally acessable variables:
      terminal_width (int): Determines the width of the terminal then divides by 2 and removes 7
          character spaces to hold space for "[", "]", "%" and percentage numbers
      api_token (str): Holds base path to FME Flow API
      err_msg (str): Represents the error message that we see from "No Logs" FME Flow Job failures
      const (dict): Object holding standard values that we want to remove from output information
      headers (dict): Object holding 2 lists of detailed and overview page headers.
    """
    global terminal_width
    terminal_width = (os.get_terminal_size().columns // 2) - 7

    global api_token
    api_token = 'http://asellus.dmz/fmerest/v3/transformations/jobs/completed?'

    global err_msg
    err_msg = 'INCLUDE -- failed to evaluate Python script '\
    '`def ParamFunc():   import fme   from fmeFramework import KIRKParams   '\
    'params = KIRKParams.KIRKParams(fme.macroValues)   fmc = params.getFieldMapCount()   '\
    "print ('fmc is', fmc)   return fmc  value = ParamFunc() macroName = 'KIRK_FLDMAPCNT' "\
    'if value == None:   return { macroName : u'' } else:   import six   try:     '\
    'value = six.text_type(value)   except UnicodeDecodeError:     '\
    "value = six.text_type(value, 'utf-8')   return { macroName : value } '"

    global const
    const = {
        'publishedParameters': {
            'KIRK_DEST_DB_KEY_OVERRIDE': "PRD"
        },
        'workspacePath': "\"KIRK/APP_KIRK__FGDB/APP_KIRK__FGDB.fmw\"",
        'TMDirectives': {
            "rtc": False,
            "ttc": -1,
            "description": "",
            "tag": "Default",
            "priority": -1,
            "ttl": -1
        },
        'NMDirectives': {
            "failureTopics": ["JOBSUBMITTER_ASYNC_JOB_FAILURE"]
        },
        "workspace": "APP_KIRK__FGDB.fmw",
        "numErrors": 0,
        "numLines": 0,
        "engineHost": "localhost",
        "description": "",
        "repository": "KIRK",
        "userName": "REPLICAT",
        "result": {
          "requesterResultPort": -1,
          "numFeaturesOutput": 0,
          "requesterHost": "142.34.140.19",
          "priority": -1,
          "statusMessage": err_msg
        },
        "sourceType": "SCHEDULES",
        "numWarnings": 0
      }

    global headers
    headers = {
        "detailed": [
          "Job ID",
          "Failed Job ID",
          'Status',
          'Failed/Previous/Related',
          'Engine Name',
          'Date',
          'Time Started',
          'Time Finished',
          'Elapsed Time',
          'CPU Time',
          'CPU Percent',
          'Peak Memory Usage',
          'Repository',
          'Number Errors',
          'Number Warnings',
          'Number Lines',
          'Workspace',
          'Workspace Path',
          'Source Type',
          'Source Name',
          'Engine Host',
          'Description',
          'Result: ID',
          'User Name',
          'Published Parameters: KIRK_JOBLABEL',
          'Published Parameters: KIRK_JOBID',
          'Published Parameters: FME_AUTOMATION_NAME',
          'Published Parameters: KIRK_DEST_DB_KEY_OVERRIDE',
          'NM Directives: Directives',
          'NM Directives: Success Topics',
          'NM Directives: Failure Topics',
          'TM Directives: RTC',
          'TM Directives: TTC',
          'TM Directives: Description',
          'TM Directives: Tag',
          'TM Directives: Priority',
          'TM Directives: TTL',
          'Result: Requester Result Port',
          'Result: Number Features Output',
          'Result: Requester Host',
          'Result: Priority',
          'Result: Status Message',
          'Result: Status',
          'Time Queued',
          'Result: Time Requested',
          'Time Submitted',
          'Result: Time Started',
          'Time Delivered',
          'Result: Time Finished',
        ],
        "overview": [
          "Failed Job ID",
          "Repository",
          "No Log Error",
          "Date",
          "Start Time",
          "End Time",
          "Total Jobs Running",
          "Number of KIRK Jobs Running"
        ],
    }
