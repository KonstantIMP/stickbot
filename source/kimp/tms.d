/**
 * Interface for TMS lib
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 12 Aug 2021
 */
module kimp.tms;

extern (C++, kimp) {
    /**
     * Contains supported color presets for the sticker
     */
    enum PresetColor {
        VIOLET, GREEN, BLUE, WHITE
    }

    extern (C++, struct) {

        /**
        * Class for creating sticker from message
        */
        class Sticker {
            /** Disbale ctor because we import just static methods */
            @disable this();
            /**
             * Creates new Telegram sticker
             * Params:
             *   preset = Color preset for the stick
             *   author = Nickname of the author
             *   avatar = Path to the author`s avatar
             *   text = quote for the stick
             *   save = Sticker`s save path
             */
            static public void createSticker (PresetColor preset, const(char)* author, const(char)* avatar, const(char)* text, const(char)* save);
        }

    }
}

/** 
 * Converts PresetColor to the string
 * Params:
 *   p = Preset for convertion
 * Returns: String with preset
 */
string presetToString (PresetColor p) {
    if (p == PresetColor.WHITE) return "white";
    if (p == PresetColor.VIOLET) return "violet";
    if (p == PresetColor.GREEN) return "green";
    return "blue";
}

/** 
 * Converts string to the PresetColor
 * Params:
 *   s = String for convertion
 * Returns: PresetColor
 */
PresetColor stringToPreset (string s) {
    if (s == "white") return PresetColor.WHITE;
    if (s == "violet") return PresetColor.VIOLET;
    if (s == "green") return PresetColor.GREEN;
    return PresetColor.BLUE;
}
