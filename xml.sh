# Takes an xmlfile (or a tag with children) and
# returns only the tags specified, with each tag 
# on one line. 
# The function does not check if the tag is
# available and returns nothing if this is the case. 
# It exits when the wrong number (!= 1) of arguments is given
function get_elements () {(
	xmllines=`cat` #get stdin
	if [[ $# -ne 1 ]]; then
		echo "usage: get_elements name_of_elements" 1>&2 # to stderr
		exit
	fi
	
	# we have to deal with an xmltag that has no 
	# children (and is put on one line by xmllint)
	# differently than we would a tag with children 
	# that is put on multiple lines, so we check if
	# there is a line that has both start and ending tags.
	on_one_line=`echo $xmllines  | XMLLINT_INDENT="" xmllint --format - | grep "^<"$1">.*</"$1">"`
	
	if [[ "$on_one_line" != "" ]]; then (
		# if the tag is one without children, just give back the one line
		echo $xmllines  | XMLLINT_INDENT="" xmllint --format - | grep "^<"$1">.*</"$1">"
	) else (
		# if the tag has children, get all lines from the 
		# beginning of every starttag to the end of every 
		# endtag, loop over and concatenate them, yielding
		# the element (on one line) every time the endtag is 
		# reached.
		echo $xmllines | XMLLINT_INDENT="" xmllint --format - | sed -n "/^<"$1"[^>]*>/, /<\/"$1">/p" | \
		while read line; do
			element=$element$line # concatenate
			endline=`echo $line | grep "</"$1">"` #grep for the endtag
			if [[ $endline != "" ]]; then
				echo $element 2> /dev/null # bash complains when we don't do something with all lines we were given
				element=
			fi
		done
	 ) fi
)}

function get_line () {(
	head -$1 | tail -1
)}

function get_content () {(
	sed "s/^\ *<[^>]*>//g;s/<\/[^>]*>//g"
)}

function search_attr() {(
    if [[ "$1" == "-l" || "$1" == "--like" ]]; then
        wildcard="[^\[^\"']*"
        shift
    else
        wildcard=
    fi
    grep "<$1[^>]*"$2"=['\"]"$wildcard$3$wildcard"['\"][^>]*>"
)}

function search_content () {(
    if [[ "$1" == "-l" || "$1" == "--like" ]]; then
        wildcard="[^\[^\"']*"
        shift
    else
        wildcard=
    fi
    grep "<"$1"[^>]*>"$wildcard$2$wildcard"<\/"$1"[^>]*>"      
)}