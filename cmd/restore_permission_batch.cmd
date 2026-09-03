echo off
setlocal enabledelayedexpansion

set Name="restore_permission_batch.cmd"

set Block_Divider_0="*********************************************************************"
set Block_Divider_1="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
set Heading_Line_0="####################"
set Heading_Line_1="===================="
set Heading_Line_2="--------------------"

rem Configue Info Sections
set /A Max_Section_Items=10
set Optional_Info_Sections=Usage,Example,Remark

rem Set info sections
set Purpose0="Batch restore folders and their permissions previously backed up with [save_permission_batch.cmd]."
set Purpose1="- Create the [Restore_Root]."
set Purpose2="- Creates top level sub folders of the [Backup_Root] in the [Restore_Root]."
set Purpose3="- And then batch backs up permission of subsequent sub folders to text files in coresponding sub folders in the [Restore_Root]."
set Purpose4="- Folders specified in [Exclusion_List] variable are excluded."
set Purpose5="- An additional folder can be added to the [Exclusion_List] through the argument [/EX:path] at the runtime."

set Usage0="restore_permission_batch.cmd [/?] [/T] [/BR:Backslash_Replacer] [/EX:Path_to_Exclude] [/S:Sub_Tree_File] [/TE:Text_Extension] Restore_Root Backup_Root"
set Usage1="."
set Usage2="  [/?]                     Optional. Show Help."
set Usage3="  [/T]                     Optional. Test run or dry run without writing."
set Usage4="  [/BR:Backslash_Replacer] Optional. The string to replace backslashes in the destination file."
set Usage5="  [/EX:Path_to_Exclude]    Optional. Additional excluded path."
set Usage6="  [/S:Sub_Tree_File]       Optional. The sub tree to be restored."
set Usage7="  [/TE:Text_Extension]     Optional. The text file extention for the output [Destination_File]. Defaults to 'txt'."
set Usage8="  Restore_Root             The root folder that folders and their permissions will be restored to."
set Usage9="  Backup_Root              The root path to backed up ACL files."
set Usage10="."

set Example0="The following command displays the process of restoring folders and permissions to [D:\], excluding folders specified by [Exclusion_List] and D:\temp specified by [/EX:temp], based on the previous backed up permissions under [C:\temp\D_Permissions] without writing to the [D:\]."
set Example1="."
set Example2="  C:\dvlp>restore_permission_batch D: C:\temp\D_Permissions /EX:temp /t"
set Example3="."

set Remark0="Remarks:"
set Remark1="1. This script calls [restore_permission.cmd]. You must update [Path_restore_permission] variable."
set Remark2="2. Alternatively, you may add the path of [restore_permission.cmd] to the Path environment variable." 
set Remark3="3. Set the Exclusion_List variable to exclude sub folders you want to escape."
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
set Path_restore_permission=C:\Dvlp\Library\source\CMD
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
	
	if /I "!tmp_arg:~0,2!" == "/S" (
		rem echo [tmp_arg]: !tmp_arg!
		set Sub_Tree_File=!tmp_arg:~3!
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
			set Restore_Root=%~1
		)
		if !Effective_Args! == 2 (
			set Backup_Root=%~1
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
if "!Backup_Root:~-1!" equ "\" (
	set Backup_Root=!Backup_Root:~0,-1!
)
if "!Restore_Root:~-1!" equ "\" (
	set Restore_Root=!Restore_Root:~0,-1!
)

echo [Batch source root]:      !Backup_Root!
echo [Batch destination root]: !Restore_Root!
echo [Exclusion List]:         !Exclusion_List!
if defined Backslash_Replacer (
	echo [Backslash Replacer]:     !Backslash_Replacer!
)
if defined Sub_Tree_File (
	echo [Sub Tree File]:          !Sub_Tree_File!
)
echo [Backup File Extension]:  !Text_Extension!
echo %Block_Divider_1:"=%
echo.

echo Create destination root: [!Restore_Root!]
if !Is_Test! == TRUE (
	echo mkdir !Restore_Root!
) else (
	mkdir !Restore_Root!
)
echo.

REM set Time_Started=%date%:%time%
REM echo [!Backup_Root!] Time started: %Time_Started%

if defined Sub_Tree_File (
	set src=!Sub_Tree_File:"=!
	set src=!src:~0,-4!
	set src=!Backup_Root!\!src!*.!Text_Extension!
	echo [src]: !src!
	call :Restore_Branch !Restore_Root! !src!
) else (
	rem *** Batch Processing ***
	for /f "tokens=*" %%a in ('dir /a:d /b !Backup_Root!\') do (
		set src=!Backup_Root!\%%a\*.!Text_Extension!
		echo.
		echo %Heading_Line_0:"=% Processing Folder: [!src!] %Heading_Line_0:"=%
		call :Test_Membership "%%a"
		if !Is_in_List! == TRUE (
			echo [%%a] is excluded.
			echo.
		) else (
			set dst=!Restore_Root!\%%a
			rem stepwise is easier to read and maintain then blockwise.
			call :Restore_Branch !Restore_Root! !src!
		)
		echo off
	)
	echo off
)
echo.
echo %Heading_Line_0:"=%***  Total Time Elapsed  ****%Heading_Line_0:"=%
echo [!Backup_Root!] Time started: %Time_Started%
echo [!Backup_Root!] Time finished: !date!:!time!
echo %Block_Divider_1:"=%

rem the Exit point of the batch CMD.
:The_Exit
endlocal
echo on
exit /B %errorlevel%

:Restore_Backslath
	set sub_folder=!sub_folder:%1=\!
Exit /B 0

:Restore_Branch
	rem Restore_Branch Restore_Root backup_path
	for /f "tokens=*" %%b in ('dir /b %2') do (
		if !Is_Test! == TRUE (
			call "%Path_restore_permission%\restore_permission.cmd" "%~1\%%b" "%~2\%%~b" /te:!Text_Extension! /t
		) else (
			call "%Path_restore_permission%\restore_permission.cmd" "%~1\%%b" "%~2\%%~b" /te:!Text_Extension!
		)
	)
Exit /B 0

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
