package nl.igorski.lib.ui.forms.components
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextFieldAutoSize;

    import nl.igorski.lib.definitions.Fonts;
    import nl.igorski.lib.ui.forms.components.interfaces.IFormElement;
    import nl.igorski.lib.ui.components.StdTextField;

    /**
     * a single select option, to be used with Select ( as part of
     * a larger option list ), not as a standalone element
     * ...
     * @author Igor Zinken
     */
    public class SelectOption extends Sprite implements IFormElement
    {
        public static const SELECTED        :String = "SelectOption::SELECTED";

        private var _checked                :Boolean = false;
        private var _value                  :String;
        private var _label                  :String;

        protected var titleField            :StdTextField;
        protected var titleFieldHighlight   :StdTextField;

        private var _alpha                  :Number = 1;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function SelectOption( value:String = "", label:String = "" )
        {
            _value = value;
            _label = label;

            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function activate():void
        {
            checked = true;
        }

        public function deactivate():void
        {
            checked = false;
        }

        public function doError():void
        {

        }

        public function undoError():void
        {

        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        public function get checked():Boolean
        {
            return _checked;
        }

        public function set checked( value:Boolean ):void
        {
            _checked = value;
            _checked ? handleRollOver() : handleRollOut();
        }

        public function get val():*
        {
            return _value;
        }

        public function set val( value:* ):void
        {
            _value = value;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function initUI( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI) ;

            draw();

            addEventListener( MouseEvent.CLICK, handleClick );
            addEventListener( MouseEvent.ROLL_OVER, handleRollOver );
            addEventListener( MouseEvent.ROLL_OUT, handleRollOut );
        }

        protected function handleClick( e:MouseEvent ):void
        {
            dispatchEvent( new Event( SelectOption.SELECTED ));
        }

        protected function handleRollOver( e:MouseEvent = null ):void
        {
            titleFieldHighlight.alpha = 1;
            titleField.alpha          = 0;
        }

        protected function handleRollOut( e:MouseEvent = null ):void
        {
            if ( !checked )
            {
                titleFieldHighlight.alpha = 0;
                titleField.alpha          = _alpha;
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        // override in subclass
        protected function draw():void
        {
            titleField          = new StdTextField( Fonts.LABEL );
            titleFieldHighlight = new StdTextField( Fonts.LABEL );

            titleField.autoSize = titleFieldHighlight.autoSize = TextFieldAutoSize.LEFT;
            titleField.text     = titleFieldHighlight.text     = _label;

            addChild( titleField );
            titleFieldHighlight.alpha = 0;
            addChild( titleFieldHighlight );

            buttonMode    = true;
            mouseChildren = false;
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
