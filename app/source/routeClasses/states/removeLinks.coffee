class RemoveLinks
	# initial props
	database: null
	messages: null
# methods
	constructor: (database, messages) ->
		@database = database
		@messages = messages
	confirmed: (user) ->
		user = await @database.updateUser user.telegramId, {state: ''}
		user = await @database.removeLinks user

		await @messages.sendMessage user, "Все ссылки удалены"
		return user
	canceled: (user) ->
		user = await @database.updateUser user.telegramId, {state: ''}
		await @messages.sendMessage user, "Удаление отменено"
		return user

module.exports = RemoveLinks
