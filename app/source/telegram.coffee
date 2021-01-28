require("dotenv").config()

database = new (require "./database")
messages = new (require "./messages")

TelegramBot = require 'node-telegram-bot-api'

botKey = process.env.BOT_KEY
botConfig = {
	polling: true
}

global.bot = new TelegramBot botKey, botConfig

RouteClass = require "./routeClasses/route"
route = new RouteClass database, messages

global.bot.on 'message', (message) ->
	chatId = message.chat.id
	textMessage = message.text

	if chatId.toString() != process.env.MY_CHAT_ID.toString()
		global.bot.sendMessage chatId, "Бот еще в разработке, приходите через время :)"
		return

	user = await database.getUser chatId

	switch textMessage
		when "/start"
			user = route.startMessage chatId
		else
			switch user.state
				when ''
					switch textMessage
						when 'Добавить ссылку'
							user = route.default.addLink chatId
						else
							if textMessage.indexOf('Мои ссылки:') == 0
								route.default.printLinks user
							else
								user = route.default.badMessage chatId
				when 'adding_link'
					switch textMessage
						when 'Вернуться в меню'
							user = route.addingLink.backToMenu chatId
						else
							user = route.addingLink.processLink chatId, textMessage
				else
					user = route.default.badMessage chatId
