echo off
setlocal enabledelayedexpansion

set BlockDivider="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
set Name="cmdTemplate.cmd"
set Purpose0="A template to process Windows CMD batch commends arguments."
rem Below are optional Help items. Delete or comment out any item that you do not use.
set Purpose1="         * Please replace head sections with your own notes.
rem use "." to insert a blank line.
set Purpose2="."
set Usage0="cmdTemplate.cmd [/?] [/t or /T] arg1 arg2 arg3 ..."
set Usage1="       Optional: /? - Help"
set Usage2="       Optional: /t or /T - Test run or dry run."
set Usage3="."
set Example0="The following command demos a test run with five auguments."
set Example1="."
set Example2="  C:\dvlp>cmdTemplate.cmd arg1 arg2 arg3 arg4 arg5 /t"
set Example3="."
set Remark0="- Set the EffArg_Required to the number of mandatory arguments."
set Remark1="        - Set Max_Help_Items to the maximun items in the head sections."
set Remark2="."
set Reference0="- A thorough reference to Windows CMD commands can be found at: https://ss64.com/nt/"
set Reference1="           - https://ss64.com/ also provides references of Linux, macOS, PowerShell, ASCII, VBScript, Tools, and Passwords."
set Head_Sections=Purpose,Usage,Example,Remark,Reference
set Max_Help_Items=0,1,2,3

echo %BlockDivider:"=%
echo %Name:"=%: %Purpose0:"=%
echo %BlockDivider:"=%

REM 'shift' will process all the argument.
set /A Arg_Count=0
set /A Effective_Args=0
set /A EffArg_Required=3
set Is_Test=FALSE
set Is_Help=FALSE
rem set delimiter=""
rem set unexpected_args=""

rem This block is for your reference only.
REM Check if at least one argument is passed
REM if "%~1"=="" (
    REM echo No argument is provided.
	REM set Is_Help=TRUE
REM ) else (
	REM echo.
	REM echo arguments: %*
REM )

:arg_loop
if "%~1"=="" goto end_arg_loop
	set /a Arg_Count+=1
	set Is_Effective=TRUE
	rem echo argument !Arg_Count!: %~1
	rem /I          Do a case Insensitive string comparison.
	if /I "%~1" == "/t" (
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
			set Eff_Arg1=%~1
			echo Eff_Arg1: !Eff_Arg1!
		)
		if !Effective_Args! == 2 (
			set Eff_Arg2=%~1
			echo Eff_Arg2: !Eff_Arg2!
		)
		if !Effective_Args! == 3 (
			set Eff_Arg3=%~1
			echo Eff_Arg3: !Eff_Arg3!
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
	echo Running mode [Active/Test]: Test.
	echo.
) else (
	echo.
	echo Running mode [Active/Test]: Active.
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
	echo %BlockDivider:"=%
	echo Name: %Name:"=% 
	for %%a in (%Head_Sections%) do (
		for %%i in (%Max_Help_Items%) do (
			if defined %%~a%%i (
				set msg=!%%~a%%i!
				if !msg! equ "." (
					echo.
				) else (
					set msg=!msg:"=!
					if %%i==0 (
						echo %%~a: !msg!
					) else (
						echo !msg!
					)
				)
			)
		)
	)
	echo %BlockDivider:"=%
Exit /B 0