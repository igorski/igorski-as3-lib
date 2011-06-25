package nl.igorski.lib.ui.forms.components
{
    import flash.display.Sprite;
    import flash.events.Event;

    import nl.igorski.lib.definitions.Fonts;
    import nl.igorski.lib.ui.components.StdTextField;

    /**
     * FormText can be used to display text comments within a Form
     * ...
     * @author Igor Zinken
     */
    public class FormText extends Sprite
    {
        private var _text   :String;
        private var _width  :int;
        protected var tf    :StdTextField = new StdTextField( Fonts.FORM_TEXT );

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function FormText( text:String = '', width:int = 300 )
        {
            _text  = text;
            _width = width;
            addEventListener(Event.ADDED_TO_STAGE, initUI);
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
            tf.width    = _width;
            tf.wordWrap = tf.multiline = true;
            tf.htmlText = _text;

            tabEnabled  = false;

            addChild( tf );
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

    }
}
