winston = require('winston')
require('winston-rsyslog')

winston.setLevels(winston.config.syslog.levels)

module.exports.log = new (winston.Logger)(transports: [
  new (winston.transports.Console)()
  new (winston.transports.File)(filename: "bounce_monitor.log")
  new winston.transports.Rsyslog(host: "localhost"),

])
