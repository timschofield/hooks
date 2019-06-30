#!/bin/bash
#
# Check for PHP syntax errors before doing actual commit
#
# Contributers:
#       Remigijus Jarmalavičius <remigijus@jarmalavicius.lt>
#       Vytautas Povilaitis <php-checker@vytux.lt>
#       William Clemens <http://github.com/wesclemens>
#       Dave Barnwell <https://github.com/freshsauce>
#
#
# Git Config Options
#       linter.php.silent : (type: boolean) Suppresses all messages that are not linter errors.
#

IFS=$'\n\t'
ERROR_FOUND=false
RED=
NC=
SILENT_MODE=$(git config --get linter.php.silent || echo false)
REPO_ROOT=$(git rev-parse --show-toplevel)

function changed_php_files {
	git diff --cached --name-only --diff-filter=ACMR | grep ".php$"
}

function php_lint {
	git show :$1 | php --syntax-check 2>&1 | grep "Parse error" | sed -e "s|file in - on line|file in $REPO_ROOT/$1 on line|"
}

function xdebug_grep {
	git show :$1 | grep -nH xdebug_ | sed -e "s|^(standard input)|PHP XDebug Statment: $REPO_ROOT/$1|"
}

function print_error {
	local l_file=$REPO_ROOT/$1
	shift

	if ! $ERROR_FOUND; then
		echo -e "Found PHP parse errors:\n "
	fi

	echo $@ | sed -e "s|${l_file}|${RED}${l_file}${NC}|g"

	ERROR_FOUND=true
}

function print_mesg {
	if ! $SILENT_MODE
	then
		echo -e "\tpre-commit: "$@
	fi
}

function main {
	local errors=

	if ! command -v php >/dev/null 2>&1
	then
		print_mesg "PHP-cli not installed. PHP lint checks will be skipped."
		exit 0;
	fi


	case "$(git config --get color.ui)" in
	  "auto" | "always")
		  RED=$(git config --get-color color.interactive.error  1)
		  NC=$'\033[0m'
		  ;;
	  *)
		  RED=
		  NC=
		  ;;
	esac

	for file in $(changed_php_files)
	do
		echo $file
		errors=$(php_lint $file; xdebug_grep $file)
		if [[ "$errors" ]]
		then
			print_error $file $errors
		fi
	done

	if $ERROR_FOUND
	then
		echo -e "\tPHP parse errors found. Fix errors and commit again."
		exit 1
	else
		print_mesg "No PHP parse errors found. PHP lint successfully."
	fi
}

main
