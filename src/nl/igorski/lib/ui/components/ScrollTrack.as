package nl.igorski.lib.ui.components
{
    import flash.display.Sprite;
    import flash.events.Event;
    /**
     * ...
     * @author Igor Zinken
     */
    public class ScrollTrack extends Sprite
    {
        private var _height	:Number;

        public function ScrollTrack( height:Number )
        {
            _height = height;
            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        private function initUI( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );

            with( graphics )
            {
                lineStyle( 1, 0xFFFFFF );
                moveTo( 3, 0 );
                lineTo( 0, _height );
            }
        }
    }
}
