This script looks up javaDoc HTML help files for J2SE and J2EE api classes.
First of all I am not sure if there is already a utility to do this or not, so here is my version.
Secondly I wrote this script almost 2 years ago, before vir. 6, after that although I have kept it in working order, but I may not have used some of the features of ver 6.
Thirdly It is a bit complicated now, so read fully the instructions supplied in the file.

About the script.
First the script runs only on Unix boxes, Windows users are more that welcome to port it .
It uses several unix commands like ls, dirname, xlswins, grep , awk, etc, which should be preety much standard on any unix installation.
It also uses a shell script provided along with this package.
It is heavily commented and can be easily modified.
Please bear with me, this is only an initial version so , it may not work out-of-box for some of you.

What it does and what it doesn't
It opens javaDoc HTML file in an external browser from VIM.
It can open the HTML in either Netscape (Netscape 4.x, 6,7.x, Mozilla , Firebird ) or
a text browser such as lynx or links. Personally I prefer to open help in netscape when I am using gvim and in a text browser when I am using vim.
Currently It only supports looking up classes and not methods , or members.

How it works.
The cursor has to be placed on the class name whose name is to be looked up. i.e.
if your source is "Connection conn = null", The cursor will have to be on the word Connection, The script can't do a reverse mapping of variable name to class name and look-up help. i.e. you can't use the variable conn to look up help for connection.

The main function called is SearchForJHelp(), Currently I have not provided any mapping , and you are free to use mapping sequence of your choice.


Extract the provided .tar.gz file . Put the javaDoc.vim in your plugin directory of $VIMRUNTIME. and the included shell script in a convenient location. Make sure to give execute permissions to the shell script.

Now for stuff in your .vimrc file.
The script uses a trick to support several javaDoc locations, e.g. J2SE, J2EE, and any generated javadoc of your Code also.
First define a global variable g_no_of_ID_Files to unique locations of your javaDocs. e.g. If you have J2SE and J2EE Api javadocs, 
let g:no_of_ID_Files=2

The define the actual locations of these API's 
The file I use to look-up class name is allclasses-frame.html, So specify locations to the allclasses-frame.html for each javadoc. If you have javaDoc of thirdparty APIs or you own Code, make sure that the allclasses-frames.html is present in it.

e.g.
let g:javadoc_ID_File_1="/user/abcd/docs/javadoc/JDK/java/api/allclasses-frame.html"
let g:javadoc_ID_File_2="/user/abcd/docs/javadoc//J2EE/java/api/allclasses-frame.html"

Note the first variable g:no_of_ID_Files determines how many g:_javadoc_ID_File_<cnt> should be defined.

Lastly specify the location of the included shell script
let g:srchJdoc_loc="/user/abcd/softwares/usr/bin/srchJdoc.sh"

For your convinence I am giving a sample menu . One pop-up menu when using gvim and a normal menu when using vim.
menu PopUp.LookUpHelp :call SearchForJHelp()<CR>
nnoremap <leader>jd :call SearchForJHelp()<CR>

Also by default the script opens the help file in a text browser called links. So if you have links be sure to put it in your $PATH. 
If you want to open the help in Netscape instead.
Put 
let g:open_IN_Netscape=1
in your .vimrc.
