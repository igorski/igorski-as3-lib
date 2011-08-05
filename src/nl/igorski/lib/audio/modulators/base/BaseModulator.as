package nl.igorski.lib.audio.modulators.base
{
    import nl.igorski.lib.audio.core.interfaces.IModulator;
    import nl.igorski.lib.audio.oscillators.LFO;

    /**
     * class BaseModulator
     *
     * Created by IntelliJ IDEA.
     * User: igor.zinken
     * Date: 28-7-11
     * Time: 16:18
     *
     *  the base modulation routines rely on a low frequency oscillator for
     * driving the modulation rate, as such these modulators extend the LFO class
     */
    public class BaseModulator extends LFO implements IModulator
    {
        //_____________________________________________________________________________________________________________
        //                                                                                        C O N S T R U C T O R
        public function BaseModulator( aWave:String = LFO_TRIANGLE, aRate:Number = MIN_RATE )
        {
            super( aWave, aRate );
        }

        //_____________________________________________________________________________________________________________
        //                                                                                                  P U B L I C

        /**
         * apply the modulators characteristics to the source signal
         *
         * @param  value the input ( audio ) value
         * @return the modulated value */

        public function modulate( value:Number ):Number
        {
            // override in subclass
            return value;
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
