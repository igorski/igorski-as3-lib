package nl.igorski.lib.utils
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.PixelSnapping;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    
    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 29-04-11
     * Time: 01:21
     */
    public class BitmapTool
    {
        private static const COLOR          :uint = 0xFF;           // default color of BitmapData instance.
        private static const TRANSPARENT    :Boolean = true;        // default transparency of BitmapData instance.
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function BitmapTool()
        {
            throw new Error( "cannot instantiate BitmapTool" );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public static function crop( source:BitmapData, targetWidth:Number = 100, targetHeight:Number = 100, sourceX:Number = -1, sourceY:Number = -1 ):BitmapData
        {
           var cropArea:Rectangle   = new Rectangle( 0, 0, targetWidth, targetHeight );
           var croppedBitmap:Bitmap = new Bitmap( new BitmapData( targetWidth, targetHeight ), PixelSnapping.ALWAYS, true );

           // if crop coordinates weren't passed, create
           // crop from center of image
           if ( sourceX == -1 )
           {
               if ( source.width > targetWidth )
                   sourceX = ( source.width - targetWidth ) * .5;
               else
                   sourceX = 0;
           }
           if ( sourceY == -1 )
           {
               if ( source.height > targetHeight )
                   sourceY = ( source.height - targetHeight ) * .5;
               else
                   sourceY = 0;
           }
           var sourceBMP:Bitmap = new Bitmap( source );
           sourceBMP.smoothing  = true;
           croppedBitmap.bitmapData.draw( sourceBMP, new Matrix( 1, 0, 0, 1, -sourceX, -sourceY ), null, null, cropArea, true );

           sourceBMP = null;

           return croppedBitmap.bitmapData;
        }

        public static function resize( source:BitmapData, targetWidth:Number, targetHeight:Number, preserveRatios:Boolean = true ):BitmapData
        {
           var input:BitmapData  = source.clone();
           var output:BitmapData = new BitmapData( targetWidth, targetHeight, true, 0x00000000 );

           var m:Matrix = new Matrix();

           var ratioX  :Number = targetWidth / input.width;
           var ratioY  :Number = targetHeight / input.height;

           // check if we need to crop the image to preserve its ratios
           if ( ratioX != ratioY && preserveRatios )
           {
               var ratio     :Number = 0;
               var toWidth   :Number = source.width  * ratioX;
               var toHeight  :Number = source.height * ratioY;
               var cropWidth :Number = source.width;
               var cropHeight:Number = source.height;

               if ( toWidth > toHeight ) {
                   ratio = toHeight / toWidth;
                   //cropHeight = source.width * ratio;
                   if ( ratioY > ratioX )
                       cropWidth = cropHeight / ratio;
                   else if ( ratioX > ratioY )
                       cropHeight = cropWidth / ratio;
               }
               else if ( toHeight > toWidth ) {
                   ratio = toHeight / toWidth;
                   cropHeight = source.width * ratio;
               }
               else if ( toHeight == toWidth ) {
                   cropHeight = cropWidth;
               }
               input = crop( input, cropWidth, cropHeight );

               ratioX  = targetWidth / input.width;
               ratioY  = targetHeight / input.height;
           }
           var sourceBMP:Bitmap = new Bitmap( input );
           sourceBMP.smoothing  = true;

           m.scale( ratioX, ratioY );
           output.draw( sourceBMP, m, new ColorTransform(), null, null, true );

           input.dispose();
           sourceBMP = null;

           return output;
        }

        /**
        * Returns horizontally-mirrored instance of supplied BitmapData instance.
        *
        * @param    bmp : BitmapData            BitmapData instance to flip horizontally.
        */
        public static function flipHoriz( bmp:BitmapData ):BitmapData
        {
            //transform.
            var mat:Matrix = new Matrix();
            mat.a = -1;
            mat.tx = bmp.width;
            //copy.
            var flip:BitmapData = new BitmapData(bmp.width, bmp.height, TRANSPARENT, COLOR);
            flip.draw(bmp, mat);
            //dispose bitmapdata instance.
            bmp.dispose();
            //return.
            return flip;
        }

        /**
        * Returns vertically-mirrored instance of supplied BitmapData instance.
        * @param    bmp : BitmapData            BitmapData instance to flip vertically.
        */
        public static function flipVert( bmp:BitmapData ):BitmapData
        {
            //transform.
            var mat:Matrix = new Matrix();
            mat.d = -1;
            mat.ty = bmp.height;
            //copy.
            var flip:BitmapData = new BitmapData(bmp.width, bmp.height, TRANSPARENT, COLOR);
            flip.draw(bmp, mat);
            //dispose bitmapdata instance.
            bmp.dispose();
            //return.
            return flip;
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
