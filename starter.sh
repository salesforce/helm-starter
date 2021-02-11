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
    helm starter update NAME        Refresh an installed Helm starter
    helm starter delete NAME        Delete an installed Helm starter
    helm starter inspect NAME       Print out a starter's readme
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
    cd ${HELM_PATH_STARTER}
    git clone ${REPO} --quiet
    exit 0
elif [ "$COMMAND" == "update" ]; then
    STARTER=${PASSTHRU[1]}
    cd ${HELM_PATH_STARTER}/${STARTER}
    git pull origin master --quiet
    exit 0
elif [ "$COMMAND" == "list" ]; then
    ls -A1 ${HELM_PATH_STARTER}
    exit 0
elif [ "$COMMAND" == "delete" ]; then 
    STARTER=${PASSTHRU[1]}
    rm -rf ${HELM_PATH_STARTER}/${STARTER}
    exit 0
elif [ "$COMMAND" == "inspect" ]; then 
    STARTER=${PASSTHRU[1]}
    find ${HELM_PATH_STARTER}/${STARTER} -type f -iname "*readme*" -exec cat {} \;
    exit 0
else
    echo "Error: Invalid command."
    usage
    exit 1
fi