package nl.igorski.lib.ui.components
{
    import flash.display.Sprite;
    import flash.events.Event;

    import nl.igorski.lib.definitions.Fonts;
    import nl.igorski.lib.interfaces.IDestroyable;
    import nl.igorski.lib.utils.Destroyer;

    /**
     * FeedbackWindow is triggered on validation errors to
     * display these errors ( received from your backend )
     * ...
     * @author Igor Zinken
     */
    public class FeedbackWindow extends Sprite implements IDestroyable
    {
        public static const CLOSE   :String = "FeedbackWindow::CLOSE";

        private var text            :StdTextField;
        private var bg              :Sprite;
        private var close           :CloseButton;

        private var margin          :int = 10;

        private var _doClose        :Boolean;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function FeedbackWindow( width:int = 250, doClose:Boolean = true, font:String = null )
        {
            if ( font == null )
                font = Fonts.FEEDBACK;

            text        = new StdTextField( font );
            text.width  = width;
            _doClose    = doClose;

            text.multiline  = text.wordWrap = true;
            text.x = text.y = margin;

            close = new CloseButton();
            close.addEventListener( CloseButton.REQUEST_CLOSE, handleClose );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function show( inText:String = '' ):void
        {
            text.text = inText;

            draw();
            mouseEnabled = mouseChildren = true;
        }

        // override in subclass for animation purposes
        public function hide():void
        {
            mouseEnabled  =
            mouseChildren = false;

            doHide();
        }

        public function destroy():void
        {
            close.removeEventListener( CloseButton.REQUEST_CLOSE, handleClose );
            Destroyer.destroyDisplayList( this );
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        protected function handleClose( e:Event ):void
        {
            hide();
        }

        protected function doHide():void
        {
            dispatchEvent( new Event( CLOSE ));
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

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

            if ( !contains( close ) && _doClose )
                addChild( close );

            if ( !contains( text ))
                addChild( text );
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
