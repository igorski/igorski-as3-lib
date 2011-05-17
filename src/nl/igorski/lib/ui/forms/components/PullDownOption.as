package nl.igorski.lib.ui.forms.components
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextFieldAutoSize;

    import nl.igorski.definitions.OBLFonts;
    import nl.igorski.lib.ui.forms.components.interfaces.IFormElement;
    import nl.igorski.views.components.StdTextField;

    /**
     * a single pulldown option, to be used with PullDown ( as part of
     * a option list ), not standalone
     * ...
     * @author Igor Zinken
     */
    public class PullDownOption extends Sprite implements IFormElement
    {

        public static const SELECTED:String = 'PullDownOption::SELECTED';

        private var _checked:Boolean = false;
        private var _value:String = '';
        private var title:String = '';

        public var titleField:StdTextField = new StdTextField( OBLFonts.BUTTON );
        private var titleFieldHighlight:StdTextField = new StdTextField( OBLFonts.BUTTON_OVER );

        private var _alpha:Number = 1;

        public function PullDownOption(inVal:String = null, inTitle:String = null)
        {
            if (inVal != null)
                _value = inVal;
            if (inTitle != null)
                title = inTitle;
            addEventListener(Event.ADDED_TO_STAGE, initUI);
        }

        private function initUI(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, initUI);

            titleField.autoSize = titleFieldHighlight.autoSize = TextFieldAutoSize.LEFT;
            titleField.text = titleFieldHighlight.text = title;

            addChild(titleField);
            titleFieldHighlight.alpha = 0;
            addChild(titleFieldHighlight);

            buttonMode = true;
            mouseChildren = false;

            addEventListener(MouseEvent.CLICK, handleClick);
            addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
            addEventListener(MouseEvent.ROLL_OUT, handleRollOut);
        }

        private function handleClick(e:MouseEvent):void {

            dispatchEvent(new Event(PullDownOption.SELECTED));

        }

        private function handleRollOver(e:MouseEvent = null):void
        {
            titleFieldHighlight.alpha = 1;
            titleField.alpha = 0;
        }

        public function handleRollOut(e:MouseEvent = null):void
        {
            if ( !checked )
            {
                titleFieldHighlight.alpha = 0;
                titleField.alpha = _alpha;
            }
        }

        public function activate():void
        {
            checked = true;
        }

        public function deactivate():void
        {
            checked = false;
        }

        public function get checked():Boolean
        {
            return _checked;
        }

        public function set checked( value:Boolean ):void
        {
            _checked = true;
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
    }
}
