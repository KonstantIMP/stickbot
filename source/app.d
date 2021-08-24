import tg.bot, std.stdio, kimp.stickbot;

void main (string [] args) {
    if (args.length != 2) {
        stderr.writeln ("[ERROR] Incorrect input data.");
        stderr.writeln ("[ERROR] [USAGE] stickbot <bot_api>");
        return;
    } else {
        StickBot stick = new StickBot(args[1]);
        stick.loop ();
    }
}
