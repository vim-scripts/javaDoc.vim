" javaDoc : A VIM plugin to open Javadoc help in a web-browser.
" Author Bhaskar V. Karambelkar
" Version 1
"
" The file is heavily commented for anyone reading it for better
" understanding.
"
" History
" v1	Initial Release.

" This is the main function. The cursor should be placed on the ClassName
" whose JavaDoc is to be opened.
" You can map a specific key-sequence for execution of this function.
" e.g. put
" map <F5> :call SearchForJHelp()<CR> 
" In your .vimrc file.
function! SearchForJHelp()

	"This local variable acts as a counter for the number of ID Files.
	let l_no_of_ID_Files = 0
	
	"This local variable contains space seperated list of JavaDoc HTML files
	"for the class being looked up. If the Class is defined in multiple packages e.g.
	"java.util.Date and java.sql.Date then the variable will contain both the
	"entries. Also if the same class is present in multiple javaDocs e.g.
	"java.naming.Context is present in javaDocs for J2SDK as well as J2EE then
	"too both the files will be present in this variable.
	let l_file_list = ""

	" g:no_of_ID_Files is a GLOBAL variable which defines how many ID files
	" are to be searched. Normally You would have One ID file per javaDoc.
	" e.g. I have two ID files one for J2SDK another for J2EE javaDocs.
	" see the end of this file for sample values.
	if exists('g:no_of_ID_Files')
		"echo "  DEBBUG-- g:no_of_ID_Files = " . g:no_of_ID_Files

		" Loop through each ID file to search for the javaDoc of the desired
		" Class File.
		while l_no_of_ID_Files <= g:no_of_ID_Files
	
			" Counter increment :-)
			let l_no_of_ID_Files = l_no_of_ID_Files +1

			"If g:no_of_ID_Files is > 0 then there should be as many global
			"variables defined which point to absolute path of each ID file.
			"This is my way of implementing non-fixed size arrays.
			"i.e. if g:no_of_ID_Files is 2 then there should be two global
			"variables g:javadoc_ID_File_1 and g:javadoc_ID_File_2 each
			"pointing to a different ID file.
			if exists("g:javadoc_ID_File_".l_no_of_ID_Files)
				"exec "echo g:javadoc_ID_File_". l_no_of_ID_Files

				"Assign the current ID file Name to a temp variable.
				exec "let l_temp_file = g:javadoc_ID_File_" . l_no_of_ID_Files

				" Check if the ID file does indeed exists and is readable.
				if filereadable(l_temp_file)
					"echo "DEBUG-- " . l_temp_file . " exists "
					
					" Search for javaDoc HTML of the desired Class in the ID
					" file and append the returned value.
					let l_file_list = l_file_list . GetJavaClassHTMLFile(l_temp_file)
					"echo " DEBUG-- l_file_list = " . l_file_list
				endif

				" release the local Variable so that it can be used again in
				" the loop.
				unlet l_temp_file
			endif
		endw
	
		"remove unwanted whitespaces at the end.
		let l_file_list = TrimString(l_file_list)

		if l_file_list != ""
			"Open the help files.
			call OpenMultipleFiles(l_file_list)
			"redraw the screen after the user closes help.
			redraw!
		endif
	endif
endf

"This function searches for all javaDoc HTML files for a perticular class in
"a ID file. The return value is a string with space seperated list of the
"matching HTML files. The function takes care of classes defined in multiple
"packages.
function! GetJavaClassHTMLFile(id_file)

	"The javaDoc HTML filename of a Class is ClassName.html ie
	"BufferedReader.html etc.
	let l_fileName =  expand("<cword>") . ".html"
	"echo " DEBUG-- l_fileName = " . l_fileName
	
	" Find the directory name of the ID file.
	let l_javadoc_dir =system("dirname " . a:id_file)

	"Get the HTML file corrosponding to the Java Class.
	let l_JavaHelp = system(g:srchJdoc_loc . " " . l_fileName . " " . a:id_file . " " . l_javadoc_dir) 

	"echo "DEBUG-- Before trim l_JavaHelp = #" . l_JavaHelp . "#"

	"Remove any unprintable characters that system command may have returned
	"such as ASCLL NULL, Newline , Formfeed etc.
	let l_JavaHelp = RemoveNewLine(l_JavaHelp)
	let l_JavaHelp = TrimString(l_JavaHelp)

	"echo "DEBUG-- After trim l_JavaHelp = #" . l_JavaHelp . "#"

	if l_JavaHelp != ""
		return l_JavaHelp . " "
	else
		return ""
	endif
