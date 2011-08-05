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

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function ScrollTrack( height:Number )
        {
            _height = height;
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

        // override in subclass
        protected function draw():void
        {
            with( graphics )
            {
                beginFill( 0xFFFFFF );
                drawRect( 0, 0, 10, _height );
                endFill();
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

    }
}
