package nl.igorski.lib.audio.generators.waveforms.base
{
    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.interfaces.IBufferModifier;
    import nl.igorski.lib.audio.core.interfaces.IModifier;
    import nl.igorski.lib.audio.core.interfaces.IModulator;
    import nl.igorski.lib.audio.core.interfaces.IWave;
    import nl.igorski.lib.audio.model.vo.VOEnvelopes;
    import nl.igorski.lib.utils.MathTool;

    /**
     * class BaseWaveForm
     *
     * Created by IntelliJ IDEA.
     * User: igor.zinken
     * Date: 13-4-11
     * Time: 10:11
     *
     * BaseWaveForm is the base class for all sound wave generating classes
     * implementing the IWave interface */

    public class BaseWaveForm implements IWave
    {
        protected var DECAY_MULTIPLIER          :int = 200;
        protected var ENVELOPE_MULTIPLIER       :Number = 1 / 20000;
        protected var DEFAULT_FADE_DURATION     :int = 64;

        protected var _delta                    :int;     // position of this wave in the sequencer
        protected var _phase                    :Number;  // phase of the wave, creates pitch
        protected var _phaseIncr                :Number;  // step value for the wave form
        protected var _frequency                :Number;  // pitch in Hz
        protected var _length                   :Number;  // length of the wave ( in sequencer steps )
        protected var _sampleLength             :int;     // length of the wave ( in samples )

        protected var _attack                   :Number;  // attack time ( 1 = entire sample length )
        protected var _attackIncr               :Number;  // step value for attack envelope operations ( per sample )
        protected var _attackEnv                :Number;  // the current value for the attack envelope
        protected var _decay                    :int;     // decay, creates wave length
        protected var _decayStart               :int;     // sample position where the decay is decreased
        protected var _decayIncr                :Number;  // step value for decay envelope operations
        protected var _release                  :Number;  // release time ( 1 = entire sample length )
        protected var _releaseStart             :int;     // sample position where the release envelope starts
        protected var _releaseIncr              :Number;  // step value for release envelope operations ( per sample )
        protected var _releaseEnv               :Number;  // the current value for the release envelope

        protected var _volume                   :Number;  // overall voice volume ( used for retrieval purposes )
        protected var _volumeL                  :Number;  // volume of left channel ( regulated by pan )
        protected var _volumeR                  :Number;  // volume of right channel ( regulated by pan )
        protected var _pan                      :Number;  // pan value ( -1 = left, 0 = center, 1 = right )
        protected var _bufferSize               :int;     // buffer size, taken from AudioSequencer

        protected var _active                   :Boolean;    // whether we should generate audio for this voice
        protected var _bufferedSamples          :int;        // amount of samples processed by generate();
        protected var _modifiers                :Vector.<IModifier>;  // list of optional modifiers
        protected var _modulators               :Vector.<IModulator>; // list of optional modulators

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        /**
         * @param aFrequency   the frequency in Hz of the note to be synthesized
         * @param aLength      the duration of the synthesized frequency
         * @param aDecayTime   decay of the generated soundwave
         * @param aAttackTime  attack curve of the generated soundwave
         * @param aReleaseTime release curve of the generated soundwave
         * @param aDelta       position of this wave in the sequencer
         * @param aVolume      volume of the generated wave
         * @param aPan         position in the stereo field of the generated wave
         */
        public function BaseWaveForm( aFrequency:Number, aLength:Number, aDecayTime:int, aAttackTime:Number, aReleaseTime:Number, aDelta:int, aVolume:Number, aPan:Number ):void
        {
            _length         = isNaN( aLength ) ? 1 : aLength;
            _sampleLength   = _length * AudioSequencer.BYTES_PER_TICK;
            _frequency      = aFrequency;
            _delta          = aDelta;
            _bufferSize     = AudioSequencer.BUFFER_SIZE;
            decay           = aDecayTime;
            attack          = isNaN( aAttackTime ) ? 0 : aAttackTime;
            release         = isNaN( aReleaseTime ) ? 0 : aReleaseTime;

            _releaseStart   = _sampleLength;

            _phase          = 0.0;
            _phaseIncr      = aFrequency / AudioSequencer.SAMPLE_RATE;

            if ( isNaN( aPan ))
                aPan    = 0;
            if ( isNaN( aVolume ))
                aVolume = .65;

            _pan        = aPan;
            volume      = aVolume;

            _modifiers  = new Vector.<IModifier>();
            _modulators = new Vector.<IModulator>();

            _bufferedSamples = 0;
            _active     = true;
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        public function generate( buffer:Array, pointer:int = -1 ):void
        {
            /* override in your subclass, this is where all
             * the calculations are performed that shape
             * the waveform and send them through their modifiers */
        }

        /* envelopes */

        public function getData():VOEnvelopes
        {
            var output:VOEnvelopes = new VOEnvelopes();

            output.volume  = volume;
            output.pan     = pan;
            output.attack  = attack;
            output.decay   = decay;
            output.release = release;

            return output;
        }

        public function setData( data:VOEnvelopes ):void
        {
            volume  = data.volume;
            pan     = data.pan;
            attack  = data.attack;
            decay   = data.decay;
            release = data.release;
        }

        /* modulators */

        public function getAllModulators():Vector.<IModulator>
        {
            return _modulators;
        }

        public function setAllModulators( value:Vector.<IModulator> ):void
        {
            if ( value != null )
                _modulators = value;
            else
                _modulators = new Vector.<IModulator>();
        }

        public function getModulator( modulatorClass:Class ):IModulator
        {
            var modulator:IModulator;

            for ( var i:int = 0; i < _modulators.length; ++i )
            {
                modulator = _modulators[i];

                if ( modulator != null && modulator is modulatorClass )
                    return modulator;
            }
            return null;
        }

        public function setModulator( modulator:IModulator ):void
        {
            _modulators.push( modulator );
        }

        public function removeModulator( modulatorClass:Class ):void
        {
            var theModulator:IModulator;

            for ( var i:int = _modulators.length - 1; i >= 0; --i )
            {
                theModulator = _modulators[i];

                if ( theModulator != null && theModulator is modulatorClass ) {
                    _modulators.splice( i,  1 );
                    theModulator = null;
                    break;
                }
            }
        }

        /* modifiers */

        public function getAllModifiers():Vector.<IModifier>
        {
            return _modifiers;
        }

        /**
         * IBufferModifiers work on entire buffer ranges at once, as such
         * these are called by the AudioProcessor class. IBufferModifiers
         * should only be used when the modifiers have constantly shifting
         * properties, or for delay based effects
         *
         * @return {Vector.<IBufferModifier>}
         */
        public function getAllBufferModifiers():Vector.<IBufferModifier>
        {
            var out:Vector.<IBufferModifier> = new <IBufferModifier>[];

            for each( var m:IModifier in _modifiers )
            {
                if ( m is IBufferModifier )
                    out.push( m );
            }
            return out;
        }

        /**
         * regular IModifier modifiers are performed during generation
         * of a waveform, this method returns only these modifiers
         *
         * @return {Vector.<IModifier>}
         */
        public function getAllNonBufferModifiers():Vector.<IModifier>
        {
            var out  :Vector.<IModifier> = new <IModifier>[];
            var isBuf:Boolean;

            for each( var m:IModifier in _modifiers )
            {
                isBuf = m is IBufferModifier;

                if ( !isBuf )
                    out.push( m );
            }
            return out;
        }

        public function setAllModifiers( value:Vector.<IModifier> ):void
        {
            if ( value != null )
                _modifiers = value;
            else
                _modifiers = new <IModifier>[];
        }

        public function getModifier( modifierClass:Class ):IModifier
        {
            var modifier:IModifier;

            for ( var i:int = 0; i < _modifiers.length; ++i )
            {
                modifier = _modifiers[i];

                if ( modifier != null && modifier is modifierClass )
                    return modifier;
            }
            return null;
        }

        public function setModifier( modifier:IModifier ):void
        {
            _modifiers.push( modifier );
        }

        public function removeModifier( modifierClass:Class ):void
        {
            var theModifier:IModifier;

            for ( var i:int = _modifiers.length - 1; i >= 0; --i )
            {
                theModifier = _modifiers[i];

                if ( theModifier != null && theModifier is modifierClass )
                {
                    _modifiers.splice( i,  1 );
                    theModifier = null;
                    break;
                }
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                        G E T T E R S   /   S E T T E R S

        // note instructions
        public function set delta( value:Number ):void
        {
            _delta = value;
        }

        public function set frequency( value:Number ):void
        {
            _phaseIncr = value / AudioSequencer.SAMPLE_RATE;
        }

        public function set length( value:Number ):void
        {
            _length         = isNaN( value ) ? 1 : value;
            _sampleLength   = _length * AudioSequencer.BYTES_PER_TICK;
        }

        public function get active():Boolean
        {
            return _active;
        }

        public function set active( value:Boolean ):void
        {
            _active = value;
        }

        // envelopes
        public function get volume():Number
        {
            return _volume;
        }

        public function set volume( value:Number ):void
        {
            if ( isNaN( value ))
                value = 1;

            _volume = value;

            // panned left
            if ( _pan < 0 ) {
                _volumeL = value;
                _volumeR = ( _pan + 1 ) * value;
            }
            // panned right
            else {
                _volumeL = ( 1 - _pan ) * value;
                _volumeR = value;
            }
        }

        public function get attack():Number
        {
            return _attack;
        }

        public function set attack( value:Number ):void
        {
            if ( !isNaN( value ))
                _attack = value;

            // no attack set ? WRONG! let's create a very minimal
            // one to prevent popping during sound start
            if ( _attack == 0 )
                _attack = ( DEFAULT_FADE_DURATION / _sampleLength );

            _attackIncr = 1 / ( _sampleLength * value );
            _attackEnv  = 0;

            // update release envelope as it takes parameters from the attack envelope
            release = _release;
        }

        public function get decay():int
        {
            return MathTool.roundPos( _decay / DECAY_MULTIPLIER );
        }

        public function set decay( value:int ):void
        {
            if ( isNaN( value ) || value == 0 )
                value = 105;

            _decay      = MathTool.roundPos( value * DECAY_MULTIPLIER );

            // some waveforms ( sine, triangle ) can have popping occurring
            // at the end when the sample is cut off at an unfortunate point
            // we prevent this pop occurring by decreasing the decay a few
            // samples before the end of the current waveform

            var fadeLength:int = 4096;
            _decayStart        = _sampleLength - fadeLength;
            _decayIncr         = MathTool.roundPos( _decay / fadeLength );
        }

        public function get release():Number
        {
            return _release;
        }

        /*
         * release is calculated backwards from the total sample length, by
         * default we set the release at a few samples before the end to
         * prevent a pop occuring when audio suddenly stops / starts */

        public function set release( value:Number ):void
        {
            if ( !isNaN( value ))
                _release = value;

            // no release set ? WRONG! let's create a very minimal
            // one to prevent popping during sound end

            if ( _release == 0 )
                _release = DEFAULT_FADE_DURATION / _sampleLength;

            _releaseStart = ( _release == 0 ) ? _sampleLength : _sampleLength - ( _sampleLength * _release );
            /*
             * if a attack envelope has been set, set the
             * release value to the attack envelope amount
             * for a gradual fade in and out */

             if ( _release > DEFAULT_FADE_DURATION && _attack > DEFAULT_FADE_DURATION ) {
                _release       = _attack;
                 _releaseStart = _sampleLength - ( _sampleLength * _release );
                _attackIncr    = 1 / ( _releaseStart );
             }

            _releaseIncr  = 1 / ( _sampleLength - _releaseStart );
            _releaseEnv   = 1;
        }

        public function get pan():Number
        {
            return _pan;
        }

        public function set pan( value:Number ):void
        {
            var currentVolume:Number = volume;
            _pan   = value;
            volume = currentVolume;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
