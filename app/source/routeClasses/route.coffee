Default = require "./states/default"

class Route
	# initial props
	database: null
	messages: null
	# initial methods
	default: null
	# methods
	constructor: (database, messages) ->
		@database = database
		@messages = messages

		@default = new Default @database, @messages

module.exports = Route
