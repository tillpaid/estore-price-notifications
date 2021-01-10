require("dotenv").config()
rootPath = require 'app-root-path'
fs = require 'fs'

databasePath =
	example: "#{rootPath}/database/example/database.sqlite"
	work: "#{rootPath}/database/database.sqlite"

if !fs.existsSync databasePath.work
	fs.createReadStream(databasePath.example).pipe(fs.createWriteStream(databasePath.work))
