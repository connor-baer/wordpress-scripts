#!/bin/bash

# Pull Assets
#
# Pull remote assets down from a remote to local
#
# @author    Connor Bär
# @copyright Copyright (c) 2017 Connor Bär
# @link      https://madebyconnor.co/
# @package   wordpress-scripts
# @since     1.0.0
# @license   MIT

# Get the directory of the currently executing script
DIR="$(dirname "${BASH_SOURCE[0]}")"

# Include files
INCLUDE_FILES=(
            "common/defaults.sh"
            ".env.sh"
            "common/common_env.sh"
            )
for INCLUDE_FILE in "${INCLUDE_FILES[@]}"
do
    if [ -f "${DIR}/${INCLUDE_FILE}" ]
    then
        source "${DIR}/${INCLUDE_FILE}"
    else
        echo 'File "${DIR}/${INCLUDE_FILE}" is missing, aborting.'
        exit 1
    fi
done

# Make sure the local assets directory exists
if [[ ! -d "${LOCAL_ASSETS_PATH}" ]] ; then
    echo "Creating asset directory ${LOCAL_ASSETS_PATH}"
    mkdir -p "${LOCAL_ASSETS_PATH}"
fi

# Pull down the asset dir files via rsync
for DIR in "${LOCAL_ASSETS_DIRS[@]}"
do
    rsync -a -z -e "ssh -p ${REMOTE_SSH_PORT}" "${REMOTE_SSH_LOGIN}:${REMOTE_ASSETS_PATH}${DIR}" "${LOCAL_ASSETS_PATH}" --progress
    echo "*** Synced assets from ${REMOTE_ASSETS_PATH}${DIR}"
done

# Make sure the WordPress files directory exists
if [[ ! -d "${LOCAL_WP_FILES_PATH}" ]] ; then
    echo "Creating WordPress files directory ${LOCAL_WP_FILES_PATH}"
    mkdir -p "${LOCAL_WP_FILES_PATH}"
fi

# Normal exit
exit 0
