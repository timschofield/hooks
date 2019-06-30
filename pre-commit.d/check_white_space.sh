#!/bin/sh

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
	if [ $ext != "css" ]
	then
		echo -e "\tpre-commit: The file '$line' is not a css script so do not mess with the tabs"
		continue # continue onto the next file
	fi

	echo -e "\tpre-commit: Remove tabs from the css file"

	$(sed -i -e 's/	//g' $line > /dev/null 2>&1)
	if [ $? -ne 0 ]
	then
		# There was a problem removing the tab character
		echo -e "\tpre-commit: There was a problem removing the tab character in file "$line
		exit 1
	fi
done

# Check if this is the initial commit
if git rev-parse --verify HEAD >/dev/null 2>&1
then
echo "\tpre-commit: About to create a new commit..."
against=HEAD
else
echo -e "\tpre-commit: About to create the first commit..."
against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi
# Use git diff-index to check for whitespace errors
echo "\tpre-commit: Testing for whitespace errors..."
if ! git diff-index --check --cached $against
then
echo "\tpre-commit: Aborting commit due to whitespace errors"
exit 1
else
echo "\tpre-commit: No whitespace errors :)"
exit 0
fi
