log    = require("../logger").log
error_types = require("../error_types")
Sequelize = require("sequelize")

mailerq_error_type_map = {
    "nohosts": -101,
    "bind": -1,
    "refused": -5,
    "connect": -5,
    "noaccess": -5,
    "graylisted": -3,
    "lost": -2,
    "timeout": -2,
    "reuse": -1,
    "reset": -1,
    "idle": -1
  }

setBounce = (event, deliveryStatus, callback) ->
  delivery = this
  events_size = event.results.length

  # in some kinds of errors the server will give up after some tries, so the
  # last event is not useful, we must use the most recent with description
  result = event.results[events_size - 1]
  if not result.description and events_size > 1
    result = event.results[events_size - 2]

  if result.description
    delivery.log = result.description
    status = deliveryStatus.filter (el) ->
      result.description.match(el.values.regex)
    delivery.delivery_status_id = status[0].values.id if status[0]

  if delivery.delivery_status_id == 2
    delivery.delivery_status_id = error_types[result.type] || -6

  delivery.save()
    .success () ->
      results = {deliveryId: delivery.id, contactId: delivery.contact_id, event: event}
      results.contactStatusId = status[0].values.contact_status_id if status
      #log.debug "Set bounce status #{status[0].values.id} for delivery #{delivery.id}"
      return callback null, results
    .error (err) ->
      #log.error "Couldn't update status for delivery #{delivery.id}: #{err}"
      return callback err, null




module.exports = (sequelize, DataTypes) ->
  Delivery = sequelize.define("Delivery",
    id: Sequelize.INTEGER
    client_id: Sequelize.INTEGER
    contact_id: Sequelize.INTEGER
    message_id: Sequelize.INTEGER
    delivery_status_id: Sequelize.INTEGER
    email: Sequelize.STRING
    log: Sequelize.TEXT
    created_at: Sequelize.DATE
    send_after: Sequelize.DATE
  ,
    associate: (models) ->
      Delivery.belongsTo models.Message
      Delivery.belongsTo models.Contact
      Delivery.hasOne models.DeliveryStatus
    instanceMethods:
      setBounce: setBounce
    tableName: 'deliveries'
    timestamps: false
  )
  Delivery
