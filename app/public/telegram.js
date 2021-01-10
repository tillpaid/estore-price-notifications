var TelegramBot, addLink, botConfig, botKey, getKeyboardData, getOptions, getUser, sendMessage, updateUser;

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

addLink = async function(userId, link) {
  return (await global.linkModel.create({
    userId: userId,
    link: link,
    oldPrice: ""
  }));
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

sendMessage = function(user, text) {
  return global.bot.sendMessage(user.telegramId, text, getOptions(user));
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
  switch (textMessage) {
    case "/start":
      user = (await updateUser(chatId, {
        state: ''
      }));
      return sendMessage(user, "Привет, это стартовое сообщение. Для начала работы давай добавим первую ссылку");
    default:
      switch (user.state) {
        case '':
          switch (textMessage) {
            case 'Добавить ссылку':
              user = (await updateUser(chatId, {
                state: 'adding_link'
              }));
              return sendMessage(user, "Отправь мне ссылку, что бы я ее начал отслеживать :)");
          }
          break;
        case 'adding_link':
          switch (textMessage) {
            case 'Вернуться в меню':
              user = (await updateUser(chatId, {
                state: ''
              }));
              return sendMessage(user, "Хорошо, возвращаю вас в меню :)");
            default:
              user = (await updateUser(chatId, {
                state: ''
              }));
              await addLink(user.id, textMessage);
              return sendMessage(user, "Ссылка добавлена");
          }
          break;
        default:
          user = (await updateUser(chatId, {
            state: ''
          }));
          return sendMessage(user, "Извините, я немного запутался.. Повторите пожалуйста запрос :)");
      }
  }
});
