#!/bin/bash
#
# Created:  Wed 16 Jun 2010 02:42:02 PM CEST
# Modified: Tue 12 Oct 2010 11:58:16 AM CEST
# Author:   Bert Van Vreckem <Bert.Van.Vreckem@gmail.com>
#
# Launch sbt, simple build tool. 
# See http://code.google.com/p/simple-build-tool/

SBT_HOME="${HOME}/Apps/sbt"
SBT_VERSION="0.7.4"
SBT_JAR="${SBT_HOME}/sbt-launch-${SBT_VERSION}.jar"

if [[ -z $SCALA_HOME && -d /opt/scala ]]; then
    export SCALA_HOME=/opt/scala
fi

if [[ ! -f "${SBT_JAR}" ]]; then
    echo "Sbt jar not found, expected at: ${SBT_JAR}" >&2
fi

java -Xmx512M -jar "${SBT_JAR}" "$@"

