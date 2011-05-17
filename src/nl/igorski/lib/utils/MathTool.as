package nl.igorski.lib.utils
{
    /**
     * amalgamation of some neat functions, some taken with liberty from Google searches, some
     * custom created in the spur of the moment. These offer compact and fast routines
     *
     * @author Igor Zinken
     */
    public final class MathTool
    {
        public function MathTool()
        {
            throw new Error( "cannot instantiate MathTool" );
        }

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
    }
}
