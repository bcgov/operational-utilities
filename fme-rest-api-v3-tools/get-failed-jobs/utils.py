"""
Holds functions that may be common to several scripts in the future, but current only serve
as assists to the control.py script.

Imports:
  datetime - datetime, timedelta: used for date and time comparisons
  settings: custom Python file used to store constants
"""
from datetime import datetime, timedelta
import settings

START_TIME = datetime.now()
TOKEN = ''

def check_token():
    """
    Check if the token is not set or if it is more than an hour old.
    If either is true request a new token to be passed in via command line.

    Returns:
      token (str): user entered token stored as global variable
    """
    global TOKEN, START_TIME

    if TOKEN == '' or datetime.now() > START_TIME + timedelta(minutes=55):
        TOKEN = input("Please provide a valid FME token: ")
        START_TIME = datetime.now()

    return TOKEN

def print_percentage(num, total):
    """
    Print a percentage progress indicator to the console.
    This function will only work if the loop it is called in has no other print statements.

    Parameters:
      num (int): The current count.
      total (int): The total count to reach.

    Returns:
      int: The terminal width used for the progress bar.
    """
    percentage = (num / total) * 100
    term_complete = round((num / total) * settings.terminal_width)
    term_uncomplete = settings.terminal_width - term_complete
    percentage_str = f"{percentage:.2f}%"
    term_str = f"[{'#' * term_complete}{'.' * term_uncomplete}]"
    print(f"{term_str} {percentage_str}", end='\r', flush=True)

def str_to_datetime(string_time):
    """
    Convert a FME date string to a datetime object.
    Ex. string_time = "2025-01-02T03:04:05-" will return a date time object (date_time) with the
    following values set:
      Year: 2025, Month: January, Day: 2, Hour: 3, Minute: 4, Seconds: 5

    Parameters:
      string_time (str): The date string in the format 'YYYY-MM-DDTHH:MM:SS-'.

    Returns:
      date_time (datetime): datetime object representation of string_time
    """
    format_str = '%Y-%m-%dT%H:%M:%S%z'
    date_time = datetime.strptime(string_time, format_str)
    return date_time
