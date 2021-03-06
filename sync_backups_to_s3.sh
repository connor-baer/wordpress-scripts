#!/bin/bash

# Sync Backups to S3
#
# Sync local backups to an Amazon S3 bucket
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
        echo "File ${DIR}/${INCLUDE_FILE} is missing, aborting."
        exit 1
    fi
done

# Make sure the local assets directory exists
if [[ ! -d "${LOCAL_BACKUPS_PATH}" ]] ; then
    echo "Creating asset directory ${LOCAL_BACKUPS_PATH}"
    mkdir -p "${LOCAL_BACKUPS_PATH}"
fi

# Sync the local backups to the Amazon S3 bucket
aws s3 sync ${LOCAL_BACKUPS_PATH} s3://${REMOTE_S3_BUCKET}
echo "*** Synced backups to ${REMOTE_S3_BUCKET}"

# Normal exit
exit 0
