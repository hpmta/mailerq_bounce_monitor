Sequelize = require("sequelize")

module.exports = (sequelize, DataTypes) ->
  Client = sequelize.define("Client",
    id: Sequelize.INTEGER
    subdomain: Sequelize.STRING
    name: Sequelize.STRING
    email: Sequelize.STRING
    credits: Sequelize.INTEGER
    url: Sequelize.STRING
    sendgrid_username: Sequelize.STRING
  ,
    associate: (models) ->
      Client.hasMany models.Contact
      Client.hasMany models.Message
    tableName: 'clients'
  )
  # define associations
  Client
