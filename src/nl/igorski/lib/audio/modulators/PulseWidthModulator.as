package nl.igorski.lib.audio.modulators
{
    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.modulators.base.BaseModulator;

    /**
     * class FrequencyModulator
     *
     * Created by IntelliJ IDEA.
     * User: igor.zinken
     * Date: 28-7-11
     * Time: 15:56
     */
    public class PulseWidthModulator extends BaseModulator
    {
        private const PI        :Number = Math.PI;
        private const POW       :Number = PI / 1.05;
        private var phase       :Number = 0;

        //_____________________________________________________________________________________________________________
        //                                                                                        C O N S T R U C T O R
        public function PulseWidthModulator( aWave:String = LFO_TRIANGLE, aRate:Number = MIN_RATE )
        {
           super( aWave, aRate );
        }

        //_____________________________________________________________________________________________________________
        //                                                                                                  P U B L I C


        override public function modulate( value:Number ):Number
        {
            if ( phase == 0 )
                phase = value;

            var amp:Number = 0.75;

//            pos = i + event.position;
//            dpw = Math.sin (pos/0x4800) * pwr; //LFO -> PW
//            sample = phase < Math.PI - dpw ? amp : -amp;
//            phase = phase + (TWO_PI_OVER_SR * BASE_FREQ);
//            phase = phase > TWO_PI ? phase-TWO_PI : phase;
//            am = Math.sin (pos/0x1000); //LFO -> AM
//            event.data.writeFloat(sample * am);
//            event.data.writeFloat(sample * am);

            var pos:int    = generate();
            var dpw:Number = Math.sin( pos / 0x4800 ) * POW; // LFO -> PW

            var sample  :Number = phase < Math.PI - dpw ? amp : -amp;
            phase = phase + ( TWO_PI_OVER_SR * pos );
            phase = phase > TWO_PI ? phase - TWO_PI : phase;

            var am:Number = Math.sin( pos / 0x1000 ); // LFO -> AM
            return sample * am;
        }

        //_____________________________________________________________________________________________________________
        //                                                                                G E T T E R S / S E T T E R S

        //_____________________________________________________________________________________________________________
        //                                                                                  E V E N T   H A N D L E R S

        //_____________________________________________________________________________________________________________
        //                                                                                            P R O T E C T E D

        //_____________________________________________________________________________________________________________
        //                                                                                                P R I V A T E
    }
}
