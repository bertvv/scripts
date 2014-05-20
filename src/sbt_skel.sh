#!/bin/bash
#
# Created:  Wed 13 Oct 2010 09:30:27 AM CEST
# Modified: Wed 13 Oct 2010 10:02:46 AM CEST
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#

#-------------------------------------------------------------------------
# Definitions 
#-------------------------------------------------------------------------

#---------- Default values of options ------------------------------------
SUBPROJECT=
DIR=${PWD}
ORGANIZATION="CoMo - VUB"

if [[ -z ${SCALA_HOME} ]]; then
    SCALA_HOME=/opt/scala
fi

#---------- Print Usage message ------------------------------------------

usage()
{
cat << _EOF_
Usage: ${0} [OPTIONS]... NAME

Create an sbt project skeleton in the current directory.

OPTIONS:
  -s      this is a subproject
  -d DIR  the parent directory for the project

NAME: the name of the project (directory)

More info:
http://www.decodified.com/scala/2010/10/12/an-integrated-sbt-%2B-idea-scala-dev-setup.html
_EOF_
}

#---------- Create a subproject skeleton ---------------------------------
subproject()
{
    mkdir -p ${PRJ_ROOT}/src/{main,test}/{resources,scala}
    mkdir -p ${PRJ_ROOT}/lib
cat << _EOF_
Add the following to ${PRJ_ROOT}/../project/build/Project.scala:

  lazy val ${NAME} = project("${NAME}", "${NAME}", new ${NAME}Project(_))
  class ${NAME}Project(info: ProjectInfo) extends DefaultProject(info) {
    // val dependsOn[...] = [...]
  }
_EOF_
}

#---------- Create a main project skeleton -------------------------------
project()
{
    mkdir -p ${PRJ_ROOT}/lib/scala
    mkdir -p ${PRJ_ROOT}/project/{build,plugins}

cat > ${PRJ_ROOT}/project/build/Project.scala << _EOF_
import sbt._
class Project(info: ProjectInfo) extends ParentProject(info) {

}
_EOF_

cat > ${PRJ_ROOT}/project/plugins/Plugins.scala << _EOF_
import sbt._
class Plugins(info: ProjectInfo) extends PluginDefinition(info) {
  // plugin definitions/dependencies go here
}
_EOF_

cat > ${PRJ_ROOT}/project/build.properties << _EOF_
project.organization=${ORGANIZATION}
project.name=${NAME}
sbt.version=0.7.4
project.version=0.1
build.scala.versions=2.8.0
project.initialize=false
_EOF_


cp ${SCALA_HOME}/lib/scala-compiler.jar ${PRJ_ROOT}/lib/scala || echo "scala-compiler.jar not found, will not be copied"
cp ${SCALA_HOME}/lib/scala-library.jar ${PRJ_ROOT}/lib/scala || echo "scala-library.jar not found, will not be copied"
cp ${SCALA_HOME}/src/scala-library-src.jar ${PRJ_ROOT}/lib/scala || echo "scala-library-src.jar not found, will not be copied"
}

#-------------------------------------------------------------------------
# Command line argument parsing 
#-------------------------------------------------------------------------
# Options:
while getopts "d:s" flag; do
    case $flag in
        d)
            DIR=${OPTARG}
            ;;
        s)
            SUBPROJECT="1"
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done

# Argument
shift $(($OPTIND - 1))
if [[ "$#" -ne "1" ]]; then
   echo "Expected one argument, NAME, but got $#"
   usage
   exit 1
fi

NAME="$1"
PRJ_ROOT=${DIR}/${NAME}

#-------------------------------------------------------------------------
# Script proper
#-------------------------------------------------------------------------

if [[ -z "$SUBPROJECT" ]]; then
    project
else
    subproject
fi

