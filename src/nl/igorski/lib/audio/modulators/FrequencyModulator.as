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
    public class FrequencyModulator extends BaseModulator
    {
        private var modulator			:Number;
        private var carrier				:Number;
        private var AMP_MULTIPLIER		:Number = 0.15;
        private var fmamp				:Number = 10;

        //_____________________________________________________________________________________________________________
        //                                                                                        C O N S T R U C T O R
        public function FrequencyModulator( aWave:String = LFO_TRIANGLE, aRate:Number = MIN_RATE )
        {
           super( aWave, aRate );

            modulator       = TWO_PI;
            carrier         = TWO_PI;
        }

        //_____________________________________________________________________________________________________________
        //                                                                                                  P U B L I C


        override public function modulate( value:Number ):Number
        {
            modulator = modulator + ( TWO_PI_OVER_SR * _rate );
            modulator = modulator < TWO_PI ? modulator : modulator - TWO_PI;
            carrier   = value;

            return value * Math.cos( carrier + fmamp * Math.cos( modulator ))/* * AMP_MULTIPLIER*/;
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
