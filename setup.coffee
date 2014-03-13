amqp = require("amqp")
fs = require("fs")
logger    = require("./src/logger")
log = logger.log

if fs.existsSync("#{__dirname}/../rabbitmq.json")
  rabbitmq_config = JSON.parse(fs.readFileSync("#{__dirname}/../rabbitmq.json","utf8"))
else
  rabbitmq_config = {}

for queue_name in ['failure', 'failure_parse', 'outbox', 'retries', 'success']
  
  connection = amqp.createConnection(rabbitmq_config)
  connection.on 'ready', () ->

    connection.exchange queue_name, type: 'direct', durable: true, autoDelete: false, () ->
      log.info "Exchange #{queue_name} created"

      connection.queue queue_name, durable: true, autoDelete: false, (q) ->
        log.info "Queue #{queue_name} created"
        if queue_name == 'failure_parse'
          q.bind 'failure', 0, () ->
            log.info "Queue {queue_name} bound to exchange failure"
            connection.disconnect()
        else
          q.bind queue_name, 0, () ->
            log.info "Queue {queue_name} bound to exchange #{queue_name}"
            connection.disconnect()


