package nl.igorski.lib.utils.statistics
{
import nl.igorski.lib.utils.*;
import nl.igorski.lib.utils.external.JavaScript;

/**
     * a quick way to track pages / events in a HTML embedded application, note
     * that the asynchronous ( _gaq ) tracker by Google should be embedded in
     * the same HTML page containing the SWF application
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

        /**
         * track a page visit through Google Analytics
         * @param page String identifier of the page to track */

        public static function track( page:String = "/" ):void
        {
            JavaScript.call( "_gaq.push(['_trackPageview', '" + page + "'])");
        }

        /**
         * track an event through Google Analytics
         *
         * @param category the name you supply for the group of objects you want to track
         * @param action a string that is uniquely paired with each category, and commonly
         *        used to define the type of user interaction for the web object.
         * @param optLabel an optional string to provide additional dimensions to the event data.
         * @param optValue an integer you can pass this to provide numerical data about the user event */

        public static function event( category:String = "", action:String = "", optLabel:String = null, optValue:int = -1 ):void
        {
            if ( optLabel == null )
                JavaScript.call( "_gaq.push(['_trackEvent', '" + category + "', '" + action + "'])");

            else if ( optValue == -1 )
                JavaScript.call( "_gaq.push(['_trackEvent', '" + category + "', '" + action + "', '" + optLabel + "'])");

            else
                JavaScript.call( "_gaq.push(['_trackEvent', '" + category + "', '" + action + "', '" + optLabel + "', '" + optValue + "'])");
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
