class Messages
	getKeyboardData: (buttons) ->
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
	getOptions: (user) ->
		options = {}

		switch user.state
			when 'list_links'
				options = {}
			when 'adding_link'
				options = @getKeyboardData ["Вернуться в меню"]
			when 'remove_links'
				options = @getKeyboardData [
					"Да"
					"Отменить"
				]
			else
				linksLength = user.links.length

				buttons = [
					"Добавить ссылку"
				]

				if linksLength
					buttons.push "Мои ссылки: #{linksLength}"
					buttons.push "Удалить все ссылки"

				options = @getKeyboardData buttons

		return options
	sendMessage: (user, text) ->
		await global.bot.sendMessage user.telegramId, text, @getOptions user

module.exports = Messages
