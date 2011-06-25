package nl.igorski.lib.audio.helpers
{
    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 21-05-11
     * Time: 15:18
     *
     * TempoHelper provides several functions for basic time / BPM related calculations
     * NOTE: these are set for 4/4 bars ( TODO : extend for flexible time signatures )
     *
     */
    public final class TempoHelper
    {
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function TempoHelper()
        {
            throw new Error( "cannot instantiate TempoHelper" );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /*
         * get the tempo in Beats per Minute from the length
         * of a audio snippet
         *
         * @length       length in milliseconds
         * @amountOfBars the amount of bars the snippet lasts
         *
         */
        public static function getBPMbyLength( length:Number = 1000, amountOfBars:int = 1 ):Number
        {
            // length to seconds
            length *= .001;

            return 240 / ( length / amountOfBars );
        }

        /*
         * get the tempo in Beats per Minute by the length in
         * samples of a audio snippet
         *
         * @length       length in samples
         * @amountOfBars the amount of bars the snippet lasts
         * @sampleRate   sampleRate in Hz
         *
         */
        public static function getBPMbySamples( length:Number = 65536, amountOfBars:int = 1, sampleRate:int = 44100 ):Number
        {
             return 240 / (( length / amountOfBars ) / sampleRate );
        }

        /*
         * return the contents of a given buffer as it's length in milliseconds
         *
         * @bufferSize bufferSize
         * @sampleRate sampleRate in Hz
         */
        public static function bufferToMilliseconds( bufferSize:int = 2048, sampleRate:int = 44100 ):Number
        {
            return bufferSize / ( sampleRate * .001 );
        }

        /*
         * calculate the bitRate of a given audiostream
         *
         * @sampleRate  sampleRate in Hz
         * @bitDepth    bit depth
         * @channels    the amount of audio channels
         *
         */
        public static function getBitRate( sampleRate:int = 44100, bitDepth:int = 16, channels:int = 1 ):Number
        {
            return sampleRate * bitDepth * channels;
        }

        /*
         * calculations within a musical context:
         * calculate the amount of bytes in each beat
         *
         * @tempo          tempo in BPM
         * @bytesPerSample the bytes per sample
         * @sampleRate     the sample rate in Hz
         *
         */
        public static function getBytesPerBeat( tempo:Number = 120, bytesPerSample:int = 8, sampleRate:int = 44100 ):Number
        {
            return Math.round(( 60 / tempo ) * ( sampleRate * bytesPerSample ));
        }

        public static function getBitsPerBeat( tempo:Number = 120, bytesPerSample:int = 8, sampleRate:int = 44100 ):Number
        {
            return getBytesPerBeat( tempo, bytesPerSample, sampleRate ) * 8;
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
