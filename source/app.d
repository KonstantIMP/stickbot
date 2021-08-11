import tg.bot, tg.type, std.file;

int main (string [] args) {
    TelegramBot bot = new TelegramBot (args[1]);

    TelegramUpdate [] updates = bot.getUpdates ();
    

    return 0;
}
