# wordpress-scripts
Shell scripts to install WordPress, manage database backups, asset backups, asset syncing, and database syncing between WordPress environments

## Overview

There are several scripts included in `wordpress-scripts`, each of which perform different functions. They all use a shared `.env.sh` to function. This `.env.sh` should be created on each environment where you wish to run the `wordpress-scripts`, and it should be excluded from your git repo via `.gitignore`.

### install_wp.sh

The `install_wp.sh` script installs and configures a fresh WordPress instance, including a new database. The script also sets the WordPress install file permissions in a strict manner, to assist in hardening WordPress installs.

All project variables are taken from the `.env.sh` file.

Note: if you use `git`, please see the **Permissions and Git** section below.

### pull_db.sh

The `pull_db.sh` script pulls down a database dump from a remote server, and then dumps it into your local database. It backs up your local database before doing the dump.

### pull_assets.sh

The `pull_assets.sh` script pulls down an arbitrary number of asset directories from a remote server, since we keep client-uploadable assets out of the git repo. The directories it will pull down are specified in `LOCAL_ASSETS_DIRS`

### pull_backups.sh

The `pull_backups.sh` script pulls down the backups created by `wordpress-scripts` from a remote server, and synced into the `LOCAL_BACKUPS_PATH`

For database backups, a sub-directory `REMOTE_DB_NAME/db` inside the `REMOTE_BACKUPS_PATH` directory is used for the database backups.

For asset backups, a sub-directory `REMOTE_DB_NAME/assets` inside the `REMOTE_BACKUPS_PATH` directory is used for the asset backups.

### sync_backups_to_s3.sh

The `sync_backups_to_s3.sh` script syncs the backups from `LOCAL_BACKUPS_PATH` to the Amazon S3 bucket specified in `REMOTE_S3_BUCKET`.

This script assumes that you have already [installed awscli](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) and have [configured it](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) with your credentials.

It's recommended that you set up a separate user with access to only S3, and set up a private S3 bucket for your backups.

### sync_backups_to_dropbox.sh

The `sync_backups_to_dropbox.sh` script uploads a compressed archive of the backups from `LOCAL_BACKUPS_PATH` to the Dropbox folder specified in `REMOTE_DROPBOX_PATH`.

