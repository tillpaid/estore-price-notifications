var rootPath;

require("dotenv").config();

rootPath = require('app-root-path');

require(`${rootPath}/app/public/check_database`);

require(`${rootPath}/app/public/database`);

require(`${rootPath}/app/public/telegram`);
