echo off
setlocal enabledelayedexpansion

set Name="save_permission_batch.cmd"

set Block_Divider_0="*********************************************************************"
set Block_Divider_1="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
set Heading_Line_0="####################"
set Heading_Line_1="===================="
set Heading_Line_2="--------------------"

rem Configue Info Sections
set /A Max_Section_Items=9
set Optional_Info_Sections=Usage,Example,Remark

rem Set info sections
set Purpose0="Batch backup permissions grouped by sub folders with exclusion list support."
set Purpose1="- Create the [Backup_Path]."
set Purpose2="- Creates top level sub folders of the [Source_Path] in the [Backup_Path]."
set Purpose3="- And then batch backs up permission of subsequent sub folders to text files in coresponding sub folders in the [Backup_Path]."
set Purpose4="- Folders specified in [Exclusion_List] variable are excluded."
set Purpose5="- An additional folder can be added to the [Exclusion_List] through the argument [/EX:path] at the runtime."

set Usage0="save_permission_batch.cmd [/?] [/T] [/BR:Backslash_Replacer] [/EX:Path_to_Exclude] [/TE:Text_Extension] Source_Path Backup_Path"
set Usage1="."
set Usage2="  [/?]                     Optional. Show Help."
set Usage3="  [/T]                     Optional. Test run or dry run without writing."
set Usage4="  [/BR:Backslash_Replacer] Optional. The string to replace backslashes in the destination file."
set Usage5="  [/EX:Path_to_Exclude]    Optional. Additional excluded path."
set Usage6="  [/TE:Text_Extension]     Optional. The text file extention for the output [Destination_File]. Defaults to 'txt'."
set Usage7="  Source_Path              Permissions of all sub folders to be backed up."
set Usage8="  Backup_Path              Permissions will be backed up to this path."
set Usage9="."

set Example0="The following command displays the process of saving permissions of sub folders of [D:\], excluding folders specified by [Exclusion_List] and [D:\temp] specified by [/EX:temp], to [C:\temp\D_Permissions] without create folder or file."
set Example1="."
set Example2="  C:\dvlp>save_permission_batch D: C:\temp\D_Permissions /EX:temp /t"
set Example3="."

set Remark0="Remarks:"
set Remark1="1. This script calls [save_permission.cmd]. You must update [Path_save_permission] variable."
set Remark2="2. Alternatively, you may add the path of [save_permission.cmd] to the Path environment variable." 
set Remark3="3. Set the [Exclusion_List] variable to exclude sub folders you want to escape."
set Remark4="4. The default exporting text file extension is set through the [Text_Extension] variable, which can be overwritten by [/TE:Text_Extension] argument at runtime.
rem set Remark1="Set the EffArg_Required to the number of mandatory arguments."

rem set Reference0="A thorough reference to Windows CMD commands: https://ss64.com/nt/"

echo %Block_Divider_0:"=%
echo %Name:"=%:
call :MSG_Lines "Purpose"
echo %Block_Divider_0:"=%

set /A Arg_Count=0
set /A Effective_Args=0
set /A EffArg_Required=2
set Is_Test=FALSE
set Is_Help=FALSE
set Path_save_permission=C:\Dvlp\Library\source\CMD
set Exclusion_List="$Recycle.Bin","Recovery","System Volume Information"
set Is_in_List=FALSE
set Text_Extension=txt

echo %Block_Divider_1:"=%
echo [All arguments]:          %*

