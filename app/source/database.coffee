rootPath = require 'app-root-path'
{Sequelize, DataTypes} = require 'sequelize'

global.sequelize = new Sequelize
	dialect: 'sqlite'
	storage: "#{rootPath}/database/database.sqlite"

checkConnect = ->
	try
		await global.sequelize.authenticate()
		console.log "Connection success"
	catch error
		console.log "Connection failed: #{error.message}"

checkConnect()

# models
userParams =
	telegramId:
		type: DataTypes.INTEGER
		allowNull: false
	state:
		type: DataTypes.STRING
		allowNull: false

linkParams =
	userId:
		type: DataTypes.INTEGER
		allowNull: false
	link:
		type: DataTypes.TEXT
		allowNull: false
	oldPrice:
		type: DataTypes.STRING
		allowNull: false

noTimestamps =
	timestamps: false

class Database
	userModel: global.sequelize.define 'user', userParams, noTimestamps
	linkModel: global.sequelize.define 'link', linkParams, noTimestamps
	constructor: ->
		@userModel.hasMany @linkModel, {}
	getUser: (chatId) ->
		user = await @userModel.findOne
			where:
				telegramId: chatId

		if !user
			user = await @userModel.create {telegramId: chatId, state: ""}

		user.links = await user.getLinks()

		return user
	updateUser: (chatId, data) ->
		await @userModel.update data,
			where:
				telegramId: chatId

		user = await @getUser chatId

		return user
	addLink: (userId, link) ->
		await @linkModel.create
			userId: userId
			link: link
			oldPrice: ""
	checkIfLinkExists: (userId, link) ->
		count = await @linkModel.count
			where:
				userId: userId
				link: link

		return count != 0

module.exports = Database
