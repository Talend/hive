#!/bin/bash
#
# This script (pre_commit_hook.sh) is executed by hive-gerrit jenkins job
# located at http://unittest.jenkins.cloudera.com/view/gerrit
#
# This script is called from inside the Hive source code directory, and it
# should be used to build and test the current Hive patched code.
#
# hive-gerrit has its own username and home directory in the Jenkins machine

# -e will make the script exit if an error happens on any command executed
set -ex

# Script created by Cloudcat with useful environment information
[ -f /opt/toolchain/toolchain.sh ] && . /opt/toolchain/toolchain.sh

# Use JAVA8_HOME if exists
export JAVA_HOME=${JAVA8_HOME:-$JAVA_HOME}

# If JDK_VERSION exists, then try to get the value from JAVAX_HOME
if [ -n "$JDK_VERSION" ]; then
  # Get JAVAX_HOME value, where X is the JDK version
  java_home=`eval echo \\$JAVA${JDK_VERSION}_HOME`
  if [ -n "$java_home" ]; then
    export JAVA_HOME="$java_home"
  else
    echo "ERROR: USE_JDK_VERSION=$JDK_VERSION, but JAVA${JDK_VERSION}_HOME is not found."
    exit 1
  fi
fi

export PATH=${JAVA_HOME}/bin:${PATH}

# activate mvn-gbn wrapper
mv "$(which mvn-gbn-wrapper)" "$(dirname "$(which mvn-gbn-wrapper)")/mvn"

# WORKSPACE is an environment variable created by Jenkins, and it is the directory where the build is executed.
# If not set, then default to $HOME
MVN_REPO_LOCAL=`readlink -f ${WORKSPACE:-$HOME}`/.m2/repository

# Add any test to be excluded in alphabetical order to keep readability, starting with files, and
# then directories.
declare -a EXCLUDE_TESTS=(
  ".*org/apache/hadoop/hive/ql/exec/.*"
  ".*org/apache/hadoop/hive/ql/io/orc/.*"
  ".*org/apache/hadoop/hive/ql/parse/TestParseNegative"
  ".*org/apache/hadoop/hive/ql/security/.*"
  ".*org/apache/hive/hcatalog/mapreduce/.*"
  ".*org/apache/hive/hcatalog/pig/.*"
  ".*org/apache/hive/jdbc/.*"
)

function get_excluded_tests() {
  local IFS="|"
  echo -n "${EXCLUDE_TESTS[*]}"
}

function get_regex_excluded_tests() {
  echo -n "%regex[`get_excluded_tests`]"
}

# For pre-commit, we just look for qtests edited in the last commit
function get_qtests_to_execute() {
  git diff --name-only --diff-filter=ACMRT HEAD~1 | grep ".q$\|.q.out$" | paste -s -d"," -
}

regex_tests=`get_regex_excluded_tests`
mvn clean install -Dmaven.repo.local="$MVN_REPO_LOCAL" -Dtest.excludes.additional="$regex_tests"
cd itests/
rm -f thirdparty/spark-latest.tar.gz
mvn clean install -Dmaven.repo.local="$MVN_REPO_LOCAL" -DskipTests

# Execute .q tests that were modified in the patch
tests_modified=`get_qtests_to_execute`
if [ -n "$tests_modified" ]; then
  driver_classes=`find .. -name Test*Driver.java | grep -Evi "llap|tez" | paste -s -d"," -`
  tests=`python ../cloudera/qtest-driver-info.py --hadoopVersion "hadoop-23" --properties ../itests/src/test/resources/testconfiguration.properties --cliConfigsPath ../itests/util/src/main/java/org/apache/hadoop/hive/cli/control/CliConfigs.java --paths $tests_modified --driverClassPaths $driver_classes`
  for t in $tests
  do
    driver=`echo $t | cut -d: -f1`
    files=`echo $t | cut -d: -f2`

    mvn test -Phadoop-2 -Dmaven.repo.local="$MVN_REPO_LOCAL" -Dtest=$driver -Dqfile=$files
  done
fi
