package nl.igorski.lib.util.audio.generators 
{
    import nl.igorski.lib.util.audio.AudioSequencer;
    /**
     * ...
     * @author Igor Zinken
     */
    public final class BufferGenerator 
    {
        
        public function BufferGenerator() 
        {
            throw new Error( "cannot instantiate BufferGenerator" );
        }

        /*
         * generates an empty stereo buffer to write audio into
         *
         * @length integer containing desired length, when empty will default to buffer size
         * @noise  boolean, when true fills buffer with noise rather than silence
         */
        public static function generate( length:int = -1, noise:Boolean = false ):Vector.<Vector.<Number>>
        {
            if ( length == -1 )
                length = AudioSequencer.BUFFER_SIZE;
              
            // we generate two Vector.<Number> vectors in the output
            // for each channel ( we're working in stereo )
            
            var output:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>( 2, true );
            
            output[0] = new Vector.<Number>( length, true );
            output[1] = new Vector.<Number>( length, true );
            
            for ( var i:int = 0; i < length; ++i )
            {
                var value:Number = ( noise ) ? Math.random() : 0.0;
                output[0][i] = value;
                output[1][i] = value;
            }
            return output;
        }

        /*
         * mixes two audio buffers into one
         *
         * @output source buffer which should be used as the output by the synthesizer class
         * @merge  buffer to be merged with the source / output buffer
         *
         * @level  optional : set the mix level of the merge buffer
         */
        public static function mix( output:Vector.<Vector.<Number>>, merge:Vector.<Vector.<Number>>, position:Number = 0, level:Number = 1 ):void
        {
            var length:int = output[0].length;

            if ( length > merge[0].length )
                length = merge[0].length;

            length -= position;

            for ( var i:int = position; i < length; ++i )
            {
                output[0][i] += ( merge[0][i] * level );
                output[1][i] += ( merge[1][i] * level );
            }
        }
    }
}
