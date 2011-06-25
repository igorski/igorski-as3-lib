package nl.igorski.lib.utils
{
    import flash.display.Sprite;
    import flash.events.Event;

    /*
     * because sometimes you just need a quick progress bar
     * to show on loading of objects / processes
     *
     * @author Igor Zinken
     */
    public class ProgressBar extends Sprite
    {
        private var _width	:Number;
        private var _height	:Number;

        private var bg		:Sprite;
        private var bar		:Sprite;
        //_________________________________________________________________________________________________________________
        //                                                                                            C O N S T R U C T O R

        public function ProgressBar( width:Number = 150, height:Number = 2 )
        {
            _width  = width;
            _height = height;

            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        //_________________________________________________________________________________________________________________
        //                                                                                      P U B L I C   M E T H O D S

        public function update( pct:Number ):void
        {
            with( bar.graphics )
            {
                clear();
                beginFill( 0xFFFFFF, 1 );
                drawRect( bg.x, bg.y, ( _width / 100 ) * pct, _height );
                endFill();
            }
        }

        public function close():void
        {
            while ( numChildren > 0 )
                removeChildAt( 0 );
            bg = null;
            bar = null;
        }

        //_________________________________________________________________________________________________________________
        //                                                                                  G E T T E R S  /  S E T T E R S


        //_________________________________________________________________________________________________________________
        //                                                                                      E V E N T   H A N D L E R S


        //_________________________________________________________________________________________________________________
        //                                                                                P R O T E C T E D   M E T H O D S


        //_________________________________________________________________________________________________________________
        //                                                                                    P R I V A T E   M E T H O D S

        private function initUI( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );

            bg = new Sprite();
            with( bg.graphics )
            {
                beginFill( 0x222222, 1 );
                drawRect( 0, 0, _width, _height );
                endFill();
            }
            addChild( bg );

            bar = new Sprite();
            addChild( bar );
        }
    }
}
