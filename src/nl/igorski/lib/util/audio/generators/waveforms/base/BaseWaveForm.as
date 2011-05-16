package nl.igorski.lib.util.audio.generators.waveforms.base
{
    import nl.igorski.lib.util.audio.AudioSequencer;
    import nl.igorski.lib.util.audio.core.interfaces.IModifier;
    import nl.igorski.lib.util.audio.core.interfaces.IWave;
    import nl.igorski.lib.util.audio.model.vo.VOEnvelopes;
    /**
     * class BaseWaveForm
     *
     * Created by IntelliJ IDEA.
     * User: igor.zinken
     * Date: 13-4-11
     * Time: 10:11
     */
    public class BaseWaveForm implements IWave
    {
        public var DECAY_MULTIPLIER    :int = 200;

        public var _delta              :int;
        public var _phase              :Number;
        public var _phaseIncr          :Number;
        public var _length             :Number;
        public var _lengthIncr         :int;

        public var _attack             :Number;
        public var _decay              :int;
        public var _release            :Number;

        public var _volumeL            :Number;
        public var _volumeR            :Number;
        public var _pan                :Number;
        public var _bufferSize         :int;

        public var _modifiers          :Vector.<IModifier>;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
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
                aVolume = .75;

            _pan        = aPan;
            volume      = aVolume;

            _modifiers      = new Vector.<IModifier>();
            if ( aModifiers != null )
            {
                for each( var m:IModifier in aModifiers )
                    _modifiers.push( m );
            }
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
            return _decay;
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
