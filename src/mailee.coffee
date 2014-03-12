log    = require("./logger").log
db = require('./models')

Mailee = ->
  return this

Mailee::version = (req, res) ->
  @database.version ((err, result, req, res) ->
    if err then res.send(500, err) else res.send(200, result[0].version)
  ), req, res

Mailee::setBounce = (event, deliveryStatus, callback) ->
  if event.delivery_id
    @findDelivery event, (err, delivery) ->
      return callback err, null if err
      delivery.setBounce(event, deliveryStatus, callback)
  else if event.transactional_delivery_id
    @findTransactionalDelivery event, (err, transactionalDelivery) ->
      return callback err, null if err
      transactionalDelivery.setBounce(event, deliveryStatus, callback)
  else
    err = "event without delivery_id or transactional_delivery_id, ignoring."
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
    where: { id: event.delivery_id }
  ).success (delivery) ->
    log.notice "Couldn't find delivery with id #{event.delivery_id}" unless delivery
    return callback "NOTICE: couldn't find delivery with id #{event.delivery_id}", null unless delivery
    return callback null, delivery
  .error (err) ->
    log.error  "Couldn't find delivery with id #{event.delivery_id}: #{err}"
    return callback err

Mailee::findTransactionalDelivery = (event, callback) ->
  db.TransactionalDelivery.find(
    where: { id: event.transactional_delivery_id }
  ).success (transactionalDelivery) ->
    log.notice "Couldn't find transactional delivery with id #{event.transactional_delivery_id}" unless transactionalDelivery
    return callback "NOTICE: couldn't find transactional delivery with id #{event.transactional_delivery_id}", null unless transactionalDelivery
    return callback null, transactionalDelivery
  .error (err) ->
    log.error "transactional_delivery_id=#{event.transactional_delivery_id}; #{err}"
    return callback err

Mailee::eventResults = (event) ->
  events_size = event.results.length
  result = event.results[events_size - 1]
  if not result.description and events_size > 1
    result = event.results[events_size - 2]
  result


module.exports = Mailee
