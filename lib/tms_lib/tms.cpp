#include <tms.hpp>

kimp::Sticker::Sticker (const Preset preset)  : stickerPreset {preset} { 
    Magick::InitializeMagick(nullptr);
        
    stickerImage = new Magick::Image (Magick::Geometry (STICKER_SIZE, STICKER_SIZE), Magick::Color ("transparent"));   
    stickerImage->magick("png");
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

void kimp::Sticker::save(std::string path)  {
    Magick::InitializeMagick(nullptr);
    stickerImage->write (path);
}

kimp::Sticker::~Sticker() {
    delete stickerImage;
}

int main (int argc, char ** argv) {
    kimp::Sticker * stick = new kimp::Sticker(kimp::GRAY);
    stick->fillBackground();
    stick->save("woof.png");
    return 0;
}
