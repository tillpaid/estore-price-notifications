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

addLink = (userId, link) ->
	await global.linkModel.create
		userId: userId
		link: link
		oldPrice: ""

checkIfLinkExists = (userId, link) ->
	count = await global.linkModel.count
		where:
			userId: userId
			link: link

	return count != 0

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

sendMessage = (user, text) ->
	await global.bot.sendMessage user.telegramId, text, getOptions user

global.bot.on 'message', (message) ->
	chatId = message.chat.id
	textMessage = message.text

	if chatId.toString() != process.env.MY_CHAT_ID.toString()
		global.bot.sendMessage chatId, "Бот еще в разработке, приходите через время :)"
		return

	user = await getUser chatId
	links = await user.getLinks()

	switch textMessage
		when "/start"
			user = await updateUser chatId, {state: ''}
			
			await sendMessage user, "Привет, это стартовое сообщение"
			await sendMessage user, "Для начала работы давай добавим первую ссылку"
			await sendMessage user, "Для этого нажми на кнопку \"Добавить ссылку\""
		else
			switch user.state
				when ''
					switch textMessage
						when 'Добавить ссылку'
							user = await updateUser chatId, {state: 'adding_link'}
							await sendMessage user, "Отправь мне ссылку, что бы я ее начал отслеживать :)"
						else
							await sendMessage user, "Извините, я немного запутался.. Повторите пожалуйста запрос :)"
				when 'adding_link'
					switch textMessage
						when 'Вернуться в меню'
							user = await updateUser chatId, {state: ''}
							await sendMessage user, "Хорошо, возвращаю вас в меню :)"
						else
							user = await updateUser chatId, {state: ''}

							link = textMessage
							linkExists = await checkIfLinkExists user.id, link

							if linkExists
								await sendMessage user, "Вы уже добавляли эту ссылку"
								await sendMessage user, "Я отслеживаю ее для вас"
							else
								await addLink user.id, link
								await sendMessage user, "Ссылка добавлена"
				else
					user = await updateUser chatId, {state: ''}
					await sendMessage user, "Извините, я немного запутался.. Повторите пожалуйста запрос :)"
