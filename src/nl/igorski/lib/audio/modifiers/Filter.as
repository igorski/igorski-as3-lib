package nl.igorski.lib.audio.modifiers
{
    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.interfaces.IModifier;
    import nl.igorski.lib.audio.oscillators.SimpleLFO;

    public final class Filter implements IModifier
    {
        protected var _cutoff       :Number = 0;
        protected var _resonance    :Number = Math.SQRT2;
        protected var _tempCutoff   :Number = 0;    // used for reading when automating via LFO

        // LFO related

        protected var _lfo          :SimpleLFO;
        protected var minFreq       :int;
        protected var maxFreq       :int;
        protected var lfoRange      :int;

        protected var fs            :Number = AudioSequencer.SAMPLE_RATE;

        // filter specific, used internally

        protected var a1            :Number;
        protected var a2            :Number;
        protected var a3            :Number;
        protected var b1            :Number;
        protected var b2            :Number;
        protected var c             :Number;

        protected var in1           :Number;
        protected var in2           :Number;
        protected var out1          :Number;
        protected var out2          :Number;
        protected var output        :Number;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        /**
         *
         * @param aCutoffFrequency {Number} desired cutoff frequency in Hz
         * @param aResonance {Number} resonance
         * @param aMinFreq {int} minimum cutoff frequency in Hz, required for LFO automation
         * @param aMaxFreq {int} maximum cutoff frequency in Hz, required for LFO automation
         * @param aLfoRate {Number} LFO speed in Hz, defaults to 0 which is OFF
         */
        public function Filter( aCutoffFrequency:Number = 8000, aResonance:Number = Math.SQRT2, aMinFreq:int = 20, aMaxFreq:int = 22050, aLfoRate:Number = 0 )
        {
            _resonance = aResonance;
            cutoff     = aCutoffFrequency;
            lfo        = aLfoRate;

            minFreq    = aMinFreq;
            maxFreq    = aMaxFreq;
            lfoRange   = ( maxFreq * .5 ) - minFreq;

            in1 = in2 = out1 = out2 = 0;

            calculateParameters();
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function process( input :Number ):Number
        {
            output = a1 * input + a2 * in1 + a3 * in2 - b1 * out1 - b2 * out2;

            in2  = in1;
            in1  = input;
            out2 = out1;
            out1 = output;

            // oscillator attached to Filter ? travel the cutoff values
            // between the minimum and half way the maximum frequencies, as
            // defined by lfoRange in the class constructor

            if ( _lfo != null )
            {
                _tempCutoff = _cutoff + ( lfoRange * _lfo.generate());

                if ( _tempCutoff > maxFreq )
                    _tempCutoff = maxFreq;

                else if ( _tempCutoff < minFreq )
                    _tempCutoff = minFreq;

                calculateParameters();
            }
            return output;
        }

        public function getData():Object
        {
            var data:Object = {};

            data.cutoff    = _cutoff;
            data.resonance = _resonance;
            data.lfo       = 0;

            if ( _lfo != null )
                data.lfo = _lfo.rate;

            return data;
        }

        public function setData( data:Object ):void
        {
            _resonance = data.resonance;
            cutoff     = data.cutoff;
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        public function set cutoff( frequency:Number ):void
        {
            _cutoff = frequency;

            if ( _cutoff >= AudioSequencer.SAMPLE_RATE * .5 )
                _cutoff = AudioSequencer.SAMPLE_RATE * .5 - 1;

            if ( _cutoff < minFreq )
                _cutoff = minFreq;

            _tempCutoff = _cutoff;

            calculateParameters();
        }

        public function get cutoff():Number
        {
            return _cutoff;
        }

        public function set resonance( resonance:Number ):void
        {
            _resonance = resonance;

            calculateParameters();
        }

        public function get resonance():Number
        {
            return _resonance;
        }

        public function get lfo():Number
        {
            if ( _lfo != null )
                return _lfo.rate;

            return 0;
        }

        public function set lfo( rate:Number ):void
        {
            if ( rate == 0 )
            {
                _lfo        = null;
                _tempCutoff = _cutoff;
                return;
            }

            if ( _lfo == null )
                _lfo = new SimpleLFO( rate );
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        private function calculateParameters():void
        {
            c = 1 / Math.tan( Math.PI * _tempCutoff / fs );
            a1 = 1.0 / ( 1.0 + _resonance * c + c * c);
            a2 = 2 * a1;
            a3 = a1;
            b1 = 2.0 * ( 1.0 - c * c) * a1;
            b2 = ( 1.0 - _resonance * c + c * c) * a1;
        }
    }
}