:arg_loop
if "%~1"=="" goto end_arg_loop
	set /a Arg_Count+=1
	set Is_Effective=TRUE
	set tmp_arg=%~1
	rem echo argument !Arg_Count!: %~1
	rem /I          Do a case Insensitive string comparison.
	if /I "!tmp_arg:~0,3!" == "/BR" (
		set Backslash_Replacer=!tmp_arg:~4!
		set Is_Effective=FALSE
	)
	
	if /I "!tmp_arg:~0,3!" == "/EX" (
		rem echo [tmp_arg]: !tmp_arg!
		set Path_to_Exclude=!tmp_arg:~4!
		set Is_Effective=FALSE
	)
	
	if /I "!tmp_arg:~0,3!" == "/TE" (
		set Text_Extension=!tmp_arg:~4!
		set Is_Effective=FALSE
	)

	if /I "%~1" == "/T" (
		set Is_Test=TRUE
		set Is_Effective=FALSE
	)
	
	if "%~1" == "/?" (
		set Is_Help=TRUE
		set Is_Effective=FALSE
	)
	
	if !Is_Effective! == TRUE (
		set /A Effective_Args+=1
		rem echo Effective Args: !Effective_Args!
		if !Effective_Args! == 1 (
			set Source_Path=%~1
		)
		if !Effective_Args! == 2 (
			set Backup_Path=%~1
		)
		if !Effective_Args! GTR %EffArg_Required% (
			if "!unexpected_args!" GTR "" (
				set delimiter=;
				rem echo delimiter: !delimiter!
			)
			set unexpected_args=!unexpected_args!!delimiter!%~1
			rem echo !unexpected_args!
		)
	)
REM 'shift' will process all the argument.
shift
goto arg_loop
:end_arg_loop

if not !Is_Help!==TRUE (
	if !Effective_Args! lss %EffArg_Required% (
		set Is_Help=TRUE
		call :MSG_EffectiveArgs Error
	)

	if !Effective_Args! gtr %EffArg_Required% (
		call :MSG_EffectiveArgs Warning
		echo The following arguments are ignored: !unexpected_args!
	)
)

if !Is_Help!==TRUE (
	echo %Block_Divider_1:"=%
	call :MSG_Help
	goto The_Exit
	exit /b 0
)

if defined Path_to_Exclude (
	rem echo [Path_to_Exclude]: !Path_to_Exclude!
	set Exclusion_List=%Exclusion_List%,"!Path_to_Exclude!"
)

rem Trim ending "\".
if "!Source_Path:~-1!" equ "\" (
	set Source_Path=!Source_Path:~0,-1!
)
if "!Backup_Path:~-1!" equ "\" (
	set Backup_Path=!Backup_Path:~0,-1!
)

echo [Batch source root]:      !Source_Path!
echo [Batch destination root]: !Backup_Path!
echo [Exclusion List]:         !Exclusion_List!
if defined Backslash_Replacer (
	echo [Backslash Replacer]:     !Backslash_Replacer!
)
echo [Backup File Extension]:  !Text_Extension!
echo %Block_Divider_1:"=%
echo.

echo Create destination root: [!Backup_Path!]
if !Is_Test! == TRUE (
	echo mkdir !Backup_Path!
) else (
	mkdir !Backup_Path!
)
echo.

set source_tree_file=!Source_Path::=_!
set source_tree_file=Tree_!source_tree_file:\=[_]!.!Text_Extension!
echo Store Source Tree to: [!source_tree_file!]
if !Is_Test! == TRUE (
	set tmp_str="tree !Source_Path! > !Backup_Path!\!source_tree_file!"
	echo !tmp_str:"=!
) else (
	tree !Source_Path! > !Backup_Path!\!source_tree_file!
)
echo.

set Time_Started=%date%:%time%
echo [!Source_Path!] Time started: %Time_Started%

