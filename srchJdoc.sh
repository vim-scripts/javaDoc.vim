grep  -s \/$1 $2 | awk -F \" '{print $2":"u"\/"$2}' u=$3
