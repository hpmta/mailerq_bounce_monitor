Sequelize = require("sequelize")

module.exports = (sequelize, DataTypes) ->
  Contact = sequelize.define("Contact",
    id: Sequelize.INTEGER
    client_id: Sequelize.INTEGER
    name: Sequelize.STRING
    email: Sequelize.STRING
    contact_status_id: Sequelize.INTEGER
    created_at: Sequelize.DATE
  ,
    associate: (models) ->
      Contact.belongsTo models.Client
    tableName: 'contacts'

  )
  Contact
