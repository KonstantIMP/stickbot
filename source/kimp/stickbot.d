/**
 * StickBot
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 24 Aug 2021
 */
module kimp.stickbot;

import tg.bot, tg.type, kimp.log;
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
