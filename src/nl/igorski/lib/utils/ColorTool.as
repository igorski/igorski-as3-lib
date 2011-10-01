package nl.igorski.lib.utils
{
    import flash.geom.ColorTransform;

    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 01-10-11
     * Time: 13:41
     */
    public class ColorTool
    {
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function ColorTool()
        {
            throw new Error( "cannot instantiate ColorTool" );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /**
         * convert a hexadecimal color to RGB values
         * @param hex {uint} hexadecimal color
         * @return {Object} w/ .r, .g, .b, .a values
         */
        public static function hexToRGB( hex:uint ):Object
        {
            var c:Object = {};

            c.a = hex >> 24 & 0xFF;
            c.r = hex >> 16 & 0xFF;
            c.g = hex >> 8 & 0xFF;
            c.b = hex & 0xFF;

            return c;
        }

        /**
         * convert RGB color object { .r, .g, .b } to a hex color
         * @param c {Object} RGB color
         * @return {uint} hexadecimal color
         */
        public static function RGBtoHex( c:Object ):uint
        {
            return new ColorTransform( 0, 0, 0, 0, c.r, c.g, c.b, 100 ) as uint;
        }

        /**
         * get a color in between two given values
         * @param value {Number} (0-1) percentage to return within the given range
         * @param highColor {uint} the higher color within the range
         * @param lowColor {uint} the lower color within the range
         * @return {uint} the requested color
         */
        public static function getColorInBetween( value:Number = 0.5, lowColor:uint = 0x000000, highColor:uint = 0xFFFFFF ):uint
        {
            var r:uint = highColor >> 16;
            var g:uint = highColor >> 8 & 0xFF;
            var b:uint = highColor & 0xFF;

            r += (( lowColor >> 16 ) - r ) * value;
            g += (( lowColor >> 8 & 0xFF ) - g ) * value;
            b += (( lowColor & 0xFF ) - b ) * value;

            return ( r << 16 | g << 8 | b );
        }

        /**
         * create a shade of a given color
         * @param color {uint} base color
         * @param intensity {int} intensity to shift color palette by
         * @return {uint}
         */
        public static function calculateShade( color:uint, intensity:int = 20 ):uint
        {
            var c:Object = hexToRGB( color );

            for ( var i:String in c )
            {
                c[ i ] += intensity;
                c[ i ] = Math.min( c[ i ], 255 ); // -- make sure below 255
                c[ i ] = Math.max( c[ i ], 0 );   // -- make sure above 0
            }
            return RGBtoHex( c );
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
