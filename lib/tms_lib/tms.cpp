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
    addNickname(author);
}

void kimp::Sticker::addAvatar(const std::string avatar) {
    Magick::Image * av = new Magick::Image(avatar);
    av->quality (Magick::NoCompression);
    av->scale(Magick::Geometry(AVATAR_SIZE, AVATAR_SIZE));

    stickerImage->composite(*av, 25, 25);

    delete av;
}

void kimp::Sticker::addNickname (const std::string author) {
    stickerImage->fontFamily("Roboto, Regular");
    stickerImage->fontStyle(Magick::StyleType::BoldStyle);
    stickerImage->fontPointsize(28);

    if (stickerPreset == VIOLET) stickerImage->fillColor(Magick::Color("#ffffff"));
    else if (stickerPreset == GREEN) stickerImage->fillColor(Magick::Color("#9400d3"));
    else stickerImage->fillColor(Magick::Color("#ffffff")); 

    stickerImage->annotate(author, Magick::Geometry (0, 0, AVATAR_SIZE + 25 + 20, 25));
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
