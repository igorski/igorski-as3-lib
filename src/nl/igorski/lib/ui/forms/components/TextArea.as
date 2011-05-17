package nl.igorski.lib.ui.forms.components
{
    /**
     * TextArea, basically a large Input!
     * ...
     * @author Igor Zinken
     */
    public class TextArea extends Input
    {

        public function TextArea( inPlaceHolder:String = "", inHeight:int = 70 )
        {
            super( inPlaceHolder, false, false, inHeight );
            style();
        }

        private function style():void
        {
            textField.border = false;
            textField.multiline = true;
            textField.wordWrap = true;
        }

        override public function doError( doMultiline:Boolean = false ):void
        {
            super.doError(true);
        }

        override public function undoError( doMultiline:Boolean = false ):void
        {
            super.undoError(true);
        }
    }
}
