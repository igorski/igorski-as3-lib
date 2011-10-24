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
         * convert a hexadecimal color to RGB values w/ alpha channel
         * @param hex {uint} hexadecimal color
         * @return {Object} w/ .r, .g, .b, .a values
         */
        public static function hexToRGBA( hex:uint ):Object
        {
            var c:Object = {};

            c.r = hex >> 16 & 0xFF;
            c.g = hex >> 8 & 0xFF;
            c.b = hex & 0xFF;
            c.a = hex >> 24 & 0xFF;

            return c;
        }

        /**
         * convert RGB color object { .r, .g, .b } to a hex color
         *
         * @param red   {int} the red value
         * @param green {int} the green value
         * @param blue  {int} the blue value
         *
         * @return {uint} hexadecimal color
         */
        public static function RGBtoHex( red:int, green:int, blue:int ):uint
        {
            return new ColorTransform( 0, 0, 0, 0, red, green, blue, 100 ) as uint;
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
