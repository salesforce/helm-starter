#!/bin/bash
# Copyright (c) 2018, salesforce.com, inc.
# All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause
# For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause

set -e

usage() {
cat << EOF
Fetch, list, and delete helm starters from github.

Available Commands:
    helm starter fetch GITURL       Install a bare Helm starter from Github (e.g git clone)
    helm starter list               List installed Helm starters
    helm starter delete NAME        Delete an installed Helm starter
    --help                          Display this text
EOF
}

# Create the passthru array
PASSTHRU=()
while [[ $# -gt 0 ]]
do
key="$1"

# Parse arguments
case $key in
    --help)
    HELP=TRUE
    shift # past argument
    ;;
    *)    # unknown option
    PASSTHRU+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

# Restore PASSTHRU parameters
set -- "${PASSTHRU[@]}" 

# Show help if flagged
if [ "$HELP" == "TRUE" ]; then
    usage
    exit 0
fi

# COMMAND must be either 'fetch', 'list', or 'delete'
COMMAND=${PASSTHRU[0]}

if [ "$COMMAND" == "fetch" ]; then
    REPO=${PASSTHRU[1]}
    mkdir -p ${HELM_DATA_HOME}/starters
    cd ${HELM_DATA_HOME}/starters
    git clone ${REPO} --quiet
    cd $OLDPWD
    exit 0
elif [ "$COMMAND" == "list" ]; then
    ls -A1 ${HELM_DATA_HOME}/starters
    exit 0
elif [ "$COMMAND" == "delete" ]; then 
    STARTER=${PASSTHRU[1]}
    rm -rf ${HELM_DATA_HOME}/starters/${STARTER}
    exit 0
else
    echo "Error: Invalid command, must be one of 'fetch', 'list', or 'delete'"
    usage
    exit 1
fi