rem *** Batch Processing ***
for /f "tokens=*" %%a in ('dir /a:d /b !Source_Path!\') do (
	set src=!Source_Path!\%%a
	echo.
	echo %Heading_Line_0:"=% Processing Folder: [!src!] %Heading_Line_0:"=%
	call :Test_Membership "%%a"
	if !Is_in_List! == TRUE (
		echo [%%a] is excluded.
		echo.
	) else (
		set dst=!Backup_Path!\%%a
		rem stepwise is easier to read and maintain then blockwise.

		set SubTime_Started=!date!:!time!
		echo [!src!] time started: !SubTime_Started!

		echo Create destination:
		if !Is_Test! == TRUE (
			echo mkdir !dst!
		) else (
			mkdir !dst!
		)
		echo.
		echo %Heading_Line_1:"=% Save root level permissions %Heading_Line_1:"=%
		rem Insert "." infront of the file name to bring it up to the top.
		set root_file="%%~a"
		if !Is_Test! == TRUE (
			call "%Path_save_permission%\save_permission.cmd" "!src!" "!dst!" !root_file! /te:!Text_Extension! /t
		) else (
			call "%Path_save_permission%\save_permission.cmd" "!src!" "!dst!" !root_file! /te:!Text_Extension!
		)
		echo.
		echo %Heading_Line_2:"=% Save Sub Folder Permissions %Heading_Line_2:"=%
		echo Root: [!src!]
		set root_file=!root_file:"=!
		if !Is_Test! == TRUE (
			if defined Backslash_Replacer (
				forfiles /p "!src!" /s /c "cmd /C if @isdir == TRUE (call "%Path_save_permission%\save_permission.cmd" "@path" "!dst!" "!root_file!\@relpath" /br:!Backslash_Replacer! /te:!Text_Extension! /t) else (echo Escape file: @path)"
			) else (
				forfiles /p "!src!" /s /c "cmd /C if @isdir == TRUE (call "%Path_save_permission%\save_permission.cmd" "@path" "!dst!" "!root_file!\@relpath" /te:!Text_Extension! /t) else (echo Escape file: @path)"
			)
		) else (
			if defined Backslash_Replacer (
				forfiles /p "!src!" /s /c "cmd /C if @isdir == TRUE (call "%Path_save_permission%\save_permission.cmd" "@path" "!dst!" "!root_file!\@relpath" /br:!Backslash_Replacer! /te:!Text_Extension!) else (echo Escape file: @path)"
			) else (
				forfiles /p "!src!" /s /c "cmd /C if @isdir == TRUE (call "%Path_save_permission%\save_permission.cmd" "@path" "!dst!" "!root_file!\@relpath" /te:!Text_Extension!) else (echo Escape file: @path)"
			)
		)
		echo.
		echo [!src!] time started: !SubTime_Started!
		echo [!src!] time finished: !date!:!time!
	)
	echo off
)
echo off

echo.
echo %Heading_Line_0:"=%***  Total Time Elapsed  ****%Heading_Line_0:"=%
echo [!Source_Path!] Time started: %Time_Started%
echo [!Source_Path!] Time finished: !date!:!time!
echo %Block_Divider_1:"=%

rem the Exit point of the batch CMD.
:The_Exit
endlocal
echo on
exit /B %errorlevel%

:Test_Membership
	set Is_in_List=FALSE

	for %%b in (!Exclusion_List!) do (
		rem echo [exclude dir]: %%~b
		rem echo [passed in dir]: %~1
		if /I "%%~b" equ "%~1" (
			set Is_in_List=TRUE
			Exit /B 0
		)
		rem echo %%~b and %~1 are !Is_in_List!
	)
Exit /B 0

:MSG_EffectiveArgs
	echo.
	echo %~1:
	echo Effective Arguments expected: %EffArg_Required%
	echo Actual Effective Arguments received: !Effective_Args!
Exit /B 0

:MSG_Help
	echo.
	REM echo %Block_Divider_1:"=%
	REM echo Name: %Name:"=% 
	for %%a in (%Optional_Info_Sections%) do (
		call :MSG_Lines "%%~a"
	)
	REM echo %Block_Divider_1:"=%
Exit /B 0

:MSG_Lines
	for /L %%i in (0,1,%Max_Section_Items%) do (
		if defined %~1%%i (
			set msg=!%~1%%i!
			if !msg! equ "." (
				echo.
			) else (
				set msg=!msg:"=!
				set msg=!msg:'="!
				echo !msg!
			)
		)
	)
Exit /B 0
