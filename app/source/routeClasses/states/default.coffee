class Default
	# initial props
	database: null
	messages: null
	# methods
	constructor: (database, messages) ->
		@database = database
		@messages = messages
	addLink: (chatId) ->
		user = await @database.updateUser chatId, {state: 'adding_link'}
		await @messages.sendMessage user, "Отправь мне ссылку, что бы я ее начал отслеживать :)"
		return user
	printLinks: (user) ->
		outputMessage = ["Вот ваши ссылки:", ""]

		for item in user.links
			outputMessage.push item.link

		await @messages.sendMessage user, outputMessage.join "\n"
	badMessage: (chatId) ->
		user = await @database.updateUser chatId, {state: ''}
		await @messages.sendMessage user, "Извините, я немного запутался.. Повторите пожалуйста запрос :)"
		return user

module.exports = Default
