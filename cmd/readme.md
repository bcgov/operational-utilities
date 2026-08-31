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
- Optional arguments with default values.
- Static variables, use %variable_name% to reference.
- Mutable variables, must enabledelayedexpansion, and use !variable_name! to reference.
- List: Define a list, add an item to the list at run time.
- Loops: Loop through arguments, a list, a range of numbers.
- Sub routine/function: Define and call with arguments.
- Standard script heading and info sections.

The template lists the content specified by the [Path_List] variable and the optional argument [/ADD:Path].
*********************************************************************
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[All arguments]: /?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cmd_template.cmd [/?] [/t | /T] [[/add | /ADD]:Path] arg1 arg2 arg3 ...

  [/?]             Optional. Display the Help info, defaults to [Is_Help].
  [/t | /T]        Optional. Test run or dry run, defaults to [Is_Test].
  [[/add | /ADD]:Path] Optional. Path to a directory. e.g. /ADD:C:\dvlp\temp. Will be added to the [Path_List] if specified.
  arg1             The first argument.
  arg2             The second argument.
  arg3             The third argument.

Example 1: The following command demos a [Test] run with 5 arguments, and to show the command of listing the content of the default folder(s) set by [Path_List].

    C:\dvlp>cmd_template.cmd arg1 arg2 arg3 arg4 arg5 /t

Example 2: The following command demos an [Active] run with 3 arguments, and to list the content of the default folder(s) set by [Path_List] plus the content specified by the [/ADD] optional argument.

    C:\dvlp>cmd_template.cmd arg1 arg2 arg3 "/ADD:C:\Program Files"

Remarks:
1. Set [EffArg_Required] to the number of mandatory arguments.
2. Set [Max_Section_Items] to the maximun items of the Info sections.
3. Set [Optional_Info_Sections] to include only sections you are using.
4. Please replace Info sections with your own notes.

References:
- A thorough reference to Windows CMD commands can be found at: https://ss64.com/nt/
- https://ss64.com/ also provides references of Linux, macOS, PowerShell, ASCII, VBScript, Tools, and Passwords.
- https://stackoverflow.com/questions/48623165/null-variable-in-a-bat-window-batch-file
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
Batch backup permissions grouped by sub folders with exclusion list support.
- Create the [destination_path].
- Creates top level sub folders of the [source_path] in the [destination_path].
- And then batch backs up permission of subsequent sub folders to text files in coresponding sub folders in the [destination_path].
- Folders specified in [Exclusion_List] variable are excluded.
- An additional folder can be added to the [Exclusion_List] through the argument [/EX:path] at the runtime.
*********************************************************************
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[All arguments]: /?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

save_permission_batch.cmd [/?] [/T] [/EX:path] source_path destination_path

  [/?]              Optional. Show Help.
  [/T]              Optional. Test run or dry run without writing.
  [/EX:path]        Optional. Additional excluded path.
  source_path       Permissions of all sub folders to be backed up.
  destination_path  Permissions will be backed up to this path.

The following command displays the process of saving permissions of sub folders of D:\, excluding folders specified by [Exclusion_List] and D:\temp specified by [/EX:temp], to C:\temp\D_Permissions without create folder or file.

  C:\dvlp>save_permission_batch D: C:\temp\D_Permissions /EX:temp /t

Remarks:
1. This script calls save_permission.cmd. You must update Path_save_permission variable.
2. Alternatively, you may add the path of save_permission.cmd to the Path environment variable.
3. Set the Exclusion_List variable to exclude sub folders you want to escape.
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
