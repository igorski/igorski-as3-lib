package nl.igorski.lib.audio.oscillators
{
    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.interfaces.IOscillator;

    /**
     * class LowFrequencyOscillator
     *
     * Created by IntelliJ IDEA.
     * User: igor.zinken
     * Date: 27-7-11
     * Time: 16:43
     */
    public class LFO implements IOscillator
    {
        // the wavetypes used for the oscillation
        public static const LFO_SINE_WAVE   :String = "LFO::SineWave";
        public static const LFO_TRIANGLE    :String = "LFO::Triangle";
        public static const LFO_SAWTOOTH    :String = "LFO::Sawtooth";
        public static const LFO_SQUARE_WAVE :String = "LFO::SquareWave";

        protected var TWO_PI_OVER_SR        :Number;
        protected var TWO_PI                :Number;

        public static const MAX_RATE        :Number = 10;   // the maximum rate of oscillation in Hz
        public static const MIN_RATE        :Number = .1;   // the minimum rate of oscillation in Hz

        protected var _phase                :Number = 0.0;
        protected var _phaseIncr            :Number = 0.0;
        protected var _rate                 :Number;        // the oscillation rate in Hz
        protected var _wave                 :String;        // one of the above wavetypes

        //_____________________________________________________________________________________________________________
        //                                                                                        C O N S T R U C T O R

        public function LFO( aWave:String = LFO_TRIANGLE, aRate:Number = MIN_RATE )
        {
            TWO_PI          = 2 * Math.PI;
            TWO_PI_OVER_SR  = TWO_PI / AudioSequencer.SAMPLE_RATE;

            _wave   = aWave;
            rate    = aRate;
        }

        //_____________________________________________________________________________________________________________
        //                                                                                                  P U B L I C

        public function generate():Number
        {
            var output  :Number = 1;
            var tmp     :Number;

            switch( _wave )
            {
                case LFO_SINE_WAVE:

                    if ( _phase < .5 ) {
                        tmp = ( _phase * 4.0 - 1.0 );
                        output = ( 1.0 - tmp * tmp );
                    }
                    else {
                        tmp = ( _phase * 4.0 - 3.0 );
                        output = ( tmp * tmp - 1.0 );
                    }

                    break;

                case LFO_TRIANGLE:

                    output = ( _phase - int( _phase )) * 4;

                    if ( output < 2 )
                        output -= 1;
                    else
                        output = 3 - output;
                    break;

                case LFO_SQUARE_WAVE:

                    if ( _phase < .5 ) {
                        tmp = TWO_PI * ( _phase * 4.0 - 1.0 );
                        output = ( 1.0 - tmp * tmp );
                    }
                    else {
                        tmp = TWO_PI * ( _phase * 4.0 - 3.0 );
                        output = ( tmp * tmp - 1.0 );
                    }
                    break;

                case LFO_SAWTOOTH:

                    tmp    = _phase + .5;
                    output = ( _phase < 0 ) ? _phase - int( _phase - 1 ) : _phase - int( _phase );

                    break;
            }
            _phase += _phaseIncr;
            return output;
        }

        public function getData():Object
        {
            var data:Object = {};

            data.rate   = _rate;
            data.wave   = _wave;

            return data;
        }

        public function setData( data:Object ):void
        {
            rate    = data.rate;
            wave    = data.wave;
        }

        //_____________________________________________________________________________________________________________
        //                                                                                G E T T E R S / S E T T E R S

        public function get rate():Number
        {
            return _rate;
        }

        public function set rate( value:Number ):void
        {
            _rate      = value;
            _phase     = 0.0;
            _phaseIncr = value / AudioSequencer.SAMPLE_RATE;
        }

        public function get wave():String
        {
            return _wave;
        }

        public function set wave( value:String ):void
        {
            _wave = value;
        }

        //_____________________________________________________________________________________________________________
        //                                                                                  E V E N T   H A N D L E R S

        //_____________________________________________________________________________________________________________
        //                                                                                            P R O T E C T E D

        //_____________________________________________________________________________________________________________
        //                                                                                                P R I V A T E
    }
}
