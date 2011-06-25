package nl.igorski.lib.audio.core
{
    import flash.events.EventDispatcher;
    import flash.events.SampleDataEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getTimer;

    import nl.igorski.lib.audio.core.interfaces.IBusModifier;
    import nl.igorski.lib.audio.core.interfaces.IModifier;
    import nl.igorski.lib.audio.generators.Synthesizer;
    import nl.igorski.lib.audio.generators.waveforms.base.BaseWaveForm;
    import nl.igorski.lib.audio.helpers.TempoHelper;
    import nl.igorski.lib.audio.model.vo.VOAudioEvent;
    import nl.igorski.lib.audio.ui.NoteGrid;

    public final class AudioSequencer extends EventDispatcher
    {
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 20-dec-2010
         * Time: 14:43:22
         *
         * Synthesizer is a singleton class as multiple instances each operating in their own buffer
         * create a massive glitchfest, you can instantiate more voices for multi-timbral usage
         *
         * BUFFER_SIZE  : the lower the buffer, the lower the latency ( perceived delay between events )
         *                when set too low, crack and pops and other non-nice artifacts occur in the audio
         *                the higher the buffer, the higher the latency, but cleans up instability issues
         *
         * SAMPLE_RATE  : in Hz, default ( CD player and in human hearing range according to Nyquist theory = 44.1 kHz )
         *
         * TEMPO        : in beats per minute
         */
        public static var INSTANCE          :AudioSequencer;
        
        public static var BUFFER_SIZE       :int;
        public static var SAMPLE_RATE       :int = 44100;
        public static var TEMPO             :Number;
        public static var BYTES_PER_SAMPLE  :int = 8;
        public static var BYTES_PER_BEAT    :int;
        public static var BYTES_PER_BAR     :int;
        public static var BYTES_PER_TICK    :int;

        private var _sound                  :Sound;
        private var _soundChannel           :SoundChannel;
        private var _latency                :Number;
        private var _tempo                  :Number;
        private var _volume                 :Number = 1;

        private var _buffer                 :Vector.<Vector.<Number>>;
        private var _lastBuffer             :int;
        private var _position               :Number;
        private var _stepPosition           :int = 0;
        
        private var _synthesizer            :Synthesizer;
        private var _voices                 :Vector.<BaseWaveForm>;
        
        // modifiers ( work on individual voices )
        private var _modifiers              :Vector.<Vector.<IModifier>>;
        
        // bus modifiers ( works on the sum of all sounds ( i.e. "master" ))
        private var _busModifiers           :Array;
        private var _grids                  :Vector.<NoteGrid>;
        
        private var _isPlaying              :Boolean;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function AudioSequencer( bufferSize:int = 2048, aTempo:Number = 120, sampleRate:Number = 44100, bytesPerSample:int = 8 )
        {
            if ( INSTANCE == null )
                INSTANCE = this;
            else
                throw new Error( "You can only instantiate ONE sequencer class" );

            BUFFER_SIZE         = bufferSize;
            SAMPLE_RATE         = sampleRate;
            BYTES_PER_SAMPLE    = bytesPerSample;
            tempo               = aTempo;

            _isPlaying          = false;

            init();
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        public static function positionToNumSamples( position: Number ):int
        {
            return int(( position * 10584000.0 ) / TEMPO + .5 );
        }

        public static function start():void
        {
            if ( INSTANCE._isPlaying )
                return;
            
            INSTANCE._sound.addEventListener( SampleDataEvent.SAMPLE_DATA, INSTANCE.processAudio );

            INSTANCE._isPlaying      = true;
            INSTANCE._lastBuffer     = getTimer();
            INSTANCE._soundChannel   = INSTANCE._sound.play();
        }

        public static function stop():void
        {
            INSTANCE._sound.removeEventListener( SampleDataEvent.SAMPLE_DATA, INSTANCE.processAudio );

            INSTANCE._isPlaying = false;
            INSTANCE.clearBuffer();
            INSTANCE.init( false );
        }
        
        public static function reset():void
        {
            stop();

            INSTANCE._synthesizer  = new Synthesizer( 3 );
            INSTANCE._modifiers    = new Vector.<Vector.<IModifier>>( 3, true );
            INSTANCE._busModifiers = [];
            INSTANCE.init( false );

            invalidateCache();
        }
        
        public static function clearBus():void
        {
            INSTANCE._busModifiers = [];
        }

        /**
         * adds voices to generate waveforms
         * @param	num   : at what index in the vector should the voice be placed
         * @param	voice : a voice Class extending BaseWaveForm
         */
        public static function attachVoice( num:int, voice:BaseWaveForm ):void
        {
            INSTANCE._voices[ num ] = voice;
        }

        /**
         * removes voices from the vector
         * @param	index : index of the voice to be removed
         */
        public static function removeVoice( index:int = 0 ):void
        {
            INSTANCE._voices.splice( index, 1 );
        }

        /**
         * returns a reference to a requested voice, for altering a voice's parameters
         *
         * @param	index : index in the Vector holding the voice Class
         */
        public static function getVoice( index:int = 0 ):BaseWaveForm
        {
            if ( index < INSTANCE._voices.length )
                return INSTANCE._voices[ index ];
            return null;
        }

        public static function attachNoteGrid( index:int, grid:NoteGrid ):void
        {
            INSTANCE._grids[ index ] = grid;
        }

        public static function retrieveNoteGrid( index:int ):NoteGrid
        {
            if ( index < INSTANCE._grids.length )
                return INSTANCE._grids[ index ];
            return null;
        }

        /**
         * adds modifiers to a voice
         * @param	modifier: an IModifier object
         * @param   voice   : the ( vector ) index corresponding to the voice the modifier should be attached to
         * @param	index   : at what position will be the modifier be placed ( in case of multiple modifiers )
         */
        public static function addModifier( modifier:IModifier, voice:int = 0, index:int = 0 ):void
        {
            if ( INSTANCE._modifiers[ voice ] == null )
                INSTANCE._modifiers[ voice ] = new Vector.<IModifier>();

            INSTANCE._modifiers[ voice ][ index ] = modifier;
            BaseWaveForm( getVoice( voice )).modifiers = INSTANCE._modifiers[ voice ];
        }

        /**
         * removes modifiers from voices
         * @param   voice : index of the voice we're targeting
         * @param	index : index of the modifier to be removed
         */
        public static function removeModifier( voice:int = 0, index:int = 0 ):void
        {
            if ( INSTANCE._modifiers[ voice ] != null )
            {
                INSTANCE._modifiers[ voice ][ index ] = null;
                INSTANCE._modifiers[ voice ].splice( index, 1 );
            }
            BaseWaveForm( getVoice( voice )).modifiers = INSTANCE._modifiers[ voice ];
        }

        /**
         * returns a reference to a requested modifier, for altering a modifier's parameters
         * @param   voice : index of the voice the modifier is attached to
         * @param	index : index in the modifier in the voice's modifiers Vector
         */
        public static function getModifier( voice:int = 0, index:int = 0 ):IModifier
        {
            return INSTANCE._modifiers[ voice ][ index ];
        }

        /**
         * same functions as the above for voice modifiers, only
         * these are bus specific
         */
        public static function addBusModifier( modifier:IBusModifier, index:int = 0 ):void
        {
            while ( index > INSTANCE._busModifiers.length )
            {
                if ( INSTANCE._busModifiers[ index ] != null )
                    INSTANCE._busModifiers[ index ] = [];
            }
            INSTANCE._busModifiers[ index ] = modifier;
        }

        public static function removeBusModifier( index:int = 0 ):void
        {
            INSTANCE._busModifiers[ index ] = null;
        }

        public static function getBusModifier( index:int = 0 ):IBusModifier
        {
            return INSTANCE._busModifiers[ index ];
        }
        
        /**
         * returns all parameters of a voice's modifier list
         * @param	voice : index of the voice whose modifiers are requested
         */
        public static function getVoiceModifierParameters( voice:int = 0 ):Array
        {
            var modifiers:Array = INSTANCE.getVoiceModifiers( voice );
            
            if ( modifiers == null )
                return null;
            
            var out:Array = [];
            for each ( var m:IModifier in modifiers )
                out.push( { type: getQualifiedClassName( m ), params: m.getData() } );
            
            return out;
        }
        
        /**
         * returns all parameters of the bus's modifier list
         */
        public static function getBusModifierParameters():Array
        {
            var modifiers:Array = INSTANCE._busModifiers;
            
            if ( modifiers == null )
                return null;
                
            var out:Array = [];
            for each( var m:IBusModifier in modifiers )
            {
                if ( m.getData() != null )
                    out.push( { type: getQualifiedClassName( m ), params: m.getData() } );
            }
            return out;
        }
        
        //_________________________________________________________________________________________________________
        //                                                                        G E T T E R S   /   S E T T E R S

        public static function get position():Number
        {
            return INSTANCE._position;
        }
  
        public static function get latency():Number
        {
            return INSTANCE._latency;
        }
         
        public static function get isPlaying():Boolean
        {
            return INSTANCE._isPlaying;
        }

        public static function get isCaching():Boolean
        {
            return INSTANCE._synthesizer.caching;
        }
        
        public static function get tempo():Number
        {
            return INSTANCE._tempo;
        }
        
        public static function set tempo( value:Number ):void
        {
            INSTANCE._tempo     = value;
            BYTES_PER_BEAT      = TempoHelper.getBytesPerBeat( value );
            BYTES_PER_TICK      = BYTES_PER_BEAT * .25;
          //  BYTES_PER_TICK      = Math.round(( SAMPLE_RATE * 60 ) / ( value * 16 ));
            BYTES_PER_BAR       = BYTES_PER_BEAT * 4;

            if ( INSTANCE._synthesizer != null )
                invalidateCache();
        }
        
        public static function get volume():Number
        {
            return INSTANCE._volume;
        }
        
        public static function set volume( value:Number ):void
        {
            INSTANCE._volume = value;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        /**
         * receives it's BPM synced tick from the SampleDataEvent handler
         * this is what actually RUNS the sequencer and initiates audio events
         */
        private function handleTick():void
        {
            for( var i:int = 0; i < _grids.length; ++i )
            {
                // collect all audio event objects at the current position for each grid
                //vo.frequency, vo.length, _voices[i], _voices[i].volume, _voices[i].pan, _voices[i].decay, _voices[i].attack, _voices[i].release
                for each ( var vo:VOAudioEvent in _grids[i].getFrequencies( _stepPosition ))
                    _synthesizer.addEvent( vo, i );
            }
        }

        /**
         * actually processes the audio events and generates and outputs sound!
         *
         * @param e SampleDataEvent from the current audio stream
         */

        private function processAudio( e:SampleDataEvent ):void
        {
            /*
            if( _soundChannel != null )
                _latency = ( e.position * 2.267573696145e-02 ) - _soundChannel.position;
                
            var to:Number = _position + BUFFER_SIZE * ( tempo * 9.448223733938e-8 );
            _lastBuffer = getTimer();
            */
            clearBuffer();
            _synthesizer.synthesize( _buffer );
                
            var beatcounter:int   = 0;
            
            var l:Vector.<Number> = _buffer[0];
            var r:Vector.<Number> = _buffer[1];
    
            // multiplication by .0625 translates as division by 16 ( the steps in the sequencer )
            var bps:int = Math.round( BYTES_PER_BEAT * .0625 );
            
            var doModifiers:Boolean = ( _busModifiers.length > 0 );
            
            for ( var i:int = 0; i < BUFFER_SIZE; ++i )
            {
                ++beatcounter;
                if ( beatcounter * BYTES_PER_SAMPLE >= bps )
                {
                    ++_stepPosition;
                    if ( _stepPosition == 16 )
                        _stepPosition = 0;

                    handleTick();
                    beatcounter = 0;
                }
                if ( doModifiers )
                {
                    for each( var m:IBusModifier in _busModifiers )
                        m.process( l[i] * _volume, r[i] * _volume, e.data );
                }
                else {
                    e.data.writeFloat( l[i] * _volume );
                    e.data.writeFloat( r[i] * _volume );
                }
            }
            //_position = to;
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        private function init( createObjects:Boolean = true ): void
        {
            if ( createObjects )
            {
                // create a synthesizer for audio output
                _synthesizer    = new Synthesizer( 3 );

                // create a voice vector for multiple wave shapes
                _voices         = new Vector.<BaseWaveForm>();

                // create a grid vector for multiple sequencers
                _grids          = new Vector.<NoteGrid>();

                // create a modifier vector for attaching FX to voices
                _modifiers      = new Vector.<Vector.<IModifier>>( 3, true );

                // create a busmodifier array for attaching FX to the master bus
                _busModifiers   = [];

                invalidateCache();
            }
            _buffer    = new Vector.<Vector.<Number>>( 2, true );
            _buffer[0] = new Vector.<Number>( BUFFER_SIZE, true );
            _buffer[1] = new Vector.<Number>( BUFFER_SIZE, true );
            _position  = 0.0;
            

            _sound = new Sound();
        }

        /*
         * clears the currently cached audio buffer
         * @voice specify a voice index to invalidate for that voice, not passing this argument clears all voices
         * @invalidateChildren also invalidates all audioEvent caches belonging to the voice's samples
         */
        public static function invalidateCache( voice:int = -1, invalidateChildren:Boolean = false ):void
        {
            INSTANCE._synthesizer.invalidateCache( voice, invalidateChildren );
        }

        private function clearBuffer(): void
        {
            var l: Vector.<Number> = _buffer[0];
            var r: Vector.<Number> = _buffer[1];

            for ( var i:int = 0; i < BUFFER_SIZE; ++i )
            {
                l[i] = 0.0;
                r[i] = 0.0;
            }
        }
        
        private function getVoiceModifiers( voice:int ):Array
        {
            if ( _modifiers[ voice ] != null )
            {
                var out:Array = [];
                for ( var i:int = 0; i < _modifiers[ voice ].length; ++i )
                {
                    if ( _modifiers[ voice ][ i ] != null )
                        out.push( _modifiers[ voice ][ i ] );
                }
                if ( out.length > 0 )
                    return out;
            }    
            return null;
        }
    }
}
