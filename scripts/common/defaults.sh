# WordPress Scripts Defaults
#
# Default settings for WordPress scripts
#
# @author    Connor Bär
# @copyright Copyright (c) 2017 Connor Bär
# @link      https://madebyconnor.co/
# @package   wordpress-scripts
# @since     1.0.0
# @license   MIT

# -- GLOBAL settings --

# What to prefix the database table names with
GLOBAL_DB_TABLE_PREFIX="wp_"

# The path of the `wp-admin` folder, relative to the root path; paths should always have a trailing /
GLOBAL_WP_PATH="wp-admin/"

# The path of the `wp-content` folder, relative to the root path; paths should always have a trailing /
GLOBAL_ASSETS_PATH="wp-content/"

# The maximum age of backups in days; backups older than this will be automatically removed
GLOBAL_DB_BACKUPS_MAX_AGE=90

# -- LOCAL settings --

# Local path constants; paths should always have a trailing /
LOCAL_ROOT_PATH="REPLACE_ME"
LOCAL_PROJECT_PATH="REPLACE_ME"
LOCAL_ASSETS_PATH=${LOCAL_ROOT_PATH}${GLOBAL_ASSETS_PATH}

# Local user & group that should own the WordPress install
LOCAL_CHOWN_USER="admin"
LOCAL_CHOWN_GROUP="apache"

# Local asset directories relative to LOCAL_ASSETS_PATH that should be writeable by the $CHOWN_GROUP and that should be synched with remote assets
LOCAL_ASSETS_DIRS=(
                "plugins"
                "themes"
                "uploads"
                )

# Local database constants
LOCAL_DB_NAME="REPLACE_ME"
LOCAL_DB_PASSWORD="REPLACE_ME"
LOCAL_DB_USER="REPLACE_ME"
LOCAL_DB_HOST="localhost"
LOCAL_DB_PORT="3306"

# If you are using mysql 5.6.10 or later and you have `login-path` setup as per:
# https://opensourcedbms.com/dbms/passwordless-authentication-using-mysql_config_editor-with-mysql-5-6/
# you can use it instead of the above LOCAL_DB_* constants; otherwise leave this blank
LOCAL_DB_LOGIN_PATH=""

# The `mysql` and `mysqldump` commands to run locally
LOCAL_MYSQL_CMD="mysql"
LOCAL_MYSQLDUMP_CMD="mysqldump"

# Local backups path; paths should always have a trailing /
LOCAL_BACKUPS_PATH="REPLACE_ME"

# Local site url
LOCAL_SITE_URL="REPLACE_ME"

# -- REMOTE settings --

# Remote ssh credentials, user@domain.com and Remote SSH Port
REMOTE_SSH_LOGIN="REPLACE_ME"
REMOTE_SSH_PORT="22"

# Remote path constants; paths should always have a trailing /
REMOTE_ROOT_PATH="REPLACE_ME"
REMOTE_ASSETS_PATH=${REMOTE_ROOT_PATH}${GLOBAL_ASSETS_PATH}

# Remote database constants
REMOTE_DB_NAME="REPLACE_ME"
REMOTE_DB_PASSWORD="REPLACE_ME"
REMOTE_DB_USER="REPLACE_ME"
REMOTE_DB_HOST="localhost"
REMOTE_DB_PORT="3306"

# If you are using mysql 5.6.10 or later and you have `login-path` setup as per:
# https://opensourcedbms.com/dbms/passwordless-authentication-using-mysql_config_editor-with-mysql-5-6/
# you can use it instead of the above REMOTE_DB_* constants; otherwise leave this blank
REMOTE_DB_LOGIN_PATH=""

# The `mysql` and `mysqldump` commands to run remotely
REMOTE_MYSQL_CMD="mysql"
REMOTE_MYSQLDUMP_CMD="mysqldump"

# Remote backups path; paths should always have a trailing /
REMOTE_BACKUPS_PATH="REPLACE_ME"

# Remote Amazon S3 bucket name
REMOTE_S3_BUCKET="REPLACE_ME"

# Remote Dropbox path; paths should always have a trailing /
REMOTE_DROPBOX_PATH="REPLACE_ME"
