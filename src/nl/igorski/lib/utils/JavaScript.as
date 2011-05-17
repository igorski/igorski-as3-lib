package nl.igorski.lib.utils
{
    import flash.external.ExternalInterface;

    /*
     * just a quick way to pass and receive
     * values from and to javascript wrapped in
     * ExternalInterface available statement
     */
    public final class JavaScript
    {

        public function JavaScript()
        {
            throw new Error( "cannot instantiate JavaScript" );
        }

        public static function call( javascriptFunction:String, ...functionArguments ):void
        {
            if ( ExternalInterface.available )
                ExternalInterface.call( javascriptFunction, functionArguments );
        }

        public static function get( javascriptFunction:String ):*
        {
            if ( ExternalInterface.available )
                return ExternalInterface.call( javascriptFunction );
        }
    }
}
