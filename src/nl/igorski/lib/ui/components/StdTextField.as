package nl.igorski.lib.ui.components
{
    import flash.geom.Rectangle;
    import flash.text.AntiAliasType;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    import nl.igorski.lib.definitions.Fonts;

    /*
     * StdTextField creates a styled TextField using externally embedded fonts, be sure
     * that these have been defined by your application using the nl.igorski.lib.definitions.Fonts class!
     */
    public class StdTextField extends TextField
    {
        private var _font        :String;
        private var _textFormat  :TextFormat;
        private var _styleSheet  :StyleSheet;
        private var _useCSS      :Boolean;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function StdTextField( font:String = null, useCSS:Boolean = false )
        {
            super();

            if ( font == null )
                font = Fonts.DEFAULT;

            _font           = font;
            _useCSS         = useCSS;

            autoSize        = TextFieldAutoSize.LEFT;
            embedFonts      = true;
            selectable      = false;

            antiAliasType   = AntiAliasType.ADVANCED;

            // CSS requested ? generate some styles to resemble HTML hyperlink styles
            if ( _useCSS ) {
                _styleSheet         = new StyleSheet();
                var link:Object     = new Object();
                link.textDecoration = "underline";
                _styleSheet.setStyle( "a", link );
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function setFont( font:String ):void
        {
            if ( font != _font || _textFormat == null )
            {
                _font       = font;
                _textFormat = Fonts.getTextFormat( font ), 0, text.length;
            }
            setTextFormat( _textFormat );

            if ( _useCSS )
                styleSheet =  _styleSheet;
        }

        public function setStyleSheet( styleSheet:StyleSheet ):void
        {
            _styleSheet = styleSheet;
            setFont( _font );
        }

        /*
         * this function can pre-calculate the final width the field would
         * occupy if it contained the String passed in the argument
         */
        public function calculateWidth( value:String = null ):Number
        {
            var length:Number = 0;

            if ( value == null )
                return length;

            var oldText:String = text;
            text = value;

            for ( var i:int = 0; i < value.length; ++i )
            {
                var r:Rectangle = getCharBoundaries(i);
                length += r.width;
            }
            text = oldText;
            return length;
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S


        override public function set text( value:String ):void
        {
            super.text = value;

            if(  value != "" )
                setFont( _font );
        }

        override public function set htmlText( value:String ):void
        {
            super.htmlText = value;

            if ( value != "" )
                setFont( _font );
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
