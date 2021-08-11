#include "Magick++/Color.h"
#include "Magick++/Drawable.h"
#include "Magick++/Geometry.h"
#include "Magick++/Image.h"
#include "Magick++/Include.h"
#include "MagickCore/composite.h"
#include "MagickCore/geometry.h"
#include <Magick++.h>
#include <cstddef>
#include <memory>
#include <string>

#include <tms.hpp>

kimp::Sticker::Sticker (const PresetColor preset)  : stickerPreset {preset} { 
    Magick::InitializeMagick(nullptr);
        
    stickerImage = std::unique_ptr<Magick::Image>(new Magick::Image (Magick::Geometry (STICKER_SIZE, STICKER_SIZE), Magick::Color ("transparent")));   
    stickerImage->magick("png"); stickerImage->quality(Magick::NoCompression);
    stickerImage->alpha(true);
}

void kimp::Sticker::fillBackground() {
    stickerImage->read(presets[stickerPreset].backgroundGradient);
}

void kimp::Sticker::addAuthor(const std::string author, const std::string avatar) {
    addAvatar(avatar);
    addNickname(author);
}

void kimp::Sticker::addText(const std::string text) {
    std::unique_ptr<Magick::Image> q = std::unique_ptr<Magick::Image>(new Magick::Image(Magick::Geometry(STICKER_SIZE - 50 - AVATAR_SIZE - 20, STICKER_SIZE - 50 - 28 - 12), Magick::Color("transparent")));

    q->magick("png");
    q->fontFamily("Roboto, Regular");
    //q->fontPointsize(22);
    q->fillColor(presets[stickerPreset].quoteColor);
    q->backgroundColor(Magick::Color("transparent"));
    q->read("CAPTION:" + text);

    stickerImage->composite(*q, Magick::Geometry(0, 0, PADDING_SIZE + AVATAR_SIZE + MARGIN_SIZE, PADDING_SIZE + MARGIN_SIZE * 2), Magick::OverCompositeOp);
}

void kimp::Sticker::addAvatar(const std::string avatar) {
    std::unique_ptr<Magick::Image> av = std::unique_ptr<Magick::Image>(new Magick::Image(avatar));
    av->quality (Magick::NoCompression); av->alpha(true);
    av->scale(Magick::Geometry(AVATAR_SIZE, AVATAR_SIZE));

    std::unique_ptr<Magick::Image> mask = std::unique_ptr<Magick::Image>(new Magick::Image(Magick::Geometry(AVATAR_SIZE, AVATAR_SIZE), Magick::Color("transparent")));
    mask->fillColor(Magick::Color("black"));
    mask->draw(Magick::DrawableCircle(AVATAR_SIZE / 2.0, AVATAR_SIZE / 2.0, 0, AVATAR_SIZE / 2.0));

    av->composite(*mask, 0, 0, MagickCore::DstInCompositeOp);

    stickerImage->composite(*av, PADDING_SIZE, PADDING_SIZE, MagickCore::OverCompositeOp);
}

void kimp::Sticker::addNickname (const std::string author) {
    std::unique_ptr<Magick::Image> n = std::unique_ptr<Magick::Image>(new Magick::Image(Magick::Geometry(STICKER_SIZE - AVATAR_SIZE - 2 * PADDING_SIZE - MARGIN_SIZE, MARGIN_SIZE * 1.5), Magick::Color("transparent")));

    n->magick("png");
    n->fontFamily("Roboto, Regular");
    n->fontPointsize(26);
    n->fillColor(presets[stickerPreset].nicknameColor);
    n->backgroundColor(Magick::Color("transparent"));
    n->textGravity(MagickCore::WestGravity);
    n->read("CAPTION:" + author);

    stickerImage->composite(*n, Magick::Geometry(0, 0, PADDING_SIZE + AVATAR_SIZE + MARGIN_SIZE, PADDING_SIZE), Magick::OverCompositeOp);
}

void kimp::Sticker::save(std::string path)  {
    stickerImage->write (path);
}

int main (int argc, char ** argv) {
    kimp::Sticker * stick = new kimp::Sticker(kimp::VIOLET);
    stick->fillBackground();
    stick->addAuthor("Tigr Baby", "/home/kimp/Downloads/photo_2021-07-31_00-22-35.jpg");
    stick->addText("Яблоко - это ананас!");
    stick->save("woof.png");
    return 0;
}
