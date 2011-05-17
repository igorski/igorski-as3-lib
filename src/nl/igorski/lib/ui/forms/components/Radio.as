package nl.igorski.lib.ui.forms.components
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import nl.igorski.definitions.OBLFonts;
    import nl.igorski.lib.ui.forms.components.interfaces.IFormElement;
    import nl.igorski.views.components.StdTextField;

    /**
     * a single RadioButton, to be used in a RadioGroup, not standalone.
     * ...
     * @author Igor Zinken
     */
    public class Radio extends Sprite implements IFormElement
    {
        public static const ACTIVATE	:String = 'Radio::ACTIVATE';

        private var bg					:Sprite = new Sprite();
        private var checked_bg			:Sprite = new Sprite();
        private var error_bg			:Sprite = new Sprite();

        private var _checked				:Boolean = false;
        private var _value				:String = '';
        private var title				:String = '';

        private var label				:StdTextField = new StdTextField( OBLFonts.LABEL );

        public function Radio(inVal:String = null, inTitle:String = null)
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

            bg.graphics.lineStyle(1, 0xFFFFFF, 0.3);
            bg.graphics.beginFill(0xa8a7a7, 1);
            bg.graphics.drawCircle(0, 0, 7);
            bg.graphics.endFill();

            error_bg.graphics.lineStyle(1, 0xFFFFFF, 1);
            error_bg.graphics.beginFill(0x000000, 1);
            error_bg.graphics.drawCircle(0, 0, 7);
            error_bg.graphics.endFill();
            error_bg.alpha = 0;

            checked_bg.graphics.beginFill(0x000000, 1);
            checked_bg.graphics.drawCircle(0, 0, 3);
            checked_bg.graphics.endFill();
            checked_bg.alpha = 0;
            checked_bg.x = 0;
            checked_bg.y = 0;

            addChild(bg);
            addChild(error_bg);
            addChild(checked_bg);

            label.text = title;
            label.x = 10;
            label.y = -9;

            addChild(label);

            buttonMode = true;
            mouseChildren = false;

            addEventListener(MouseEvent.CLICK, handleClick);

        }

        private function handleClick(e:MouseEvent):void
        {
            switch( _checked )
            {
                case true:
                    uncheck();
                    break;
                case false:
                    check();
                    dispatchEvent(new Event(Radio.ACTIVATE));
                    break;
            }
        }

        public function check():void
        {
            _checked = true;
            if (checked_bg.alpha < 1)
                checked_bg.alpha = 1;
        }

        public function uncheck():void
        {
            _checked = false;
            if (checked_bg.alpha > 0)
                checked_bg.alpha = 0;
        }

        public function get selected():Boolean
        {
            return _checked;
        }

        public function set selected( value:Boolean ):void
        {
            if ( value )
                check();
            else
                uncheck();
        }

        public function doError():void
        {
            uncheck();
            bg.alpha = 0;
            error_bg.alpha = 1;
        }

        public function undoError():void
        {
            bg.alpha = 1;
            error_bg.alpha = 0;
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
