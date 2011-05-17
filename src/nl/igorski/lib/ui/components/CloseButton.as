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

        public function CloseButton()
        {
            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        private function initUI( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );

            buttonMode = useHandCursor = true;
            mouseChildren = false;

            addEventListener( MouseEvent.CLICK, handleClick );
            draw();
        }

        private function handleClick( e:MouseEvent ):void
        {
            dispatchEvent( new Event( CLICK ));
        }

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
    }
}
