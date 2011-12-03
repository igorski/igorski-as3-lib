package nl.igorski.lib.audio.modifiers
{
    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.interfaces.IBusModifier;

    public final class Delay implements IBusModifier
    {
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 21-dec-2010
         * Time: 10:08:50
         *
         * TODO: currently only works as a bus modifier
         */
        private var _delayBuffer            :Vector.<Vector.<Number>>;
        private var _delayIndex             :int;
        private var _time                   :int;
        private var _mix                    :Number;
        private var _feedback               :Number;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        /**
         * @param delayTime {Number} in milliseconds, time between consecutive repeats
         * @param mix       {Number} 0-1, percentage of dry/wet mix
         * @param feedback  {Number} 0-1, amount of repeats
         */
        public function Delay( delayTime:Number = 250, mix:Number = .2, feedback:Number = .7 ):void
        {
            _time = Math.round(( AudioSequencer.SAMPLE_RATE * .001 ) * delayTime );
            _delayBuffer = new Vector.<Vector.<Number>>( _time, true );
            _mix       = mix;
            _feedback  = feedback;

            for( var i:int = 0 ; i < _time ; ++i )
                _delayBuffer[ i ] = new Vector.<Number>( 2, true );

            _delayIndex = 0;
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        /**
         * run an audio signal through the delay line
         *
         * @param sampleBuffer {Array} containing two Number Vectors
         */
        public function process( sampleBuffer:Array ):void
        {
            var inputLeft   :Vector.<Number> = sampleBuffer[ 0 ];
            var inputRight  :Vector.<Number> = sampleBuffer[ 1 ];
            var delayLeft   :Number;
            var delayRight  :Number;

            var readIndex   :int;

            for ( var i:int = 0, j:int = sampleBuffer[ 0 ].length; i < j; ++i )
            {
                readIndex = _delayIndex - _time + 1;

                if( readIndex < 0 )
                    readIndex += _time;

                // read the previously delayed samples from the buffer
                // ( for feedback purposes ) and append the current sample to it

                delayLeft   = _delayBuffer[ readIndex ][ 0 ];
                delayRight  = _delayBuffer[ readIndex ][ 1 ];

                _delayBuffer[ _delayIndex ][ 0 ] = inputLeft[ i ]  + delayLeft * feedback;
                _delayBuffer[ _delayIndex ][ 1 ] = inputRight[ i ] + delayRight * feedback;

                if( ++_delayIndex == _time )
                    _delayIndex = 0;

                // stamp the echo onto the buffer
                inputLeft[ i ]  += ( delayLeft * _mix );
                inputRight[ i ] += ( delayRight * _mix );
            }
        }
        
        public function getData():Object
        {
            // might as well be OFF - we do this to prevent it from
            // being saved as it's not removed from the sequencer's busModifiers
            if ( mix == 0 && feedback == 0 )
                return null;
            
            var data:Object = { };
            
            data.delayTime  = delayTime;
            data.mix        = mix;
            data.feedback   = feedback;
            
            return data;
        }

        //_________________________________________________________________________________________________________
        //                                                                        G E T T E R S   /   S E T T E R S
        
        public function get delayTime():Number
        {
            return _time / ( AudioSequencer.SAMPLE_RATE * .001 );
        }

        public function set delayTime( value:Number ):void
        {
            _time = Math.round(( AudioSequencer.SAMPLE_RATE * .001 ) * delayTime );
            _delayBuffer = new Vector.<Vector.<Number>>( _time, true );

            for( var i:int = 0 ; i < _time ; ++i )
                _delayBuffer[i] = new Vector.<Number>( 2, true );
        }

        public function get mix():Number
        {
            return _mix;
        }

        public function set mix( value:Number ):void
        {
            _mix = value;
        }

        public function get feedback():Number
        {
            return _feedback;
        }

        public function set feedback( value:Number ):void
        {
            _feedback = value;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
