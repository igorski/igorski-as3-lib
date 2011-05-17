package nl.igorski.lib.ui.forms.components
{
    import flash.display.Sprite;
    import flash.events.Event;

    import nl.igorski.lib.ui.forms.components.interfaces.IFormElement;

    /**
     * ...
     * @author Igor Zinken
     */
    public class RadioGroup extends Sprite implements IFormElement
    {

        public static const CHANGE:String = 'RadioGroup::CHANGE';

        private var title:String;
        private var buttons:Array;
        private var maxWidth:int;
        private var radios:Array = [];

        public function RadioGroup(inTitle:String, inButtons:Array, inMaxWidth:int = 200)
        {
            title = inTitle;
            maxWidth = inMaxWidth;
            buttons = inButtons;

            addEventListener(Event.ADDED_TO_STAGE, initUI);

        }

        private function initUI(e:Event):void {

            removeEventListener(Event.ADDED_TO_STAGE, initUI);

            var col:int = 0;
            var row:int = 0;
            var maxCols:int = 2;
            var secondCol:int = 130;

            for (var i:int = 0; i < buttons.length; ++i) {

                ++col;

                var r:Radio = new Radio(buttons[i][0], buttons[i][1]);
                addChild(r);
                r.addEventListener(Radio.ACTIVATE, handleClick);
                r.x = 8;
                if (i % 2) r.x += secondCol;
                r.y = (row * r.height) + 8;
                radios.push(r);

                if (i > 0 && buttons.length == 2) {
                    r.x = radios[i - 1].x + radios[i - 1].width + 10;
                }

                if (col >= maxCols) {
                    col = 0;
                    ++row;
                }

            }

            if (buttons.length <= 2) x = secondCol;

        }

        private function handleClick(e:Event):void {

            undoError();

            unselectAll();
            e.target.check();
            dispatchEvent(new Event(RadioGroup.CHANGE));

        }

        public function activate(num:int):void
        {
            unselectAll();
            var count:int = 0;

            for each(var r:Radio in radios)
            {
                if ( count == num )
                    r.check();
                ++count;
            }
            dispatchEvent( new Event( RadioGroup.CHANGE ));
        }

        public function get val():*
        {
            for each(var r:Radio in radios)
            {
                if ( r.selected )
                    return r.val;
            }
            return '';
        }

        public function set val( value:*):void
        {
            for each( var r:Radio in radios )
                 r.selected = ( r.val == value );
        }

        public function doError():void
        {
            for each (var r:Radio in radios)
                r.doError();
        }

        public function undoError():void
        {
            for each (var r:Radio in radios)
                r.undoError();
        }

        public function unselectAll():void
        {
            for each(var r:Radio in radios )
                r.uncheck();
        }
    }
}
