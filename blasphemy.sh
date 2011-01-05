

# Takes an xmlfile (or one tag with children) and
# returns only the tags specified, with each tag 
# on one line. 
# The function does not check if the tag is
# available and returns nothing if this is the case. 
# It exits when the wrong number of arguments is given
function get_elements () {(
	xmllines=`XMLLINT_INDENT="" xmllint --format -` #get stdin and format (without indents) with xmllint
	if [[ $# -ne 1 ]]; then
		echo "usage: get_elements name_of_elements" 1>&2
		exit
	fi


	# xmllint puts tags with children on multiple lines
	# and tags without children on one line.
    # Check if there is a line that has both start and ending tags.
	on_one_line=`echo $xmllines | grep "^<"$1">.*</"$1">"`
	
	if [[ "$on_one_line" != "" ]]; then (
		# if the tag is one without children, just give back the one line 
		echo $xmllines | grep "^<"$1">.*</"$1">"
	) else (
		# if the tag has children, get all lines from the 
		# beginning of every starttag to the end of every 
		# endtag, loop over and concatenate them, yielding
		# the element (on one line) every time the endtag is 
		# reached.
		echo $xmllines | sed -n "/^<"$1"[^>]*>/, /<\/"$1">/p" | \
		while read line; do
			element="$element $line" # concatenate
			endline=`echo $line | grep "</"$1">"` #grep for the endtag
			if [[ $endline != "" ]]; then
				echo $element 2> /dev/null # bash complains when we don't do something with all lines we were given
				element=
			fi
		done
	 ) fi
)}

function get_content () {(
    while read line; do
	    echo $line | sed "s/^\ *<[^>]*>//g;s/<\/[^>]*>//g"
	done
)}

function search_attr() {(
    if [[ "$1" == "-l" || "$1" == "--like" ]]; then
        wildcard="[^\[^\"']*"
        shift
    else
        wildcard=
    fi
    while read line; do
        echo $line | grep "<$1[^>]*"$2"=['\"]"$wildcard$3$wildcard"['\"][^>]*>"
    done
)}

function search_content () {(
    if [[ "$1" == "-l" || "$1" == "--like" ]]; then
        wildcard="[^\[^\"']*"
        shift
    else
        wildcard=
    fi
    while read line; do
        echo $line | grep "<"$1"[^>]*>"$wildcard$2$wildcard"<\/"$1"[^>]*>"
    done;
)}