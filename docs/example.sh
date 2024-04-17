#!/bin/sh
# Examples taken from the ShellCheck Gallery of bad code - https://github.com/koalaman/shellcheck#gallery-of-bad-code

# Quoting
# =======

echo $1                           # Unquoted variables
# rm "~/my file.txt"                # Quoted tilde expansion
# v='--verbose="true"'; cmd $v      # Literal quotes in variables
touch $@                          # Unquoted $@
echo 'Path is $PATH'              # Variables in single quotes
# trap "echo Took ${SECONDS}s" 0    # Prematurely expanded trap
unset var[i]                      # Array index treated as glob

# Conditionals
# ============

# [[ n != 0 ]]                      # Constant test expressions
# [[ -e *.mpg ]]                    # Existence checks of globs
# [[ $foo==0 ]]                     # Always true due to missing spaces
# [[ -n "$foo " ]]                  # Always true due to literals
# [[ $foo =~ "fo+" ]]               # Quoted regex in =~
# [ foo =~ re ]                     # Unsupported [ ] operators
# [ $1 -eq "shellcheck" ]           # Numerical comparison of strings
# [ $n && $m ]                      # && in [ .. ]
# [[ "$$file" == *.jpg ]]           # Comparisons that can't succeed
# (( 1 -lt 2 ))                     # Using test operators in ((..))
# [ x ] & [ y ] | [ z ]             # Accidental backgrounding and piping

# Frequently misused commands
# ===========================

# grep '*foo*' file                 # Globs in regex contexts
# find . -exec foo {} && bar {} \;  # Prematurely terminated find -exec
# sudo echo 'Var=42' > /etc/profile # Redirecting sudo
# time --format=%s sleep 10         # Passing time(1) flags to time builtin
# alias archive='mv $1 /backup'     # Defining aliases with arguments
# tr -cd '[a-zA-Z0-9]'              # [] around ranges in tr
# exec foo; echo "Done!"            # Misused 'exec'
# find -name \*.bak -o -name \*~ -delete  # Implicit precedence in find
# find . -exec foo > bar \;       # Redirections in find
# f() { whoami; }; sudo f           # External use of internal functions

# Common beginner's mistakes
# var = 42                          # Spaces around = in assignments
# $foo=42                           # $ in assignments
# var$n="Hello"                     # Wrong indirect assignment
# echo ${var$n}                     # Wrong indirect reference
# var=(1, 2, 3)                     # Comma separated arrays
# array=( [index] = value )         # Incorrect index initialization
# echo $var[14]                     # Missing {} in array references
# echo "Argument 10 is $10"         # Positional parameter misreference
# [ false ]                         # 'false' being true

# Style
# =====

# [[ -z $(find /tmp | grep mpg) ]]  # Use grep -q instead
# a >> log; b >> log; c >> log      # Use a redirection block instead
# echo "The time is `date`"         # Use $() instead
# cd dir; process *; cd ..;         # Use subshells instead
# echo $[1+2]                       # Use standard $((..)) instead of old $[]
# echo $(($RANDOM % 6))             # Don't use $ on variables in $((..))
# echo "$(date)"                    # Useless use of echo
# cat file | grep foo               # Useless use of cat

# Data and typing errors
# ======================

# args="$@"                         # Assigning arrays to strings
# files=(foo bar); echo "$files"    # Referencing arrays as strings
# declare -A arr=(foo bar)          # Associative arrays without index
# printf "%s\n" "Arguments: $@."    # Concatenating strings and arrays
# [[ $# > 2 ]]                      # Comparing numbers as strings
# var=World; echo "Hello " var      # Unused lowercase variables
# echo "Hello $name"                # Unassigned lowercase variables
# cmd | read bar; echo $bar         # Assignments in subshells
# cat foo | cp bar                  # Piping to commands that don't read
# printf '%s: %s\n' foo             # Mismatches in printf argument count
# eval "${array[@]}"                # Lost word boundaries in array eval

# Robustness
# ==========

# rm -rf "$STEAMROOT/"*            # Catastrophic rm
# touch ./-l; ls *                 # Globs that could become options
# find . -exec sh -c 'a && b {}' \; # Find -exec shell injection
# printf "Hello $name"             # Variables in printf format
# export MYVAR=$(cmd)              # Masked exit codes

# Portability
# ===========

# echo {1..$n}                     # Works in ksh, but not bash/dash/sh
# echo {1..10}                     # Works in ksh and bash, but not dash/sh
# echo -n 42                       # Works in ksh, bash and dash, undefined in sh
# expr match str regex             # Unportable alias for `expr str : regex`
# trap 'exit 42' sigint            # Unportable signal spec
# cmd &> file                      # Unportable redirection operator
# read foo < /dev/tcp/host/22      # Unportable intercepted files
# foo-bar() { ..; }                # Undefined/unsupported function name
# [ $UID = 0 ]                     # Variable undefined in dash/sh
# local var=value                  # local is undefined in sh
# time sleep 1 | sleep 5           # Undefined uses of 'time'

# Miscellaneous
# =============

# PS1='\e[0;32m\$\e[0m '            # PS1 colors not in \[..\]
# PATH="$PATH:~/bin"                # Literal tilde in $PATH
# rm “file”                         # Unicode quotes
# echo "Hello world"                # Carriage return / DOS line endings
# echo hello \                      # Trailing spaces after \
# var=42 echo $var                  # Expansion of inlined environment
# echo $((n/180*100))               # Unnecessary loss of precision
# ls *[:digit:].txt                 # Bad character class globs
# sed 's/foo/bar/' file > file      # Redirecting to input
# var2=$var2                        # Variable assigned to itself
# [ x$var = xval ]                  # Antiquated x-comparisons
# ls() { ls -l "$@"; }              # Infinitely recursive wrapper
