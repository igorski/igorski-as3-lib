package nl.igorski.lib.audio.oscillators
{
    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.interfaces.IOscillator;

    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 09-12-11
     * Time: 14:43
     *
     * SimpleLFO is a very basic oscillator based on
     * a modulating sine wave, for different waveTypes
     * use Class LFO
     */
    public class SimpleLFO implements IOscillator
    {
        protected var _phase                :Number = 0.0;
        protected var _phaseIncr            :Number = 0.0;
        protected var _rate                 :Number;        // the oscillation rate in Hz

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function SimpleLFO( aRate:Number = 0.1 )
        {
            rate = aRate;
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /**
         * generate the oscillator's wave
         * @return Number between -1 and 1
         */
        public function generate():Number
        {
            var tmp         :Number;
            var amplitude   :Number;

            if( _phase < .5 ) {
                tmp = ( _phase * 4.0 - 1.0 );
                amplitude = ( 1.0 - tmp * tmp );
            }
            else {
                tmp = ( _phase * 4.0 - 3.0 );
                amplitude = ( tmp * tmp - 1.0 );
            }
            _phase += _phaseIncr;

            if ( _phase >= 1 )
                --_phase;

            return amplitude;
        }

        public function getData():Object
        {
            var data:Object = {};

            data.rate   = _rate;

            return data;
        }

        public function setData( data:Object ):void
        {
            rate    = data.rate;
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        public function get rate():Number
        {
            return _rate;
        }

        public function set rate( value:Number ):void
        {
            _rate      = value;
            _phaseIncr = value / AudioSequencer.SAMPLE_RATE;
        }

        public function get wave():String
        {
            return "LFO::SineWave";
        }

        public function set wave( value:String ):void
        {
            // nowt...
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

    }
}
