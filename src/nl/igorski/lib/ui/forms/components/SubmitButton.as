package nl.igorski.lib.ui.forms.components
{
    import flash.display.Sprite;
    import flash.events.Event;

    import nl.igorski.lib.definitions.Fonts;
    import nl.igorski.lib.ui.components.StdTextField;

    /**
     * button that triggers submit event for the entire form
     * ...
     * @author Igor Zinken
     */
    public class SubmitButton extends Sprite
    {
        private var bg      :Sprite;
        private var title   :StdTextField;
        private var _label  :String;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function SubmitButton( label:String )
        {
            _label = label;
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

            useHandCursor = buttonMode = true;
            mouseChildren = false;
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        // override in subclass for custom skinning
        protected function draw():void
        {
            title = new StdTextField( Fonts.LABEL );
            title.x = 10;
            title.y = -1;
            title.text = _label;

            bg = new Sprite();
            with( bg.graphics )
            {
                lineStyle( 1, 0xFFFFFF );
                drawRect( 0, 0, title.width + 20, 16 );
                endFill();
            }
            addChild( bg );

            addChild( title );
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
