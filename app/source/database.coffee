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
user = global.sequelize.define 'user', {
	telegramId:
		type: DataTypes.INTEGER
		allowNull: false
	state:
		type: DataTypes.STRING
		allowNull: false
}, {
	timestamps: false
}

link = global.sequelize.define 'link', {
	userId:
		type: DataTypes.INTEGER
		allowNull: false
	link:
		type: DataTypes.TEXT
		allowNull: false
	oldPrice:
		type: DataTypes.STRING
		allowNull: false
}, {
	timestamps: false
}

user.hasMany link, {}

# functions
getUser = (chatId) ->
	user = await database.userModel.findOne
		where:
			telegramId: chatId

	if !user
		user = await database.userModel.create {telegramId: chatId, state: ""}

	user.links = await user.getLinks()

	return user

updateUser = (chatId, data) ->
	await database.userModel.update data,
		where:
			telegramId: chatId

	user = await database.getUser chatId

	return user

addLink = (userId, link) ->
	await database.linkModel.create
		userId: userId
		link: link
		oldPrice: ""

checkIfLinkExists = (userId, link) ->
	count = await database.linkModel.count
		where:
			userId: userId
			link: link

	return count != 0

# export
database =
	userModel: user
	linkModel: link
	getUser: getUser
	updateUser: updateUser
	addLink: addLink
	checkIfLinkExists: checkIfLinkExists

module.exports = database
