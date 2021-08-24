/**
 * StickBot
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 24 Aug 2021
 */
module kimp.stickbot;

import tg.bot, tg.type;

import kimp.log;

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
        logger.log ("StickBot started : ", this.bot().firstName(), " (@", this.bot().username(), ')');
    }

    /** Local logger object */
    private StickBotLogger logger;
}
