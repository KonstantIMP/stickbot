#include "Magick++/Color.h"
#include "Magick++/Drawable.h"
#include "Magick++/Geometry.h"
#include "Magick++/Image.h"
#include "Magick++/Include.h"
#include "MagickCore/composite.h"
#include <Magick++.h>
#include <cstddef>
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
    q->fontFamily("Roboto");
    q->fontPointsize(18);
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
    stickerImage->fontFamily("Roboto, Regular");
    stickerImage->fontStyle(Magick::StyleType::BoldStyle);
    stickerImage->fontPointsize(28);

    stickerImage->fillColor(Magick::Color(presets[stickerPreset].nicknameColor));

    stickerImage->annotate(author, Magick::Geometry (0, 0, AVATAR_SIZE + PADDING_SIZE + MARGIN_SIZE, PADDING_SIZE));
}

void kimp::Sticker::save(std::string path)  {
    stickerImage->write (path);
}

int main (int argc, char ** argv) {
    kimp::Sticker * stick = new kimp::Sticker(kimp::VIOLET);
    stick->fillBackground();
    stick->addAuthor("KonstantIMP", "/home/kimp/Projects/stickBot/logo10.png");
    stick->addText("Когда-то, я подскользнулся на льду. Чтобы не упасть я выкрикрнул: \"Свинка Пеппа\". И это сработало!");
    stick->save("woof.png");
    return 0;
}
