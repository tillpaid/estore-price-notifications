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
			else
				options = @getKeyboardData [
					"Добавить ссылку"
					"Мои ссылки: #{user.links.length}"
				]


		return options
	sendMessage: (user, text) ->
		await global.bot.sendMessage user.telegramId, text, @getOptions user

module.exports = Messages
