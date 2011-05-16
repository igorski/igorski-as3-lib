package nl.igorski.lib.util.audio.generators.waveforms
{
    import nl.igorski.lib.util.audio.AudioSequencer;
    import nl.igorski.lib.util.audio.core.interfaces.IModifier;
    import nl.igorski.lib.util.audio.generators.waveforms.base.BaseWaveForm;

    public final class Noise extends BaseWaveForm
    {
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 20-dec-2010
         * Time: 17:02:29
         */
        private const VOLUME_MULTIPLIER :Number = 15;
        
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function Noise( aFrequency:Number = 440, aLength:Number = 1, aDecayTime:int = 1, aAttackTime:Number = 1, aReleaseTime:Number = 0, delta:int = 0, aVolume:Number = .45, aPan:Number = 0, aModifiers:Array = null ):void
        {
            DECAY_MULTIPLIER = 50;

            if ( isNaN( aVolume ))
                aVolume = .45;

            super( aFrequency, aLength, aDecayTime, aAttackTime, aReleaseTime, delta, aVolume, aPan, aModifiers );
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        override public function generate( buffer:Vector.<Vector.<Number>> ):Boolean
        {
           /*
                square(t) = sgn(sin(2 * pi * t))
                sawtooth(t) = t - floor(t + 1/2)
                triangle(t) = abs(sawtooth(t))
            */
            var amplitude   :Number;
            var env         :Number;
            var tmp         :Number;

            var l           :Vector.<Number> = buffer[0];
            var r           :Vector.<Number> = buffer[1];
            
            var division    :Number = 1 / 20000;
            var attackIncr  :Number = 1 / _bufferSize;
            
            for( var i:int = 0, j:int = _bufferSize; i < j; ++i )
            {
                env = _decay * division;

                if( _phase < .5 )
                {
                    tmp = ( _phase * 4.0 - 1.0 );
                    amplitude = ( 1.0 - tmp * tmp ) * env * env * .5;
                }
                else
                {
                    tmp = ( _phase * 4.0 - 3.0 );
                    amplitude = ( tmp * tmp - 1.0 ) * env * env * .5;
                }
                // above we calculated pitch, now we add some
                // randomization to the signal for the actual noise
                amplitude *= Math.random();
                
                _phase += _phaseIncr;

                if ( _phase >= 1 )
                    --_phase;

                // envelopes
                if ( _attack < 1 ) {
                    _attack += attackIncr;
                    amplitude *= _attack;
                }
                if ( _modifiers.length > 0 )
                {
                    for ( var m:int = 0; m < _modifiers.length; ++m )
                    {
                        l[i] += _modifiers[m].process( amplitude * _volumeL );
                        r[i] += _modifiers[m].process( amplitude * _volumeR );
                    }   
                }
                else {
                    l[i] += amplitude * _volumeL;
                    r[i] += amplitude * _volumeR;
                }
                if ( _length <= 1 )
                {
                    if( --_decay == 0 )
                    {
                        return true;
                    }
                } else {
                   --_lengthIncr;
                   if ( _lengthIncr <= 0 )
                        --_length;
                }
            }
            return false;
        }

        //_________________________________________________________________________________________________________
        //                                                                        G E T T E R S   /   S E T T E R S
        
        override public function get volume():Number
        {
            return ( _volumeL / VOLUME_MULTIPLIER ) / ( 1 - _pan );
        }

        override public function set volume( value:Number ):void
        {
            // we multiply the volume as the random function decreases output levels
            var v:Number    = value * VOLUME_MULTIPLIER;
            
            _volumeL        = ( 1 - _pan ) * v;
            _volumeR        = ( _pan + 1 ) * v;
        }
        
        override public function set decay( value:int ):void
        {
            if ( isNaN( value ) || value == 0 )
                value = 70;
            _decay = Math.round( value * DECAY_MULTIPLIER );
        }
        
        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
