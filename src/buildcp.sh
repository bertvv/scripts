#! /bin/bash
#
# buildcp -- builds a classpath with all jars in the specified directories.
#
# Author: Bert Van Vreckem, 2002, 2012

# These are the directories searched by default.
DEFAULT_DIRS=/usr/share/java

# These directories or jars are always added.
CP=.

# These are de directories to be searched.
DIRS=

function helpmessage() {
cat << EOF
Usage: ${0} [DIR]...
Build a \$CLASSPATH variable containing all the .jar files in the
specified directories recursively.
EOF
}

case ${1} in
    "")
        # Search the default dir
        DIRS="${DEFAULT_DIRS}";;
    "-h" | "--help" | "-?")
        # Print a help message
        helpmessage
        exit 0;;
    *)
        # Search the specified directories
        DIRS="$@";;
esac

for d in ${DIRS}; do
    if [[ -d ${d} ]]; then
        CP=${CP}:$(find ${d} -type f -name *.jar | xargs | tr ' ' ':')
    fi
done

echo $CP
