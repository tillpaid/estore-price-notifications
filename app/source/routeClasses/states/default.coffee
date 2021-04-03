class Default
	# initial props
	database: null
	messages: null
	# methods
	constructor: (database, messages) ->
		@database = database
		@messages = messages
	addLink: (user) ->
		user = await @database.updateUser user.telegramId, {state: 'adding_link'}
		await @messages.sendMessage user, "Отправь мне ссылку, что бы я ее начал отслеживать :)"
		return user
	printLinks: (user) ->
		await @messages.sendMessage user, "Вот ваши ссылки:"

		for item in user.links
			await @messages.sendMessage user, item.link
	removeLinks: (user) ->
		user = await @database.updateUser user.telegramId, {state: 'remove_links'}
		await @messages.sendMessage user, "Вы уверены, что хотите удалить все ссылки?"
		return user
	badMessage: (user) ->
		user = await @database.updateUser user.telegramId, {state: ''}
		await @messages.sendMessage user, "Извините, я немного запутался.. Повторите пожалуйста запрос :)"
		return user

module.exports = Default
