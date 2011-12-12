package nl.igorski.lib.audio.modulators
{
    import nl.igorski.lib.audio.modulators.base.BaseModulator;

    /**
     * class AmplitudeModulator
     *
     * Created by IntelliJ IDEA.
     * User: igor.zinken
     * Date: 28-7-11
     * Time: 15:56
     *
     */
    public class AmplitudeModulator extends BaseModulator
    {
        //_____________________________________________________________________________________________________________
        //                                                                                        C O N S T R U C T O R
        public function AmplitudeModulator( aWave:String = LFO_TRIANGLE, aRate:Number = MIN_RATE )
        {
            super( aWave, aRate );
        }

        //_____________________________________________________________________________________________________________
        //                                                                                                  P U B L I C

        override public function modulate( value:Number ):Number
        {
            var theVolume:Number = .5;

            // these can get loud
            if ( _wave == LFO_SINE_WAVE )
                theVolume = 0.05;
            else if ( _wave == LFO_SQUARE_WAVE )
                theVolume = 0.03;

            return value * ( generate() * theVolume );
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
