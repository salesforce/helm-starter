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
    helm starter fetch GITURL [VERSION]   Install a bare Helm starter from Github (e.g git clone)
					  Optionally specify a version (e.g. a git tag)
    helm starter list                     List installed Helm starters
    helm starter update NAME [VERSION]    Refresh an installed Helm starter
                                          Optionally specify a version (e.g. a git tag)
    helm starter delete NAME              Delete an installed Helm starter
    helm starter inspect NAME             Print out a starter's readme
    --help                                Display this text
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

# Create the /starters directory, if needed
mkdir -p ${HELM_DATA_HOME}/starters

if [ "$COMMAND" == "fetch" ]; then
    REPO=${PASSTHRU[1]}
    VERSION=${PASSTHRU[2]}
    cd ${HELM_DATA_HOME}/starters
    if [ -z "$VERSION" ]; then
        git clone ${REPO} --quiet
    else
        git -c advice.detachedHead=false clone ${REPO} --quiet --branch ${VERSION}
    fi
    exit 0
elif [ "$COMMAND" == "update" ]; then
    STARTER=${PASSTHRU[1]}
    VERSION=${PASSTHRU[2]:-"HEAD"}
    cd ${HELM_DATA_HOME}/starters/${STARTER}
    git pull origin $(git rev-parse --abbrev-ref HEAD) --quiet
    git checkout ${VERSION} --quiet
    exit 0
elif [ "$COMMAND" == "list" ]; then
    cd ${HELM_DATA_HOME}/starters
    printf "%-20s   %-10s\n" NAME VERSION
    for STARTER in *; do
	if [ -d "$STARTER" ]; then
	    cd ${HELM_DATA_HOME}/starters/${STARTER}
	    VERSION=$(git describe --tags)
	    printf "%-20s   %-10s\n" ${STARTER} ${VERSION}
	fi
    done
    exit 0
elif [ "$COMMAND" == "delete" ]; then 
    STARTER=${PASSTHRU[1]}
    rm -rf ${HELM_DATA_HOME}/starters/${STARTER}
    exit 0
elif [ "$COMMAND" == "inspect" ]; then 
    STARTER=${PASSTHRU[1]}
    find ${HELM_DATA_HOME}/starters/${STARTER} -type f -iname "*readme*" -exec cat {} \;
    exit 0
else
    echo "Error: Invalid command."
    usage
    exit 1
fi
