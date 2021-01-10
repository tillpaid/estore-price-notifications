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

global.userModel = user
global.linkModel = link
