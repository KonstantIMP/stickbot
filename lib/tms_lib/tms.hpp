// Functions and enumeration definition
// Author: KonstantIMP <mihedovkos@gmail.com>
// Date: 9 Aug 2021
#pragma once

#include <Magick++.h>

#include <cstddef>
#include <memory>
#include <map>
#include <string>

namespace kimp {

/**
 * @brief Contains supported color presets for the sticker
 */
enum PresetColor {
    VIOLET, GREEN, BLUE, WHITE
};

/**
 * @brief Class for creating sticker from message
 */
class Sticker {
public:
    /**
     * @brief Static method for importing to the D
     * @param[in] preset Sticker`s color preset
     * @param[in] author C-style string with author
     * @param[in] avatar C-style string with path to the avatar
     * @param[in] text C-style string with quote
     * @param[in] save Path for saving the stick
     */
    static void createSticker (PresetColor preset, const char * author, const char * avatar, const char * text, const char * save);

    /**
     * Init the sticker object and complete Magick init
     * @param [in] preset Color preset for the sticker
     */
    Sticker (const PresetColor preset = VIOLET);

    /**
     * @brief Draws background gradient
     */
    void fillBackground ();

    /**
     * @brief Add user`s avatar and name
     * @param[in] author Author`s name
     * @param[in] avatar Author`s avatar
     */
    void addAuthor (const std::string author, const std::string avatar);

    /**
     * @brief Add qoute to the sticker
     * @param[in] text Quote for adding
     */
    void addText (const std::string text);

    /**
     * @brief Crop the sticker and round corners
     */
    void trim ();

    /**
     * @brief Saves the sticker to the file
     * @param[in] path Path to the new file
     */
    void save (std::string path);
private:
    /**
     * @brief Draws author`s avatar
     * @param[in] avatar Path to the author`s avatar
     */
    void addAvatar (const std::string avatar);

    /**
     * @brief Generate avatar if it does not exsist
     * @param[in] author Authors name
     */
    void genAvatar (const std::string author);

    /**
     * @brief Draws author`s nickname
     * @param[in] author Nickname for display
     */
    void addNickname (const std::string author);

    ///> Image with the sticker
    std::unique_ptr<Magick::Image> stickerImage;
    ///> Used color preset
    PresetColor stickerPreset;
    ///> Value for smart sticker trim
    std::size_t trimSize;

private:
    /**
     * @brief Representation of colored sticker preset
     */
    struct StickerPreset {
        std::string backgroundGradient = ""; ///> String with command for generating background gradient
        std::string nicknameColor      = ""; ///> String with color for nickname
        std::string quoteColor         = ""; ///> String with color for the quite
        std::string avatarGradient     = ""; ///> String with gradiend for avatar generation
        std::string avatarColor        = ""; ///> String with the color for avatar generation
    };

    ///> Map with prebuilt color presets
    std::map<PresetColor, StickerPreset> presets = {
        {VIOLET, StickerPreset{"gradient:#0d324d-#7f5a83", "#ea8df7","white", "gradient:#5f0a87-#a4508b", "white"}},
        {GREEN, StickerPreset{"gradient:#20ded3-#f6fba2", "#007B9D", "#4f4f4f", ""}},
        {BLUE, StickerPreset{"gradient:#b621fe-#1fd1f9", "#1fd1f9", "white", ""}},
        {WHITE, StickerPreset{"gradient:#fffcff-#d5fefd", "#6666ff", "#6495ed", ""}}
    };

    ///> Contains sticker`s size
    const std::size_t STICKER_SIZE = 512;

    ///> Contain`s avatar size
    const std::size_t AVATAR_SIZE  = 72;

    ///> Padding for the sticker`s borders
    const std::size_t PADDING_SIZE = 25;

    ///> Margin between sticker`s elements
    const std::size_t MARGIN_SIZE  = 20;
};

} // namespace kimp
