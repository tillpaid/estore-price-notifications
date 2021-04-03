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
			user = route.startMessage user
		else
			switch user.state
				when ''
					switch textMessage
						when 'Добавить ссылку'
							route.default.addLink user
						when 'Удалить ссылку'
							route.default.removeOneLink user
						when 'Удалить все ссылки'
							route.default.removeLinks user
						else
							if textMessage.indexOf('Мои ссылки:') == 0
								route.default.printLinks user
							else
								route.default.badMessage user
				when 'adding_link'
					switch textMessage
						when 'Вернуться в меню'
							route.addingLink.backToMenu user
						else
							route.addingLink.processLink user, textMessage
				when 'remove_one_link'
					switch textMessage
						when 'Вернуться в меню'
							route.default.backToMenu user
						else
							route.removeOneLink.processLink user, textMessage
				when 'remove_one_link_confirm'
					switch textMessage
						when 'Да'
							route.removeOneLink.confirmed user
						else
							route.removeOneLink.canceled user
				when 'remove_links'
					switch textMessage
						when 'Да'
							route.removeLinks.confirmed user
						else
							route.removeLinks.canceled user
				else
					route.default.badMessage user
