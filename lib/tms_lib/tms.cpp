#include "Magick++/Drawable.h"
#include "Magick++/Geometry.h"
#include "Magick++/Image.h"
#include "Magick++/Include.h"
#include <string>
#include <tms.hpp>

kimp::Sticker::Sticker (const Preset preset)  : stickerPreset {preset} { 
    Magick::InitializeMagick(nullptr);
        
    stickerImage = new Magick::Image (Magick::Geometry (STICKER_SIZE, STICKER_SIZE), Magick::Color ("transparent"));   
    stickerImage->magick("png"); stickerImage->quality(Magick::NoCompression);
}

void kimp::Sticker::fillBackground() {
    if (stickerPreset == VIOLET) {
        stickerImage->read("gradient:#6e45e1-#89d4cf");
    }
    else if (stickerPreset == GREEN) {
        stickerImage->read("gradient:#80ff72-#7ee8fa");
    }
    else {
        stickerImage->read("gradient:#d2ccc4-#2f4353");
    }
}

void kimp::Sticker::addAuthor(const std::string author, const std::string avatar) {
    addAvatar(avatar);
}

void kimp::Sticker::addAvatar(const std::string avatar) {
    Magick::Image * av = new Magick::Image(avatar);
    av->quality (Magick::NoCompression);
    av->scale(Magick::Geometry(108, 108));

    stickerImage->composite(*av, 25, 25);

    delete av;
}

void kimp::Sticker::save(std::string path)  {
    stickerImage->write (path);
}

kimp::Sticker::~Sticker() {
    delete stickerImage;
}

int main (int argc, char ** argv) {
    kimp::Sticker * stick = new kimp::Sticker(kimp::VIOLET);
    stick->fillBackground();
    stick->addAuthor("KonstantIMP", "/home/kimp/Projects/stickBot/logo10.png");
    stick->save("woof.png");
    return 0;
}
