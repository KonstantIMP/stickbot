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

    /** Local logger object */
    private StickBotLogger logger;
}
