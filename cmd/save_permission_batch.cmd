echo off
setlocal enabledelayedexpansion

set BlockDivider0="*********************************************************************"
set BlockDivider1="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
set Heading_Line0="####################"
set Heading_Line1="===================="
set Heading_Line2="--------------------"

set Name="save_permission_batch.cmd"
set Purpose0="Batch backup permissions grouped by sub directories with exclusion list support."
set Purpose1="- Creates top level sub directories of the [source_directory] in the [destination_directory].
set Purpose2="- And then batch backs up permission of subsequent sub directories to text files in coresponding sub directories in the [destination_directory]."
REM set Usage0="."
set Usage0="save_permission_batch.cmd [/?] [/T] source_directory destination_directory"
rem Below are optional Help items. Comment out any item that you do not use.
set Usage1="."
set Usage2="  [/?]                   Optional. Show Help."
set Usage3="  [/T]                   Optional. Test run or dry run without writing."
set Usage4="  source_directory       Permissions of all sub directories to be backed up."
set Usage5="  destination_directory  Permissions will be backed up to this directory."
set Usage6="."
set Example0="The following command displays the process of saving permissions of sub directories of D:\ to C:\temp\D_Permissions without create folder or file."
set Example1="."
set Example2="  C:\dvlp>save_permission_batch D: C:\temp\D_Permissions /t"
set Example3="."
set Remark0="Remarks:"
set Remark1="1. This script calls save_permission.cmd. You must update Path_save_permission variable."
set Remark2="2. Alternatively, you may add the path of save_permission.cmd to the Path environment variable." 
set Remark3="3. Set the Exclusion_List variable to exclude sub directories you want to escape."
rem set Remark1="Set the EffArg_Required to the number of mandatory arguments."
rem set Reference0="A thorough reference to Windows CMD commands: https://ss64.com/nt/"
set Head_Sections=Usage,Example,Remark
set Max_Help_Items=0,1,2,3,4,5,6

echo %BlockDivider0:"=%
echo %Name:"=%:
call :MSG_Lines "Purpose"
echo %BlockDivider0:"=%

REM 'shift' will process all the argument.
set /A Arg_Count=0
set /A Effective_Args=0
set /A EffArg_Required=2
set Is_Test=FALSE
set Is_Help=FALSE
set Path_save_permission=C:\Dvlp\Library\source\CMD
set Exclusion_List="$Recycle.Bin","Recovery","System Volume Information"
set Is_in_List=FALSE

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
	
	if !Is_Effective! == TRUE (
		set /A Effective_Args+=1
		rem echo Effective Args: !Effective_Args!
		if !Effective_Args! == 1 (
			set source_directory=%~1
		)
		if !Effective_Args! == 2 (
			set destination_directory=%~1
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

rem Trim ending "\".
if "!source_directory:~-1!" equ "\" (
	set source_directory=!source_directory:~0,-1!
)
if "!destination_directory:~-1!" equ "\" (
	set destination_directory=!destination_directory:~0,-1!
)

echo Batch source root: !source_directory!
echo Batch destination root: !destination_directory!

set Time_Started=%date%:%time%
echo [!source_directory!] Time started: %Time_Started%

rem *** Batch Processing ***
for /f "tokens=*" %%a in ('dir /a:d
 /b !source_directory!\') do (
	call :Test_Membership "%%a"
	if !Is_in_List! == TRUE (
		echo [%%a] is excluded.
	) else (
		set src=!source_directory!\%%a
		set dst=!destination_directory!\%%a
		rem stepwise is easier to read and maintain then blockwise.
		echo.
		echo %Heading_Line0:"=% Processing directory: [!src!] %Heading_Line0:"=%

		set SubTime_Started=!date!:!time!
		echo [!src!] time started: !SubTime_Started!

		echo Create destination:
		if !Is_Test! == TRUE (
			echo mkdir !dst!
		) else (
			mkdir !dst!
		)
		echo.
		echo %Heading_Line1:"=% Save root level permissions %Heading_Line1:"=%
		if !Is_Test! == TRUE (
			call "%Path_save_permission%\save_permission.cmd" "!src!" "!dst!" "%%a" /t
		) else (
			call "%Path_save_permission%\save_permission.cmd" "!src!" "!dst!" "%%a"
		)
		echo.
		echo %Heading_Line2:"=% Save sub directory Permissions %Heading_Line2:"=%
		echo Root: [!src!]
		if !Is_Test! == TRUE (
			forfiles /p "!src!" /s /c "cmd /C if @isdir == TRUE (call "%Path_save_permission%\save_permission.cmd" "@path" "!dst!" "@relpath" /t) else (echo Escape file: @path)"
		) else (
			forfiles /p "!src!" /s /c "cmd /C if @isdir == TRUE (call "%Path_save_permission%\save_permission.cmd" "@path" "!dst!" "@relpath") else (echo Escape file: @path)"
		)
		echo.
		echo [!src!] time started: !SubTime_Started!
		echo [!src!] time finished: !date!:!time!
	)
	echo off
)
echo off

echo.
echo %Heading_Line0:"=%***  Total Time Elapsed  ****%Heading_Line0:"=%
echo [!source_directory!] Time started: %Time_Started%
echo [!source_directory!] Time finished: !date!:!time!
echo %BlockDivider1:"=%

endlocal
echo on
exit /B %errorlevel%

:Test_Membership
	set Is_in_List=FALSE

	for %%b in (%Exclusion_List%) do (
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
