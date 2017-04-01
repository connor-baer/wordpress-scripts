#! /bin/bash

# Install WordPress
#
# Install WordPress, configure the database and harden file permissions
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
            "common/common_db.sh"
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

# The permissions for all files & directories in the WordPress install
GLOBAL_DIR_PERMS=755     # `-rwxr-xr-x`
GLOBAL_FILE_PERMS=644    # `-rw-r--r--`

# The permissions for files & directories that need to be writeable
WRITEABLE_DIR_PERMS=775  # `-rwxrwxr-x`
WRITEABLE_FILE_PERMS=664 # `-rw-rw-r--`

# Create the database.
echo "Creating database ${LOCAL_DB_NAME}..."

$LOCAL_MYSQL_CMD $LOCAL_DB_CREDS -e"CREATE DATABASE $LOCAL_DB_NAME"

# Download WP Core.
wp core download --path=${LOCAL_ROOT_PATH}

# Generate the wp-config.php file
wp core config --path=${LOCAL_ROOT_PATH} --dbname=${LOCAL_DB_NAME} --dbuser=${LOCAL_DB_USER} --dbpass=${LOCAL_DB_PASSWORD} --extra-php <<PHP
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', true);
define('WP_MEMORY_LIMIT', '256M');
PHP

# Install the WordPress database.
wp core install --path=${LOCAL_ROOT_PATH} --url=${LOCAL_SITE_URL} --title=${LOCAL_DB_NAME} --admin_user=connorbaer --admin_password=developer --admin_email=connor.baer@me.com

# Set project permissions
echo "Setting base permissions for the project ${LOCAL_ROOT_PATH}"
chown -R ${LOCAL_CHOWN_USER}:${LOCAL_CHOWN_GROUP} "${LOCAL_ROOT_PATH}"
chmod -R ${GLOBAL_DIR_PERMS} "${LOCAL_ROOT_PATH}"
find "${LOCAL_ROOT_PATH}" -type d -exec chmod $GLOBAL_DIR_PERMS {} \;
find "${LOCAL_ROOT_PATH}" -type f ! -name "*.sh" -exec chmod $GLOBAL_FILE_PERMS {} \;

for DIR in ${LOCAL_ASSETS_DIRS[@]}
    do
        FULLPATH=${LOCAL_ROOT_PATH}${DIR}
        if [ -d "${FULLPATH}" ]
        then
            echo "Fixing permissions for ${FULLPATH}"
            chmod -R $WRITEABLE_DIR_PERMS "${FULLPATH}"
            find "${FULLPATH}" -type f ! -name "*.sh" -exec chmod $WRITEABLE_FILE_PERMS {} \;
        else
            echo "Creating directory ${FULLPATH}"
            mkdir "${FULLPATH}"
            chmod -R $WRITEABLE_DIR_PERMS "${FULLPATH}"
        fi
    done

# Normal exit
exit 0
