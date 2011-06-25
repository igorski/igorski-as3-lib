package nl.igorski.lib.definitions
{
    import flash.text.Font;
    import flash.text.TextFormat;
    import flash.utils.Dictionary;
    /**
     * Fonts is a static class used to embed external Fonts, create linkage ID's
     * for these fonts and to return textFormats for use with StdTextField class
     * ...
     * @author Igor Zinken
     */
    
    public class Fonts
    {
        private static var INSTANCE         :Fonts  = new Fonts();
        private var _fontMappings           :Dictionary;

        /*
         * constants defining the font styles ( to be used as accessors for the getTextFormat
         * method ), these are defaults ( used by the nl.igorski.lib.ui.forms.components )
         *
         * it is suggested you use a definitions file for creating your own constants to
         * be used in your application. If you wish to extend this class, bare in mind
         * static variables / methods aren't inherited unless you wrap their accessors!
         * for easy usage with the form elements ( if you're not overriding their draw
         * functions ) you keep the string values of your re-defined constants the same
         *
         */
        public static const DEFAULT         :String = "Fonts::DEFAULT";
        public static const TITLE           :String = "Fonts::TITLE";
        public static const FORM_TEXT       :String = "Fonts::FORM_TEXT";
        public static const LABEL           :String = "Fonts::LABEL";
        public static const FEEDBACK        :String = "Fonts::FEEDBACK";
        public static const INPUT           :String = "Fonts::INPUT";
        public static const SMALL_INPUT     :String = "Fonts::SMALL_INPUT";
        public static const INPUT_ERROR     :String = "Fonts::INPUT_ERROR";
        public static const BUTTON          :String = "Fonts::BUTTON";
        public static const BUTTON_OVER     :String = "Fonts::BUTTON_OVER";

        /*
         * EMBED YOUR FONT CLASSES - preferably in a wrapper class - AS SUCH:
         *
         * each embed needs to be followed by a class definition, don't forget to register the font using the register()
         * method! note that the 'fontName' is used for mapping the styles for the textFormats to be used in your application
         *
         * [Embed(source = "../../../../../fonts/Arial.ttf", fontName = "Arial", mimeType = "application/x-font", embedAsCFF="false")]
         * private var font1:Class;
         *
         */

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function Fonts()
        {
            if ( INSTANCE != null )
                throw new Error( "you cannot instantiate Fonts" );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /*
         * register each embedded font here, you can separate these by comma's
         * allowing you to register the whole list at once
         */
        public static function register( ...fontClasses ):void
        {
            for each( var fontClass:Class in fontClasses )
                Font.registerFont( fontClass );
        }

        /*
         * register a textFormat for a stylename, you can access these from
         * the dictionary by passing the stylename to the getTextFormat method of this class
         */
        public static function mapStyle( styleName:String, fontName:String, fontSize:Number, fontColor:uint, bold:Boolean = false, leading:Number = 0 ):void
        {
            if ( INSTANCE._fontMappings == null )
                INSTANCE._fontMappings = new Dictionary();

            INSTANCE._fontMappings[ styleName ] = new TextFormat( fontName, fontSize, fontColor, bold, null, null, null, null, null, null, null, null, leading );
        }

        /*
         * retrieve a textFormat by it's registered styleName ( as accessed
         * by the stdTextField class upon generation of a styled field )
         *
         * if a non-existing style is requested, this will default to the default
         * style, or to a blank format in case no styles have been mapped by the application!
         *
         */
        public static function getTextFormat( styleName:String ):TextFormat
        {
            if ( INSTANCE._fontMappings[ styleName ] != null ) {
                return INSTANCE._fontMappings[ styleName ];
            } else {
                if ( INSTANCE._fontMappings[ DEFAULT ] != null )
                    return INSTANCE._fontMappings[ DEFAULT ];
                else
                    return new TextFormat();
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
