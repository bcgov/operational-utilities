echo off
setlocal enabledelayedexpansion

set BlockDivider="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
set Name="save_permission.cmd"
set Purpose0="Backup a directory or a file permission to a text file."
rem Below are optional Help items. Delete or comment out any item that you do not use.
set Purpose1="."
set Usage0="save_permission.cmd [/t or /T] [/?] source_directory_or_file destination_directory destination_file"
set Usage1="       Optional: /t or /T - Test run or dry run."
set Usage2="       Optional: /? - Help"
set Usage3="       source_directory_or_file: Source file or directory which permissions to be captured.
set Usage4="       destination_directory: The directory where the result will be saved.
set Usage5="       destination_file: The file name to which the result will be saved.
set Usage6="."
set Example0="The following command test run save the permission of [C:\dvlp\Library\CMD] to [C:\temp\dvlp-_-Library-_-CMD.txt]:"
set Example1="."
set Example2="  C:\dvlp>save_permission.cmd C:\dvlp\Library\CMD C:\temp dvlp\Library\CMD /t"
set Example3="."
set Example4="  *  By default, the backslashes in the destination_file is replaced by [-_-]."
set Example5="  ** The default backslash replacer can be changed by replace [-_-] with a new string in [set Backslash_Replacer=-_-]."
set Example6="."
set Remark0="Use the relative path of the [source_directory_or_file] as [destination_file] can help with the search later."
set Remark1="Backslashes in the destination_file will be replaced by the string defined by Backslash_Replacer variable."
rem set Remark0="Set the EffArg_Required to the number of mandatory arguments."
rem set Reference0="A thorough reference to Windows CMD commends: https://ss64.com/nt/"
set Head_Sections=Purpose,Usage,Example,Remark
set Max_Help_Items=0,1,2,3,4,5,6

echo %BlockDivider:"=%
echo %Name:"=%: %Purpose0:"=%
echo %BlockDivider:"=%

REM 'shift' will process all the argument.
set /A Arg_Count=0
set /A Effective_Args=0
set /A EffArg_Required=3
set Is_Test=FALSE
set Is_Help=FALSE
set Is_RemoveDot=FALSE
set Backslash_Replacer=-_-
rem set delimiter=""
rem set unexpected_args=""

rem echo args: %*

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
			set source_name=%~1
			echo Source_name: !source_name!
		)
		if !Effective_Args! == 2 (
			set backup_directory=%~1
			echo backup_directory: !backup_directory!
		)
		if !Effective_Args! == 3 (
			set backup_file=%~1
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

rem Remove leading ".\":
if "!backup_file:~0,2!" equ ".\" (
	set backup_file=!backup_file:~2!
)
rem Replace backslashes:
set backup_file=!backup_file:\=%Backslash_Replacer%!
rem Add default extention:
if "!backup_file:~-4,1!" neq "." (
	set backup_file=!backup_file!.txt
)
echo backup_file: !backup_file!

rem Capture the permission:
if !Is_Test!==TRUE (
	echo.
	echo Running mode [Active/Test]: Test.
	echo save_permission cmd: icacls "!source_name!" /save "!backup_directory!\!backup_file!"
	icacls "!source_name!"
	echo.
) else (
	echo.
	echo Running mode [Active/Test]: Active.
	icacls "!source_name!" /save "!backup_directory!\!backup_file!"
	echo.
)

endlocal
echo on
exit /B %errorlevel%

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