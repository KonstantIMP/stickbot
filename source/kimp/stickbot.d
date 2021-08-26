/**
 * StickBot
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 24 Aug 2021
 */
module kimp.stickbot;

import tg.bot, tg.type, tg.core.format, di.i18n, kimp.log, kimp.storage, kimp.tms;
import std.exception, std.signals, std.algorithm, std.array;

/** 
 * Class for the StickBot managing
 */
class StickBot : TelegramBot {
    /** 
     * Init`s the bot
     * Params:
     *   tocken = Access tocken for the bot
     */
    public this (string tocken) { 
        super(tocken); logger = new StickBotLogger();
        logger.log ("StickBot started: ", this.bot().firstName(), " (@", this.bot().username(), ')');
    
        connectSignals ();
    }

    override public void loop (ulong delay = 500) {
        logger.log ("Update loop started...");

        while (true) {
            try super.loop(delay);
            catch (Exception e) logger.error (e.msg);
        }
    }

    /** 
     * Connect slots and signals for the loop
     */
    private void connectSignals () {
        logger.log ("Connect signals: Message and CallbackQuery");
        this.connect (&this.messageRecieved);
        this.connect (&this.callbackQueryRecieved);
    }

    /** 
     * Slot for recieved messages process
     * Params:
     *   bot = Bot recieved the msg
     *   msg = Recieved msg
     */
    private void messageRecieved (TelegramBot bot, TelegramMessage msg) {
        logger.log ("Message recieved: ", msg.messageId);

        if (msg.forwardFrom !is null) processForwardedMessage (msg);
        else if (msg.text.length) {
            if (msg.text[0] == '/') processCommandMessage (msg);
            if (msg.replyToMessage !is null) {
                if (msg.replyToMessage.text.length && msg.replyToMessage.from.id == bot.bot.id) {
                    if (['|', '\\', '/', '-'].count(msg.replyToMessage.text[0])) {
                        PresetColor preset = PresetColor.VIOLET;
                        if (msg.replyToMessage.text[0] == '/') preset = PresetColor.GREEN;
                        else if (msg.replyToMessage.text[0] == '\\') preset = PresetColor.BLUE;
                        else if (msg.replyToMessage.text[0] == '-') preset = PresetColor.WHITE;

                        createSticker (msg.chat, msg.from, msg.text, preset);
                    } else logger.error (msg.messageId, " : Incorrect answer. Incorrect to");
                } else logger.error (msg.messageId, " : Incorrect answer. Empty or reply");
            }
        }
    }

    /** 
     * Process forwarded message
     * Params:
     *   msg = Msg for processing
     */
    private void processForwardedMessage (TelegramMessage msg) {
        logger.log (msg.messageId, " : forwarded message. Process...");

        if (msg.text.length == 0) logger.warning (msg.messageId, " : empty message. Skip...");
        else createSticker (msg.chat, msg.forwardFrom, msg.text);
    }

    /** 
     * Process message with command
     * Params:
     *   msg = Message for process
     */
    private void processCommandMessage (TelegramMessage msg) {
        logger.log (msg.messageId, " : command message. Process...");

        if (msg.text.count('@')) {
            if (msg.text.split('@')[$ - 1].split(' ')[0] != this.bot().username()) {
                logger.error (msg.messageId, " : this message does not for the @", this.bot().username());
                return;
            }
        }

        string command = msg.text.split('@')[0].split(' ')[0];

        if (command == "/start" && msg.chat.type == "private")
            this.sendMessage (msg.chat.id, _f("hello_msg", _("hello_msg"), msg.from.languageCode), TextFormat.None, null, false, false, 0, false, generateStartKeyboard (msg.from.languageCode));
        else if (command == "/help")
            this.sendMessage (msg.chat.id, _f("help_msg", _("help_msg"), msg.from.languageCode), TextFormat.None, null, false, false, 0, false, generateStartKeyboard (msg.from.languageCode, msg.chat.type == "private"));
        else if (["/q", "/qg", "/qw", "/qb"].count(command)) {
            if (msg.replyToMessage is null) logger.error (msg.messageId, " : /q* command without reply to");
            else {
                PresetColor preset = PresetColor.VIOLET;
                if (command == "/qg") preset = PresetColor.GREEN;
                else if (command == "/qw") preset = PresetColor.WHITE;
                else if (command == "/qb") preset = PresetColor.BLUE;

                createSticker (msg.chat, msg.replyToMessage.from, msg.replyToMessage.text, preset);
            }
        }
        else {
            logger.error (msg.messageId, " : Incorrect command");
        }
    }

