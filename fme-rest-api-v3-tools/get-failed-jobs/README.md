# Get Failed Jobs

## Overview

This collection of scripts is used to query [FME Flow REST API V3](http://asellus.dmz/fmerest/apidoc/v3/#) for failed jobs then will loop through all jobs creating an Excel workbook with related job information.

> [!NOTE]
> To use the FME Flow REST API V3 you will need to be connected to VPN (or VPN2) and have an account with access to use the API.
> See the section [Requirements](#Requirements) below for more information on connecting and using FME Flow REST API V3.

## Requirements

- Python 3 and included libraries
- Python additional library `xlsxwriter`
- FME Flow REST API Token
  - This can be generated from any page within [FME Flow REST API V3](http://asellus.dmz/fmerest/apidoc/v3/#)
  - Access is restricted to VPN (or VPN2)
  - To generate the token use the `Get Token` button to the top left of the screen
    - This will require a valid Asellus FME Flow Account with permissions to API use
  - The token only lasts an hour and will need to be refreshed after that time

## Directory

A brief description of the files included in this directory. To see detailed information refer to each files documentation and the [Process](#Process) section below.

| Item              | Description                                                       |
| ------------------| ----------------------------------------------------------------- |
| `control.py`      | Handles configuration and flow of curating output.                |
| `fme_flow_api.py` | Handles all calls to FME Flow REST API V3.                        |
| `jobs.py`         | Handles creation of jobs in the format specified.                 |
| `settings.py`     | Constants and global variables defined here.                      |
| `utils.py`        | Common functions that may be used accross many different scripts. |
| `README.md`       | This document                                                     |

## Process

> [!NOTE]
> This section will go into the process of the scripts. If the scripts are updated it may be out of date.

1. User starts script
2. `control.py`s main() function hit
   1. `settings.py` init() function called
      1. Global variables set
   2. logger is initilized and configured
   3. (info level log) "Requesting failed jobs..."
   4. `fme_flow_api.py`s get_failed() function is called. Results set as `fail_jobs`
      1. Get first batch of failed jobs
      2. While there are more jobs to process:
         1. If this is the first batch of failed jobs set failed jobs to the dict of failed jobs
         2. If this is not the first batch of failed jobs add all new jobs to failed jobs dict
         3. Add the number of jobs requested to the offset
         4. Get the next batch of jobs
      3. Return the failed job dict
  5. (info level log) "Failed jobs loaded."
  6. Check the number of failed jobs in `fail_jobs` dict against total count of failed jobs
     1. If the difference is more than 0 (warn level log) "Missing X failed jobs"
  7. (info level log) "Configuring Output..."
  8. build_output_dir(fail_jobs) is called. Return value set to `output`
     1. For each failed job within fail_jobs:
        1. Check if the start time and job id for the current failed job is already in the out dict. If it is:
           1. Add to duplicated list
           2. go to the next failed job
        2. Compare the current failed jobs status message with the global status message (from `settings.py`). If they are the same flag that this is a no logs error
        3. `jobs.py` build_job function called for current job. Returned value set to `job`
           1. Create a dict with information passed in, see [Jobs](#Jobs) for more information on this process.
        4. Add new object with key of failed job start time to the out dict
        5. go to next failed job.
     2. Check if duplicated list is empty. If it isnt:
        1. (warn level log) "Duplicated failed jobs found:" with information on each duplicated job.
     3. Return failed jobs out dict
  9. (info level log) "Output Setup"
  10. (info level log) "Getting Related Jobs..."
  11. `fme_flow_api`s get_related_jobs() is called passing in `output`. Returned value is set to `related_jobs`
      1. Request completed jobs from FME Flow REST API
      2. While there are more jobs to parse:
         1. Print the percentage complete
         2. Get start and end times for current job
         3. Loop through failed jobs in `out`
            1. Get failed jobs start and end time
            2. Check if the current job and the failed job are the same, if they are jump to the next job
            3. If the current jobs start time is before the failed jobs end time and one of the following is true (the current jobs end time is after the failed jobs start time  or the current jobs start time and the failed jobs start time are the same)
               1. Build the current job using `jobs.py` build_job() function (see step 8.3 for basic steps)
               2. Add 1 to the `NUM_JOBS` of the failed jobs
               3. Add the engine of the current job to the failed jobs `ENGINES`
               4. Add the current job to the list of related jobs in `RELATED_JOBS`
           4. Else if the engine name of the current job is the same as the failed job
              1. Build a job for the current job using `jobs.py` build_job() function (see step 8.3 for basic steps)
              2. If the failed jobs start time is after the current jobs end time and one of the following is true (the `PREVIOUS_JOB` has not been set or the `PREVIOUS_JOB`s time started is before the current jobs start time)
                 1. Set the failed jobs `PREVIOUS_JOB` to the current job
         4. Add the limit to the offset
         5. Get another batch of jobs
      3. Print the final progress bar
      4. Return the `out` directory
  12. (info level log) "Related Jobs Loaded."
  13. Call clean_output(related_jobs). Save result as `cleaned`
      1. Loop through all related jobs information in result
         1. If the current failed job has nothing in `RELATED_JOBS` and nothing is set for `PREVIOUS_JOB`
            1. remove from the related job dir and add to no_related_jobs list
      2. Add no_related_job list as a value for root level key `FAILED_NO_CONCURRENT` in the related jobs dict
      3. Return the cleaned related jobs dict
  14. (info level log) "Writing to Excel..."
  15. Call write_to_excel() passing in `cleaned`
      1. Create a workbook called "FailedJobs.xlsx"
      2. Add a sheet called "Failed Overview"
      3. Add overview headers to "Failed Overview"
      4. Add a sheet called "Details"
      5. Add detail headers to "Details"
      6. For every element in `cleaned`
         1. Print progress bar
         2. If the key is `FAILED_NO_CONCURRENT` and there are elements within the value
            1. Add a new sheet called "Failed Jobs no Related Jobs"
            2. Add detail headers to "Failed Jobs no Related Jobs"
            3. Write each job within `FAILED_NO_CONCURRENT` to "Failed Jobs no Related Jobs" using function detail_write():
               1. Loop through detailed headers list
                  1. If the header is "Failed/Previous/Related"
                     1. Write parameter `job_type`
                     2. Go to next header
                  2. If the header is "Failed Job ID"
                     1. Write parameter `failed_job_id`
                     2. Go to next header
                  3. Get the header field value from `to_write` save as variable `data`
                  4. If the field is a datetime type
                     1. Convert the datetime object to `date` and `time` strings
                     2. If the header is "Time Started"
                        1. Write the `date` to the sheet
                     3. Set the `time` to variable `data`
                  5. Write `data` to the matching header cell
            4. Go to next element
         3. If the key is a list
            1. Go to the next element
         4. Get the failed job
         5. Write failed job information to the "Failed Overview" sheet
            1. Failed job ID
            2. Repository
            3. No log error flag
            4. Start datetime date
            5. Start datetime time
            6. End datetime time
            7. Number of jobs running concurrently
         6. Write the failed job to "Details" using function detail_write()
         7. Write the previous job to "Details" using function detail_write()
         8. For every job within `RELATED_JOBS`:
            1. Write the current job to "Deatils" using function detail_write()
      7. Close the workbook
      8. Print the final progress percentage
  16. (info level log) "Complete."

# Job Data from request

Requests are returned with the following structure:

{
  'request': {
    'publishedParameters': [{ "name": str, "raw": str }, ... ],
    'workspacePath': str,
    'TMDirectives': { "rtc": bool, "ttc": int, "description": str, "tag": str, "priority": int, "ttl": int }
    },
    'NMDirectives': { "directives": list, "successTopics": list, "failureTopics": list(str) },
    "timeDelivered": datetime,
    "workspace": str,
    "numErrors": int,
    "numLines": int,
    "engineHost": str,
    "timeQueued": datetime,
    "cpuPct": float,
    "description": str,
    "timeStarted": datetime,
    "repository": str,
    "userName": str,
    "result": {
      "timeRequested": datetime, "requesterResultPort": int, "numFeaturesOutput": int, "requesterHost": str, "timeStarted": datetime, "id": int, "timeFinished": datetime, "priority": int, "statusMessage": str, "status": str
    },
    "cpuTime": int,
    "sourceType": str,
    "id": int,
    "sourceName": str,
    "timeFinished": datetime,
    "engineName": str,
    "numWarnings": int,
    "timeSubmitted": datetime,
    "elapsedTime": int,
    "peakMemUsage": int,
    "status": str
}

## Jobs

Reviewing the information provided in the documentation within [FME Flow REST API V3](http://asellus.dmz/fmerest/apidoc/v3/#) the results are provided in a JSON structure:

```
{
  "items": [{}, ..., {}],
  "limit": int,
  "offset": int,
  "totalCount": int
}
```

Because there are over 19 thousand completed jobs to parse at any given time the script uses a default 1000 limit to the request and uses the offset amount to query for additional jobs.

### Items

The list of objects within "items" from the API returns the following structure:

```
{
  "id": int,
  "cpuPct": int,
  "cpuTime": int,
  "description": string,
  "elapsedTime": int,
  "engineHost": string,
  "engineName": string,
  "numErrors": int,
  "numLines": int,
  "numWarnings": int,
  "peakMemUsage": int,
  "repository": string,
  "request": {
    "NMDirectives": {
      "directives": [ {}, ..., {} ],
      "failureTopics": [ string, ...],
      "successTopics": [ string, ...]
    },
    "TMDirectives": {
      "rtc": true,
      "ttc": int,
      "ttl": int,
      "description": string,
      "priority": int,
      "tag": "string"
    },
    "publishedParameters": [ {}, ..., {} ],
    "workspacePath": "string"
  },
  "result": {
    "id": int,
    "numFeaturesOutput": int,
    "priority": int,
    "requesterHost": string,
    "requesterResultPort": int,
    "resultDatasetDownloadUrl": string,
    "status": string,
    "statusMessage": string,
    "timeFinished": string,
    "timeRequested": string,
    "timeStarted": "string"
  },
  "sourceID": string,
  "sourceName": string,
  "sourceType": string,
  "status": string,
  "timeDelivered": string,
  "timeFinished": string,
  "timeQueued": string,
  "timeStarted": string,
  "timeSubmitted": string,
  "userName": string,
  "workspace": "string"
}
```

Some of these fields we expect to have no value, or values that are not useful to our search. See the structure below for information on what is kept or not for each job.

```
'request': {
    'publishedParameters': {
        'FME_AUTOMATION_NAME': str, # always keep
    },
    'workspacePath': str, # always keep
    'TMDirectives': {
        "rtc": bool, # include if not false
        "ttc": int, # include if not -1
        "description": str, # include if not ""
        "tag": str, # include if not "Default"
        "priority": int, # include if not -1
        "ttl": int # include if not -1
    },
    'NMDirectives': {
        "directives": list, # include if not []
        "successTopics": list, # include if not []
    },
    "timeDelivered": datetime, # include if it is different that time finished
    "workspace": str, # always keep
    "numErrors": int, # always keep
    "numLines": int, # always keep
    "engineHost": str, # include if not "localhost"
    "timeQueued": datetime, # include if it is different than time started
    "cpuPct": float, # always keep
    "description": str, # include if not ""
    "timeStarted": datetime, # keep, should be the same as time queued, time requested, and inner time started
    "repository": str, # always keep
    "result": {
      "timeRequested": datetime, # include if it is different than time started
      "requesterResultPort": int, # include if not -1
      "numFeaturesOutput": int, # always keep
      "requesterHost": str, # include if not "142.34.140.19"
      "timeStarted": datetime, # include if it is different than time started
      "id": int, # include if not same as outer ID
      "timeFinished": datetime, # include if it is different that time finished (outer)
      "priority": int, # include if not -1
      "statusMessage": str, # always keep
    },
    "cpuTime": int, # always keep
    "sourceType": str, # always keep
    "id": int, # always keep
    "sourceName": str, # always keep
    "timeFinished": datetime, # include. Checks to see if timeSubmitted, request.timeFinished, timeDelivered are the same
    "engineName": str, # always keep
    "numWarnings": int, # always keep
    "timeSubmitted": datetime, # include if it is different that time finished
    "elapsedTime": int, # always keep
    "peakMemUsage": int, # always keep
    "status": str # always keep
  }
```

## Output

The worksheet that is created will always at minimum have two sheets `Overview` and `Failed Overview`. If there are any failed jobs that have no related or previous jobs included in their object a third sheet `Failed Jobs no Related Jobs` will be created.

### Headers

#### `Failed Overview` and `Failed Jobs no Related Jobs` Sheets

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
'Result: Time Finished'

#### `Overview` Sheet

"Failed Job ID",
"Repository",
"No Log Error",
"Date",
"Start Time",
"End Time",
"Number of Jobs Running",
"Number of KIRK Jobs Running"
