db = require('../src/models')
fs = require('fs')
spec_helper = require('./spec_helper')
maileeClass = require('../src/mailee')
mailee = new maileeClass

describe 'Model', ->

  before (done)  ->
    spec_helper.after ->
    spec_helper.before(done)

  beforeEach (done)  ->
    spec_helper.beforeEach(done)

  describe 'Mailee', ->
    event = JSON.parse(fs.readFileSync('spec/fixtures/failures.json','utf-8'))

    describe '.setBounce', ->
      describe ' for a delivery', ->
        it "should find the delivery and call the callback", (done) ->
          db.DeliveryStatus.findAll().success (deliveryStatus) ->
            db.Delivery.findAll().success (rows) ->
              mailee.setBounce event[0], deliveryStatus, (err, result) ->
                result.should.have.property('contact_id', -10)
                result.should.have.property('status', -1)
                result.should.have.property('event', event[0])
                done()
      describe ' for a transactional delivery', ->
        it "should find the transactional delivery and call the callback", (done) ->
          db.DeliveryStatus.findAll().success (deliveryStatus) ->
            db.TransactionalDelivery.findAll().success (rows) ->
              mailee.setBounce event[3], deliveryStatus, (err, result) ->
                result.should.have.property('transactional_delivery_id', -10)
                result.should.have.property('status', -101)
                result.should.have.property('event', event[3])
                done()

    describe '.updateContactStatus', ->
      it "should update contact status and return the callback if passed", (done) ->
        mailee.updateContactStatus null, {contactId: -10, contactStatusId: -1}, (err, c) ->
          db.Contact.findAll().success (contact) ->
            contact[1].values.should.have.property('id', -10)
            contact[1].values.should.have.property('contact_status_id', -1)
            done()

  afterEach (done)  ->
    spec_helper.afterEach(done)


  after (done)  ->
    spec_helper.after(done)
