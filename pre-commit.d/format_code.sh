#!/bin/bash

# get a list of staged files and iterate throgh them placing each filename in the $line variable
for line in $(git diff-index --cached --full-index HEAD | cut -d' ' -f5 | cut -c 3-)
do

	# Get the status of the file
	status=$(git status | grep $line  | cut -d' ' -f1)
	if [ $status == 'deleted:' ]
	then
		echo 'pre-commit: The file '$line' is being deleted so dont try to format it'
		continue
	fi

	# extract the file extension from the file name
	ext=$(echo $line | sed 's/^.*\.//')

	# only check files with php extension
	if [ $ext != "php" ]
	then
		echo 'pre-commit: The file '$line' is not a PHP script so do not format it'
		continue # continue onto the next file
	fi

	# format the code using php beautifier and save the formatted code in ~/temp.php
	result=$(~/code/KwaMoja/.git/hooks/pre-commit.d/bin/format.phps $line > ~/temp.php)

	if [ $? -ne 0 ]
	then
		# There was a problem and format.phps returned a non zero value
		echo 'pre-commit: There was a problem formatting the code in '$line
		exit 1
	fi

	# Move the re-formatted code from ~/temp.php to overwrite the original code
	mv ~/temp.php ~/code/KwaMoja/$line
	if [ $? -ne 0 ]
	then
		# There was a problem moving the file returned a non zero value
		echo 'pre-commit: There was a problem moving '$line' back to its original location'
		exit 1
	fi

	# Re-stage the file with git, as any changes in the formatting will not be staged
	git add $line
	if [ $? -ne 0 ]
	then
		# There was a problem staging the file returned a non zero value
		echo 'pre-commit: There was a problem staging '$line
		exit 1
	fi

	# The formatting was successful so return a zero value
	echo -e '\tpre-commit: '$line' has been formatted'
done
exit 0
