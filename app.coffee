amqp = require("amqp")
fs = require("fs")
maileeClass = require("./src/mailee")
db        = require("./src/models")
logger    = require("./src/logger")
log = logger.log
StringDecoder = require('string_decoder').StringDecoder;

mailee = new maileeClass

if fs.existsSync("#{__dirname}/../rabbitmq.json")
  rabbitmq_config = JSON.parse(fs.readFileSync("#{__dirname}/../rabbitmq.json","utf8"))
else
  rabbitmq_config = {}


db.sequelize.authenticate().complete (err) ->
  if err
    throw err
  else
    db.DeliveryStatus.findAll()
      .success (deliveryStatus) ->
        decoder = new StringDecoder("utf8")
        connection = amqp.createConnection(rabbitmq_config)
        connection.on "ready", ->
          log.info "Connected to AMQP at localhost"
          connection.queue "failure_parse", durable: true, passive: true, autoDelete: false , (q) ->
            log.info "Bound to queue failure_parse"
            # Catch all messages
            q.bind "#"
            # Receive messages
            q.subscribe (message, headers, deliveryInfo) ->
              message = JSON.parse(decoder.write(message.data))
              mailee.setBounce(message, deliveryStatus, (err, result) ->
                if err
                  log.error(err) 
                else
                  if result.delivery_id 
                    log.info "Status of delivery #{result.delivery_id} updated to #{result.status}"
                  else
                    log.info "Status of transactional delivery #{result.transactional_delivery_id} updated to #{result.status}"

              )
      .error (err) ->
        log.error err

