import tg.bot, std.stdio, kimp.stickbot, kimp.log, std.experimental.logger;

void main (string [] args) {
    if (args.length != 2) {
        stderr.writeln ("[ERROR] Incorrect input data.");
        stderr.writeln ("[ERROR] [USAGE] stickbot <bot_api>");
        return;
    } else {
        sharedLog = new StickBotLogger();

        StickBot stick = new StickBot(args[1]);
    }
}
