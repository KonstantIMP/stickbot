/**
 * StickBot
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 24 Aug 2021
 */
module kimp.stickbot;

import tg.bot, tg.type;

import std.experimental.logger;

/** 
 * Class for the StickBot managing
 */
class StickBot : TelegramBot {
    /** 
     * Init`s the bot
     * Params:
     *   tocken = Access tocken for the bot
     */
    public this (string tocken) { super(tocken);
    
    }
}
