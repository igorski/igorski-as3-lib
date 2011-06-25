package nl.igorski.lib.ui.components
{
    import flash.geom.Rectangle;
    import flash.text.AntiAliasType;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    import nl.igorski.lib.definitions.Fonts;
    import nl.igorski.lib.utils.StringTool;

    /*
     * StdTextField creates a styled TextField using externally embedded fonts, be sure
     * that these have been defined by your application using the nl.igorski.lib.definitions.Fonts class!
     */
    public class StdTextField extends TextField
    {
        private var styleType	:String;
        private var fontSize	:int = 16;
        private var _styleSheet	:StyleSheet = new StyleSheet();
        private var useCSS		:Boolean;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function StdTextField( inStyleType:String = Fonts.DEFAULT, inFontSize:int = 16, inUseCSS:Boolean = false )
        {
            super();

            if ( inStyleType != null )
                styleType = inStyleType;

            fontSize        = inFontSize;
            useCSS          = inUseCSS;

            autoSize        = TextFieldAutoSize.LEFT;
            embedFonts      = true;
            selectable      = false;

            antiAliasType   = AntiAliasType.ADVANCED;

            // by default we generate standard HTML text styles ( for accenting hyperlinks )
            var link:Object     = new Object();
            link.textDecoration = "underline";
            _styleSheet.setStyle( "a", link );
            link.textDecoration = "none";
            _styleSheet.setStyle( "a:hover", link );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function setStyle( style:String ):void
        {
            setTextFormat( Fonts.getTextFormat( style ), 0, text.length );

            if ( useCSS )
                styleSheet =  _styleSheet;
        }

        public function setSize( fs:int = 12, sub:int = 0 ):void
        {
            var l:Number = text.length;
            setTextFormat( new TextFormat( styleType, fs, 0xFF0000, true ), sub, l );
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
                setStyle( styleType );
        }

        override public function set htmlText( value:String ):void
        {
            super.htmlText = StringTool.html_entity_decode( value );
            if ( value != "" )
                setStyle( styleType );
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
