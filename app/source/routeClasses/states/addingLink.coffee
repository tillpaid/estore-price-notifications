axios = require "axios"

class AddingLink
	# initial props
	database: null
	messages: null
# methods
	constructor: (database, messages) ->
		@database = database
		@messages = messages
	backToMenu: (chatId) ->
		user = await @database.updateUser chatId, {state: ''}
		await @messages.sendMessage user, "Хорошо, возвращаю вас в меню :)"
		return user
	processLink: (chatId, textMessage) ->
		user = await @database.updateUser chatId, {state: ''}

		link = textMessage
		regex = /(((https:\/\/?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/

		match = link.match regex
		if match and match[2] and match[2] == "https://estore.ua"
			linkExists = await @database.checkIfLinkExists user.id, link

			if linkExists
				await @messages.sendMessage user, "Вы уже добавляли эту ссылку"
				await @messages.sendMessage user, "Я отслеживаю ее для вас"
			else
				await @messages.sendMessage user, "Проверяю ссылку. Подождите несколько минут."
				statusCode = null

				try
					response = await axios.get link
					statusCode = response.status
				catch error
					if error.response and error.response.status
						statusCode = error.response.status

				if statusCode == 200
					await @database.addLink user.id, link
					user = await @database.getUser user.telegramId
					await @messages.sendMessage user, "Ссылка добавлена"
				else
					await @messages.sendMessage user, "Ссылка ведет на другую страницу или такой страницы не существует :("
					await @messages.sendMessage user, "Пожалуйста, проверьте, что ссылка верная и попробуйте еще раз."
		else
			await @messages.sendMessage user, "Извините, но эта ссылка не похожа, на ссылку с сайта https://estore.ua"

		return user

module.exports = AddingLink