endf

function! RemoveNewLine(input)
	"Convert any non printable characters from the string to white spaces.
	let output= substitute(a:input,"[^[:graph:]]"," ","g")
	" Remove extra white spaces at the end of the string.
	let output= substitute(output,"  *"," ","g")
	return output
endf


function! TrimString(input)
	let output= substitute(a:input,"^[^[:graph:]]*","","")
	let output= substitute(output,"[^[:graph:]]*$","","")
	return output
endf

"This function gives the User Options to Open a perticular javaDoc HTML file.
"e.g. if the Class is Date, then the function will give two options 
"1) java.sql.Date 2) java.util.Date
"Also for files such as java.naming.Context which are found in both J2EE and
"J2SDK documents the function will give two options.
"l_JavaHelp is a space seperated list of multiple files.
function! OpenMultipleFiles(l_JavaHelp)
	"echo "DEBUG-- l_JavaHelp = " a:l_JavaHelp
	
	"local counter
	let l_cnt = 0
	"Add extra space in the end for stridx() function to work correctly.
	let l_tmp_var= a:l_JavaHelp . " "
	
	" Get the index of first white space.
	let l_idx = stridx(l_tmp_var," ")
	"echo " DEBUG-- l_idx = " .l_idx
	let l_conf_Msg = ""

	"This while loop acts as a string tokenizer.
	while l_idx != -1
		let l_cnt=l_cnt+1

		"Get the file name, starting from current position to next space.
		"Assign this file name to a local variable l_File_<N> where <N> is
		"the file no.
		"e.g. if l_JavaHelp = "abc qwe" then l_File_1 = abc and l_File_2 = qwe
		let l_tmp  = strpart(l_tmp_var,0,l_idx) 
		"echo " DEBUG-- l_tmp = " . l_tmp
		
		" l_fullClassName_<cnt> stores the fully qualified classname
		" while l_File_<cnt> stores the Name of HTML file corrosponding to the
		" Class.
		let l_cnam_idx = stridx(l_tmp,":")
		exec "let l_fullClassName_" . l_cnt . " = strpart(l_tmp,0,l_cnam_idx) "
		exec "let l_File_" . l_cnt . " = strpart(l_tmp,l_cnam_idx+1) "

		"Convert the Array Variables into temp. variables.
		exec "let l_tmpFname = l_File_" . l_cnt
		exec "let l_cFullName = l_fullClassName_" . l_cnt
		
		"If the file does exists and is readable then add it to the options.
		if filereadable(l_tmpFname)
			let l_conf_Msg = l_conf_Msg . "&" . l_cnt . " " . l_cFullName ."\n"
		else
			let l_cnt=l_cnt-1
		endif

		"Move the string pointer to next white space.
		let l_tmp_var = strpart(l_tmp_var,l_idx+1)
		"echo "DEBUG-- l_tmp_var = " . l_tmp_var
		let l_idx = stridx(l_tmp_var," ")
		"echo " DEBUG-- l_idx = " . l_idx
	endw


	"If only One file is found then Open it.
	if l_cnt == 1
		call OpenInBrowser(l_File_1)
	" else if more than One files are found present Options to user and Open
	" the file selected.
	else
		let l_conf_Msg = TrimString(l_conf_Msg) 
		if l_conf_Msg != ""
			"echo "DEBUG-- l_conf_Msg = " . l_conf_Msg
			let l_choice = confirm("Choose for one of the below Files :\n",l_conf_Msg,"1")
			if l_choice > 0 && l_choice <= l_cnt
				exec "let l_tmp_FileName = l_File_" . l_choice
				echo " l_tmp_FileName = " . l_tmp_FileName
				call OpenInBrowser(l_tmp_FileName)
			endif
		endif
	endif
