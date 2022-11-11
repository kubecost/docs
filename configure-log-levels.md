# Configure Log Levels

The log output can be adjusted while deploying through Helm by using the `LOG_LEVEL` and/or `LOG_FORMAT` environment variables. These variables include:
* `trace`
* `debug`
* `info`
* `warn`
* `error`
* `fatal`

For example, to set the log level to `debug`, add the following flag to the Helm command:

    --set 'kubecostModel.extraEnv[0].name=LOG_LEVEL,kubecostModel.extraEnv[0].value=debug'

`LOG_FORMAT` options:

* `JSON`
    * A structured logging output
    * `{"level":"info","time":"2006-01-02T15:04:05.999999999Z07:00","message":"Starting cost-model (git commit \"1.91.0-rc.0\")"}`

* `pretty`
    * A nice human readable output 
    * `2006-01-02T15:04:05.999999999Z07:00 INF Starting cost-model (git commit "1.91.0-rc.0")`
