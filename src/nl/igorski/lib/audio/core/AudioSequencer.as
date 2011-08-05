package nl.igorski.lib.audio.core
{
    import flash.events.EventDispatcher;
    import flash.events.SampleDataEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getTimer;

    import nl.igorski.lib.audio.core.events.SequencerEvent;
    import nl.igorski.lib.audio.core.interfaces.IBusModifier;
    import nl.igorski.lib.audio.core.interfaces.IModifier;
    import nl.igorski.lib.audio.core.interfaces.IModulator;
    import nl.igorski.lib.audio.generators.BufferGenerator;
    import nl.igorski.lib.audio.generators.Synthesizer;
    import nl.igorski.lib.audio.generators.waveforms.base.BaseWaveForm;
    import nl.igorski.lib.audio.model.vo.VOAudioEvent;
    import nl.igorski.lib.audio.ui.interfaces.IAudioTimeline;
    import nl.igorski.lib.utils.MathTool;

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
        private static var INSTANCE         :AudioSequencer;
        
        public static var BUFFER_SIZE       :int;
        public static var SAMPLE_RATE       :int = 44100;
        public static var TEMPO             :Number;
        public static var BYTES_PER_SAMPLE  :int = 8;
        public static var BYTES_PER_BEAT    :int;
        public static var BYTES_PER_BAR     :int;
        public static var BYTES_PER_TICK    :int;
        public static var AMOUNT_OF_VOICES  :int = 3;
        public static var AMOUNT_OF_STEPS   :int = 16;

        private var _sound                  :Sound;
        private var _soundChannel           :SoundChannel;
        private var _latency                :Number;
        private var _tempo                  :Number;
        private var _volume                 :Number = 1;

        private var _buffer                 :Vector.<Vector.<Number>>;
        private var _lastBuffer             :int;
        private var _position               :int;
        private var _stepPosition           :int = 0;
        
        private var _synthesizer            :Synthesizer;
        private var _voices                 :Vector.<BaseWaveForm>;
        
        // bus modifiers ( work on the sum of all sounds ( i.e. "master" ))
        private var _busModifiers           :Array;
        private var _timelines              :Vector.<IAudioTimeline>;
        
        private var _isPlaying              :Boolean;
        private var _doStop                 :Boolean;

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
            _doStop             = false;

            init();
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        public static function getInstance():AudioSequencer
        {
            return INSTANCE;
        }

        public static function start():void
        {
            if ( INSTANCE._isPlaying )
                return;
            
            INSTANCE._sound.addEventListener( SampleDataEvent.SAMPLE_DATA, INSTANCE.processAudio );

            // add events at the first sequencer position
            // to the synthesizer, as it otherwise gets skipped!
            if ( INSTANCE._stepPosition == 0 )
                INSTANCE.handleTick();

            INSTANCE._isPlaying      = true;
            INSTANCE._lastBuffer     = getTimer();
            INSTANCE._soundChannel   = INSTANCE._sound.play();

            INSTANCE.dispatchEvent( new SequencerEvent( SequencerEvent.START ));
        }

        public static function pause():void
        {
            if ( !INSTANCE._isPlaying )
                return;

            INSTANCE._sound.removeEventListener( SampleDataEvent.SAMPLE_DATA, INSTANCE.processAudio );
            INSTANCE._isPlaying = false;
            INSTANCE.clearBuffer();

            INSTANCE.dispatchEvent( new SequencerEvent( SequencerEvent.PAUSE ));
        }

        /*
         * "stopping" the sequencer is actually waiting for the
         * current processAudio method to complete, and then
         * dispatching the actual stop event, this prevents buffer
         * underruns when asynchronously stopping the sequencer
         * and performing complex calculations afterwards
         */
        public static function stop():void
        {
            INSTANCE._doStop = true;
        }
        
        public static function reset():void
        {
            if ( INSTANCE._isPlaying )
                stop();

            INSTANCE._synthesizer  = new Synthesizer( AMOUNT_OF_VOICES );
            INSTANCE._busModifiers = [];
            INSTANCE.init( false );

            invalidateCache();
        }

        public static function presynthesize():void
        {
            var tlVO:Vector.<Vector.<VOAudioEvent>> = new Vector.<Vector.<VOAudioEvent>>();

            // collect all events from the timelines
            for each( var tl:IAudioTimeline in INSTANCE._timelines )
            {
                var VOs:Vector.<VOAudioEvent> = new Vector.<VOAudioEvent>();

                for ( var i:int = 0; i < AMOUNT_OF_STEPS; ++i ) {
                    for each ( var vo:VOAudioEvent in tl.getFrequencies( i ))
                        VOs.push( vo );
                }
                tlVO.push( VOs );
            }
            INSTANCE._synthesizer.presynthesize( tlVO );
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
         * returns a reference to a requested voice, for altering a voices parameters
         *
         * @param	index : index in the Vector holding the voice Class
         */
        public static function getVoice( index:int = 0 ):BaseWaveForm
        {
            if ( index < INSTANCE._voices.length )
                return INSTANCE._voices[ index ];
            return null;
        }

        public static function attachTimeline( index:int, timeline:IAudioTimeline ):void
        {
            INSTANCE._timelines[ index ] = timeline;
        }

        public static function retrieveTimeline( index:int ):IAudioTimeline
        {
            if ( index < INSTANCE._timelines.length )
                return INSTANCE._timelines[ index ];
            return null;
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
         * @param voice : index of the voice whose modifiers are requested */

        public static function getVoiceModifierParameters( voice:int = 0 ):Array
        {
            var vwf         :BaseWaveForm = getVoice( voice );
            var modifiers   :Vector.<IModifier> = vwf.getAllModifiers();
            var out         :Array;

            if ( modifiers != null )
            {
                out = [];

                for ( var i:int = 0; i < modifiers.length; ++i )
                {
                    out.push( { type: getQualifiedClassName( modifiers[i] ),
                                params: modifiers[i].getData()} );
                }
            }
            return out;
        }

        /**
         * returns all parameters of a voice's modulator list
         * @param voice : index of the voice whose modulators are requested */

         public static function getVoiceModulatorParameters( voice:int ):Array
        {
            var vwf         :BaseWaveForm = getVoice( voice );
            var modulators  :Vector.<IModulator> = vwf.getAllModulators();
            var out         :Array;

            if ( modulators != null )
            {
                out = [];

                for ( var i:int = 0; i < modulators.length; ++i )
                {
                    out.push( { type: getQualifiedClassName( modulators[i] ),
                                params: modulators[i].getData()} );
                }
            }
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

        public static function get stepPosition():int
        {
            return INSTANCE._stepPosition;
        }
  
        public static function get latency():Number
        {
            return INSTANCE._latency;
        }
         
        public static function get isPlaying():Boolean
        {
            return INSTANCE._isPlaying;
        }

        public static function get tempo():Number
        {
            return INSTANCE._tempo;
        }
        
        public static function set tempo( value:Number ):void
        {
            INSTANCE._tempo     = value;
            BYTES_PER_BEAT      = Math.round(( SAMPLE_RATE * 60 ) / value  );

            // AudioSequencer works within a sixteen notes per bar context
            // the bytes per tick defines the bytes per sixteenth notes
            BYTES_PER_TICK      = BYTES_PER_BEAT * .25;
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
            for( var i:int = 0; i < _timelines.length; ++i )
            {
                // collect all audio event objects at the current step position for each timeline
                for each ( var vo:VOAudioEvent in _timelines[i].getFrequencies( _stepPosition ))
                    _synthesizer.addEvent( vo, i );

                // update timeline pointer position, keeping the latency in mind! We also use
                // the _position as it is the accurate representation of the sequencer step
                // in the currently audible audio stream
                _timelines[i].updatePosition( MathTool.roundPos(( _position - _latency ) / BYTES_PER_TICK ) - 1 );
            }
        }

        /**
         * actually processes the audio events and outputs sound!
         * @param e SampleDataEvent from the current audio stream */

        private function processAudio( e:SampleDataEvent ):void
        {
            if( _soundChannel != null )
                _latency = ( e.position * 2.267573696145e-02 ) - _soundChannel.position;
                
            //var to:Number = _position + BUFFER_SIZE * ( tempo * 9.448223733938e-8 );
            //_lastBuffer = getTimer();

            clearBuffer();
            _synthesizer.synthesize( _buffer );
                
            var l:Vector.<Number> = _buffer[0];
            var r:Vector.<Number> = _buffer[1];

            var doModifiers:Boolean = ( _busModifiers.length > 0 );

            for ( var i:int = 0; i < BUFFER_SIZE; ++i )
            {
                if ( _position % BYTES_PER_TICK == 0 )
                {
                    ++_stepPosition;
                    if ( _stepPosition == AMOUNT_OF_STEPS )
                        _stepPosition = 0;

                    handleTick();
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
                ++_position;
                if ( _position > BYTES_PER_BAR )
                    _position = 0;
            }
            if ( _doStop ) {
                _sound.removeEventListener( SampleDataEvent.SAMPLE_DATA, processAudio );
                doStop();
            }
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
                _synthesizer    = new Synthesizer( AMOUNT_OF_VOICES );

                // create a voice vector for multiple wave shapes
                _voices         = new Vector.<BaseWaveForm>();

                /*
                 * create a timeline vector for multiple sequencers
                 * ( in case you need multiple sequencers for multiple instruments ) */

                 _timelines          = new Vector.<IAudioTimeline>();

                // create a bus modifier array for attaching FX to the master bus
                _busModifiers   = [];

                invalidateCache();
            }
            _buffer       = BufferGenerator.generate();
            _position     = 0.0;
            _stepPosition = 0;
            _sound        = new Sound();
        }

        /*
         * clears a currently cached audio buffer in the Synthesizer class
         *
         * @param voice              specify a voice index to invalidate for that voice, not passing this argument clears all voices
         * @param invalidateChildren also invalidates all VO audioEvent caches belonging to the voice's samples
         * @param immediateFlush     when true, caches are invalidated on next synthesize cycle rather than
         *                           on the first step of the sequencer's loop
         * @param recacheChildren    if children are to be invalidated this Boolean dictates whether their caches
         *                           are to be rebuilt immediately
         */
        public static function invalidateCache( voice:int = -1, invalidateChildren:Boolean = false, immediateFlush:Boolean = false, recacheChildren:Boolean = true ):void
        {
            INSTANCE._synthesizer.invalidateCache( voice, invalidateChildren, immediateFlush, recacheChildren );
        }

        private function clearBuffer(): void
        {
            var l:Vector.<Number> = _buffer[0];
            var r:Vector.<Number> = _buffer[1];

            for ( var i:int = 0; i < BUFFER_SIZE; ++i )
            {
                l[i] = 0.0;
                r[i] = 0.0;
            }
        }

        private function doStop():void
        {
            //INSTANCE._soundChannel.stop();

            _isPlaying = false;
            _doStop    = false;

            clearBuffer();
            init( false );

            dispatchEvent( new SequencerEvent( SequencerEvent.STOP ));
        }
    }
}
