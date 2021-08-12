/**
 * Main loop for the bot
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 12 Aug 2021
 */
module kimp.loop;

import tg.bot, tg.type;

import kimp.answer;

import std.experimental.logger, core.thread, std.conv;
import std.array : split;
import std.algorithm : count;

/** 
 * Loop updtaes handling
 * Params:
 *   bot = Bot for updtaes process
 * Returns: Exit code for main
 */
public int botLoop (ref TelegramBot bot) {
    ulong updateOffset = 0;

    try botInit (bot);
    catch (Exception e) {
        error ("Bot error : " ~ e.msg);
        error ("Cannot init the bot. Exiting...");
        return 1;
    }

    while (true) {
        try {
            auto updates = bot.getUpdates (updateOffset);

            foreach (u; updates) {
                if (u.message !is null) handleMessage (bot, u.message);
                else if (u.callbackQuery !is null) handleCallback (bot, u.callbackQuery);
                else log ("Resieved an unsupported method update. Skipping...");

                log ("Handled update : " ~ to!string(u.updateId));
                updateOffset = u.updateId + 1;
            }
        } catch (Exception e) {
            error ("Bot error : " ~ e.msg);
        }

        Thread.sleep (500.msecs);
    }

    return 0;
}

/**
 * Inits the bot
 * Params:
 *   bot = Bot for init
 */
private void botInit (ref TelegramBot bot) {
    log ("Bot init : " ~ bot.bot.firstName ~ ' ' ~ bot.bot.lastName ~ " (" ~ bot.bot.username ~ ')');

    TelegramWebhookInfo webhook = bot.getWebhookInfo ();
    if (webhook.url != "") {
        warning ("The bot has webhook mode enabled! Disbaling...");
        bot.deleteWebhook (true);
    } else log ("The bot does not have enabled webhook mode");
}

/** 
 * Process recieved message
 * Params:
 *   bot = Bot for process
 *   message =  Recieved message
 */
private void handleMessage (ref TelegramBot bot, TelegramMessage message) {
    log ("Recieved TelegramMessage : " ~ to!string(message.messageId));

    if (message.forwardFrom !is null && message.chat.type == "private") {
        log ("Found forwarded message. Process...");
        answerForward (bot, message);
    }
    else {
        if (["/start", "/help", "/q", "/qg", "/qw", "/qb", "/qv"].count (message.text.split(' ')[0])) processCommand (bot, message);
    }
}

/** 
 * Answer recieved command
 * Params:
 *   bot = Bot for process
 *   message = Recieved message with the command
 */
private void processCommand (ref TelegramBot bot, TelegramMessage message) {
    log ("Found command. Processing...");

    if (message.text.split(' ')[0] == "/start") {
        sendStart (bot, message.chat.id);
    }
    else if (message.text.split(' ')[0] == "/help") {
        sendHelp (bot, message.chat.id);
    }
}

/** 
 * Process recieved CallbackQuery
 * Params:
 *   bot = Bot for process
 *   callback = Recieved query
 */
private void handleCallback (ref TelegramBot bot, TelegramCallbackQuery callback) {
    log ("Recieved TelegramCallbackQuery : " ~ to!string(callback.id));

    if (callback.data == "/help") {
        sendHelp (bot, callback.message.chat.id);
    }
}
