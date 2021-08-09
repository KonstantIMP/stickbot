import tg.bot, tg.type, std.file;

int main (string [] args) {
    TelegramBot bot = new TelegramBot (args[1]);

    TelegramUpdate [] updates = bot.getUpdates ();
    TelegramUserProfilePhotos photos = bot.getUserProfilePhotos (updates[$ - 1].message().from().id());

    write("logo10.png", bot.downloadFile(bot.getFile(photos.photos[0][0].fileId)));

    return 0;
}
