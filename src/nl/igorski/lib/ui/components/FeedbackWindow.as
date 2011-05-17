package nl.igorski.lib.ui.components
{
    import nl.igorski.lib.definitions.Fonts;
    import flash.display.Sprite;
    import flash.events.Event;

    import nl.igorski.views.components.StdTextField;
    /**
     * FeedbackWindow is triggered on validation errors to
     * display these errors ( received from your backend )
     * ...
     * @author Igor Zinken
     */
    public class FeedbackWindow extends Sprite
    {
        public static const CLOSE	:String = 'FeedbackWindow::CLOSE';

        private var text			:StdTextField;
        private var bg				:Sprite;
        private var close			:CloseButton;

        private var _width			:int;
        private var margin			:int = 10;

        private var doClose			:Boolean;

        public function FeedbackWindow( inWidth:int = 250, inClose:Boolean = true, inFont:String = Fonts.FEEDBACK )
        {
            text = new StdTextField( inFont );
            text.width = inWidth;
            doClose = inClose;

            text.multiline = text.wordWrap = true;
            text.x = text.y = margin;

            close = new CloseButton();
            close.addEventListener( CloseButton.CLICK, handleClose );
        }

        public function show( inText:String = '' ):void
        {
            text.text = inText;

            draw();

            mouseEnabled = mouseChildren = true;
        }

        // override in subclass for custom skinning
        protected function draw():void
        {
            if ( bg == null )
                bg = new Sprite();

            with( bg.graphics )
            {
                clear();
                lineStyle( 1, 0xFFFFFF, .65 );
                beginFill( 0x1b1b1b, .9 );
                drawRect( 0, 0, text.width + ( margin * 2 ), text.height + ( margin * 2 ));
                endFill();
            }
            close.x = bg.width - ( CloseButton.WIDTH * .5 );
            close.y = -( CloseButton.HEIGHT * .5 );

            if ( !contains( bg ))
                addChild( bg );
            if ( !contains( close ) && doClose )
                addChild( close );
            if ( !contains( text ))
                addChild( text );
        }

        // override in subclass for animation purposes
        public function hide():void
        {
            mouseEnabled = mouseChildren = false;
            doHide();
        }

        private function handleClose( e:Event ):void
        {
            hide();
        }

        private function doHide():void
        {
            dispatchEvent( new Event( CLOSE ));
        }
    }
}
