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

            // body
            graphics.lineStyle( 2, 0x000000 );
            graphics.beginFill( 0x000000, 1 );
            graphics.drawRoundRect( 0, 0, 12, 35, 3 );
            graphics.endFill();
            graphics.lineStyle( 1, 0xFFFFFF );
            // arrow up
            graphics.moveTo( 3, 9 );
            graphics.lineTo( 6, 5 );
            graphics.lineTo( 9, 9 );
            // arrow down
            graphics.moveTo( 3, 26 );
            graphics.lineTo( 6, 30 );
            graphics.lineTo( 9, 26 );
        }
    }
}
