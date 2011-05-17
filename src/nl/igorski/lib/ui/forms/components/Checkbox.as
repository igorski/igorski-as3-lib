package nl.igorski.lib.ui.forms.components
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import nl.igorski.definitions.OBLFonts;
    import nl.igorski.lib.ui.forms.components.interfaces.IFormElement;
    import nl.igorski.views.components.StdTextField;
    /**
     * ...
     * @author Igor Zinken
     */
    public class Checkbox extends Sprite implements IFormElement
    {
        private var bg			:Sprite = new Sprite();
        private var checked_bg	:Sprite = new Sprite();
        private var error_bg	:Sprite = new Sprite();

        private var _checked	:Boolean = false;
        private var title		:String = '';
        private var labelWidth	:int = 0;

        private var label		:StdTextField = new StdTextField( OBLFonts.DEFAULT );

        public function Checkbox(inTitle:String = null, inLabelWidth:int = 250)
        {
            if (inTitle != null)
                title = inTitle;
            labelWidth = inLabelWidth;

            addEventListener(Event.ADDED_TO_STAGE, initUI);
        }

        private function initUI(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, initUI);

            draw();

            addEventListener(MouseEvent.CLICK, handleClick);
        }

        // override in subclass for custom skinning
        protected function draw():void
        {
            with ( bg.graphics )
            {
                lineStyle(1, 0x000000, 0.3);
                beginFill(0xFFFFFF, 1);
                drawRect(0, 0, 15, 15)
                endFill();
            }
            with( checked_bg.graphics )
            {
                beginFill(0x33384f, 1);
                drawRect(0, 0, 7, 7);
                endFill();
            }
            checked_bg.x = 4;
            checked_bg.y = 4;

            with( error_bg.graphics )
            {
                lineStyle(1, 0xFFFFFF, 1);
                beginFill(0x000000, 1);
                drawRect(0, 0, 10, 10);
                endFill();
            }
            error_bg.alpha = 0;

            addChild(bg);
            addChild(error_bg);

            label.wordWrap = true;
            label.width = labelWidth;
            label.text = title;
            label.x = 22;
            label.y = -2;

            // addChild(label);
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
                    break;
            }
        }

        public function check():void
        {
            _checked = true;
            if (!contains(checked_bg))
                addChild(checked_bg);
        }

        public function uncheck():void
        {
            _checked = false;
            if (contains(checked_bg))
                removeChild(checked_bg);
        }

        public function doError():void
        {
            var _time:Number = .5;
            uncheck();

            bg.alpha = 0;
            error_bg.alpha = 1;
        }

        public function undoError():void
        {
            var _time:Number = .5;
            bg.alpha = 1;
            error_bg.alpha = 0;
        }

        public function get val():*
        {
            return _checked;
        }

        public function set val( value:* ):void
        {
            _checked = value;
        }

        // "HTML properties"
        public function get checked():Boolean
        {
            return _checked;
        }

        public function set checked( value:Boolean ):void
        {
            _checked = value;
        }

        /*
         * returns bit values instead of Boolean values
         * for this object's checked state
         */
        public function get numericVal():int
        {
            return ( _checked ) ? 1 : 0;
        }

        public function set numericVal( value:int ):void
        {
            _checked = ( value == 1 );
        }
    }
}