This script assumes that you have already [installed dbxcli](https://github.com/dropbox/dbxcli#installation) and have configured it with your credentials.

### backup_db.sh

The `backup_db.sh` script backs up the local database into a timestamped, `gzip` compressed archive into the directory set via `LOCAL_BACKUPS_PATH`. It will also automatically rotate out (delete) any backups that are older than `GLOBAL_DB_BACKUPS_MAX_AGE`.

The database backups are stored in the sub-directory `LOCAL_DB_NAME/db`, inside of `LOCAL_BACKUPS_PATH`.

The numbers at the end of the backup archive are a timestamp in the format of `YYYYMMDD-HHMMSS`.

See the **Automated Script Execution** section below for details on how to run this automatically

### backup_assets.sh

The `backup_assets.sh` script backs up an arbitrary number of asset directories to the directory specified in `LOCAL_BACKUPS_PATH`. The directories it backs are up specified in `LOCAL_ASSETS_DIRS`, just as they were for the `pull_assets.sh` script.

See the **Automated Script Execution** section below for details on how to run this automatically

### restore_db.sh

The `restore_db.sh` restores the local database to the database dumb passed in via command line argument. It backs up your local database before doing the restore.

You can pass in either a path to a `.sql` file or ` .gz` file to `restore_db.sh`, and it will do the right thing based on the file type.

### Setting it up

1. Download or clone the `wordpress-scripts` git repo
2. Copy the `scripts` directory into the root directory of your WordPress project
3. Duplicate the `example.env.sh` file, and rename it to `.env.sh`
4. Add `.env.sh` to your `.gitignore` file
5. Then open up the `.env.sh` file into your favorite editor, and replace `REPLACE_ME` with the appropriate settings.

All configuration is done in the `.env.sh` file, rather than in the scripts themselves. This is is so that the same scripts can be used in multiple environments such as `local` dev, `staging`, and `live` production without modification. Just create a `.env.sh` file in each environment, and keep it out of your git repo via `.gitignore`.

#### Global Settings

All settings that are prefaced with `GLOBAL_` apply to **all** environments.

`GLOBAL_DB_TABLE_PREFIX` is the WordPress database table prefix, usually `wordpress_`

`GLOBAL_WP_PATH` is the path of the `wp-admin` folder, relative to the root path. This should normally be `wp-admin/`, unless you have moved it elsewhere. Paths should always have a trailing `/`

`GLOBAL_ASSETS_PATH` is the path of the `wp-content` folder, relative to the root path. This should normally be `wp-content/`, unless you have moved it elsewhere. Paths should always have a trailing `/`

`GLOBAL_DB_BACKUPS_MAX_AGE` Is the maximum age of local backups in days; backups older than this will be automatically rotated out (removed).

#### Local Settings

All settings that are prefaced with `LOCAL_` refer to the local environment where the script will be run, **not** your `local` dev environment.

`LOCAL_ROOT_PATH` is the absolute path to the root of your local WordPress install, with a trailing `/` after it.

`LOCAL_PROJECT_PATH` is the absolute path to your local custom themes/plugins, with a trailing `/` after it.

`LOCAL_ASSETS_PATH` is the relative path to your local assets directories, with a trailing `/` after it.

`LOCAL_CHOWN_USER` is the user that is the owner of your entire WordPress install.

`LOCAL_CHOWN_GROUP` is your webserver's group, usually either `nginx` or `apache`.

`LOCAL_WRITEABLE_DIRS` is a quoted list of directories relative to `LOCAL_ROOT_PATH` that should be writeable by your webserver.

`LOCAL_ASSETS_DIRS` is a quoted list of asset directories relative to `LOCAL_ASSETS_PATH` that should be writeable by your webserver and that you want to pull down from the remote server. It's done this way in case you wish to sync some asset directories, but not others. If you want to pull down all asset directories in `LOCAL_ASSETS_PATH`, just leave one blank quoted string in this array

`LOCAL_DB_NAME` is the name of the local mysql WordPress database

`LOCAL_DB_PASSWORD` is the password for the local mysql WordPress database

`LOCAL_DB_USER` is the user for the local mysql WordPress database

`LOCAL_DB_HOST` is the host name of the local mysql database host. This is normally `localhost`

`LOCAL_DB_PORT` is the port number of the local mysql database host. This is normally `3306`

`LOCAL_MYSQL_CMD` is the command for the local mysql executable, normally just `mysql`. It is provided because some setups like MAMP require a full path to a copy of `mysql` inside of the application bundle.

`LOCAL_MYSQLDUMP_CMD` is the command for the local mysqldump executable, normally just `mysqldump`. It is provided because some setups like MAMP require a full path to a copy of `mysqldump` inside of the application bundle.

`LOCAL_DB_LOGIN_PATH` if this is set, it will use `--login-path=` for your local db credentials instead of sending them in via the commandline (see below)

`LOCAL_BACKUPS_PATH` is the absolute path to the directory where local backups should be stored. For database backups, a sub-directory `LOCAL_DB_NAME/db` will be created inside the `LOCAL_BACKUPS_PATH` directory to store the database backups. Paths should always have a trailing `/`

`LOCAL_SITE_URL` is the url for the local WordPress site.

##### Using mysql within a local docker container

`LOCAL_MYSQL_CMD` which is normally just `mysql`, is prepended with `docker exec -i CONTAINER_NAME` to execute the command within the container. (Example: `docker exec -i container_mysql_1 mysql`)

`LOCAL_MYSQLDUMP_CMD` which is normally just `mysqldump`, is prepended with `docker exec CONTAINER_NAME` to execute the command within the container. (Example: `docker exec container_mysql_1 mysqldump`)

#### Remote Settings

All settings that are prefaced with `REMOTE_` refer to the remote environment where assets and the database will be pulled from.

`REMOTE_SSH_LOGIN` is your ssh login to the remote server, e.g.: `user@domain.com`

`REMOTE_SSH_PORT` is the port to use for ssh on the remote server. This is normally `22`

`REMOTE_ROOT_PATH` is the absolute path to the root of your WordPress install on the remote server, with a trailing `/` after it.

`REMOTE_ASSETS_PATH` is the relative path to the remote assets directories, with a trailing `/` after it.

`REMOTE_DB_NAME` is the name of the remote mysql WordPress database

`REMOTE_DB_PASSWORD` is the password for the remote mysql WordPress database

`REMOTE_DB_USER` is the user for the remote mysql WordPress database

`REMOTE_DB_HOST` is the host name of the remote mysql database host. This is normally `localhost`

`REMOTE_DB_PORT` is the port number of the remote mysql database host. This is normally `3306`

`REMOTE_MYSQL_CMD` is the command for the local mysql executable, normally just `mysql`.

`REMOTE_MYSQLDUMP_CMD` is the command for the local mysqldump executable, normally just `mysqldump`.

`REMOTE_DB_LOGIN_PATH` if this is set, it will use `--login-path=` for your remote db credentials instead of sending them in via the commandline (see below)

`REMOTE_BACKUPS_PATH` is the absolute path to the directory where the remote backups are stored. For database backups, a sub-directory `REMOTE_DB_NAME/db` inside the `REMOTE_BACKUPS_PATH` directory is used for the database backups. Paths should always have a trailing `/`

`REMOTE_S3_BUCKET` is the name of the Amazon S3 bucket to backup to via the `sync_backups_to_s3.sh` script

### Setting up SSH Keys

Normally when you `ssh` into a remote server (as some of the `wordpress-scripts` do), you have to enter your password. Best practices from a security POV is to not allow for password-based logins, but instead use [SSH Keys](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2).

The day in, day out benefit of setting up SSH Keys is that you never have to enter your password again, so it allows for automated execution of the various `wordpress-scripts`. Use the excellent [How To Set Up SSH Keys](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2) artice as a guide for setting up your SSH keys.

### Permissions and Git

If you use `git`, a sample `.gitignore` file that you can modify & use for your WordPress projects is included in `wordpress-scripts` as `example.gitignore`. If you wish to use it, the file should be copied to your WordPress project root, and renamed `.gitignore`

If you change file permissions on your remote server, you may encounter git complaining about `overwriting existing local changes` when you try to deploy. This is because git considers changing the executable flag to be a change in the file, so it thinks you changed the files on your server (and the changes are not checked into your git repo).

To fix this, we just need to tell git to ignore permission changes on the server. You can change the `fileMode` setting for `git` on your server, telling it to ignore permission changes of the files on the server:

    git config --global core.fileMode false

See the [git-config man page](https://git-scm.com/docs/git-config#git-config-corefileMode) for details.

The other way to fix this is to set the permission using `set_perms.sh` in `local` dev, and then check the files into your git repo. This will cause them to be saved with the correct permissions in your git repo to begin with.

The downside to the latter approach is that you must have matching user/groups in both `local` dev and on `live` production.

### Automatic Script Execution

If you want to run any of these scripts automatically at a set schedule, here's how to do it. We'll use the `backup_db.sh` script as an example, but the same applies to any of the scripts.

Please see the **Setting up SSH Keys** section and set up your SSH keys before you set up automatic script execution.

#### On Linux

If you're using [Forge](https://forge.laravel.com/) you can set the `backup_db.sh` script to run nightly (or whatever interval you want) via the Scheduler. If you're using [ServerPilot.io](https://serverpilot.io/community/articles/how-to-use-cron-to-schedule-scripts.html) or are managing the server yourself, just set the `backup_db.sh` script to run via `cron` at whatever interval you desire.

`wordpress-scripts` includes a `crontab-helper.txt` that you can add to your `crontab` to make configuring `cron` easier. Remember to use full, absolute paths to the scripts when running them via `cron`, as `cron` does not have access to your environment paths, e.g.:

    /home/forge/madebyconnor.co/scripts/backup_db.sh

#### On a Mac

If you're using a Mac and you want to execute the script locally, Apple uses [Launch Daemons](https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html) instead of `cron`.

**N.B.:** Even if you _are_ on a Mac, if you run your `local` dev in a VM like Vagrant/Homestead, you'll want to execute the `wordpress-scripts` from inside of the VM itself, not on your local Mac. If you use something like Valet or Mamp, read on.

Included in `wordpress-scripts` is a `com.example.launch_daemon.plist` to help you get started. This file is an `XML` file, and the name should be a unique, reverse-DNS-style name suffixed with `.plist`. This file is analogous to a single line in a `crontab` file.

Rename `com.example.launch_daemon.plist` to something unique to your project/script, e.g.: `com.clientdomain.backup_db.plist` and place it in `/Library/LaunchDaemons/` (you'll need to `sudo` to do this).

The Launch Daemon `.plist` file is an `XML` file with a series of `<key></key>`s followed by some type that is a value for that key. The value for the `<key>Label</key>` should match the name of the file, minus the `.plist` extension, e.g.: `<string>com.clientdomain.backup_db</string>`. The value for the `<key>UserName</key>` should be the user name that you want the task to run as, e.g.: `<string>andrew</string>`

The value for the `<key>Program</key>` is a path to the command to execute, e.g.: `<string>/Users/andrew/webdev/sites/Connor Bär/scripts/backup_db.sh</string>`

Launch Daemons offer any number of ways to schedule when and how they execute; please see the [Launch Daemon documentation](https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html) for details.

Once the file has been created in `/Library/LaunchDaemons/`, it'll need to be loaded (you only need to do this once) via `launchctl`, e.g.:

    sudo launchctl load /Library/LaunchDaemons/com.clientdomain.backup_db.plist

For more information on configuring Launch Daemons, please see the excellent [launchd.info](http://www.launchd.info/) website.

### Using login-path with mysql 5.6

If you're using `mysql 5.6` or later, you’ll note the warning from mysql (this is [not an issue if you’re using MariaDB](https://mariadb.com/kb/en/mariadb/mysql_config_editor-compatibility/)):

    mysql: [Warning] Using a password on the command line interface can be insecure.

What the `wordpress-scripts` is doing isn’t any less secure than if you typed it on the command line yourself; everything sent over the wire is always encrypted via ssh. However, you can set up `login-path` to store your credentials in an encrypted file as per the [Passwordless authentication using mysql_config_editor with MySQL 5.6](https://opensourcedbms.com/dbms/passwordless-authentication-using-mysql_config_editor-with-mysql-5-6/) article.

If you set `LOCAL_DB_LOGIN_PATH` or `REMOTE_DB_LOGIN_PATH` it will use `--login-path=` for your db credentials on the respective environments instead of sending them in via the commandline.

For example, for my `local` dev setup:

    mysql_config_editor set --login-path=localdev --user=homestead --host=localhost --port=3306 --password

...and then enter the password for that user. And then in the `.env.sh` I set it to:

    LOCAL_DB_LOGIN_PATH="localdev"

...and it will use my stored, encrypted credentials instead of passing them in via commandline. You can also set this up on your remote server, and then set it via `REMOTE_DB_LOGIN_PATH`

[Made by Connor](https://madebyconnor.co/)
