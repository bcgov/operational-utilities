#!/bin/bash
# Usage: ./replaceStrings.sh [Options] [input.txt]
# [input.txt]: text file with "[operation type]~[old string]~[new string]" per line
# Replace [old string] with [new string] in all file with extension [.file_extension]
# in a directory and its sub directories

iOpt=$#
stInputFile=${!iOpt}
fileExt="\.html"
stDir="./"
stDelimiter="~"
stMsg=""

function _usage()
{
	### Usage ###
	cat <<EOF
		Usage: replaceStrings.sh [Options] [Input File]
		Search through a directory supplied (defaults to current directory) and its sub directories,
		find file with the extension supplied (defaults to .html),
		replace [old string] with [new string] listed in [Input File].
		[Input File] contains a list of "[operation type]~[old string]~[new string]" per line,
		where '~' is the default delimiter. You may specify your own delimiter by using the -l option.
		[operation type]:
			'm' for multipleline replacing,
			's' for single line replacing,
			'#' skip the line.
		
		
		Options:
			-d [Search Directory], optional. Defaults to the current directory.
			-e [File Extension], such as \.html, \.py, etc. optional. defaults to '.html'.
			-l [delimiter], optional. Defaults to '~'
EOF
}

# Fetch arguments
while getopts ":d:e:l:-:" chOpt; do
	case $chOpt in
	d)
		stDir=$OPTARG
		;;
	e)
		fileExt=$OPTARG
		;;
	l)
		stDelimiter=$OPTARG
		;;
	*)
		echo "Unhandled argument -$chOpt with parameter $OPTARG" >&2
		_usage
		echo
		;;
	esac
done

# Apply changes from the input file to all files with the specified extension in the directory.
while IFS="$stDelimiter" read -r chMultiLine oldString newString;do
	if [ $chMultiLine == "m" ]; then
		stMsg="($chMultiLine) Multi-line operation:\n Replacing \n'$oldString' \n with \n'$newString'."
		sed -i "N; s/$oldString/$newString/; P; D" `tree -fi $stDir | grep $fileExt`
	elif [ $chMultiLine == "s" ]; then
		stMsg="($chMultiLine) Single line operation:\n Replacing '$oldString' with '$newString'."
		sed -i "s/$oldString/$newString/g" `tree -fi $stDir | grep $fileExt`
	else
		stMsg="($chMultiLine) Skip the line: $chMultiLine~$oldString~$newString."
	fi
	echo -e "$stMsg"
	
done < "$stInputFile"
