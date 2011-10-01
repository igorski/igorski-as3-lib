package nl.igorski.lib.utils
{
    import flash.external.ExternalInterface;

    /*
     * just a quick way to pass and receive
     * values from and to javascript wrapped in
     * ExternalInterface available statements
     */
    public final class JavaScript
    {
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function JavaScript()
        {
            throw new Error( "cannot instantiate JavaScript" );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /**
         * calls a JavaScript function and passes optional arguments
         *
         * @param javascriptFunction String name of the function embedded in the HTML page
         * @param functionArguments  several comma-separated values to be passed to the function */

        public static function call( javascriptFunction:String, ...functionArguments ):void
        {
            if ( ExternalInterface.available )
                ExternalInterface.call( javascriptFunction, functionArguments );
        }

        /**
         * call a function and retrieve it's return value
         *
         * @param  javascriptFunction String name of the function embedded in the HTML page
         */
        public static function get( javascriptFunction:String ):*
        {
            if ( ExternalInterface.available )
                return ExternalInterface.call( javascriptFunction );
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
