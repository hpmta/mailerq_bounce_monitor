fs = require("fs")
path = require("path")
Sequelize = require("sequelize")
lodash = require("lodash")
log    = require("./logger").log


unless global.hasOwnProperty("db")
  if fs.existsSync("#{__dirname}/../opsworks.js")
    config = require("../opsworks.js").db
  else if fs.existsSync("#{__dirname}/../database.json")
    config = JSON.parse(fs.readFileSync("#{__dirname}/../database.json","utf8"))
  else
    config = {"database":"mailee_test","username":"mailee","port":5432,"password":"", "host":"localhost", "ssl": false, "debug": false}

  log.info("Connecting to database #{config.username}@#{config.host}:#{config.port}/#{config.database}")

  sequelize = new Sequelize(config.database, config.username, config.password,
    dialect: "postgres"
    protocol: "postgres"
    port: config.port
    host: config.host
    logging: config.debug
    native: config.ssl
    ssl: config.ssl
    define: {
      underscored: true
    }
  )

db = {}

fs.readdirSync("#{__dirname}/models/").filter((file) ->
  (file.indexOf(".") isnt 0)
).forEach (file) ->
  model = sequelize.import(path.join("#{__dirname}/models/", file))
  db[model.name] = model

Object.keys(db).forEach (modelName) ->
  db[modelName].options.associate db  if db[modelName].options.hasOwnProperty("associate")

module.exports = lodash.extend(
  sequelize: sequelize
  Sequelize: Sequelize
, db)
