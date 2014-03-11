db = require('../src/models')
fs = require('fs')
spec_helper = require('./spec_helper')

describe 'Model', ->

  before (done)  ->
    spec_helper.after ->
    spec_helper.before(done)

  beforeEach (done)  ->
    spec_helper.beforeEach(done)

  describe 'TransactionalDelivery', ->
    event = JSON.parse(fs.readFileSync('spec/fixtures/failures.json','utf-8'))

    describe '.setBounce', ->
      it "should change status and log", (done) ->
        db.TransactionalDelivery.findAll().success (rows) ->
          transactionalDelivery = rows[0]
          db.DeliveryStatus.findAll().success (deliveryStatus) ->
            transactionalDelivery.setBounce event[3], deliveryStatus, (err, del) ->
              transactionalDelivery.reload().success ->
                transactionalDelivery.values.should.have.property('delivery_status_id', -101)
                done()
      it "should handle unknown bounces", (done) ->
        db.Delivery.findAll().success (rows) ->
          transactionalDelivery = rows[0]
          db.DeliveryStatus.findAll().success (deliveryStatus) ->
            transactionalDelivery.setBounce event[4], deliveryStatus, (err, del) ->
              transactionalDelivery.reload().success ->
                transactionalDelivery.values.should.have.property('delivery_status_id', -102)
                transactionalDelivery.values.should.have.property('log', "The email account that you tried to reach does not exist. Please try double-checking the recipient's email address for typos or unnecessary spaces. Learn more at http://support.google.com/mail/bin/answer.py?answer=6596 39si3417756qgx.91 - gsmtp")
                done()


  afterEach (done)  ->
    spec_helper.afterEach(done)


  after (done)  ->
    spec_helper.after(done)
