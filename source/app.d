import tg.bot, std.stdio, kimp.loop;

int main (string [] args) {
    if (args.length != 2) {
        stderr.writeln ("[ERROR] Incorrect input data.");
        stderr.writeln ("[ERROR] [USAGE] stickbot <bot_api>");
        return -1;
    }

    TelegramBot stickbot = new TelegramBot(args[1]);
    return botLoop(stickbot);
}
