package nl.igorski.lib.ui.components
{
    import flash.display.Sprite;
    import flash.events.Event;
    /**
     * ...
     * @author Igor Zinken
     */
    public class ScrollHandle extends Sprite
    {
        public function ScrollHandle()
        {
            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        private function initUI( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );

            with( graphics )
            {
                // body
                lineStyle( 2, 0x000000 );
                beginFill( 0x000000, 1 );
                drawRoundRect( 0, 0, 12, 35, 3 );
                endFill();
                lineStyle( 1, 0xFFFFFF );
                // arrow up
                moveTo( 3, 9 );
                lineTo( 6, 5 );
                lineTo( 9, 9 );
                // arrow down
                moveTo( 3, 26 );
                lineTo( 6, 30 );
                lineTo( 9, 26 );
            }
        }
    }
}
