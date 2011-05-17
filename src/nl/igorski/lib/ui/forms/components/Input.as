package nl.igorski.lib.ui.forms.components
{
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.text.TextFieldType;
    import flash.text.TextFieldAutoSize;
    import flash.utils.*;

    import nl.igorski.definitions.OBLFonts;
    import nl.igorski.lib.ui.forms.components.interfaces.IFormElement;
    import nl.igorski.views.components.StdTextField;

    public class Input extends Sprite implements IFormElement
    {
        public static const BLUR	:String = "Input::BLUR";

        public var textField		:StdTextField;
        private var bg				:Shape = new Shape();
        private var error_bg		:Shape = new Shape();
        private var _text			:String;

        public var placeHolder		:String = "";
        private var intervalId		:uint;

        public function Input( inPlaceHolder:String = "", small:Boolean = false, password:Boolean = false, bgHeight:int = 18 )
        {
            if( inPlaceHolder != null )
                placeHolder = inPlaceHolder;
            _text = placeHolder;

            super();

            if ( !small )
                textField = new StdTextField( OBLFonts.INPUT );
            else
                textField = new StdTextField( OBLFonts.SMALL_INPUT );

            textField.width = bg.width;
            textField.autoSize = TextFieldAutoSize.NONE;
            textField.type = TextFieldType.INPUT;
            textField.embedFonts = true;
            textField.border = false;
            textField.background = false;
            textField.selectable = true;

            if ( password )
                textField.displayAsPassword = true;

            bg.graphics.lineStyle( 1, 0xFFFFFF );
            bg.graphics.beginFill( 0x000000, 1 );
            bg.graphics.drawRect(0, 0, 190, bgHeight);
            bg.graphics.endFill();
            addChild(bg);

            error_bg.graphics.lineStyle(1, 0xFF0000);
            error_bg.graphics.beginFill(0x000000, 1);
            error_bg.graphics.drawRect(0, 0, 190, bgHeight);
            error_bg.graphics.endFill();
            error_bg.alpha = 0;
            addChild(error_bg);

    //		draw();
            addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
        }

        public function noBG():void
        {
            textField.background = false;
            textField.border = false;
            if ( contains( bg )) removeChild( bg );
        }

        public function doBG():void
        {
            textField.background = true;
            textField.border = true;
            addChild( bg );
            swapChildren( textField, bg );
        }

        public function set editable( value:Boolean ):void
        {
            if( value )
                textField.type = TextFieldType.INPUT;
            else
                textField.type = TextFieldType.DYNAMIC;
        }

        public function set smalltext(value:Boolean):void
        {
            textField.setStyle("forminput");
        }

        private function handleAddedToStage(e:Event):void
        {
            draw();
            removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
        }

        public function set multiline( value:Boolean ):void
        {
            textField.multiline = value;
        }

        public function draw():void
        {
            textField.width = bg.width;
            textField.text = _text;
            if ( textField.multiline ) {
                textField.height = bg.height - 2;
                textField.y = Math.round( bg.y + 1 );
            } else {
                textField.height = 18;
                textField.y = Math.round(( bg.height - 20 ) * .5 );
            }
            textField.addEventListener(FocusEvent.FOCUS_IN, handleTextFieldFocus);
            textField.addEventListener(FocusEvent.FOCUS_OUT, handleTextFieldBlur);
            addChild(textField);
        }

        private function handleTextFieldFocus(e:FocusEvent):void
        {
            if ( textField.text == placeHolder )
            {
                textField.text = " "; // for some RETARDED reason, we set a string on focus to prevent hell breaking loose
                textField.setSelection( 0, textField.text.length );
                intervalId = setInterval( handleInterval, 1 );
            }
        }

        private function handleTextFieldBlur(e:FocusEvent):void
        {
            if(textField.text == " " || textField.text == "") {
                textField.text = placeHolder;
            } else {
                if( textField.text.substring( 0,1 ) == " ")
                    textField.text = textField.text.substring(1, textField.text.length);
            }
            dispatchEvent( new Event( BLUR ));
        }

        private function handleInterval():void // and here we clear the screen (to avoid password field annoyances =p)
        {
            clearInterval(intervalId);
            textField.text = "";
        }

        // values are of String type
        public function get val():*
        {
            if( textField.text == placeHolder )
                return "";
            return textField.text;
        }

        public function set val( value:* ):void
        {
            if( value == "" )
                value = placeHolder;

            _text = value;
            textField.text = value;
        }

        public function set border( value:Boolean ):void
        {
            bg.visible = value;
        }

        override public function set tabIndex(value:int):void
        {
            textField.tabIndex = value;
        }

        override public function set tabEnabled(value:Boolean):void
        {
            textField.tabEnabled = true;
        }

        override public function set height(value:Number):void
        {
            bg.height = value;
            error_bg.height = value;
        }

        override public function set width(value:Number):void
        {
            bg.width = value;
            error_bg.width = value;
        }

        public function set wrap(value:Boolean):void
        {
            textField.wordWrap = value;
        }

        public function doError( doMultiline:Boolean = false ):void
        {
            var _time:Number = .5;

            if (contains(textField))
                removeChild(textField);

            var tv:String = textField.text;
            textField = new StdTextField( OBLFonts.INPUT_ERROR );
            textField.multiline = textField.wordWrap = doMultiline;
            textField.width = bg.width;
            textField.autoSize = TextFieldAutoSize.NONE;
            textField.type = TextFieldType.INPUT;
            textField.embedFonts = true;
            textField.background = false;
            textField.selectable = true;
            textField.text = tv;
            addChild( textField );
            draw();
            swapChildren(textField, getChildAt(numChildren - 1));

            bg.alpha = 0;
            error_bg.alpha = 1;
        }

        public function undoError( doMultiline:Boolean = false ):void
        {
            var _time:Number = .5;

            if (contains(textField))
                removeChild(textField);
            var tv:String = textField.text;
            textField = new StdTextField( OBLFonts.INPUT );
            textField.multiline = textField.wordWrap = doMultiline;
            this.val = tv;
            textField.width = bg.width;
            textField.autoSize = TextFieldAutoSize.NONE;
            textField.type = TextFieldType.INPUT;
            textField.selectable = true;
            addChild(textField);
            draw();
            swapChildren(textField, getChildAt(numChildren - 1));

            bg.alpha = 1;
            error_bg.alpha = 0;
        }
    }
}
