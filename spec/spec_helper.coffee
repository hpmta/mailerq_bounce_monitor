async = require('async')
fs = require('fs')
db = require('../src/models')

before = (done) ->
  models = JSON.parse(fs.readFileSync('spec/fixtures/models.json','utf-8'))

  objects = models.delivery_status.map (object) ->
    {class: db.DeliveryStatus, model: object}

  functions = objects.map (obj) ->
    (callback) ->
      obj.class.build(obj.model).save()
        .success (client) ->
          callback null, client
        .error (error) ->
          callback error, null

  async.series functions, (err, result) ->
    done(err) if err
    done() if result

beforeEach = (done) ->
  models = JSON.parse(fs.readFileSync('spec/fixtures/models.json','utf-8'))

  objects = [
    {class: db.Client, model: models.client},
    {class: db.Message, model: models.message},
    {class: db.Contact, model: models.contacts[0]},
    {class: db.Delivery, model: models.deliveries[0]}
    {class: db.Contact, model: models.contacts[1]},
    {class: db.Delivery, model: models.deliveries[1]},
    {class: db.TransactionalDelivery, model: models.transactional_deliveries[0]}
  ]
  functions = objects.map (obj) ->
    (callback) ->
      obj.class.build(obj.model).save()
        .success (client) ->
          callback null, client
        .error (error) ->
          callback error, null


  async.series functions, (err, result) ->
    done(err) if err
    done() if result

afterEach = (done) ->
  objects = [db.TransactionalDelivery, db.Unsubscribe, db.Delivery, db.Contact, db.Message, db.Client]
  functions = objects.map (obj) ->
    (callback) ->
      obj.destroy()
        .success (client) ->
          callback null, client
        .error (error) ->
          callback error, null

  async.series functions, (err, result) ->
    done(err) if err
    done() if result

after = (done) ->
  objects = [db.DeliveryStatus]
  functions = objects.map (obj) ->
    (callback) ->
      obj.destroy()
        .success (client) ->
          callback null, client
        .error (error) ->
          callback error, null

  async.series functions, (err, result) ->
    done(err) if err
    done() if result

module.exports = {before: before, beforeEach: beforeEach, after: after, afterEach: afterEach}
