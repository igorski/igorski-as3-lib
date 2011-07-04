package nl.igorski.lib.ui.forms.components
{
    /**
     * TextArea, basically a large Input!
     * ...
     * @author Igor Zinken
     */
    public class TextArea extends Input
    {
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function TextArea( placeHolderText:String = "", width:int = 190, height:int = 70 )
        {
            _multiline = true;
            _wordwrap  = true;

            super( placeHolderText, false, false, width, height );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
