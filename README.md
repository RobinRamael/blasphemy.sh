blasphemy.sh
========
blasphemy.sh is an xml parser written in bash for people who are violently forced to parse xml in a shell script.

Usage
=====
Always read the blasphemy.sh file in first.

    source blasphemy.sh

get_elements returns all children of the root with the given name.
Return all elements with the tag "book":
    
    cat examples/books.xml | get_elements book

Search for attributes with search\_attr and search\_content, use --like or -l for partial search:
	
	cat examples/books.xml | get_elements book | search_attr book id bk111
	# searches for books with the id attribute set to bk111
	
	cat examples/books.xml | get_elements book | search_content --like description XML
	# searches for all books that have "XML" int their description.
	
You can pipe all these:
    
    cat examples/books.xml | get_elements book | \
    search_content --like description XML | \
	search_content author "O'Brien, Tim" | get_elements publish_date
    # get all books with "XML" in their description and by Tim O'Brien.

After all that, you can strip the tags with get\_content:

	cat examples/books.xml | get_elements book |\
	search_attr book id bk111 | get_elements title | get_content 
	