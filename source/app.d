import tg.bot, kimp.log, kimp.stickbot, kimp.exit;

void main (string [] args) {
    StickBotLogger logger = new StickBotLogger();

    if (args.length != 2) {
        logger.error ("Incorrect input data.");
        logger.warning ("USAGE] stickbot <bot_api>");
    } else {
        exitScope (() {
            StickBot stick = new StickBot(args[1]);
            stick.loop ();
        }, () nothrow @nogc @system {
            import core.stdc.stdio;
            printf ("\033[33;1m[WARNING]\033[0m Catched Ctrl+C. Exit.\n");    
        });
    }
}
