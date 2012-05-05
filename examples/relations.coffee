ActiveRecord = require '../lib'
config = require __dirname + "/config"

class User extends ActiveRecord.Model
  config: config
  fields: ['id', 'username', 'name']
  hasMany: -> [
    Message
  ]

class Message extends ActiveRecord.Model
  config: config
  fields: ['id', 'user_id', 'text']
  belongsTo: -> [
    User
  ]

sqlite3 = require('sqlite3')
db = new sqlite3.Database "#{__dirname}/test.db"
db.serialize ->
  db.run "CREATE TABLE IF NOT EXISTS messages (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, `text` TEXT)", []
  db.run "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, username VARCHAR(20), name VARCHAR(255))", [], (err) ->
    console.log err if err

    user = new User name: 'Ryan', username: 'meltingice'
    user.save (err) ->
      message = new Message user_id: user.id, text: "This is a test!"
      message.save (err) ->
        message.user (user) ->
          console.log user.toJSON()
          
          db.run "DROP TABLE messages"
          db.run "DROP TABLE users"