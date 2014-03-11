log    = require("../logger").log
error_types = require("../error_types")
Sequelize = require("sequelize")

setBounce = (event, deliveryStatus, callback) ->
  transactionalDelivery = this
  events_size = event.results.length

  # in some kinds of errors the server will give up after some tries, so the
  # last event is not useful, we must use the most recent with description
  result = event.results[events_size - 1]
  if not result.description and events_size > 1
    result = event.results[events_size - 2]
  if result.description
    transactionalDelivery.log = result.description
    status = deliveryStatus.filter (el) ->
      result.description.match(el.values.regex)
    transactionalDelivery.delivery_status_id = status[0].values.id if status[0]

  if transactionalDelivery.delivery_status_id == 2
    transactionalDelivery.delivery_status_id = error_types[result.type] || -6

  transactionalDelivery.save()
    .success () ->
      results = {transactionalDeliveryId: transactionalDelivery.id, deliveryStatusId: transactionalDelivery.delivery_status_id, event: event}
      return callback null, results
    .error (err) ->
      log.error "Couldn't set bounce for transactional delivery #{transactionalDelivery.id}: #{err}"
      return callback err, null

module.exports = (sequelize, DataTypes) ->
  TransactionalDelivery = sequelize.define("TransactionalDelivery",
    id: Sequelize.INTEGER
    client_id: Sequelize.INTEGER
    from: Sequelize.STRING
    to: Sequelize.STRING
    log: Sequelize.STRING
    accounted: Sequelize.BOOLEAN
    delivery_status_id: Sequelize.INTEGER
    unique_id: Sequelize.STRING
  ,
    associate: (models) ->
      TransactionalDelivery.belongsTo models.Client
      TransactionalDelivery.hasOne models.DeliveryStatus
    instanceMethods:
      setBounce: setBounce
    tableName: 'transactional_deliveries'
  )
  TransactionalDelivery
