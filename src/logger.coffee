winston = require('winston')
require('winston-syslog').Syslog

winston.setLevels(winston.config.syslog.levels)

module.exports.log = new (winston.Logger)(transports: [
  new (winston.transports.Console)()
  new (winston.transports.File)(filename: "bounce_monitor.log")
  new winston.transports.Syslog(app_name: "bounce_monitor",colorize: true),

])
