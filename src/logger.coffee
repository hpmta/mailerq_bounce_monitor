winston = require('winston')
require('winston-syslog').Syslog

winston.setLevels(winston.config.syslog.levels)

module.exports.log = winston
#module.exports.errorLogger = expressWinston.errorLogger(
      #transports: [
        ##new winston.transports.Syslog(app_name: "event-api",colorize: true, port: 1024),
        #new winston.transports.Console(colorize: true)
      #],
      #dumpExceptions: true,
      #showStack: true
    #)

#module.exports.requestLogger = expressWinston.logger(
      #transports: [
        ##new winston.transports.Syslog(colorize: true, app_name: "event-api", port: 1024),
        #new winston.transports.Console(colorize: true)
      #],
      #meta: true,
    #)

