### Usage: `replaceStrings.sh [Options] [Input File]`

A wrapper bash script based on `sed`. It can evaluate patterns across <b>two lines</b>.

Search through a directory supplied (defaults to current directory) and its sub directories,<br>
find file with the extension supplied (defaults to .html),<br>
replace [old string] with [new string] listed in [Input File].

	$ ./replaceStrings.sh
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
                m~Func():\n  import myModule~Func():\n  import fme\n  from myPackage import myModule
                #~
                #~Insert a new line 'import fme', if it is missing.
                #~FME file format 1, single line operation. Skip the line if 'import\&lt;space\&gt;fme&lt;' exists:
                e~\(\"import\)~\1\&lt;space\&gt;fme\&lt;lf\&gt;import~import\&lt;space\&gt;fme&lt;
                #~FME file format 2, two-line operation. Skip the 2-line block if 'Func():\n[ ]*import fme' exists:
                n~\(Func():\n\)\([ ]*\)import~\1\2import fme\n\2import~Func():\n[ ]*import fme
                #~where \1 is 'Func():\n', and \2 is [ ]* or any spaces before 'import'.

[replaceStringsSampleList.txt](https://github.com/xieshihua/utilities/blob/main/replace-string-in-file/replaceStringsSampleList.txt)
