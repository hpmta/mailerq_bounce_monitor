Sequelize = require("sequelize")

module.exports = (sequelize, DataTypes) ->
  Message = sequelize.define("Message",
    id: Sequelize.INTEGER
    client_id: Sequelize.INTEGER
    title: Sequelize.STRING
    subject: Sequelize.STRING
    from_name: Sequelize.STRING
    from_email: Sequelize.STRING
    reply_email: Sequelize.STRING
    send_after: Sequelize.DATE
    created_at: Sequelize.DATE
  ,
    associate: (models) ->
      Message.belongsTo models.Client
      Message.hasMany models.Delivery
    tableName: 'messages'
    timestamps: false

  )
  Message
