package nl.igorski.lib.ui.components
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    /**
     * ...
     * @author Igor Zinken
     */
    public class CloseButton extends Sprite
    {
        public static const CLICK		:String = 'CloseButton::CLICK';
        public static const WIDTH		:int = 18;
        public static const HEIGHT		:int = 18;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function CloseButton()
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

            buttonMode = useHandCursor = true;
            mouseChildren = false;

            addEventListener( MouseEvent.CLICK, handleClick );
            draw();
        }


        protected function handleClick( e:MouseEvent ):void
        {
            dispatchEvent( new Event( CLICK ));
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        // override in subclass for custom skinning
        protected function draw():void
        {
            with( graphics )
            {
                clear();
                lineStyle( 1, 0xFFFFFF );
                beginFill( 0x000000 );
                drawRect( 0, 0, WIDTH, HEIGHT );
                endFill();
                lineStyle( 1, 0xFFFFFF );
                moveTo( WIDTH / 3, HEIGHT / 3 );
                lineTo( ( WIDTH / 3 ) * 2, ( HEIGHT / 3 ) * 2 );
                moveTo( WIDTH / 3, ( HEIGHT / 3 ) * 2 );
                lineTo( ( WIDTH / 3 ) * 2, HEIGHT / 3 );
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
