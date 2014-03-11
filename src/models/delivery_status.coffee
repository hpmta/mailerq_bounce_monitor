Sequelize = require("sequelize")


module.exports = (sequelize, DataTypes) ->
  DeliveryStatus = sequelize.define("DeliveryStatus",
    id: Sequelize.INTEGER
    contact_status_id: Sequelize.INTEGER
    name: Sequelize.STRING
    log: Sequelize.TEXT
    regex: Sequelize.TEXT
  ,
    tableName: 'delivery_status'
    timestamps: false
  )
  DeliveryStatus

