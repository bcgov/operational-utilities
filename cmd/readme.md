## CMD - Windows CMD batch scripts
### `cmdTemplate.cmd` A template to process Windows CMD batch commends arguments.
<pre>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Name: cmdTemplate.cmd
Purpose: A template to process Windows CMD batch commends arguments.
         * Please replace head sections with your own notes.

Usage: cmdTemplate.cmd [/?] [/t or /T] arg1 arg2 arg3 ...
       Optional: /? - Help
       Optional: /t or /T - Test run or dry run.

Example: The following command demos a test run with five auguments.

  C:\dvlp>cmdTemplate.cmd arg1 arg2 arg3 arg4 arg5 /t

Remark: - Set the EffArg_Required to the number of mandatory arguments.
        - Set Max_Help_Items to the maximun items in the head sections.

Reference: - A thorough reference to Windows CMD commands can be found at: https://ss64.com/nt/
           - https://ss64.com/ also provides references of Linux, macOS, PowerShell, ASCII, VBScript, Tools, and Passwords.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
</pre>
### `save_permission.cmd` Backup a directory or a file permission to a text file.
<pre>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Name: save_permission.cmd
Purpose: Backup a directory or a file permission to a text file.

Usage: save_permission.cmd [/t or /T] [/?] source_directory_or_file destination_directory destination_file
       Optional: /t or /T - Test run or dry run.
       Optional: /? - Help
       source_directory_or_file: Source file or directory which permissions to be captured.
       destination_directory: The directory where the result will be saved.
       destination_file: The file name to which the result will be saved.

Example: The following command test run save the permission of [C:\dvlp\Library\CMD] to [C:\temp\dvlp-_-Library-_-CMD.txt]:

  C:\dvlp>save_permission.cmd C:\dvlp\Library\CMD C:\temp dvlp\Library\CMD /t

  *  By default, the backslashes in the destination_file is replaced by [-_-].
  ** The default backslash replacer can be changed by replace [-_-] with a new string in [set Backslash_Replacer=-_-].

Remark: Use the relative path of the [source_directory_or_file] as [destination_file] can help with the search later.
Backslashes in the destination_file will be replaced by the string defined by Backslash_Replacer variable.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
</pre>
### `save_permission_batch.cmd` Batch process permissions and stores by top level subdirectory
<pre>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Name: save_permission_batch.cmd
Purpose: Creates top level sub directories of the source_directory in the destination_directory, and batch backs up permission of subsequent sub directories to text files in coresponding sub directories.

Usage: save_permission_batch.cmd [/?] [/t or /T] source_directory destination_directory
       Optional: /? - Help
       Optional: /t or /T - Test run or dry run.
       source_directory - Permissions of all sub directories under this directory will be backed up to a corresponding sub directory under the destination_directory.
       destination_directory - Permissions will be backed up to this directory.

Example: The following command test run save the permission of sub directories of D:\ to C:\temp\D_Permissions.

  C:\dvlp>save_permission_batch D: C:\temp\D_Permissions /t

Remark: This script calls save_permission.cmd. You must update Path_save_permission variable.
Alternatively, you may add the path of save_permission.cmd to the Path environment variable.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
</pre>
### `startService.cmd` Start a Windows service if it is not running.
<pre>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Name: startService.cmd
Purpose: Start a Windows service if it is not running.

Usage: startService.cmd [/?] [/t or T] service_name
       Optional: /? - Help
       Optional: /t or /T - Test run or dry run.

Example: The following command shows the status of AppReadiness.
If the service is not running, it shows the command to start the service:

  C:\dvlp>startService.cmd AppReadiness /t
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
</pre>
