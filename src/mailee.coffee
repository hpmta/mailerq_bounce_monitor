log    = require("./logger").log
db = require('./models')

Mailee = ->
  return this

Mailee::version = (req, res) ->
  @database.version ((err, result, req, res) ->
    if err then res.send(500, err) else res.send(200, result[0].version)
  ), req, res

Mailee::setBounce = (event, deliveryStatus, callback) ->
  if event.deliveryId
    log.debug {deliveryId: event.deliveryId, status: @eventResults(event).status, description: @eventResults(event).description}
    @findDelivery event, (err, delivery) ->
      return callback err, null if err
      delivery.setBounce(event, deliveryStatus, callback)
  else if event.transactionalDeliveryId
    log.debug {transactionalDeliveryId: event.transactionalDeliveryId, status: @eventResults(event).status, description: @eventResults(event).description} 
    @findTransactionalDelivery event, (err, transactionalDelivery) ->
      return callback err, null if err
      transactionalDelivery.setBounce(event, deliveryStatus, callback)
  else
    err = "event without delivery_id or transactionalDeliveryId, ignoring."
    log.debug err
    callback err, null

Mailee::updateContactStatus = (err, result, callback) ->
  return if err
  return unless result.contactId and result.contactStatusId
  db.Contact.find(result.contactId).success (contact) ->
    contact.contact_status_id = result.contactStatusId
    contact.save()
      .success ->
        log.debug "Status of contact #{result.contactId} updated to #{result.contactStatusId}"
        callback null, contact if callback
      .error (err) ->
        log.error "ERROR updating status for contact #{result.contactId}: #{err}"
        callback err, null if callback

Mailee::findDelivery = (event, callback) ->
  db.Delivery.find(
    where: { id: event.deliveryId }
  ).success (delivery) ->
    log.notice "Couldn't find delivery with id #{event.deliveryId}" unless delivery
    return callback "NOTICE: couldn't find delivery with id #{event.deliveryId}", null unless delivery
    return callback null, delivery
  .error (err) ->
    log.error  "Couldn't find delivery with id #{event.deliveryId}: #{err}"
    return callback err

Mailee::findTransactionalDelivery = (event, callback) ->
  db.TransactionalDelivery.find(
    where: { id: event.transactionalDeliveryId }
  ).success (transactionalDelivery) ->
    log.notice "Couldn't find transactional delivery with id #{event.transactionalDeliveryId}" unless transactionalDelivery
    return callback "NOTICE: couldn't find transactional delivery with id #{event.transactionalDeliveryId}", null unless transactionalDelivery
    return callback null, transactionalDelivery
  .error (err) ->
    log.error "transactional_delivery_id=#{event.transactionalDeliveryId}; #{err}"
    return callback err

Mailee::eventResults = (event) ->
  events_size = event.results.length
  result = event.results[events_size - 1]
  if not result.description and events_size > 1
    result = event.results[events_size - 2]
  result


module.exports = Mailee
