package nl.igorski.lib.ui.forms.components
{
    import flash.display.GradientType;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix;

    /**
     * Divider simply adds a line break between form elements
     * ...
     * @author Igor Zinken
     */
    public class Divider extends Sprite
    {
        private var _width   :int;
        private var _height  :int;
        private var line     :Sprite;

        public function Divider( inHeight:int = 0, inWidth:int = 0 )
        {
            _height = inHeight;
            _width  = inWidth;

            addEventListener(Event.ADDED_TO_STAGE, initUI);
        }

        private function initUI(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, initUI);
            draw();
        }

        // override in subclass for custom skinning
        protected function draw():void
        {
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(_width, 1, 0, 0, 0);

            line = new Sprite();
            with( line.graphics )
            {
                lineStyle(1);
                lineGradientStyle(GradientType.LINEAR, [0xFFFFFF, 0x666666], [0.65, 0.65], [0, 255], matrix);
                lineTo(_width, 0);
            }
            line.y = _height * .5;
            line.x = - 27;

            addChild( line );
        }
    }
}
