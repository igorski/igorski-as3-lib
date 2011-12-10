package nl.igorski.lib.utils.statistics
{
    import flash.utils.getTimer;
    /**
     * ...
     * @author Igor Zinken
     * 
     * Profiler is a class for quickly testing the time spent performing
     *          tasks. Note: the function of this class is to give a general
     *          idea which function performs faster than others, for more accurate
     *          timing tests, these functions should be run in inline code
     */
    public final class Profiler 
    {
        private var startTime   :int;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        /*
         * @autoStart set to true to immediately set the startTime
         *            during instantiation
         */
        public function Profiler( autoStart:Boolean = true ) 
        {
            if ( autoStart )
                start();
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /*
         * set the start time, should be set when
         * starting the test
         */
        public function start():void
        {
            startTime = getTimer();
        }
        
        /*
         * set the "end point" for the test, and immediately
         * return the time difference between end and start points
         */
        public function stop():int
        {
            return ( getTimer() - startTime );
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