endf

"Opens the URL in either NETSCAPE if g:open_IN_Netscape is set else
"opens in links.
"This function can be easyly extended to accomodate other GUI browsers
"such as mozilla or text-based browsers such as lynx or elinks etc.
function! OpenInBrowser(URL)
	if exists('g:open_IN_Netscape')
		call OpenInNetscape(a:URL)
	else
		call OpenInLinks(a:URL)
	endif
endf

"This function opens the given URL in Netscape.
function! OpenInNetscape(URL)
	"echo "1 = " 
	let URL = GetFullPathName(a:URL)
	echo "URL = " . URL
	
	"Check if this function has already been run at least once and that
	"g:Netscape_Instance_ID has been determined. The variable
	"g:Netscape_Instance_ID stores the instance ID of the netscape window
	"which is already being used to display the JAVADOC help.
	if exists('g:Netscape_Instance_ID')
		let l_tmpID = g:Netscape_Instance_ID
		"Open the javaDoc URL in the same window as used before. and redirect
		"the stdout and stderr to a temp file.
		exec "silent !netscape  -remote 'openURL(file://" . URL . ")'  >&/tmp/vimNets123"
		"Check for some typical errors.
		let l_err_0 = TrimString(system("grep -i BadWindow /tmp/vimNets123"))
		let l_err_1 = TrimString(system("grep -i \"no such window\" /tmp/vimNets123"))
		let l_err_2 = TrimString(system("grep -i invalid /tmp/vimNets123"))
		"If any errors then unlet the instance ID so that we can open the URL
		"in a new window.
		if l_err_0 != "" || l_err_1 != 0 || l_err_2 != ""
			unlet g:Netscape_Instance_ID
			"Call the same function again. except this time since
			"g:Netscape_Instance_ID is unlet, a new Netscape window will be
			"opened.
			call OpenInNetscape(URL)
		endif
	else
		"else if no previous window was showing javaDoc, then open a new one.
		exec "silent !netscape -remote 'openURL(file://" . URL . ", new-window)' >&/tmp/vimNets123"
		" If error, see if netscape was running or Not.
		let l_err = TrimString(system("grep \"not running\" /tmp/vimNets123"))
		if l_err != ""
			echo "l_err = #" . l_err . "#"
			echo "Error while Running Netscape : Probable Cause Netscape Not Running "
			return
		endif	
		"Now determine the instance ID of the newly Opened window, we will use
		"this instanceID next time.
		"This makes use of the xlswin command and the fact that the Netscape
		"window which has the documentation open has a Title starting with
		"the string "Netscape: Java 2 Platform SE". If some other javaDoc
		"produces a different Title then the grep command has to search for
		"all possible titles of diff. JavaDocs.
		 let g:Netscape_Instance_ID = system("xlswins -l | grep \"Java 2 Platform SE \" | sed -e 's/[   ][      ]*/ /g' | cut -d \" \" -f2")
		let g:Netscape_Instance_ID = TrimString(g:Netscape_Instance_ID)
		"echo "#" g:Netscape_Instance_ID "#"

		"IF no window is found, search for another pattern of window title
		"'Netscape: Generated Documentation'. This is the title of mostly for
		"javadocs generated using the javadoc command.
		if g:Netscape_Instance_ID == ""
		   let g:Netscape_Instance_ID = system("xlswins -l | grep \"Generated Documentation \" | sed -e 's/  */ /g' | cut -d \" \" -f2")
		   let g:Netscape_Instance_ID = TrimString(g:Netscape_Instance_ID)
		   if g:Netscape_Instance_ID == ""
			 unlet g:Netscape_Instance_ID
		   endif
		endif
	endif
	exec "silent !rm -rf /tmp/vimNets123"
endf

function! OpenInLinks(URL)
	exec "silent !links " . a:URL
endf

