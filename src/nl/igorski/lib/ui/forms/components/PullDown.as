package nl.igorski.lib.ui.forms.components
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import nl.igorski.lib.ui.components.ScrollBlock;
    import nl.igorski.lib.ui.forms.components.interfaces.IFormElement;

    /**
     * PullDown acts as the HTML SelectBox
     * masks several options within a container and shows them after user interaction
     *
     * @author Igor Zinken
     */
    public class PullDown extends Sprite implements IFormElement
    {
        private var arrowUp		:Sprite = new Sprite();
        private var arrowDown	:Sprite = new Sprite();

        private var title		:String;
        private var items		:Array;
        private var options		:Array;

        private var _height		:int;
        private var toggle		:Sprite;
        private var opened		:Boolean = false;

        private var _mask		:Sprite;
        private var bg			:Sprite;
        private var container	:ScrollBlock;
        private var current		:Bitmap;

        public function PullDown(inTitle:String, inItems:Array, inHeight:int = 125)
        {
            title = inTitle;
            items = inItems;
            _height = inHeight;

            addEventListener(Event.ADDED_TO_STAGE, initUI);

        }

        private function initUI(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, initUI);

            draw();

            buildList();
            toggle.addEventListener(MouseEvent.CLICK, handleToggle);
        }

        // override in subclass for skinning purposes
        protected function draw():void
        {
            _mask = new Sprite();
            with( _mask.graphics )
            {
                beginFill(0xFF0000, 0);
                drawRect(0, 0, 185, 18);
                endFill();
            }
            addChild(_mask);

            bg = new Sprite();
            addChild(bg);

            toggle = new Sprite();
            toggle.y = 5;
            toggle.x = 192;
            arrowUp.alpha = 0;
            toggle.addChild(arrowUp);
            toggle.addChild(arrowDown);
            toggle.buttonMode = true;
            toggle.mouseChildren = false;
            addChild(toggle);
        }

        private function buildList():void {

            var count:int = 0;
            var margin:int = 20;
            options = [];

            var window:Sprite = new Sprite();

            for each(var item:Array in items) {

                var input:PullDownOption = new PullDownOption(item[0], item[1]);
                input.addEventListener(PullDownOption.SELECTED, handleOptionSelect);
                window.addChild(input);
                input.x = 6;
                input.y = count * margin;
                options.push(input);
                ++count;

            }

            container = new ScrollBlock(window, _mask.width - 50, 150, 0, true);
    //			container.addEventListener(MouseEvent.ROLL_OUT, hideList);
            container.mask = _mask;
            container.alpha = 0;
            addChild(container);

            if (options.length > 0) {
                options[0].activate();
                cloneSelection(options[0]);
            }

            hideList();

        }

        public function update(inItems:Array):void {

            items = inItems;
            if (items.length == 0 || !items) items = [];

            if (container != null) {
                if (contains(container)) removeChild(container);
                container.removeEventListener(MouseEvent.ROLL_OUT, hideList);
                container = null;
            }

            for each(var b:PullDownOption in options) {
                if (b != null) {
                    b.removeEventListener(PullDownOption.SELECTED, handleOptionSelect);
                    b = null;
                }
            }

            if (current != null) {
                if (contains(current)) removeChild(current);
            }

            options = null;
            buildList();

        }

        private function handleOptionSelect(e:Event):void {

            for each(var b:PullDownOption in options) b.deactivate();
            var curButton:PullDownOption = PullDownOption(e.target);

            curButton.activate();
            cloneSelection(curButton);

            container.scrollTo(curButton);
            hideList();

        }

        private function cloneSelection(b:PullDownOption):void {

            if (b == null) return;

            try {
                if (current != null)
                    current.bitmapData.dispose();
                var bmpd:BitmapData = new BitmapData(b.width, b.height, true, 0x00000000);
                bmpd.draw(b);
                current = new Bitmap(bmpd);
                current.x = 6;
                current.y = 0;
                if (!contains(current))
                    addChild(current);
            } catch (e:Error) {

            }
        }

        public function get val():*
        {
            for each( var b:PullDownOption in options )
            {
                if ( b.checked )
                    return b.val;
            }
            return '';
        }

        public function set val( value:* ):void
        {
            for each( var b:PullDownOption in options )
            {
                b.checked = ( b.val == value );
            }
        }

        private function handleToggle(e:MouseEvent):void
        {
            switch( opened )
            {
                case true:
                    hideList();
                    break;
                case false:
                    showList();
                    break;
            }
        }

        private function showList():void
        {
            opened = true;
            if (container != null)
                container.mask = null;

            bg.graphics.clear();
            bg.graphics.lineStyle(1, 0xFFFFFF, 0.5);
            bg.graphics.beginFill(0x000000, 1);
            bg.graphics.drawRect(_mask.x, _mask.y, _mask.width, 150);
            bg.graphics.endFill();

            if (current != null)
                removeChild(current);

            container.alpha = 1;
            arrowDown.alpha = 0;
            arrowUp.alpha   = 1;
        }

        private function hideList(e:MouseEvent = null):void
        {
            opened = false;
            if (container != null)
                container.mask = _mask;

            bg.graphics.clear();
            bg.graphics.lineStyle(1, 0xFFFFFF, 0.5);
            bg.graphics.beginFill(0x000000, 1);
            bg.graphics.drawRect(_mask.x, _mask.y, _mask.width, 18);
            bg.graphics.endFill();

            if (current != null)
                addChild(current);

            container.alpha = 0;
            arrowDown.alpha = 1;
            arrowUp.alpha   = 0;
        }
    }
}
