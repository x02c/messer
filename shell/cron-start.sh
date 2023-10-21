#!/usr/bin/env bash
#
# This is useful to run a script from crontab with all environment variables restored.
#
# Usage:
#
# 1. Export and save your environment variables for subsequent use:
#
#    $ export -p > .env
#
# 2. Start your scripts immediately:
#
#    $ /usr/bin/bash cron-start.sh bash my-other-script-with-env-restored.sh
#
#    Or run your script in specified directory and write logs to log-file-name.log:
#
#    $ JOB_CWD=/path/to/cwd JOB_NAME=log-file-name /usr/bin/bash cron-start.sh my-script.sh
#
# 3. Use with crontab
#
#    ```
#    PATH=/usr/bin:/bin
#    JOB_ROOT=/path/to/jobs
#    JOB_CWD=/path/to/jobs
#    JOB_SH=/path/to/messer/shell/cron-start.sh
#
#    * * * * * JOB_NAME=name JOB_CWD=/path/to/cwd $JOB_SH my_command args
#    ```

JOB_ROOT=${JOB_ROOT:-$(pwd)}
JOB_ENV=${JOB_ENV:-$JOB_ROOT/.env}

source $JOB_ENV

JOB_CWD=${JOB_CWD:-$JOB_ROOT}
JOB_NAME=${JOB_NAME:-default}
JOB_TIMEOUT=${JOB_TIMEOUT:-30}
JOB_AWK=${JOB_AWK:-awk}

cd $JOB_CWD
status=$({
  {
    {
      echo Start job: "$@"
      timeout -v $JOB_TIMEOUT "$@"
      status=$?
      echo Exit code: $status
      echo $status >&4
    } 2>&3 | logger -t $JOB_NAME
  } 3>&1 | logger -p 2 -t $JOB_NAME
} 4>&1)
exit $status