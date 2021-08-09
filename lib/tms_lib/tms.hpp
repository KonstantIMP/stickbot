// Functions and enumeration definition
// Author: KonstantIMP <mihedovkos@gmail.com>
// Date: 9 Aug 2021
#pragma once

#include "Magick++/Include.h"
#include <Magick++.h>

namespace kimp {

///> Contains sticker`s size
const unsigned long STICKER_SIZE = 512;

/**
 * @brief Contains supported color presets for the sticker
 */
enum Preset {
    VIOLET, GREEN, GRAY
};

/**
 * @brief Class for creating sticker from message
 */
class Sticker {
public:
    /**
     * Init the sticker object and complete Magick init
     * @param [in] preset Color preset for the sticker
     */
    Sticker (const Preset preset = VIOLET);

    /**
     * @brief Draws background gradient
     */
    void fillBackground ();

    /**
     * @brief Saves the sticker to the file
     * @param[in] path Path to the new file
     */
    void save (std::string path);

    /**
     * @brief Free memory after using
     */
    ~Sticker ();
private:
    Preset stickerPreset;
    Magick::Image * stickerImage;

};

} // namespace kimp
