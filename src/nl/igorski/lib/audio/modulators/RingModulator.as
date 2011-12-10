package nl.igorski.lib.audio.modulators
{
    import nl.igorski.lib.audio.modulators.base.BaseModulator;

    /**
     * class RingModulator
     *
     * Created by IntelliJ IDEA.
     * User: igor.zinken
     * Date: 28-7-11
     * Time: 15:56
     */
    public class RingModulator extends BaseModulator
    {
        //_____________________________________________________________________________________________________________
        //                                                                                        C O N S T R U C T O R
        public function RingModulator( aWave:String = LFO_TRIANGLE, aRate:Number = MIN_RATE )
        {
           super( aWave, aRate );
        }

        //_____________________________________________________________________________________________________________
        //                                                                                                  P U B L I C


        override public function modulate( value:Number ):Number
        {
            // TODO very much unfinished
            return Math.cos( 440 * 1 ) * Math.cos( 220 * 1  );

            // output = CARRIER * MODULATOR;
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
