/**
 * Functions for sending pebuilt messages
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 12 Aug 2021
 */
module kimp.answer;

import tg.bot, tg.type, tg.core.format;
import kimp.storage, std.file, kimp.tms;

/** 
 * Sends hello message to the user
 * Params:
 *   bot = Bot for sending
 *   id = User for sending
 */
void sendStart (T) (ref TelegramBot bot, T id) if (is (T == ulong) || is (T == string)) {
    string helloMessage = "" ~
        "Welcome to the StickBot!\n" ~
        "\n" ~ 
        "This bot can create beautiful stickers from your messages. You can send text to me or add me to the group chat. I will create sticker from forwarded message with /q label.\n" ~
        "\n" ~
        "Let`s go!\n";

    bot.sendMessage (id, helloMessage, TextFormat.None, null, true, false, 0, true, generateKeyboard());
}

/** 
 * Sends hellp message to the user
 * Params:
 *   bot = Bot for sending
 *   id = User for sending
 */
void sendHelp (T) (ref TelegramBot bot, T id) if (is (T == ulong) || is (T == string)) {
    string helpMessage = "" ~
        "Small user manual!\n" ~
        "\n" ~
        "How to create the sticker? There are some ways to do that.\n" ~
        "\n" ~
        "Using this chat : \n" ~
        "1. Forward message with the quote here and I will create the sticker\n" ~
        "2. Use \"🦄 Create\" button\n" ~
        "3. Send me a command (read more later)\n" ~
        "\n" ~
        "In group chat\n" ~
        "1. Send a command (read more later)\n" ~
        "\n" ~
        "Supported commands :\n" ~
        "/q [Username] [Quote] - creates random sticker\n" ~
        "/qg [Username] [Quote] - creates green sticker\n" ~
        "/qw [Username] [Quote] - creates white sticker\n" ~
        "/qb [Username] [Quote] - creates blue sticker\n" ~
        "/qv [Username] [Quote] - creates violet sticker\n" ~
        "\n";

        bot.sendMessage (id, helpMessage);
}

/** 
 * Creates sticker from forwarded message
 * Params:
 *   bot = Bot for sending sticker
 *   message = Forwarded message
 *   preset = Color preset for the stick
 */
void answerForward (ref TelegramBot bot, TelegramMessage message, PresetColor preset = PresetColor.VIOLET) {
    string avatar = TmpStorage.genTmpFile ();
    string sticker = TmpStorage.genTmpFile ();

    auto photos = bot.getUserProfilePhotos(message.forwardFrom.id);
    if (photos.totalCount) {
        write (avatar, bot.downloadFile(bot.getFile(photos.photos[0][$ - 1].fileId)));
    } else avatar = "";

    string fullName = message.forwardFrom.firstName ~ " " ~ message.forwardFrom.lastName ~ '\0';
    Sticker.createSticker (preset, fullName.ptr, (avatar ~ '\0').ptr, (message.text ~ '\0').ptr, (sticker ~ '\0').ptr);
    bot.sendSticker (message.chat.id, TelegramInputFile.createFromFile(sticker));
}

/** 
 * Generate default inline keyboard for the stickbot
 * Returns: Generated keyboard
 */
private TelegramInlineKeyboardMarkup generateKeyboard () {
    TelegramInlineKeyboardMarkup keyboard = new TelegramInlineKeyboardMarkup ();

    auto arr = keyboard.inlineKeyboard;

    TelegramInlineKeyboardButton createBtn = new TelegramInlineKeyboardButton ();
    createBtn.text = "🦄 Create"; createBtn.callbackData = "/create";

    TelegramInlineKeyboardButton helpBtn = new TelegramInlineKeyboardButton();
    helpBtn.text = "🍏 Help"; helpBtn.callbackData = "/help";

    TelegramInlineKeyboardButton donateBtn = new TelegramInlineKeyboardButton();
    donateBtn.text = "🐈 Donate"; donateBtn.url = "https://sobe.ru/na/coffee_and_learning";

    arr.length = 1;
    arr[0].length = 3;

    arr[0][0] = createBtn;
    arr[0][1] = helpBtn;
    arr[0][2] = donateBtn;

    keyboard.inlineKeyboard = arr;

    return keyboard;
}
