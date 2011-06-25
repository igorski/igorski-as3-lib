package nl.igorski.lib.audio.modifiers
{
    import flash.utils.ByteArray;    
    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.interfaces.IBusModifier;

    public class Delay implements IBusModifier
    {
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 21-dec-2010
         * Time: 10:08:50
         */

        /**
         * Delay is a audio modifier that creates an echo effect
         * base mix writing concept by Andre Michelle
         *
         * TODO: currently only works as a bus modifier
         */
        private var _delaySize              :int;
        private var _delayLine              :Vector.<Vector.<Number>>;
        private var _delayWriteIndex        :int;
        private var _mix					:Number;
        private var _feedback				:Number;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        /**
         *
         * @param delayTime
         *        the time ( in milliseconds ) between the original signal and the echo
         *        not we calculate the delaysize by using the samplerate in kHz
         *
         * 		  mix
         * 		  dry / wet mix of delayed signal and original signal
         *
         *        feedback
         *        the amount of signal we return to the echo
         */
        public function Delay( delayTime:Number = 250, mix:Number = .2, feedback:Number = .7 ):void
        {
            _delaySize = Math.round(( AudioSequencer.SAMPLE_RATE * .001 ) * delayTime );
            _delayLine = new Vector.<Vector.<Number>>( _delaySize, true );
            _mix 	   = mix;
            _feedback  = feedback;

            for( var i:int = 0 ; i < _delaySize ; ++i )
                _delayLine[i] = new Vector.<Number>( 2, true ); // STEREO DELAY LINE

            _delayWriteIndex = 0;
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        public function process( sourceLeft:Number, sourceRight:Number, buffer:ByteArray ):void
        {
            var delayLeft   :Number;
            var delayRight  :Number;

            var readIndex   :int;
            
            //-- COMPUTE READ POINT
            readIndex = _delayWriteIndex - _delaySize + 1;
            if( readIndex < 0 )
                readIndex += _delaySize;

            //-- READ FROM DELAY LINE
            delayLeft   = _delayLine[readIndex][0];
            delayRight  = _delayLine[readIndex][1];
            
            //-- WRITE INTO DELAY LINE
            _delayLine[ _delayWriteIndex ][0] = sourceLeft + delayRight * feedback;
            _delayLine[ _delayWriteIndex ][1] = sourceRight + delayLeft * feedback;

            //-- WRITE MIX BACK
            buffer.writeFloat( sourceLeft + delayLeft * _mix );
            buffer.writeFloat( sourceRight + delayRight * _mix );

            //-- MOVE WRITE POINTER
            if( ++_delayWriteIndex == _delaySize )
                _delayWriteIndex = 0;
        }
        
        public function getData():Object
        {
            // might as well be OFF - we due this to prevent it from
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
            return _delaySize / ( AudioSequencer.SAMPLE_RATE * .001 );
        }

        public function set delayTime( value:Number ):void
        {
            _delaySize = Math.round(( AudioSequencer.SAMPLE_RATE * .001 ) * delayTime );
            _delayLine = new Vector.<Vector.<Number>>( _delaySize, true );

            for( var i:int = 0 ; i < _delaySize ; ++i )
                _delayLine[i] = new Vector.<Number>( 2, true );
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
