echo off
setlocal enabledelayedexpansion

set Name="cmd_template.cmd"

set Block_Divider_0="*********************************************************************"
set Block_Divider_1="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

rem *** Info Section Configuration ***
rem * Delete or comment out any item that you do not use.
rem * use "." to insert a blank line.
rem **********************************
rem Configue Info Sections
set /A Max_Section_Items=10
set Optional_Info_Sections=Usage,Example,Remark,Reference

rem When called by a parent batch CMD, variables defined in the parent process may stay. So, clear All!
call :Unset_Info_Sections Purpose
for %%s in (Optional_Info_Sections) do (
	call :Unset_Info_Sections %%~s
)

rem Info Section - Purpose (Used in the Batch CMD heading)
set Purpose0="A template to process Windows CMD batch command arguments, which covers:"
set Purpose1="- Mandatory arguments."
set Purpose2="- Optional arguments with default values."
set Purpose3="- Static variables, use %%variable_name%% to reference."
set Purpose4="- Mutable variables, must enabledelayedexpansion, and use ^!variable_name^! to reference."
set Purpose5="- Unset or undefine variables."
set Purpose5="- List: Define a list, add an item to the list at run time."
set Purpose6="- Loops: Loop through arguments, a list, a range of numbers."
set Purpose7="- Sub routine/function: Define and call with arguments."
set Purpose8="- Standard script heading and info sections."
set Purpose9="."
set Purpose10="The template lists the content specified by the [Path_List] variable and the optional argument [/ADD:Path]."

rem Info Section - Usage
set Usage0="cmd_template.cmd [/?] [/t | /T] [[/add | /ADD]:Path] arg1 arg2 arg3 ..."
set Usage1="."
set Usage2="  [/?]             Optional. Display the Help info, defaults to [Is_Help]."
set Usage3="  [/t | /T]        Optional. Test run or dry run, defaults to [Is_Test]."
set Usage4="  [[/add | /ADD]:Path] Optional. Path to a directory. e.g. /ADD:C:\dvlp\temp. Will be added to the [Path_List] if specified."
set Usage5="  arg1             The first argument."
set Usage6="  arg2             The second argument."
set Usage7="  arg3             The third argument." 
set Usage8="."

rem Info Section - Example
set Example0="Example 1: The following command demos a [Test] run with 5 arguments, and to show the command of listing the content of the default folder(s) set by [Path_List]."
set Example1="."
set Example2="    C:\dvlp>cmd_template.cmd arg1 arg2 arg3 arg4 arg5 /t"
set Example3="."
set Example4="Example 2: The following command demos an [Active] run with 3 arguments, and to list the content of the default folder(s) set by [Path_List] plus the content specified by the [/ADD] optional argument."
set Example5="."
set Example6="    C:\dvlp>cmd_template.cmd arg1 arg2 arg3 '/ADD:C:\Program Files'"
set Example7="."

rem Info Section - Remark
set Remark0="Remarks:"
set Remark1="1. Set [EffArg_Required] to the number of mandatory arguments."
set Remark2="2. Set [Max_Section_Items] to the maximun items of the Info sections."
set Remark3="3. Set [Optional_Info_Sections] to include only sections you are using."
set Remark4="4. Please replace Info sections with your own notes."
set Remark5="."

rem Info Section - Reference
set Reference0="References:"
set Reference1="- A thorough reference to Windows CMD commands can be found at: https://ss64.com/nt/"
set Reference2="- https://ss64.com/ also provides references of Linux, macOS, PowerShell, ASCII, VBScript, Tools, and Passwords."
set Reference3="- https://stackoverflow.com/questions/48623165/null-variable-in-a-bat-window-batch-file"

rem Batch CMD heading
echo %Block_Divider_0:"=%
echo %Name:"=%:
call :MSG_Lines "Purpose"
echo %Block_Divider_0:"=%

rem Set the number of mandatory arguments
set /A EffArg_Required=3

rem Set default values
set Is_Test=FALSE
set Is_Help=FALSE
set Path_List="C:\dvlp","C:\temp"

rem Initialization
set /A Arg_Count=0
set /A Effective_Args=0
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

echo %Block_Divider_1:"=%
echo [All arguments]: %*

rem Loop through Arguments
:arg_loop
if "%~1"=="" goto end_arg_loop
	set /a Arg_Count+=1
	set Is_Effective=TRUE
	rem echo argument !Arg_Count!: %~1
	set tmp_arg=%~1
	rem echo tmp_arg: !tmp_arg!
	
	rem Process Optional Arguments
	if "!tmp_arg!" == "/?" (
		set Is_Help=TRUE
		set Is_Effective=FALSE
	)
	
	rem use /I for a case Insensitive string comparison.
	if /I "!tmp_arg:~0,4!" == "/ADD" (
		set Path_to_Add=!tmp_arg:~5!
		set Is_Effective=FALSE
	)
	
	if /I "!tmp_arg!" == "/T" (
		set Is_Test=TRUE
		set Is_Effective=FALSE
	)
	
	rem Process Mandatory Arguments
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
rem Use 'shift' to loop through all the argument.
shift
goto arg_loop
:end_arg_loop

rem Number of arguments mismatching handling
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

rem Display the help message if is requested or the number of passed-in mandatory arguments is less than the required number of mandatory arguments.
if !Is_Help!==TRUE (
	echo %Block_Divider_1:"=%
	call :MSG_Help
	goto The_Exit
)

echo [Original Path List]: %Path_List%
echo [Path to Be Added]: !Path_to_Add!
if defined Path_to_Add (
	set Path_List=%Path_List%,"!Path_to_Add!"
)
echo [Effective Path List]: !Path_List!

echo %Block_Divider_1:"=%
echo.

rem Actual Tasks Handling
for %%a in (!Path_List!) do (
	call :List_Directory !Is_Test! %%a
)

rem the Exit point of the batch CMD.
:The_Exit
endlocal
echo on
Exit /B 0

:List_Directory
if %1==TRUE (
	echo.
	echo Running mode [Active/Test]: Test.
	echo DIR "%~2"
	echo.
) else (
	echo.
	echo Running mode [Active/Test]: Active.
	DIR "%~2"
	echo.
)
Exit /B 0

:Unset_Info_Sections
	for /L %%i in (0,1,%Max_Section_Items%) do (
		set "%~1%%i="
	)
Exit /B 0

rem Show number of mandatory arguments mismatching info
:MSG_EffectiveArgs
	echo.
	echo %~1:
	echo Effective Arguments expected: %EffArg_Required%
	echo Actual Effective Arguments received: !Effective_Args!
Exit /B 0


rem Show help message sections
:MSG_Help
	echo.
	REM echo %Block_Divider_1:"=%
	REM echo Name: %Name:"=% 
	for %%a in (%Optional_Info_Sections%) do (
		call :MSG_Lines "%%~a"
	)
	REM echo %Block_Divider_1:"=%
Exit /B 0

rem Process and show one message section
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
