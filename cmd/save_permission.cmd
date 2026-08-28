echo off
setlocal enabledelayedexpansion

set Name="save_permission.cmd"

set Block_Divider_0="*********************************************************************"
set Block_Divider_1="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

rem Configue Info Sections
set /A Max_Section_Items=7
set Optional_Info_Sections=Usage,Example,Remark

rem Clear info sections inherited from the caller.
call :Unset_Info_Sections Purpose
for %%s in (Optional_Info_Sections) do (
	call :Unset_Info_Sections %%~s
)

rem Set info sections
set Purpose0="Backup permissions of a folder or a file to a text file."

rem Below are optional Help items. Delete or comment out any item that you do not use.
set Usage0="save_permission.cmd [/BR:Backslash_Replacer] [/T] [/?] 'source_folder_or_file' 'destination_folder' 'destination_file'"
set Usage1="."
set Usage2="  [/?]                     Optional. Show Help."
set Usage3="  [/BR:Backslash_Replacer] Optional. The string to replace backslashes in the [destination_file]. Defaults to [[_]] (without brackets)."
set Usage4="  [/T]                     Optional. Test run or dry run without writing."
set Usage5="  source_folder_or_file    Source file or folder with which permissions to be captured."
set Usage6="  destination_folder       The folder where the result will be saved."
set Usage7="  destination_file         The file name to which the result will be saved."
set Usage8="."

set Example0="The following command shows the process of saving the permission of [C:\dvlp\CMD] to [C:\temp\dvlp[_]CMD.txt] without create any file:"
set Example1="."
set Example2="  C:\dvlp>save_permission.cmd C:\dvlp\CMD C:\temp dvlp\CMD /t"
set Example3="."

set Remark0="Remarks:"
set Remark1="1. Backslashes in the [destination_file] will be replaced by the string defined by [Backslash_Replacer] variable. E.g. [dvlp\CMD] will become [dvlp[_]CMD]."
set Remark2="2. The default backslash replacer is set through the [set Backslash_Replacer] variable, which can be replaced by [/BR:Backslash_Replacer] argument at runtime."
set Remark3="3. Use the relative path of the [source_folder_or_file] as [destination_file] can help with the search later."
rem set Remark0="Set the EffArg_Required to the number of mandatory arguments."

rem set Reference0="A thorough reference to Windows CMD commends: https://ss64.com/nt/"

echo %Block_Divider_0:"=%
echo %Name:"=%:
call :MSG_Lines "Purpose"
echo %Block_Divider_0:"=%

set /A Arg_Count=0
set /A Effective_Args=0
set /A EffArg_Required=3
set Is_Test=FALSE
set Is_Help=FALSE
set Backslash_Replacer=[_]
rem set Is_RemoveDot=FALSE
rem set delimiter=""
rem set unexpected_args=""

rem echo args: %*echo %Block_Divider_1:"=%
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
			set source_name=%~1
			echo Source_name: !source_name!
		)
		if !Effective_Args! == 2 (
			set backup_folder=%~1
			echo backup_folder: !backup_folder!
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

rem Remove leading ".\":
if "!backup_file:~0,2!" equ ".\" (
	set backup_file=!backup_file:~2!
)
rem Replace backslashes:
call :Replace_Backslath !Backslash_Replacer!
rem Add default extention:
if /I "!backup_file:~-4,4!" neq ".txt" (
	set backup_file=!backup_file!.txt
)

if defined Backslash_Replacer (
	echo [Backslash Replacer]:     !Backslash_Replacer!
)
echo [backup_file]: !backup_file!
echo %Block_Divider_1:"=%
echo.

rem Capture the permission:
if !Is_Test!==TRUE (
	echo.
	echo Running mode [Active/Test]: Test.
	echo save_permission cmd: icacls "!source_name!" /save "!backup_folder!\!backup_file!"
	icacls "!source_name!"
	echo.
) else (
	echo.
	echo Running mode [Active/Test]: Active.
	icacls "!source_name!" /save "!backup_folder!\!backup_file!"
	echo.
)

rem the Exit point of the batch CMD.
:The_Exit
endlocal
echo on
exit /B %errorlevel%

:Replace_Backslath
	set backup_file=!backup_file:\=%1!
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
