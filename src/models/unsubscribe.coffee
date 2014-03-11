Sequelize = require("sequelize")

module.exports = (sequelize, DataTypes) ->
  Unsubscribe = sequelize.define("Unsubscribe",
    contact_id: Sequelize.INTEGER
    message_id: Sequelize.INTEGER
    reason: Sequelize.STRING
    spam: Sequelize.BOOLEAN
    created_at: Sequelize.DATE
  ,
    associate: (models) ->
      Unsubscribe.belongsTo models.Contact
    tableName: 'unsubscribes'
    timestamps: false
  )
  Unsubscribe
