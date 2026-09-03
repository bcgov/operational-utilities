## CMD - Windows CMD batch scripts<a id='top'></a>
- [cmd_template.cmd](#cmd_template)
- [restore_permission.cmd](#restore_permission)
- [restore_permission_batch.cmd](#restore_permission_batch)
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
[back to top](#top)

### `restore_permission.cmd` Create a folder and restore ACL permissions previously backed up with [save_permission.cmd](#save_permission).<a id='restore_permission'></a>
<pre>
*********************************************************************
restore_permission.cmd:
Create a folder and restore ACL permissions from a previously backed up with [save_permission.cmd].
*********************************************************************

restore_permission.cmd [/?] [/T] [/BR:Backslash_Replacer] [/TE:Text_Extension] "Restore_Folder" "ACL_File"

  [/?]                     Optional. Show Help.
  [/T]                     Optional. Test run or dry run without writing.
  [/BR:Backslash_Replacer] Optional. The backslash replacer used during the back up. Defaults to [_].
  [/TE:Text_Extension]     Optional. The text file extention for the output [Destination_File]. Defaults to "txt".
  Restore_Folder       The path to be created and the permission to be restored to the new folder.
  ACL_File                 Acl file which contains the previously captured Acl permissions.

The following command shows the process of restore the permission of [C:\dvlp\CMD] from [C:\temp\dvlp[_]CMD.txt] without create the folder and restore the permission:

  C:\dvlp>restore_permission.cmd C:\dvlp[_]CMD C:\temp\dvlp[_]CMD.txt /t

Remarks:
1. Please use the backslash replacer used during the back up. By default, it is [[_]].
2. The default backslash replacer is set through the [Backslash_Replacer] variable.
3. All [Backslash_Replacer] strings in the [Restore_Folder] will be restored to backslash.
4. The default exporting text file extension is set through the [Text_Extension] variable, which can be overwritten by [/TE:Text_Extension] argument at runtime.
</pre>
[back to top](#top)

### `restore_permission_batch.cmd` Batch restore folders and their permissions previously backed up with [save_permission_batch.cmd](#save_permission_batch).<a id='restore_permission_batch'></a>
<pre>
*********************************************************************
restore_permission_batch.cmd:
Batch restore folders and their permissions previously backed up with [save_permission_batch.cmd].
- Create the [Restore_Root].
- Creates top level sub folders of the [Backup_Root] in the [Restore_Root].
- And then batch backs up permission of subsequent sub folders to text files in coresponding sub folders in the [Restore_Root].
- Folders specified in [Exclusion_List] variable are excluded.
- An additional folder can be added to the [Exclusion_List] through the argument [/EX:path] at the runtime.
*********************************************************************

restore_permission_batch.cmd [/?] [/T] [/BR:Backslash_Replacer] [/EX:Path_to_Exclude] [/S:Sub_Tree_File] [/TE:Text_Extension] Restore_Root Backup_Root

  [/?]                     Optional. Show Help.
  [/T]                     Optional. Test run or dry run without writing.
  [/BR:Backslash_Replacer] Optional. The string to replace backslashes in the destination file.
  [/EX:Path_to_Exclude]    Optional. Additional excluded path.
  [/S:Sub_Tree_File]       Optional. The sub tree to be restored.
  [/TE:Text_Extension]     Optional. The text file extention for the output [Destination_File]. Defaults to "txt".
  Restore_Root             The root folder that folders and their permissions will be restored to.
  Backup_Root              The root path to backed up ACL files.

The following command displays the process of restoring folders and permissions to [D:\], excluding folders specified by [Exclusion_List] and D:\temp specified by [/EX:temp], based on the previous backed up permissions under [C:\temp\D_Permissions] without writing to the [D:\].

  C:\dvlp>restore_permission_batch D: C:\temp\D_Permissions /EX:temp /t

Remarks:
1. This script calls [restore_permission.cmd]. You must update [Path_restore_permission] variable.
2. Alternatively, you may add the path of [restore_permission.cmd] to the Path environment variable.
3. Set the Exclusion_List variable to exclude sub folders you want to escape.
4. The default exporting text file extension is set through the [Text_Extension] variable, which can be overwritten by [/TE:Text_Extension] argument at runtime.
</pre>
[back to top](#top)

### `save_permission.cmd` Backup a directory or a file permission to a text file.<a id='save_permission'></a>
<pre>
*********************************************************************
save_permission.cmd:
Backup permissions of a folder or a file to a text file.
*********************************************************************

save_permission.cmd [/?] [/T] [/BR:Backslash_Replacer] [/TE:Text_Extension] "Source_Folder_or_File" "Destination_Folder" "Destination_File"

  [/?]                     Optional. Show Help.
  [/T]                     Optional. Test run or dry run without writing.
  [/BR:Backslash_Replacer] Optional. The string to replace backslashes in the [Destination_File]. Defaults to "[_]".
  [/TE:Text_Extension]     Optional. The text file extention for the output [Destination_File]. Defaults to "txt".
  Source_Folder_or_File    Source file or folder with which permissions to be captured.
  Destination_Folder       The folder where the result will be saved.
  Destination_File         The file name to which the result will be saved.

The following command shows the process of saving the permission of "C:\dvlp\CMD" to "C:\temp\dvlp[_]CMD.txt" without create any file:

  C:\dvlp>save_permission.cmd C:\dvlp\CMD C:\temp dvlp\CMD /t

Remarks:
1. Backslashes in the [Destination_File] will be replaced by the string defined by [Backslash_Replacer] variable, defaults to "[_]". E.g. "dvlp\CMD" will become "dvlp[_]CMD".
2. The default backslash replacer is set through the [Backslash_Replacer] variable, which can be overwritten by [/BR:Backslash_Replacer] argument at runtime.
3. The default exporting text file extension is set through the [Text_Extension] variable, which can be overwritten by [/TE:Text_Extension] argument at runtime.
4. Use the relative path of the [Source_Folder_or_File] as [Destination_File] can help with the search later.
</pre>
[back to top](#top)

### `save_permission_batch.cmd` Batch process permissions and stores by top level sub-directory (with exclusion list support). <a id='save_permission_batch'></a>
<pre>
*********************************************************************
save_permission_batch.cmd:
Batch backup permissions grouped by sub folders with exclusion list support.
- Create the [backup_path].
- Creates top level sub folders of the [source_path] in the [backup_path].
- And then batch backs up permission of subsequent sub folders to text files in coresponding sub folders in the [backup_path].
- Folders specified in [Exclusion_List] variable are excluded.
- An additional folder can be added to the [Exclusion_List] through the argument [/EX:path] at the runtime.
*********************************************************************

save_permission_batch.cmd [/?] [/T] [/BR:Backslash_Replacer] [/EX:Path_to_Exclude] [/TE:Text_Extension] source_path backup_path

  [/?]                     Optional. Show Help.
  [/T]                     Optional. Test run or dry run without writing.
  [/BR:Backslash_Replacer] Optional. The string to replace backslashes in the destination file.
  [/EX:Path_to_Exclude]    Optional. Additional excluded path.
  [/TE:Text_Extension]     Optional. The text file extention for the output [Destination_File]. Defaults to "txt".
  source_path              Permissions of all sub folders to be backed up.
  backup_path         Permissions will be backed up to this path.

The following command displays the process of saving permissions of sub folders of [D:\], excluding folders specified by [Exclusion_List] and [D:\temp] specified by [/EX:temp], to [C:\temp\D_Permissions] without create folder or file.

  C:\dvlp>save_permission_batch D: C:\temp\D_Permissions /EX:temp /t

Remarks:
1. This script calls [save_permission.cmd]. You must update [Path_save_permission] variable.
2. Alternatively, you may add the path of [save_permission.cmd] to the Path environment variable.
3. Set the [Exclusion_List] variable to exclude sub folders you want to escape.
4. The default exporting text file extension is set through the [Text_Extension] variable, which can be overwritten by [/TE:Text_Extension] argument at runtime.

</pre>
[back to top](#top)

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
[back to top](#top)

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
[back to top](#top)
