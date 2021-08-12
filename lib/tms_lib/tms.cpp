// Functions and enumeration definition
// Author: KonstantIMP <mihedovkos@gmail.com>
// Date: 9 Aug 2021
#include <Magick++.h>
#include <algorithm>
#include <cstddef>
#include <memory>
#include <string>

#include "tms.hpp"

void kimp::Sticker::createSticker (kimp::PresetColor preset, const char * author, const char * avatar, const char * text, const char * save) {
    std::unique_ptr<kimp::Sticker> stick = std::unique_ptr<kimp::Sticker>(new kimp::Sticker(preset));
    stick->fillBackground();
    stick->addAuthor (author, avatar);
    stick->addText (text);
    stick->trim ();
    stick->save (save);
}

kimp::Sticker::Sticker (const PresetColor preset)  : stickerPreset {preset}, trimSize{0} { 
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
    q->fontPointsize(22);
    q->fillColor(presets[stickerPreset].quoteColor);
    q->backgroundColor(Magick::Color("transparent"));
    q->read("CAPTION:" + text);

    q->trim (); trimSize = q->size().height();

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

void kimp::Sticker::trim () {
    std::size_t newHeight = std::max(AVATAR_SIZE + PADDING_SIZE * 2, PADDING_SIZE * 2 + MARGIN_SIZE * 2 + trimSize);

    std::unique_ptr<Magick::Image> mask = std::unique_ptr<Magick::Image>(new Magick::Image(Magick::Geometry(STICKER_SIZE, STICKER_SIZE), Magick::Color("transparent")));
    mask->fillColor(Magick::Color("black")); stickerImage->alpha(true);
    mask->draw(Magick::DrawableRoundRectangle(0, 0, STICKER_SIZE, newHeight, 36, 36));

    stickerImage->composite(*mask, 0, 0, MagickCore::DstInCompositeOp);
    stickerImage->trim();
}

void kimp::Sticker::save(std::string path)  {
    stickerImage->write (path);
}
