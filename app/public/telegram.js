var TelegramBot, botConfig, botKey, getKeyboardData, getOptions, getUser, updateUser;

require("dotenv").config();

TelegramBot = require('node-telegram-bot-api');

botKey = process.env.BOT_KEY;

botConfig = {
  polling: true
};

global.bot = new TelegramBot(botKey, botConfig);

getUser = async function(chatId) {
  var user;
  user = (await global.userModel.findOne({
    where: {
      telegramId: chatId
    }
  }));
  if (!user) {
    user = (await global.userModel.create({
      telegramId: chatId,
      state: ""
    }));
  }
  return user;
};

updateUser = async function(chatId, data) {
  var user;
  await global.userModel.update(data, {
    where: {
      telegramId: chatId
    }
  });
  user = (await getUser(chatId));
  return user;
};

getKeyboardData = function(buttons) {
  var button, i, keyboard, len, options;
  options = {};
  if (buttons.length) {
    keyboard = [];
    for (i = 0, len = buttons.length; i < len; i++) {
      button = buttons[i];
      keyboard.push([button]);
    }
    //		keyboard.push ['/start']
    options = {
      reply_markup: {
        keyboard: keyboard,
        resize_keyboard: true,
        one_time_keyboard: false
      }
    };
  }
  return options;
};

getOptions = function(user) {
  var options;
  options = {};
  switch (user.state) {
    case 'list_links':
      options = {};
      break;
    case 'adding_link':
      options = getKeyboardData(["Вернуться в меню"]);
      break;
    default:
      options = getKeyboardData(["Добавить ссылку"]);
  }
  return options;
};

global.bot.on('message', async function(message) {
  var chatId, links, textMessage, user;
  chatId = message.chat.id;
  textMessage = message.text;
  if (chatId.toString() !== process.env.MY_CHAT_ID.toString()) {
    global.bot.sendMessage(chatId, "Бот еще в разработке, приходите через время :)");
    return;
  }
  user = (await getUser(chatId));
  links = (await user.getLinks());
  console.log(user);
  console.log(links);
  switch (textMessage) {
    case "/start":
      user = (await updateUser(chatId, {
        state: ''
      }));
      return global.bot.sendMessage(chatId, "Привет, это стартовое сообщение. Для начала работы давай добавим первую ссылку", getOptions(user));
    default:
      switch (user.state) {
        case '':
          switch (textMessage) {
            case 'Добавить ссылку':
              user = (await updateUser(chatId, {
                state: 'adding_link'
              }));
              return global.bot.sendMessage(chatId, "Отправь мне ссылку, что бы я ее начал отслеживать :)", getOptions(user));
          }
          break;
        case 'adding_link':
          switch (textMessage) {
            case 'Вернуться в меню':
              user = (await updateUser(chatId, {
                state: ''
              }));
              return global.bot.sendMessage(chatId, "Хорошо, возвращаю вас в меню :)", getOptions(user));
            default:
              return global.bot.sendMessage(chatId, "Хм.. Это не похоже на ссылку", getOptions(user));
          }
          break;
        default:
          user = (await updateUser(chatId, {
            state: ''
          }));
          return global.bot.sendMessage(chatId, "Извините, я немного запутался.. Повторите пожалуйста запрос :)");
      }
  }
});
