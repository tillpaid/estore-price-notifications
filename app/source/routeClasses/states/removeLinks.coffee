class RemoveLinks
	# initial props
	database: null
	messages: null
# methods
	constructor: (database, messages) ->
		@database = database
		@messages = messages
	confirmed: (chatId) ->
		user = await @database.updateUser chatId, {state: ''}
		user = await @database.removeLinks user

		await @messages.sendMessage user, "Все ссылки удалены"
		return user
	canceled: (chatId) ->
		user = await @database.updateUser chatId, {state: ''}
		await @messages.sendMessage user, "Удаление отменено"
		return user

module.exports = RemoveLinks
