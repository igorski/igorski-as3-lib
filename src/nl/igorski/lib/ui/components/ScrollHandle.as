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
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function ScrollHandle()
        {
            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function initUI( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );
            draw();
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        // override in subclass for custom skinning
        protected function draw():void
        {
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

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

    }
}
