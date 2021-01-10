require("dotenv").config()

TelegramBot = require 'node-telegram-bot-api'

botKey = process.env.BOT_KEY
botConfig = {
	polling: true
}

global.bot = new TelegramBot botKey, botConfig

getUser = (chatId) ->
	user = await global.userModel.findOne
		where:
			telegramId: chatId

	if !user
		user = await global.userModel.create {telegramId: chatId, state: ""}

	return user

updateUser = (chatId, data) ->
	await global.userModel.update data,
		where:
			telegramId: chatId

	user = await getUser chatId

	return user

getKeyboardData = (buttons) ->
	options = {}

	if buttons.length
		keyboard = []

		for button in buttons
			keyboard.push [button]

#		keyboard.push ['/start']

		options =
			reply_markup:
				keyboard: keyboard
				resize_keyboard: true
				one_time_keyboard: false

	return options

getOptions = (user) ->
	options = {}

	switch user.state
		when 'list_links'
			options = {}
		when 'adding_link'
			options = getKeyboardData ["Вернуться в меню"]
		else
			options = getKeyboardData ["Добавить ссылку"]

	return options

global.bot.on 'message', (message) ->
	chatId = message.chat.id
	textMessage = message.text

	if chatId.toString() != process.env.MY_CHAT_ID.toString()
		global.bot.sendMessage chatId, "Бот еще в разработке, приходите через время :)"
		return

	user = await getUser chatId
	links = await user.getLinks()

	console.log user
	console.log links

	switch textMessage
		when "/start"
			user = await updateUser chatId, {state: ''}
			global.bot.sendMessage chatId, "Привет, это стартовое сообщение. Для начала работы давай добавим первую ссылку", getOptions user
		else
			switch user.state
				when ''
					switch textMessage
						when 'Добавить ссылку'
							user = await updateUser chatId, {state: 'adding_link'}
							global.bot.sendMessage chatId, "Отправь мне ссылку, что бы я ее начал отслеживать :)", getOptions user
				when 'adding_link'
					switch textMessage
						when 'Вернуться в меню'
							user = await updateUser chatId, {state: ''}
							global.bot.sendMessage chatId, "Хорошо, возвращаю вас в меню :)", getOptions user
						else
							global.bot.sendMessage chatId, "Хм.. Это не похоже на ссылку", getOptions user

				else
					user = await updateUser chatId, {state: ''}
					global.bot.sendMessage chatId, "Извините, я немного запутался.. Повторите пожалуйста запрос :)"
