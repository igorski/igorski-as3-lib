package nl.igorski.lib.audio.generators.waveforms
{
    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.interfaces.IModifier;
    import nl.igorski.lib.audio.core.interfaces.IModulator;
    import nl.igorski.lib.audio.generators.waveforms.base.BaseWaveForm;

    public final class SquareWave extends BaseWaveForm
    {
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 24-jan-2010
         * Time: 10:46:00
         */
        private const VOLUME_MULTIPLIER :Number = .04;

        private var TWO_PI_OVER_SR      :Number;
        private var TWO_PI              :Number;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function SquareWave( aFrequency:Number = 440, aLength:Number = 1, aDecayTime:int = 70, aAttackTime:Number = 0, aReleaseTime:Number = 0, delta:int = 0, aVolume:Number = 1, aPan:Number = 0 ):void
        {
            TWO_PI          = 2 * Math.PI;
            TWO_PI_OVER_SR  = TWO_PI / AudioSequencer.SAMPLE_RATE;

            super( aFrequency, aLength, aDecayTime, aAttackTime, aReleaseTime, delta, aVolume, aPan );
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        override public function generate( buffer: Vector.<Vector.<Number>> ):void
        {
            var amplitude   :Number;
            var env         :Number;
            var tmp         :Number;

            var theModulator:IModulator;
            var theModifier :IModifier;

            var l           :Vector.<Number> = buffer[0];
            var r           :Vector.<Number> = buffer[1];

            for( var i:int = 0, j:int = _bufferSize; i < j; ++i )
            {
                env = _decay * ENVELOPE_MULTIPLIER;

                if( _phase < .5 ) {
                    tmp = TWO_PI * ( _phase * 4.0 - 1.0 );
                    amplitude = ( 1.0 - tmp * tmp ) * env * env * .5;
                }
                else {
                    tmp = TWO_PI * ( _phase * 4.0 - 3.0 );
                    amplitude = ( tmp * tmp - 1.0 ) * env * env * .5;
                }
                _phase += _phaseIncr;

                if ( _phase >= 1 )
                    --_phase;

                // attack envelope
                if ( _attack > 0 ) {
                    if ( _attackEnv < 1 ) {
                        _attackEnv += _attackIncr;
                        amplitude *= _attackEnv;
                    }
                }
                // release envelope
                if ( _release > 0 )
                {
                    if (  _bufferedSamples >= _releaseStart ) {
                        _releaseEnv -= _releaseIncr;
                        amplitude   *= _releaseEnv;
                    }
                }

                // optional modulation of the wave
                if ( _modulators.length > 0 )
                {
                    for ( var m:int = 0; m < _modulators.length; ++m )
                    {
                        theModulator = _modulators[m];
                        if ( theModulator != null )
                            amplitude = theModulator.modulate( amplitude );
                    }
                }
                // optional modifiers
                if ( _modifiers.length > 0 )
                {
                    for ( m = 0; m < _modifiers.length; ++m )
                    {
                        theModifier = _modifiers[m];
                        if ( theModifier != null )
                            amplitude += theModifier.process( amplitude );
                    }
                }
                l[i] += amplitude * _volumeL;
                r[i] += amplitude * _volumeR;

                if ( _length <= 1 )
                {
                    if( --_decay == 0 )
                        return;

                } else {
                   --_sampleLength;
                   if ( _sampleLength <= 0 )
                        --_length;
                }
                ++_bufferedSamples;
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                        G E T T E R S   /   S E T T E R S

        override public function set volume( value:Number ):void
        {
            super.volume = value;

            // these get loud
            _volumeL *= VOLUME_MULTIPLIER;
            _volumeR *= VOLUME_MULTIPLIER;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
