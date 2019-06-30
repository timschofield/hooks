#!/bin/bash

# get a list of staged files and iterate throgh them placing each filename in the $line variable
for line in $(git diff-index --cached --full-index HEAD | cut -d' ' -f5 | cut -c 3-)
do

	# Get the status of the file
	status=$(git status | grep $line  | cut -d' ' -f1)
	if [ $status = "deleted:" ]
	then
		echo "\tpre-commit: The file '$line' is being deleted so dont bother with it"
		continue
	fi

	# Get the status of the file
	status=$(git status | grep $line  | cut -d' ' -f1)
	if [ $status = "renamed:" ]
	then
		echo "\tpre-commit: The file '$line' is being renamed so dont bother with it"
		continue
	fi

	# extract the file extension from the file name
	ext=$(echo $line | sed 's/^.*\.//')

	# only check files with php extension
	if [ $ext != "php" ]
	then
		echo "\tpre-commit: The file '$line' is not a PHP script so do not mess with the line endings"
		continue # continue onto the next file
	fi

	echo -e "\tpre-commit: Convert any windows line endings to unix style"

	$(dos2unix $line > /dev/null 2>&1)
	if [ $? -ne 0 ]
	then
		# There was a problem moving the file returned a non zero value
		echo "\tpre-commit: There was a problem converting line endings in file "$line
		exit 1
	fi

	# Re-stage the file with git, as any changes in the line endings made above will not be staged
	$(git add $line > /dev/null 2>&1)
	if [ $? -ne 0 ]
	then
		# There was a problem staging the file returned a non zero value
		echo "\tpre-commit: There was a problem staging "$line
		exit 1
	fi

done
exit 0
