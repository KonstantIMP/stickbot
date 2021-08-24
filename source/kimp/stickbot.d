/**
 * StickBot
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 24 Aug 2021
 */
module kimp.stickbot;

import tg.bot, tg.type, kimp.log, kimp.storage, kimp.tms;
import std.exception, std.signals;

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

    /** Local logger object */
    private StickBotLogger logger;
}
