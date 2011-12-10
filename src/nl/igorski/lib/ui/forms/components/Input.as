package nl.igorski.lib.ui.forms.components
{
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.text.TextFieldType;
    import flash.text.TextFieldAutoSize;
    import flash.utils.setTimeout;

    import nl.igorski.lib.definitions.Fonts;
    import nl.igorski.lib.interfaces.IDestroyable;
    import nl.igorski.lib.ui.forms.components.interfaces.IFormElement;
    import nl.igorski.lib.ui.components.StdTextField;
    import nl.igorski.lib.ui.forms.components.interfaces.ITabbableFormElement;

    public class Input extends Sprite implements IFormElement, ITabbableFormElement, IDestroyable
    {
        public static const BLUR    :String = "Input::BLUR";

        protected var textField     :StdTextField;
        protected var bg            :Shape;
        protected var error_bg      :Shape;
        private var _text           :String;

        public var _placeHolderText :String;

        protected var _isSmall      :Boolean;
        protected var _isPassword   :Boolean;
        protected var _width        :int;
        protected var _height       :int;

        protected var _multiline    :Boolean;
        protected var _wordwrap     :Boolean;
        protected var _tabIndex     :int;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function Input( placeHolderText:String = "", isSmall:Boolean = false, isPassword:Boolean = false, width:int = 190, height:int = 18 )
        {
            _placeHolderText = placeHolderText;
            _isSmall         = isSmall;
            _isPassword      = isPassword;
            _width           = width;
            _height          = height;

            _text            = placeHolderText;

            super();
            draw();
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function doError():void
        {
            if ( contains( textField ))
                removeChild( textField );

            var tv:String        = textField.text;

            textField            = new StdTextField( Fonts.INPUT_ERROR );
            textField.multiline  = _multiline;
            textField.wordWrap   = _wordwrap;
            textField.width      = bg.width;
            textField.autoSize   = TextFieldAutoSize.NONE;
            textField.type       = TextFieldType.INPUT;
            textField.embedFonts = true;
            textField.background = false;
            textField.selectable = true;
            textField.text = tv;

            addChild( textField );
            draw();
            swapChildren( textField, getChildAt( numChildren - 1 ));

            tabIndex = _tabIndex;

            bg.alpha = 0;
            error_bg.alpha = 1;
        }

        public function undoError():void
        {
            if ( contains( textField ))
                removeChild( textField );

            var tv:String        = textField.text;
            textField            = new StdTextField( Fonts.INPUT );
            textField.multiline  = _multiline;
            textField.wordWrap   = _wordwrap;
            this.val             = tv;
            textField.width      = bg.width;
            textField.autoSize   = TextFieldAutoSize.NONE;
            textField.type       = TextFieldType.INPUT;
            textField.selectable = true;

            tabIndex = _tabIndex;

            addChild( textField );
            draw();
            swapChildren( textField, getChildAt( numChildren - 1 ));

            bg.alpha = 1;
            error_bg.alpha = 0;
        }

        public function noBG():void
        {
            textField.background = false;
            textField.border     = false;

            if ( contains( bg ))
                removeChild( bg );
        }

        public function doBG():void
        {
            textField.background = true;
            textField.border = true;
            addChild( bg );
            swapChildren( textField, bg );
        }

        public function setSelection( beginIndex:int, endIndex:int ):void
        {
            textField.setSelection( beginIndex, endIndex );
        }

        public function destroy():void
        {
            removeListeners();
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        public function get autoSize():String
        {
            return textField.autoSize;
        }

        public function set autoSize( value:String ):void
        {
            textField.autoSize = value;
        }

        public function set editable( value:Boolean ):void
        {
            if( value )
                textField.type = TextFieldType.INPUT;
            else
                textField.type = TextFieldType.DYNAMIC;
        }

        public function set smalltext( value:Boolean ):void
        {
            textField.setFont( Fonts.SMALL_INPUT );
        }

        public function set multiline( value:Boolean ):void
        {
            _multiline          = value;
            textField.multiline = value;
        }

        // values are of String type
        public function get val():*
        {
            if( textField.text == _placeHolderText )
                return "";

            return textField.text;
        }

        public function set val( value:* ):void
        {
            if( value == "" )
                value = _placeHolderText;

            _text = value;
            textField.text = value;
        }

        public function set border( value:Boolean ):void
        {
            bg.visible = value;
        }

        override public function get tabIndex():int
        {
            return _tabIndex;
        }

        override public function set tabIndex( value:int ):void
        {
            _tabIndex          = value;
            textField.tabIndex = _tabIndex;
            tabEnabled         = true;
        }

        override public function set tabEnabled( value:Boolean ):void
        {
            textField.tabEnabled = true;
        }

        override public function set height( value:Number ):void
        {
            bg.height = value;
            error_bg.height = value;
        }

        override public function set width( value:Number ):void
        {
            bg.width = value;
            error_bg.width = value;
        }

        public function set wrap( value:Boolean ):void
        {
            _wordwrap          = value;
            textField.wordWrap = value;
        }

        public function get textLength():int
        {
            return textField.text.length;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        // we must set a blank space String to prevent strange
        // behaviour occurring when setting focus on an empty text field

        private function handleTextFieldFocus( e:FocusEvent ):void
        {
            if ( textField.text == _placeHolderText )
            {
                textField.text = " ";
                textField.setSelection( 0, textField.text.length );
                setTimeout( handleInterval, 1 );
            }
        }

        private function handleTextFieldBlur( e:FocusEvent ):void
        {
            if ( textField.text == " " || textField.text == "" )
            {
                textField.text = _placeHolderText;

            } else {
                if ( textField.text.substring( 0,1 ) == " " )
                    textField.text = textField.text.substring( 1, textField.text.length );
            }
            dispatchEvent( new Event( BLUR ));
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        // override these in subclass for custom skinning

        protected function draw():void
        {
            bg       = new Shape();
            error_bg = new Shape();

            with ( bg.graphics )
            {
                lineStyle( 1, 0xFFFFFF );
                beginFill( 0x000000, 1 );
                drawRect( 0, 0, _width, _height );
                endFill();
            }
            addChild( bg );

            with ( error_bg.graphics )
            {
                lineStyle( 1, 0xFF0000 );
                beginFill( 0x000000, 1 );
                drawRect( 0, 0, _width, _height );
                endFill();
            }
            error_bg.alpha = 0;
            addChild( error_bg );

            if ( !_isSmall )
                textField = new StdTextField( Fonts.INPUT );
            else
                textField = new StdTextField( Fonts.SMALL_INPUT );

            textField.width      = bg.width;
            textField.autoSize   = TextFieldAutoSize.NONE;
            textField.type       = TextFieldType.INPUT;
            textField.embedFonts = true;
            textField.border     = false;
            textField.background = false;
            textField.selectable = true;
            textField.multiline  = _multiline;
            textField.wordWrap   = _wordwrap;

            if ( _isPassword )
                textField.displayAsPassword = true;

            textField.width = bg.width;
            textField.text  = _text;

            if ( textField.multiline ) {
                textField.height = bg.height - 2;
                textField.y = Math.round( bg.y + 1 );
            } else {
                textField.height = 18;
                textField.y = Math.round(( bg.height - 20 ) * .5 );
            }
            addChild( textField );
            addListeners();
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        private function addListeners():void
        {
            textField.addEventListener( FocusEvent.FOCUS_IN, handleTextFieldFocus );
            textField.addEventListener( FocusEvent.FOCUS_OUT, handleTextFieldBlur );
        }

        private function removeListeners():void
        {
            textField.removeEventListener( FocusEvent.FOCUS_IN, handleTextFieldFocus );
            textField.removeEventListener( FocusEvent.FOCUS_OUT, handleTextFieldBlur );
        }

        // here we clear the field's text content ( avoiding password field annoyances =p )
        private function handleInterval():void
        {
            textField.text = "";
        }
    }
}
