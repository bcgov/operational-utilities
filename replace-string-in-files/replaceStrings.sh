#!/bin/bash
# Usage: ./replaceStrings.sh [Options] [input.txt]
# [input.txt]: text file with "[operation type]~[old string]~[new string]~[optional begin string]~[optional end string]" per line
# Replace [old string] with [new string] in all file with extension [.file_extension]
# in a directory and its sub directories

iOpt=$#
stInputFile=${!iOpt}
fileExt="\.html"
stDir="./"
stDelimiter="~"
stMsg=""
stCommand=""
bIsCommand=1
iCounter=0

function _usage()
{
	### Usage ###
	cat <<EOF
		Usage: replaceStrings.sh <[Options]> [Input File]
		Search through a directory supplied (defaults to current directory) and its sub directories,
		find file with the extension supplied (defaults to .html),
		replace [old string] with [new string] listed in [Input File].
		
		[Input File] contains a list of:
		"[operation type]~[old string]~[new string]~<[except begin string]>~<[except end string]>"
		per line,
		where '~' is the default delimiter (you may specify your own delimiter through the -l option),
		[except begin string] and [except end string] are optional and used with the 'e' or 'n' operation type.
		You may omit [except end string] if only exclude lines that contains [except begin string] in the text file.
		
		[operation type]:
			'e' single line replacing with exception,
			'm' two-line replacing,
			'n' two-line replacing with exception,
			'p' pass in your own command,
			's' single line replacing,
			'#' Comment line.
		
		Options:
			-d [Search Directory], optional. Defaults to the current directory.
			-e [File Extension], such as \.html, \.py, etc. optional. defaults to '.html'.
			-l [delimiter], optional. Defaults to '~'
		
		Example entries of an [Input File]:
		#~Comment
		#~Insert a new line 'import fme' and insert 'from myPackage ' in front of 'import myModule'.
		#~
		#~FME file format 1, string based new line, single line operation:
		s~\"import\&lt;space\&gt;myModule\&lt;~\"import\&lt;space\&gt;fme\&lt;lf\&gt;from\&lt;space\&gt;myPackage\&lt;space\&gt;import\&lt;space\&gt;myModule\&lt;
		#~FME file format 2, new line based, two-line operation:
		m~Func():\n  import myModule~Func():\\n  import fme\n  from myPackage import myModule
		#~
		#~Insert a new line 'import fme', if it is missing.
		#~FME file format 1, single line operation. Skip the line if 'import\&lt;space\&gt;fme&lt;' exists:
		e~\(\"import\)~\1\&lt;space\&gt;fme\&lt;lf\&gt;import~import\&lt;space\&gt;fme&lt;
		#~FME file format 2, two-line operation. Skip the 2-line block if 'Func():\\n[ ]*import fme' exists:
		n~\(Func():\\n\)\([ ]*\)import~\1\2import fme\\n\2import~Func():\\n[ ]*import fme
		#~where \1 is 'Func():\\n', and \2 is [ ]* or any spaces before 'import'.
		
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
	let "iCounter += 2"
done

if [ $iOpt -eq 0 ] || [ $iCounter -eq $iOpt ]; then
	_usage
	exit 0
fi

# Apply changes from the input file to all files with the specified extension in the directory.
while IFS="$stDelimiter" read -r chOperation stOld stNew stBegin stEnd;do
	if [ $chOperation == "e" ]; then
		if [ -z $stEnd ]; then
			stMsg="($chOperation) Single line with exception operation:\n Replacing '$stOld' with '$stNew', except having '$stBegin'."
			stCommand="/$stBegin/!s/$stOld/$stNew/g"
		else
			stMsg="($chOperation) Single line with exception operation:\n Replacing '$stOld' with '$stNew', except between '$stBegin' and '$stEnd'."
			stCommand="/$stBegin/,/$stEnd/!s/$stOld/$stNew/g"
		fi
	elif [ $chOperation == "m" ]; then
		stMsg="($chOperation) two-line operation:\n Replacing \n'$stOld' \n with \n'$stNew'."
		stCommand="{N; s/$stOld/$stNew/g; P; D}"
	elif [ $chOperation == "p" ]; then
		stMsg="($chOperation) Pass in command:\n '$stOld'."
		stCommand="$stOld"
	elif [ $chOperation == "n" ]; then
		if [ -z $stEnd ]; then
			stMsg="($chOperation) two-line with exception operation:\n Replacing '$stOld' with '$stNew', except having '$stBegin'."
			stCommand="{N; /$stBegin/!s/$stOld/$stNew/g; P; D}"
		else
			stMsg="($chOperation) two-line with exception operation:\n Replacing '$stOld' with '$stNew', except between '$stBegin' and '$stEnd'."
			stCommand="{N; /$stBegin/,/$stEnd/!s/$stOld/$stNew/g; P; D}"
		fi
	elif [ $chOperation == "s" ]; then
		stMsg="($chOperation) Single line operation:\n Replacing '$stOld' with '$stNew'."
		stCommand="s/$stOld/$stNew/g"
	else
		stMsg="($chOperation) Comment: $chOperation~$stOld~$stNew~$stBegin~$stEnd."
		bIsCommand=0
	fi
	
	echo -e "$stMsg"
	if [ $bIsCommand -eq 1 ]; then
		sed -i "$stCommand" `tree -fi $stDir | grep $fileExt`
	fi
	
	bIsCommand=1
	
done < "$stInputFile"
