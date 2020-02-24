#!/bin/bash
# MerlinMake version 1.0.0 23-Feb-2019 15:12

# This script generates the command line required to use the proper version of merlin libraries both for
# compiling a project and for executing the project.  The command is then executed.

# The sole argument is either 'debug' or 'release' depending on configuration.
# If no argument is specified defaults to 'debug'.

# The file must either be named make.sh or use a symlink named run.sh
# The filename is then detected; make.sh will build while run.sh will run.

# Dynamic library dependencies are specified in the file 'dylib.manifest' located in the same directory
# as make.sh.
# There are two line formats:
# project version -OR-
# project LOCAL path
#
# The second format facilitates simple development of libraries by easily allowing a local directory
# as a source.

config=${1:-debug}
filename=$(basename -- "$0")
case $filename in
    "run.sh")
	mode="run";;
    "make.sh")
	mode="build";;
    *)
	# Terminate on error after message
	echo "Expected filename to be either 'make.sh' or 'run.sh'"
	exit 1;;
esac

if [[ ! "$config" =~ ^(debug|release)$ ]]; then
    echo "Unexpected configuration; must be either debug or release, not $config"
    exit 1
fi

# Requires: MERLIN_LIBRARY_ROOT_DIR (e.g. /usr/local/lib/merlin)
[ -z "$MERLIN_LIBRARY_ROOT_DIR" ] && { echo "MERLIN_LIBRARY_ROOT_DIR must be defined"; exit 1; }

# Reference: https://www.ostricher.com/2014/10/the-right-way-to-get-the-directory-of-a-bash-script/
get_script_dir () {
    source="${BASH_SOURCE[0]}"
    # While $source is a symlink, resolve it
    while [ -h "$source" ]; do
	dir="$( cd -P "$( dirname "$source" )" && pwd )"
	source="$( readlink "$source" )"
	# If $source was a relative symlink (so no "/" as prefix, need to resolve it relative to the symlink base directory
	[[ $source != /* ]] && source="$dir/$source"
    done
    dir="$( cd -P "$( dirname "$source" )" && pwd )"
    echo "$dir"
}

# Start with a basic command line and empty library path
commandLine="swift $mode -c $config"
LD_LIBRARY_PATH=""

# Read the manifest file
# If it exists, it must be in the format projectName tag
manifestPath="$(get_script_dir)/dylib.manifest"
if [ -f $manifestPath ]; then
    echo "Reading manifest at $manifestPath"

    while read line; do
	if [ ! -z "$line" ]; then
	    # If the line is not empty, it must be in the format specified
	    # The first case is specification of a library found in the MERLIN_LIBRARY_ROOT_DIR
	    # This format specifies only a library name and version
	    # e.g. "Igis 1.0.7"
	    libraryRegex='^([[:alpha:]]+)[[:space:]]+([[:alnum:]\.]+)$'

	    # An alterntive is specifying a local path which will be used directly
	    # iff the tag is 'LOCAL'
	    localRegex='^([[:alpha:]]+)[[:space:]]+LOCAL[[:space:]]+([[:alnum:]/-]+)$'
	    
	    if [[ "$line" =~ $localRegex ]]; then
		project=${BASH_REMATCH[1]}
		directory=${BASH_REMATCH[2]}
		echo "Requires LOCAL $project @ LOCAL from $directory"

		# The library path is determined by the exact name used for the directory
		libraryPath="$directory/.build/$config"
            elif [[ "$line" =~ $libraryRegex ]]; then
		project=${BASH_REMATCH[1]}
		tag=${BASH_REMATCH[2]}
		echo "Requires LIBRARY $project @ $tag"

		# Determine the library path based on the name of the project and tag
		libraryPath="$MERLIN_LIBRARY_ROOT_DIR/$project-$tag/$project/.build/$config"
	    else
		echo "Unexpected line format: $line"
		exit 1
	    fi

	    # Verify that the libraryPath exists
  	    if [[ ! -d "$libraryPath" ]]; then
		echo "The specified library path was not found '$libraryPath'"
		exit 1
	    fi

	    # Build the command line by appending the library for inclusion and linking
	    commandLine="$commandLine -Xswiftc -I -Xswiftc $libraryPath"
	    commandLine="$commandLine -Xswiftc -L -Xswiftc $libraryPath"
	    commandLine="$commandLine -Xswiftc -l$project"
	    
	    # Build the LD_LIBRARY_PATH
	    LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$libraryPath"
	fi 
    done < "$manifestPath"

else
    echo "No manifest found at $manifestPath"
fi

# Whether or not there was a manifest, we evaluate the command line
eval "$commandLine"
echo "Done"
