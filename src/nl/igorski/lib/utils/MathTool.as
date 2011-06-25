package nl.igorski.lib.utils
{
    /**
     * amalgamation of some neat functions, some taken with liberty from Google searches, some
     * custom created in the spur of the moment. These offer compact and fast routines, some
     * as faster replacements for the flash Math functions
     *
     * @author Igor Zinken
     */
    public final class MathTool
    {
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function MathTool()
        {
            throw new Error( "cannot instantiate MathTool" );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /*
         * @method rand
         * returns a random number within a given range
         */
        public static function rand( low:Number = 0, high:Number = 1 ):Number
        {
            return Math.round( Math.random() * ( high - low )) + low;
        }

        /*
         * @method scale
         * scales a value against a scale
         * @param value           => value to get scaled to
         * @param maxValue 		  => the maximum value we are likely to expect for param value
         * @param maxCompareValue => the maximum value in the scale we're matching against
         */
        public static function scale( value:Number, maxValue:Number, maxCompareValue:Number ):Number
        {
            var ratio:Number = maxCompareValue / maxValue;
            return value * ratio;
        }

        /**
         * @method deg2rad
         * translates a value in degrees to radians
         */
        public static function deg2rad( deg:Number ):Number
        {
            return deg / ( 180 / Math.PI );
        }

        /**
         * @method rad2deg
         * translates a value in radians to degrees
         */
        public static function rad2deg( rad:Number ):Number
        {
            return rad / ( Math.PI / 180 );
        }

        /*
         * 6 x faster than Math.floor and Math.ceil !!
         * preferably you use these inline in your code when speed is of importance
         */
        public static function floor( value:Number ):int
        {
            return ( value < 0 ) ? int( value - 1 ) : int( value );
        }

        public static function ceil( value:Number ):int
        {
            return int( value + .5 );
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
