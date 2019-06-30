#!/bin/bash

# get a list of staged files and iterate throgh them placing each filename in the $line variable
for line in $(git diff-index --cached --full-index HEAD | cut -d' ' -f5 | cut -c 3-)
do

	# Get the status of the file
	status=$(git status | grep $line  | cut -d' ' -f1)
	if [ $status == 'deleted:' ]
	then
		echo -e "\tpre-commit: The file '$line' is being deleted so dont bother with it"
		continue
	fi

	# extract the file extension from the file name
	ext=$(echo $line | sed 's/^.*\.//')

	# only check files with php extension
	if [ $ext != "php" ]
	then
		echo -e "\tpre-commit: The file '$line' is not a PHP script so do not mess with the variable names"
		continue # continue onto the next file
	fi

	echo -e "\tpre-commit: Change variable names where they are all lower case"

	$(sed -i -e 's/$pdf/$PDF/g' $line > /dev/null 2>&1)
	if [ $? -ne 0 ]
	then
		# There was a problem moving the file returned a non zero value
		echo -e "\tpre-commit: There was a problem renaming the variable $pdf in file "$line
		exit 1
	fi

	$(sed -i -e 's/$sql/$SQL/g' $line > /dev/null 2>&1)
	if [ $? -ne 0 ]
	then
		# There was a problem moving the file returned a non zero value
		echo -e "\tpre-commit: There was a problem renaming the variable $sql in file "$line
		exit 1
	fi

	$(sed -i -e 's/$result/$Result/g' $line > /dev/null 2>&1)
	if [ $? -ne 0 ]
	then
		# There was a problem moving the file returned a non zero value
		echo -e "\tpre-commit: There was a problem renaming the variable $result in file "$line
		exit 1
	fi

	$(sed -i -e 's/$myrow/$MyRow/g' $line > /dev/null 2>&1)
	if [ $? -ne 0 ]
	then
		# There was a problem moving the file returned a non zero value
		echo -e "\tpre-commit: There was a problem renaming the variable $myrow in file "$line
		exit 1
	fi

	# Re-stage the file with git, as any changes in the variable names made above will not be staged
	$(git add $line > /dev/null 2>&1)
	if [ $? -ne 0 ]
	then
		# There was a problem staging the file returned a non zero value
		echo -e "\tpre-commit: There was a problem staging "$line
		exit 1
	fi

done
exit 0
