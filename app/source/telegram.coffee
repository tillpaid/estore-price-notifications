require("dotenv").config()
rootPath = require "app-root-path"

axios = require "axios"
database = require "#{rootPath}/app/public/database"
messages = require "#{rootPath}/app/public/messages"

TelegramBot = require 'node-telegram-bot-api'

botKey = process.env.BOT_KEY
botConfig = {
	polling: true
}

global.bot = new TelegramBot botKey, botConfig

global.bot.on 'message', (message) ->
	chatId = message.chat.id
	textMessage = message.text

	if chatId.toString() != process.env.MY_CHAT_ID.toString()
		global.bot.sendMessage chatId, "Бот еще в разработке, приходите через время :)"
		return

	user = await database.getUser chatId

	switch textMessage
		when "/start"
			user = await database.updateUser chatId, {state: ''}

			await messages.sendMessage user, "Привет, это стартовое сообщение"
			await messages.sendMessage user, "Для начала работы давай добавим первую ссылку"
			await messages.sendMessage user, "Для этого нажми на кнопку \"Добавить ссылку\""
		else
			switch user.state
				when ''
					switch textMessage
						when 'Добавить ссылку'
							user = await database.updateUser chatId, {state: 'adding_link'}
							await messages.sendMessage user, "Отправь мне ссылку, что бы я ее начал отслеживать :)"
						else
							if textMessage.indexOf('Мои ссылки:') == 0
								outputMessage = ["Вот ваши ссылки:", ""]

								for item in user.links
									outputMessage.push item.link

								await messages.sendMessage user, outputMessage.join "\n"
							else
								await messages.sendMessage user, "Извините, я немного запутался.. Повторите пожалуйста запрос :)"
				when 'adding_link'
					switch textMessage
						when 'Вернуться в меню'
							user = await database.updateUser chatId, {state: ''}
							await messages.sendMessage user, "Хорошо, возвращаю вас в меню :)"
						else
							user = await database.updateUser chatId, {state: ''}

							link = textMessage
							regex = /(((https:\/\/?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/

							match = link.match regex
							if match and match[2] and match[2] == "https://estore.ua"
								linkExists = await database.checkIfLinkExists user.id, link

								if linkExists
									await messages.sendMessage user, "Вы уже добавляли эту ссылку"
									await messages.sendMessage user, "Я отслеживаю ее для вас"
								else
									await messages.sendMessage user, "Проверяю ссылку. Подождите несколько минут."
									statusCode = null

									try
										response = await axios.get link
										statusCode = response.status
									catch error
										if error.response and error.response.status
											statusCode = error.response.status

									if statusCode == 200
										await database.addLink user.id, link
										user = await database.getUser user.telegramId
										await messages.sendMessage user, "Ссылка добавлена"
									else
										await messages.sendMessage user, "Ссылка ведет на другую страницу или такой страницы не существует :("
										await messages.sendMessage user, "Пожалуйста, проверьте, что ссылка верная и попробуйте еще раз."

							else
								await messages.sendMessage user, "Извините, но эта ссылка не похожа, на ссылку с сайта https://estore.ua"
				when 'show_links'
				else
					user = await database.updateUser chatId, {state: ''}
					await messages.sendMessage user, "Извините, я немного запутался.. Повторите пожалуйста запрос :)"