    /** 
     * Creates and send the sticker
     * Params:
     *   to = Chat to send
     *   author = Author of the quote
     *   text = The quote
     *   preset = Color preset for the stick
     */
    private void createSticker (TelegramChat to, TelegramUser author, string text, PresetColor preset = PresetColor.VIOLET) {
        import std.file : write;

        string avatar = TmpStorage.genTmpFile (), sticker = TmpStorage.genTmpFile ();

        auto photos = this.getUserProfilePhotos(author.id);
        if (photos.totalCount) write (avatar, this.downloadFile(this.getFile(photos.photos[0][$ - 1].fileId)));
        else avatar = "";

        string fullName = author.firstName ~ " " ~ author.lastName ~ '\0';
        Sticker.createSticker (preset, fullName.ptr, (avatar ~ '\0').ptr, (text ~ '\0').ptr, (sticker ~ '\0').ptr);
        this.sendSticker (to.id, TelegramInputFile.createFromFile(sticker));

        if (avatar.length) { TmpStorage.removeTmpFile (avatar); } TmpStorage.removeTmpFile (sticker);
    }

    /** 
     * Slot for callback queries process
     * Params:
     *   bot = Bot recieved the callback
     *   callback = Recieved callback
     */
    private void callbackQueryRecieved (TelegramBot bot, TelegramCallbackQuery callback) {
        logger.log ("Callback query recieved: ", callback.id);

        if (callback.data == "/help")
            this.sendMessage (callback.message.chat.id, _f("help_msg", _("help_msg"), callback.message.from.languageCode), TextFormat.None, null, false, false, 0, false, generateStartKeyboard (callback.message.from.languageCode, callback.message.chat.type == "private"));
        else if (callback.data == "/create")
            this.sendMessage (callback.message.chat.id, _f("create_callback", _("create_callback"), callback.message.from.languageCode), TextFormat.None, null, false, false, 0, false, generateColorKeyboard (callback.message.from.languageCode));
        else if (["/violet", "/green", "/white", "/blue"].count(callback.data)) {
            string color = "| 🍆";
            if (callback.data == "/green") color = "/ 💸";
            else if (callback.data == "/white") color = "- ⛄";
            else if (callback.data == "/blue") color = "\\ 🐬";

            auto fr = new TelegramForceReply ();
            fr.forceReply = true; fr.inputFieldPlaceholder = _f("callback_request_placeholder", _("callback_request_placeholder"), callback.message.from.languageCode);
        
            color = color ~ " " ~ _f("callback_request", _("callback_request"), callback.message.from.languageCode);
        
            this.sendMessage (callback.message.chat.id, color, TextFormat.None, null, false, false, 0, false, fr);
        }
        else logger.error(callback.id, " : Incorrect callback query...");

        this.answerCallbackQuery (callback.id);
    }

    /** 
     * Generate keyboard for the start message
     * Params:
     *   languageCode = Language for keyboard translate
     *   isPrivate = Set true if the keyboard for the private chat
     * Returns: Generated keyboard
     */
    private TelegramInlineKeyboardMarkup generateStartKeyboard (string languageCode, bool isPrivate = true) {
        TelegramInlineKeyboardMarkup keyboard = new TelegramInlineKeyboardMarkup();
        auto keyArr = keyboard.inlineKeyboard();

        auto createBtn = new TelegramInlineKeyboardButton();
        createBtn.text = _f("create_btn", _("create_btn"), languageCode); createBtn.callbackData = "/create";

        auto helpBtn = new TelegramInlineKeyboardButton();
        helpBtn.text = _f("help_btn", _("help_btn"), languageCode); helpBtn.callbackData = "/help";

        auto donateBtn = new TelegramInlineKeyboardButton();
        donateBtn.text = _f("donate_btn", _("donate_btn"), languageCode); donateBtn.url = "https://sobe.ru/na/coffee_and_learning";

        keyArr.length = 1; keyArr[0].length = 3;
        keyArr[0][0] = createBtn; keyArr[0][1] = helpBtn; keyArr[0][2] = donateBtn;

        if (isPrivate == false) keyArr[0] = keyArr[0][1 .. $];

        keyboard.inlineKeyboard = keyArr; return keyboard;
    }

    /** 
     * Creates keuboard for color choose
     * Params:
     *   languageCode = Language for i18n
     * Returns: Generated keyboard
     */
    private TelegramInlineKeyboardMarkup generateColorKeyboard (string languageCode) {
        auto keyboard = new TelegramInlineKeyboardMarkup();
        auto keyArr = keyboard.inlineKeyboard();

        auto vBtn = new TelegramInlineKeyboardButton ();
        vBtn.text = _f("violet_btn", _("violet_btn"), languageCode); vBtn.callbackData = "/violet";

        auto bBtn = new TelegramInlineKeyboardButton ();
        bBtn.text = _f("blue_btn", _("blue_btn"), languageCode); bBtn.callbackData = "/blue";

        auto wBtn = new TelegramInlineKeyboardButton ();
        wBtn.text = _f("white_btn", _("white_btn"), languageCode); wBtn.callbackData = "/white";
        
        auto gBtn = new TelegramInlineKeyboardButton ();
        gBtn.text = _f("green_btn", _("green_btn"), languageCode); gBtn.callbackData = "/green";

        keyArr.length = 2; keyArr[0].length = keyArr[1].length = 2;

        keyArr[0][0] = vBtn; keyArr[0][1] = bBtn;
        keyArr[1][0] = wBtn; keyArr[1][1] = gBtn;

        keyboard.inlineKeyboard = keyArr; return keyboard;
    }

    /** Local logger object */
    private StickBotLogger logger;
}
