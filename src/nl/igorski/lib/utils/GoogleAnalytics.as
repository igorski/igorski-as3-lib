package nl.igorski.lib.utils
{
    import flash.external.ExternalInterface;
    /**
     * a quick way to track pages / events in a HTML embedded
     * application using a JavaScript wrapper ( used for try / catching
     * pushing of _gaq methods in the JavaScript / HTML DOM )
     *
     * @author Igor Zinken
     */
    public final class GoogleAnalytics
    {
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function GoogleAnalytics()
        {
            throw new Error( "cannot instantiate GoogleAnalytics" );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S


        public static function track( page:String = '/' ):void
        {
            JavaScript.call( "GAtrack", page );
        }

        public static function event( category:String = '', action:String = '', item:String = '' ):void
        {
            if ( ExternalInterface.available )
                ExternalInterface.call( "GAevent('" + category + "', '" + action + "', '" + item + "')" );
        }

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
