echo off
setlocal enabledelayedexpansion

set Name="restore_permission.cmd"

set Block_Divider_0="*********************************************************************"
set Block_Divider_1="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

rem Configue Info Sections
set /A Max_Section_Items=8
set Optional_Info_Sections=Usage,Example,Remark

rem Clear info sections inherited from the caller.
call :Unset_Info_Sections Purpose
for %%s in (Optional_Info_Sections) do (
	call :Unset_Info_Sections %%~s
)

rem Set info sections
set Purpose0="Create a folder and restore ACL permissions from a previously backed up with [save_permission.cmd]."

set Usage0="restore_permission.cmd [/?] [/T] [/BR:Backslash_Replacer] [/TE:Text_Extension] 'Restore_Folder' 'ACL_File'"
set Usage1="."
set Usage2="  [/?]                     Optional. Show Help."
set Usage3="  [/T]                     Optional. Test run or dry run without writing." 
set Usage4="  [/BR:Backslash_Replacer] Optional. The backslash replacer used during the back up. Defaults to [_]."
set Usage5="  [/TE:Text_Extension]     Optional. The text file extention for the output [Destination_File]. Defaults to 'txt'."
set Usage6="  Restore_Folder           The path to be created and the permission to be restored to the new folder."
set Usage7="  ACL_File                 ACL file which contains the previously captured ACL permissions."
set Usage8="."

set Example0="The following command shows the process of restore the permission of [C:\dvlp\CMD] from [C:\temp\dvlp[_]CMD.txt] without create the folder and restore the permission:"
set Example1="."
set Example2="  C:\dvlp>restore_permission.cmd C:\dvlp[_]CMD C:\temp\dvlp[_]CMD.txt /t"
set Example3="."

set Remark0="Remarks:"
set Remark1="1. Please use the backslash replacer used during the back up. By default, it is [[_]]."
set Remark2="2. The default backslash replacer is set through the [Backslash_Replacer] variable."
set Remark3="3. All [Backslash_Replacer] strings in the [Restore_Folder] will be restored to backslash."
set Remark4="4. The default exporting text file extension is set through the [Text_Extension] variable, which can be overwritten by [/TE:Text_Extension] argument at runtime.
rem set Remark0="Set the EffArg_Required to the number of mandatory arguments."

rem set Reference0="A thorough reference to Windows CMD commends: https://ss64.com/nt/"

echo %Block_Divider_0:"=%
echo %Name:"=%:
call :MSG_Lines "Purpose"
echo %Block_Divider_0:"=%

set /A Arg_Count=0
set /A Effective_Args=0
set /A EffArg_Required=2
set Is_Test=FALSE
set Is_Help=FALSE
set Backslash_Replacer=[_]
set Text_Extension=txt
rem set Is_RemoveDot=FALSE
rem set delimiter=""
rem set unexpected_args=""

echo %Block_Divider_1:"=%
echo [All arguments]:          %*

:arg_loop
if "%~1"=="" goto end_arg_loop
	set /a Arg_Count+=1
	set Is_Effective=TRUE
	set tmp_arg=%~1
	rem echo argument !Arg_Count!: %~1
	rem /I          Do a case Insensitive string comparison.
	rem use /I for a case Insensitive string comparison.
	if /I "!tmp_arg:~0,3!" == "/BR" (
		set Backslash_Replacer=!tmp_arg:~4!
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
	
	if %Is_Effective% == TRUE (
		set /A Effective_Args+=1
		rem echo Effective Args: !Effective_Args!
		if !Effective_Args! == 1 (
			set Restore_Folder=%~1
		)
		if !Effective_Args! == 2 (
			set Backup_File=%~1
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
)

if defined Backslash_Replacer (
	echo [Backslash Replacer]:     !Backslash_Replacer!
)
echo [Backup File Extension]: !Text_Extension!
rem Retore backslashes:
call :Restore_Backslath !Backslash_Replacer!
rem Remove text extention:
if /I "!Restore_Folder:~-4,4!" equ ".!Text_Extension!" (
	set Restore_Folder=!Restore_Folder:~0,-4!
)

echo [Restore Folder]:        !Restore_Folder!
echo %Block_Divider_1:"=%
echo.

rem Restore the permission:
if !Is_Test!==TRUE (
	echo.
	echo Running mode [Active/Test]: Test.
	echo Create destination:   mkdir "!Restore_Folder!"
	echo Restore permission:   icacls "!Restore_Folder!" /restore "!Backup_File!"
	echo.
) else (
	echo.
	echo Running mode [Active/Test]: Active.
	mkdir "!Restore_Folder!"
	icacls "!Restore_Folder!" /restore "!Backup_File!"
	echo.
)

rem the Exit point of the batch CMD.
:The_Exit
endlocal
echo on
exit /B %errorlevel%

:Restore_Backslath
	set Restore_Folder=!Restore_Folder:%1=\!
Exit /B 0

:Unset_Info_Sections
	for /L %%i in (0,1,%Max_Section_Items%) do (
		set "%~1%%i="
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
	REM echo %BlockDivider1:"=%
	REM echo Name: %Name:"=% 
	for %%a in (%Optional_Info_Sections%) do (
		call :MSG_Lines "%%~a"
	)
	REM echo %BlockDivider1:"=%
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
