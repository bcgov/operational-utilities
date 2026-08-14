echo off
setlocal enabledelayedexpansion

set BlockDivider0="*********************************************************************"
REM set BlockDivider1="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
set Name="start_service.cmd"
set Purpose0="Start a Windows service if it is not running."
set Usage0="start_service.cmd [/?] [/T] service_name"
set Usage1="."
set Usage2="  [/?]          Optional. Display the Help info, defaults to FALSE."
set Usage3="  [/T]          Optional. Test run or dry run, defaults to FALSE."
set Usage4="  service_name  The name of a Windows service."
set Usage5="."
set Example0="The following command shows the status of AppReadiness."
set Example1="If the service is not running, it shows the command to start the service:"
set Example2="."
set Example3="  C:\dvlp>start_service.cmd AppReadiness /t"
set Example4="."
rem set Remark="Set the EffArg_Required to the number of mandatory arguments."
rem set Reference="A thorough reference to Windows CMD commends: https://ss64.com/nt/"
set Head_Sections=Usage,Example
set Max_Help_Items=0,1,2,3,4,5

echo %BlockDivider0:"=%
echo %Name:"=%:
call :MSG_Lines "Purpose"
echo %BlockDivider0:"=%

REM 'shift' will process all the arguments.
set /A Arg_Count=0
set /A Effective_Args=0
set /A EffArg_Required=1
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
	rem echo tmp_arg: !tmp_arg!
	if "!tmp_arg!" == "/?" (
		set Is_Help=TRUE
		set Is_Effective=FALSE
	)
	if /I "!tmp_arg!" == "/t" (
		set Is_Test=TRUE
		set Is_Effective=FALSE
	)
	
	if %Is_Effective% == TRUE (
		set /A Effective_Args+=1
		rem echo Effective Args: !Effective_Args!
		if !Effective_Args! == 1 (
			set Eff_Arg1=%~1
			set service_name=%~1
		)
		if !Effective_Args! GTR %EffArg_Required% (
			if "!unexpected_args!" GTR "" (
				set delimiter=;
			)
			set unexpected_args=!unexpected_args!!delimiter!%~1
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

if !Is_Test!==TRUE (
	echo.
	sc query %service_name% | findstr RUNNING && (
		echo.
		echo The %service_name% service is already RUNNING.
	) || (
		echo.
		echo The service is not running.
		echo You may run the following command to start the %service_name% service:
		echo.
		echo sc start %service_name%
	)
	echo.
) else (
	echo.
	sc query %service_name% | findstr RUNNING && (
		echo.
		echo The %service_name% service is already RUNNING.
	) || (
		echo.
		echo The service is not running. Start the %service_name% service:
		sc start %service_name%
	)
	echo.
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
