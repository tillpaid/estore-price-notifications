Default = require "./states/default"
AddingLink = require "./states/addingLink"
RemoveLinks = require "./states/removeLinks"

class Route
	# initial props
	database: null
	messages: null
	# initial methods
	default: null
	addingLink: null
	removeLinks: null
	# methods
	constructor: (database, messages) ->
		@database = database
		@messages = messages

		@default = new Default @database, @messages
		@addingLink = new AddingLink @database, @messages
		@removeLinks = new RemoveLinks @database, @messages
	startMessage: (user) ->
		user = await @database.updateUser user.telegramId, {state: ''}
		await @messages.sendMessage user, "Привет, это стартовое сообщение"
		await @messages.sendMessage user, "Для начала работы давай добавим первую ссылку"
		await @messages.sendMessage user, "Для этого нажми на кнопку \"Добавить ссылку\""
		return user

module.exports = Route
