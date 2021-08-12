/**
 * Functions for sending pebuilt messages
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 12 Aug 2021
 */
module kimp.answer;

import tg.bot, tg.type, tg.core.format;
import kimp.storage, std.file, kimp.tms;
import std.array : split;

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
        "This bot can create beautiful stickers from your messages." ~
        " You can send text to me or add me to the group chat. I will create sticker from forwarded messages.\n" ~
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
        "\n" ~
        "In group chat\n" ~
        "1. Send a command as a reply to the message with needed text (read more later)\n" ~
        "\n" ~
        "Supported commands :\n" ~
        "/q - creates random sticker\n" ~
        "/qg - creates green sticker\n" ~
        "/qw - creates white sticker\n" ~
        "/qb - creates blue sticker\n" ~
        "/qv - creates violet sticker\n" ~
        "\n";

        bot.sendMessage (id, helpMessage, TextFormat.None, null, true, false, 0, true, generateKeyboard());
}

/** 
 * Creates sticker from forwarded message
 * Params:
 *   bot = Bot for sending sticker
 *   message = Forwarded message
 */
void answerForward (ref TelegramBot bot, TelegramMessage message) {
    string avatar = TmpStorage.genTmpFile ();
    string sticker = TmpStorage.genTmpFile ();

    auto photos = bot.getUserProfilePhotos(message.forwardFrom.id);
    if (photos.totalCount) {
        write (avatar, bot.downloadFile(bot.getFile(photos.photos[0][$ - 1].fileId)));
    } else avatar = "";

    string fullName = message.forwardFrom.firstName ~ " " ~ message.forwardFrom.lastName ~ '\0';
    Sticker.createSticker (PresetColor.VIOLET, fullName.ptr, (avatar ~ '\0').ptr, (message.text ~ '\0').ptr, (sticker ~ '\0').ptr);
    bot.sendSticker (message.chat.id, TelegramInputFile.createFromFile(sticker));
}

/** 
 * Send sticker from reply and command
 * Params:
 *   bot = Bot for sending
 *   message = Message for process
 */
void answerReply (ref TelegramBot bot, TelegramMessage message) {
    string avatar = TmpStorage.genTmpFile ();
    string sticker = TmpStorage.genTmpFile ();

    auto photos = bot.getUserProfilePhotos(message.replyToMessage.from.id);
    if (photos.totalCount) {
        write (avatar, bot.downloadFile(bot.getFile(photos.photos[0][$ - 1].fileId)));
    } else avatar = "";

    PresetColor preset; string presetStr = message.text.split(' ')[0];
    if (presetStr == "/q" || presetStr == "/qv") preset = PresetColor.VIOLET;
    else if (presetStr == "/qb") preset = PresetColor.BLUE;
    else if (presetStr == "/qw") preset = PresetColor.WHITE;
    else preset = PresetColor.GREEN;

    string fullName = message.replyToMessage.from.firstName ~ " " ~ message.replyToMessage.from.lastName ~ '\0';
    Sticker.createSticker (preset, fullName.ptr, (avatar ~ '\0').ptr, (message.text ~ '\0').ptr, (sticker ~ '\0').ptr);
    bot.sendSticker (message.chat.id, TelegramInputFile.createFromFile(sticker));
}

/** 
 * Create stick from the callback message
 * Params:
 *   bot = Bot for sending the stick
 *   message = Message for process
 *   preset = Color preset for the stick
 */
void answer (ref TelegramBot bot, TelegramMessage message, PresetColor preset) {
    string avatar = TmpStorage.genTmpFile ();
    string sticker = TmpStorage.genTmpFile ();

    auto photos = bot.getUserProfilePhotos(message.from.id);
    if (photos.totalCount) {
        write (avatar, bot.downloadFile(bot.getFile(photos.photos[0][$ - 1].fileId)));
    } else avatar = "";

    string fullName = message.from.firstName ~ " " ~ message.from.lastName ~ '\0';
    Sticker.createSticker (preset, fullName.ptr, (avatar ~ '\0').ptr, (message.text ~ '\0').ptr, (sticker ~ '\0').ptr);
    bot.sendSticker (message.chat.id, TelegramInputFile.createFromFile(sticker));
}

/** 
 * Handler for Create button
 * Params:
 *   bot = Bot for sticker creating
 *   id = User for sneding
 */
void createStickerCallback (T) (ref TelegramBot bot, T id) if (is (T == ulong) || is (T == string)) {
    string chooseColor = "" ~
        "Let`s create a new sticker!\n" ~
        "Choose a preset color for it.";

    bot.sendMessage(id, chooseColor, TextFormat.None, null, true, false, 0, true, generateColorKeyboard());
}

/** 
 * Process callback query for sticker creating
 * Params:
 *   bot = Bot for sticker creting
 *   id = User for creating
 *   preset = Color for the stick
 */
void createStickerCallback (T) (ref TelegramBot bot, T id, PresetColor preset) if (is (T == ulong) || is (T == string)) {
    string enterQute = "" ~
        "You have choosen " ~ presetToString(preset) ~ " color!\n" ~
        "Please, enter the text for sticker creating\n";

    TelegramForceReply cb = new TelegramForceReply();
    cb.forceReply = true; cb.selective = true;

    bot.sendMessage(id, enterQute, TextFormat.None, null, true, false, 0, true, cb);
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

/** 
 * Creates color keyboard for stick creating
 * Returns: Generated keyboard
 */
private TelegramInlineKeyboardMarkup generateColorKeyboard () {
    TelegramInlineKeyboardMarkup keyboard = new TelegramInlineKeyboardMarkup ();

    auto arr = keyboard.inlineKeyboard;

    TelegramInlineKeyboardButton vBtn = new TelegramInlineKeyboardButton ();
    vBtn.text = "🍆 Violet"; vBtn.callbackData = "/violet";

    TelegramInlineKeyboardButton bBtn = new TelegramInlineKeyboardButton ();
    bBtn.text = "🐬 Blue"; bBtn.callbackData = "/blue";

    TelegramInlineKeyboardButton wBtn = new TelegramInlineKeyboardButton ();
    wBtn.text = "⛄ White"; wBtn.callbackData = "/white";
    
    TelegramInlineKeyboardButton gBtn = new TelegramInlineKeyboardButton ();
    gBtn.text = "💸 Green"; gBtn.callbackData = "/green";

    arr.length = 2; arr[0].length = arr[1].length = 2;

    arr[0][0] = vBtn; arr[0][1] = bBtn;
    arr[1][0] = wBtn; arr[1][1] = gBtn;

    keyboard.inlineKeyboard = arr;

    return keyboard;
}
