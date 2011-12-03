package nl.igorski.lib.audio.generators
{
    import nl.igorski.lib.audio.core.AudioSequencer;
    /**
     * ...
     * @author Igor Zinken
     */
    public final class BufferGenerator 
    {
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function BufferGenerator() 
        {
            throw new Error( "cannot instantiate BufferGenerator" );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /**
         * generates an empty stereo buffer to write audio into
         *
         * @param  length {int} containing desired length, when empty will default to buffer size
         * @return {Array} containing two Number Vectors
         */
        public static function generate( length:int = -1 ):Array
        {
            if ( length == -1 )
                length = AudioSequencer.BUFFER_SIZE;
              
            // we generate two Vector.<Number> vectors in the output
            // for each channel ( we're working in stereo )
            
            var output:Array = [];
            
            output[ 0 ] = new Vector.<Number>( length, true );
            output[ 1 ] = new Vector.<Number>( length, true );
            
            for ( var i:int = 0; i < length; ++i )
            {
                output[ 0 ][ i ] = 0.0;
                output[ 1 ][ i ] = 0.0;
            }
            return output;
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
