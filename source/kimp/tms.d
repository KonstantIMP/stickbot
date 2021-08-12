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
