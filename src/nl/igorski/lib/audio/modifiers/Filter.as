package nl.igorski.lib.audio.modifiers
{
    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.interfaces.IModifier;

    public class Filter implements IModifier
    {
        protected var f     :Number = 0;
        protected var r     :Number = Math.SQRT2;
        protected var fs    :Number = AudioSequencer.SAMPLE_RATE;

        protected var a1    :Number;
        protected var a2    :Number;
        protected var a3    :Number;
        protected var b1    :Number;
        protected var b2    :Number;
        protected var c     :Number;

        protected var in1   :Number;
        protected var in2   :Number;
        protected var out1  :Number;
        protected var out2  :Number;
        protected var output:Number;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function Filter( cutoffFrequency:Number = 8000, resonance:Number = Math.SQRT2 )
        {
            f = cutoffFrequency;
            r = resonance;

            in1 = in2 = out1 = out2 = 0;

            calculateParameters();
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function process( input :Number ):Number
        {
            output = a1 * input + a2 * in1 + a3 * in2 - b1 * out1 - b2 * out2;

            in2 = in1;
            in1 = input;
            out2 = out1;
            out1 = output;

            return output;
        }

        public function getData():Object
        {
            var data:Object = { };

            data.cutoff    = f;
            data.resonance = r;

            return data;
        }

        public function setData( data:Object ):void
        {
            f = data.cutoff;
            r = data.resonance;
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        public function set cutoffFrequency( frequency : Number ) : void
        {
            f = frequency;
            if ( f >= AudioSequencer.SAMPLE_RATE * .5 )
                f = AudioSequencer.SAMPLE_RATE * .5 - 1;

            if ( f <= 0 )
                f = 20;

            calculateParameters();
        }

        public function get cutoffFrequency():Number
        {
            return f;
        }

        public function set resonance( resonance:Number ):void
        {
            r = resonance;
            calculateParameters();
        }

        public function get resonance():Number
        {
            return r;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        private function calculateParameters():void
        {
            c = 1 / Math.tan( Math.PI * f / fs );
            a1 = 1.0 / ( 1.0 + r * c + c * c);
            a2 = 2 * a1;
            a3 = a1;
            b1 = 2.0 * ( 1.0 - c * c) * a1;
            b2 = ( 1.0 - r * c + c * c) * a1;
        }
    }
}