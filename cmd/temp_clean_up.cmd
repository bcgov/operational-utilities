echo off
setlocal enabledelayedexpansion

set BlockDivider0="*********************************************************************"
REM set BlockDivider1="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
set Name="temp_clean_up.cmd"
set Purpose0="Remove files in [Path_to_Check] folder(s) and their sub folders that are older than [Cut_off_Days] days."
rem Below are optional Help items. Delete or comment out any item that you do not use.
rem use "." to insert a blank line.
set Usage0="temp_clean_up.cmd [/?] [/T] [/D:Days] [/P:Path]"
set Usage1="."
set Usage2="  [/?]       Optional, defaults to FALSE. Display the Help info."
set Usage3="  [/D:Days]  Optional, defaults to [Cut_off_Days]. Cut off days. e.g. /D:30."
set Usage4="  [/P:Path]  Optional, defaults to [Path_to_Check]. Folder to be scanned and cleaned up. e.g. /P:C:\temp."
set Usage5="  [/t | /T]  Optional, defaults to FALSE. Lists files meeting the criteria without deleting them."
set Usage6="."
set Example0="The following command scans [C:\Program Files] and display the files that are older than 30 days."
set Example1="."
set Example2="  C:\dvlp>temp_clean_up.cmd /D:30 '/P:C:\Program Files' /t"
set Example3="."
set Remark0="* It goes through sub folders recursively."
set Remark1="."
rem set Reference0="- A thorough reference to Windows CMD commands can be found at: https://ss64.com/nt/"
rem set Reference1="           - https://ss64.com/ also provides references of Linux, macOS, PowerShell, ASCII, VBScript, Tools, and Passwords."
set Head_Sections=Usage,Example,Remark
set Max_Help_Items=0,1,2,3,4,5,6

echo %BlockDivider0:"=%
echo %Name:"=%:
call :MSG_Lines "Purpose"
echo %BlockDivider0:"=%

set /A Cut_off_Days=90

rem Set folders to be checked. Quotate each path with double quotation and separate paths by comma. For example:
rem Set Path_to_Check="%sde_temp%","C:\temp\jenkins_workspace","C:\temp\FME_workspace"
set Path_to_Check="C:\temp","C:\Dvlp"

rem "shift" will process all the argument.
set /A Arg_Count=0
set /A Effective_Args=0
set /A EffArg_Required=0
set Is_Test=FALSE
set Is_Help=FALSE
rem set delimiter=""
rem set unexpected_args=""

:arg_loop
if "%~1"=="" goto end_arg_loop
	set /a Arg_Count+=1
	set Is_Effective=TRUE
	rem echo argument !Arg_Count!: %~1
	rem /I          Do a case Insensitive string comparison.
	set tmp_arg=%~1
	REM echo tmp_arg: !tmp_arg!
	if "!tmp_arg!" == "/?" (
		set Is_Help=TRUE
		set Is_Effective=FALSE
	)
	if /I "!tmp_arg:~0,2!" == "/d" (
		set /A Cut_off_Days=!tmp_arg:~3!
		set Is_Effective=FALSE
	)
	if /I "!tmp_arg:~0,2!" == "/p" (
		set Path_to_Check=!tmp_arg:~3!
		set Is_Effective=FALSE
	)
	if /I "!tmp_arg!" == "/t" (
		set Is_Test=TRUE
		set Is_Effective=FALSE
	)
	
	if %Is_Effective% == TRUE (
		set /A Effective_Args+=1
		rem echo Effective Args: !Effective_Args!
		if !Effective_Args! GTR %EffArg_Required% (
			if "!unexpected_args!" GTR "" (
				set delimiter=;
				rem echo delimiter: !delimiter!
			)
			set unexpected_args=!unexpected_args!!delimiter!!tmp_arg!
			rem echo !unexpected_args!
		)
	)
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
	call :MSG_Help
	exit /b 0
)

echo Cut_off_Days: !Cut_off_Days!
echo Path_to_Check: !Path_to_Check!
call :clean_up !Cut_off_Days!, !Path_to_Check!, !Is_Test!

REM You may set up another set days and Path_to_Check and then call :clean_up
REM set /A Cut_off_Days=120
REM set Path_to_Check="D:\tmp\apps_data","D:\tmp\web_temp","D:\tmp\sde_client"
REM call :clean_up %Cut_off_Days%, %Path_to_Check%, %1

endlocal
echo on
exit /B %errorlevel%

:clean_up
for %%a in (%~2) do (
	if /i %3==TRUE (
		echo The following files in "%%~a" are older than %~1:
		forfiles /p "%%~a" /s /d -%~1 /c "cmd /c if @isdir==FALSE (echo @relpath; @fdate; @fsize Bytes)"
	) else (
		echo Deleting files are older than %~1 in "%%~a":
		forfiles /p "%%~a" /s /d -%~1 /c "cmd /c if @isdir==FALSE (del /q @path)"
	)
)
exit /B 0

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
	for %%a in (%Head_Sections%) do (
		call :MSG_Lines "%%~a"
	)
	REM echo %BlockDivider1:"=%
Exit /B 0

:MSG_Lines
	for %%i in (%Max_Help_Items%) do (
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
