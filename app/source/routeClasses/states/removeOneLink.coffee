class RemoveOneLink
	# initial props
	database: null
	messages: null
	# methods
	constructor: (database, messages) ->
		@database = database
		@messages = messages
	processLink: (user, textMessage) ->
		linkExists = await @database.checkIfLinkExists user.id, textMessage
		newState = null
		text = null

		if linkExists
			newState = 'remove_one_link_confirm'
			text = "Вы уверены, что хотите удалить эту ссылку из списка отслеживаний?"
		else
			newState = ''
			text = "Такой ссылки нет в вашем списке отслеживаний"

		user = await @database.updateUser user.telegramId, {state: newState, linkToRemove: textMessage}
		await @messages.sendMessage user, text

		return user
	confirmed: (user) ->
		user = await @database.removeOneLink user, user.linkToRemove
		user = await @database.updateUser user.telegramId, {state: '', linkToRemove: null}

		await @messages.sendMessage user, "Ссылка удалена"
		return user
	canceled: (user) ->
		user = await @database.updateUser user.telegramId, {state: '', linkToRemove: null}
		await @messages.sendMessage user, "Удаление отменено"
		return user

module.exports = RemoveOneLink
