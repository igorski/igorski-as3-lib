package nl.igorski.lib.ui.forms.components
{
    import flash.display.Sprite;
    import flash.events.Event;

    import nl.igorski.definitions.OBLFonts;
    import nl.igorski.views.components.StdTextField;

    /**
     * FormText can be used to display text comments within a Form
     * ...
     * @author Igor Zinken
     */
    public class FormText extends Sprite
    {

        private var _text:String;
        private var _width:int;
        private var tf:StdTextField = new StdTextField( OBLFonts.DEFAULT );

        public function FormText( inText:String = '', inWidth:int = 300 )
        {
            _text  = inText;
            _width = inWidth;
            addEventListener(Event.ADDED_TO_STAGE, initUI);
        }

        private function initUI( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );

            tf.width = _width;
            tf.wordWrap = tf.multiline = true;
            tf.htmlText = _text;
            addChild( tf );
        }
    }
}
