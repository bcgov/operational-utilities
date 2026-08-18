## CMD - Windows CMD batch scripts
- [cmd_template.cmd](#cmd_template)
- [save_permission.cmd](#save_permission)
- [save_permission_batch.cmd](#save_permission_batch)
- [start_service.cmd](#start_service)
- [temp_clean_up](#temp_clean_up)
### `cmd_template.cmd` A template to process Windows CMD batch commends arguments.<a id='cmd_template'></a>
<pre>
*********************************************************************
cmd_template.cmd:
A template to process Windows CMD batch command arguments, which covers:
- Mandatory arguments.
- Optional arguments with default value.
- Static variables, use %variable_name% reference.
- Mutable variables, must enabledelayedexpansion, and use !variable_name! reference.
- Loops.
- Sub routine/function.
- Standard script heading, and help sections.
*********************************************************************

cmd_template.cmd [/?] [/t | /T] [[/p | /P]:Path] arg1 arg2 arg3 ...

  [/?]             Optional. Display the Help info, defaults to [Is_Help].
  [/t | /T]        Optional. Test run or dry run, defaults to [Is_Test].
  [[/p | /P]:Path] Optional. Path to a directory. e.g. /P:C:\dvlp\temp. Defaults to [Path_to_Check].
  arg1             The first argument.
  arg2             The second argument.
  arg3             The third argument.

Example 1: The following command demos a [Test] run with 5 arguments, and to show the command of listing the content of the default folder set by [Path_to_Check].

    C:\dvlp>cmd_template.cmd arg1 arg2 arg3 arg4 arg5 /t

Example 2: The following command demos an [Active] run with 3 arguments, and to list the content of [C:\Program Files] specified by the [/P] optional argument.

    C:\dvlp>cmd_template.cmd arg1 arg2 arg3 "/P:C:\Program Files"

Remarks:
1. Set [EffArg_Required] to the number of mandatory arguments.
2. Set [Max_Help_Items] to the maximun items in the head sections.
3. Set [Head_Sections] to include only sections you are using.
4. Please replace head sections with your own notes.

References:
- A thorough reference to Windows CMD commands can be found at: https://ss64.com/nt/
- https://ss64.com/ also provides references of Linux, macOS, PowerShell, ASCII, VBScript, Tools, and Passwords.
</pre>
### `save_permission.cmd` Backup a directory or a file permission to a text file.<a id='save_permission'></a>
<pre>
*********************************************************************
save_permission.cmd:
Backup permissions of a directory or a file to a text file.
*********************************************************************

save_permission.cmd [/t | /T] [/?] "source_directory_or_file" "destination_directory" "destination_file"

  [/?]                     Optional. Show Help.
  [/T]                     Optional. Test run or dry run without writing.
  source_directory_or_file Source file or directory with which permissions to be captured.
  destination_directory    The directory where the result will be saved.
  destination_file         The file name to which the result will be saved.

The following command shows the process of saving the permission of [C:\dvlp\CMD] to [C:\temp\dvlp-_-CMD.txt] without create any file:

  C:\dvlp>save_permission.cmd C:\dvlp\CMD C:\temp dvlp\CMD /t

Remarks:
1. By default, the backslashes in the destination_file is replaced by [-_-].
2. The default backslash replacer can be changed by replace [-_-] with a new string in [set Backslash_Replacer=-_-].
3. Use the relative path of the [source_directory_or_file] as [destination_file] can help with the search later.
4. Backslashes in the destination_file will be replaced by the string defined by Backslash_Replacer variable.
</pre>
### `save_permission_batch.cmd` Batch process permissions and stores by top level sub-directory (with exclusion list support). <a id='save_permission_batch'></a>
<pre>
*********************************************************************
save_permission_batch.cmd:
Batch backup permissions grouped by sub directories with exclusion list support.
- Creates top level sub directories of the [source_directory] in the [destination_directory].
- And then batch backs up permission of subsequent sub directories to text files in coresponding sub directories in the [destination_directory].
*********************************************************************

save_permission_batch.cmd [/?] [/T] source_directory destination_directory

  [/?]                   Optional. Show Help.
  [/T]                   Optional. Test run or dry run without writing.
  source_directory       Permissions of all sub directories to be backed up.
  destination_directory  Permissions will be backed up to this directory.

The following command displays the process of saving permissions of sub directories of D:\ to C:\temp\D_Permissions without create folder or file.

  C:\dvlp>save_permission_batch D: C:\temp\D_Permissions /t

Remarks:
1. This script calls save_permission.cmd. You must update Path_save_permission variable.
2. Alternatively, you may add the path of save_permission.cmd to the Path environment variable.
3. Set the Exclusion_List variable to exclude sub directories you want to escape.
</pre>
### `start_service.cmd` Start a Windows service if it is not running.<a id='start_service'></a>
<pre>
*********************************************************************
start_service.cmd:
Start a Windows service if it is not running.
*********************************************************************

start_service.cmd [/?] [/T] service_name

  [/?]          Optional. Display the Help info, defaults to FALSE.
  [/T]          Optional. Test run or dry run, defaults to FALSE.
  service_name  The name of a Windows service.

The following command shows the status of AppReadiness.
If the service is not running, it shows the command to start the service:

  C:\dvlp>start_service.cmd AppReadiness /t
</pre>
### `temp_clean_up.cmd` Remove files in [Path_to_Check] folder(s) and their sub folders that are older than [Cut_off_Days] days.<a id='temp_clean_up'></a>
<pre>
*********************************************************************
temp_clean_up.cmd:
Remove files in [Path_to_Check] folder(s) and their sub folders that are older than [Cut_off_Days] days.
*********************************************************************

temp_clean_up.cmd [/?] [/T] [/D:Days] [/P:Path]

  [/?]       Optional, defaults to FALSE. Display the Help info.
  [/D:Days]  Optional, defaults to [Cut_off_Days]. Cut off days. e.g. /D:30.
  [/P:Path]  Optional, defaults to [Path_to_Check]. Folder to be scanned and cleaned up. e.g. /P:C:\temp.
  [/t | /T]  Optional, defaults to FALSE. Lists files meeting the criteria without deleting them.

The following command scans [C:\Program Files] and display the files that are older than 30 days.

  C:\dvlp>temp_clean_up.cmd /D:30 "/P:C:\Program Files" /t

* It goes through sub folders recursively.
</pre>
