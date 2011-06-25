package nl.igorski.lib.audio.generators.waveforms.base
{
    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.interfaces.IModifier;
    import nl.igorski.lib.audio.core.interfaces.IWave;
    import nl.igorski.lib.audio.model.vo.VOEnvelopes;

    /**
     * class BaseWaveForm
     *
     * Created by IntelliJ IDEA.
     * User: igor.zinken
     * Date: 13-4-11
     * Time: 10:11
     *
     * BaseWaveForm is the base class for all sound wave generating classes
     * implementing the IWave interface
     *
     */
    public class BaseWaveForm implements IWave
    {
        protected var DECAY_MULTIPLIER    :int = 200;

        protected var _delta              :int;
        protected var _phase              :Number;
        protected var _phaseIncr          :Number;
        protected var _length             :Number;
        protected var _lengthIncr         :int;

        protected var _attack             :Number;
        protected var _decay              :int;
        protected var _release            :Number;

        protected var _volumeL            :Number;
        protected var _volumeR            :Number;
        protected var _pan                :Number;
        protected var _bufferSize         :int;

        protected var _modifiers          :Vector.<IModifier>;

        protected var _active          :Boolean;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        /*
         * @aFrequency   the frequency in Hz of the note to be synthesized
         * @aLength      the duration of the synthesized frequency
         * @aDecayTime   decay of the generated soundwave
         * @aAttackTime  attack curve of the generated soundwave
         * @aReleaseTime release curve of the generated soundwave
         * @aDelta       position of this wave in the sequencer
         * @aVolume      volume of the generated wave
         * @aPan         position in the stereo field of the generated wave
         * @aModifiers   Array of modifiers that should process the synthesized audio
         */
        public function BaseWaveForm( aFrequency:Number, aLength:Number, aDecayTime:int, aAttackTime:Number, aReleaseTime:Number, aDelta:int, aVolume:Number, aPan:Number, aModifiers:Array ):void
        {
            _delta          = aDelta;
            decay           = aDecayTime;
            _attack         = isNaN( aAttackTime ) ? 1 : aAttackTime;
            _length         = isNaN( aLength ) ? 1 : aLength;
            _bufferSize     = AudioSequencer.BUFFER_SIZE;
            _lengthIncr     = _length * AudioSequencer.BYTES_PER_TICK;
            _release        = isNaN( aReleaseTime ) ? _bufferSize : aReleaseTime;

            _phase          = 0.0;
            _phaseIncr      = aFrequency / AudioSequencer.SAMPLE_RATE;

            if ( isNaN( aPan ))
                aPan    = 0;
            if ( isNaN( aVolume ))
                aVolume = .65;

            _pan        = aPan;
            volume      = aVolume;

            _modifiers      = new Vector.<IModifier>();
            if ( aModifiers != null )
            {
                for each( var m:IModifier in aModifiers )
                    _modifiers.push( m );
            }
            _active = true;
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        public function generate( buffer: Vector.<Vector.<Number>> ):Boolean
        {
            // override in subclass
            return true;
        }

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
            _lengthIncr     = _length * AudioSequencer.BYTES_PER_TICK;
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
            return _volumeL / ( 1 - _pan );
        }

        public function set volume( value:Number ):void
        {
            if ( isNaN( value ))
                value = 1;

            _volumeL = ( 1 - _pan ) * value;
            _volumeR = ( _pan + 1 ) * value;
        }

        public function get attack():Number
        {
            return _attack;
        }

        public function set attack( value:Number ):void
        {
            if ( !isNaN( value ))
                _attack = value;
        }

        public function get decay():int
        {
            return Math.round( _decay / DECAY_MULTIPLIER );
        }

        public function set decay( value:int ):void
        {
            if ( isNaN( value ) || value == 0 )
                value = 105;

            _decay = Math.round( value * DECAY_MULTIPLIER );
        }

        public function get release():Number
        {
            return _release;
        }

        public function set release( value:Number ):void
        {
            if ( !isNaN( value ))
                _release = value;
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

        public function get modifiers():Vector.<IModifier>
        {
            return _modifiers;
        }

        public function set modifiers( value:Vector.<IModifier> ):void
        {
            _modifiers = value;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
