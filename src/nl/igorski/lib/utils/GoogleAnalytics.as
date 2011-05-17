package nl.igorski.lib.utils
{	
    import flash.external.ExternalInterface;
    /**
     * a quick way to track pages / events in a HTML embedded
     * application with the _gaq JavaScript embedded
     *
     * @author Igor Zinken
     */
    public final class GoogleAnalytics
    {
        public function GoogleAnalytics()
        {
            throw new Error( "cannot instantiate GoogleAnalytics" );
        }

        public static function track( page:String = '/' ):void
        {
            JavaScript.call( "GAtrack", page );
        }

        public static function event( category:String = '', action:String = '', item:String = '' ):void
        {
            if ( ExternalInterface.available )
                ExternalInterface.call( "GAevent('" + category + "', '" + action + "', '" + item + "')" );
        }
    }
}
