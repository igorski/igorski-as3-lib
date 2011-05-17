package nl.igorski.definitions
{
    import flash.text.Font;
import flash.text.TextFormat;

import nl.igorski.managers.ColorSchemeManager;

/**
     * ...
     * @author Igor Zinken
     */
    
    public class OBLFonts
    {
        private static var INSTANCE         :OBLFonts = new OBLFonts();

        // font styles
        public static const DEFAULT         :String = "Fonts::DEFAULT";
        public static const TITLE           :String = "Fonts::TITLE";
        public static const LABEL           :String = "Fonts::LABEL";
        public static const PLUGIN_LABEL    :String = "Fonts::PLUGIN_LABEL";
        public static const PITCH           :String = "Fonts::PITCH";
        public static const SONG_TITLE      :String = "Fonts::SONG_TITLE";
        public static const AUTHOR          :String = "Fonts::AUTHOR";
        public static const FEEDBACK        :String = "Fonts::FEEDBACK";
        // form related styles
        public static const INPUT           :String = "Fonts::INPUT";
        public static const SMALL_INPUT     :String = "Fonts::SMALL_INPUT";
        public static const INPUT_ERROR     :String = "Fonts::INPUT_ERROR";
        public static const BUTTON          :String = "Fonts::BUTTON";
        public static const BUTTON_OVER     :String = "Fonts::BUTTON_OVER";

        // font classes
        [Embed(source = "../../../../lib/fonts/CaviarDreams.ttf", fontName = "FontThin", mimeType = "application/x-font", embedAsCFF="false")]
        private var f1:Class;
        
        [Embed(source = "../../../../lib/fonts/REZB____.TTF", fontName = "FontTitle", mimeType = "application/x-font-truetype", embedAsCFF="false")]
        private var f2:Class;
        
        public function OBLFonts()
        {
            if ( INSTANCE != null )
                throw new Error( "you cannot instantiate FontManager" );
        }
        
        public static function init():void
        {
            Font.registerFont( INSTANCE.f1 );
            Font.registerFont( INSTANCE.f2 );
        }

        public static function getTextFormat( style:String ):TextFormat
        {
            var tf:TextFormat;

            switch( style )
            {
                default:
                case DEFAULT:
                    tf = new TextFormat( "FontThin", 14, 0x000000, true );
                    break;
                case TITLE:
                    tf = new TextFormat( "FontTitle", 16, 0xFFFFFF, true );
                    break;
                case PITCH:
                    tf = new TextFormat( "FontThin", 12, 0x000000, true, null, null, null, null, null, null, null, null, 13 );
                    break;
                case LABEL:
                    tf = new TextFormat( "FontThin", 14, 0x000000, true, null, null, null, null, null, null, null, null, 13 );
                    break;
                case PLUGIN_LABEL:
                    tf = new TextFormat( "FontTitle", 12, ColorSchemeManager.PLUGIN_BACKGROUND, true );
                    break;
                // song entries
                case SONG_TITLE:
                    tf = new TextFormat( "FontTitle", 34, 0x000000, true );
                    break;
                case AUTHOR:
                    tf = new TextFormat( "FontThin", 16, 0xFFFFFF, true );
                    break;
            }
            return tf;
        }
    }
}
