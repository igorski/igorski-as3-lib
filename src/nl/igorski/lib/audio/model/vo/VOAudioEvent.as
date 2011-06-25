package nl.igorski.lib.audio.model.vo
{
    import flash.events.EventDispatcher;

    import nl.igorski.lib.audio.core.AudioSequencer;
import nl.igorski.lib.audio.core.events.AudioCacheEvent;
import nl.igorski.lib.audio.generators.AudioCache;
    import nl.igorski.lib.audio.generators.BufferGenerator;
    import nl.igorski.lib.audio.generators.waveforms.base.BaseWaveForm;
    import nl.igorski.lib.audio.helpers.IWaveCloner;

    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 12-04-11
     * Time: 19:47
     */
    public final class VOAudioEvent extends EventDispatcher
    {
        // the voice index ( in the AudioSequencer class ) used to
        // shape the timbre of the audio output
        public var voice        :int;

        // unique values to this event
        public var frequency    :Number;
        public var length       :Number;
        public var delta        :int;
        public var autoCache    :Boolean;
        public var isCaching    :Boolean;

        // the cached representation of this events
        // audio properties, used for output by the
        // Synthesizer class
        public var sample       :AudioCache;
        private var wave        :BaseWaveForm;

        public var id           :String;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function VOAudioEvent( data:Object = null )
        {
            if ( data == null )
                return;

            isCaching = false;

            for ( var i:* in data )
            {
                try {
                    this[ i ] = data[ i ];
                }
                catch ( e:Error )
                {
                    trace( "property " + i + " non-existent in VOAudioEvent" );
                }
            }
            // create unique identifier
            id = voice + ":" + frequency + "/" + length + "@" + delta;

            // start caching
            if ( autoCache )
                cache();
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /*
         * pre caches the entire audio event
         * for fast writes into output buffers
         */
        public function cache():void
        {
            isCaching = true;

            // the 16 shows this is hard-wired to work
            // within a 16-step sequencer constraint
            var sampleLength:int = ((( AudioSequencer.BYTES_PER_BAR / 8 ) / 16 ) * length ) + 0.5|0;
            sampleLength = ( 65536 * ( length / 16 )) + 0.5|0; // TODO: above seems to be expensive on CPU! and this SEEMS to work...
            sample = new AudioCache( sampleLength );

            wave = IWaveCloner.clone( AudioSequencer.getVoice( voice ));

            wave.frequency = frequency;
            wave.length    = length;

            // synthesize this event into audio
            for ( var i:int = 0; i < sampleLength; i += AudioSequencer.BUFFER_SIZE )
            {
                var cacheBuffer:Vector.<Vector.<Number>> = BufferGenerator.generate();
                wave.generate( cacheBuffer );
                sample.append( cacheBuffer );
            }

            isCaching = false;
            wave      = null;

            dispatchEvent( new AudioCacheEvent( AudioCacheEvent.CACHE_COMPLETED ));
        }

        /*
         * generate some audio for the given buffer length
         * this can be used by the Synthesizer class for writing
         * straight into the currently playing audio buffer
         */
        public function generate( bufferLength:Number = -1 ):Vector.<Vector.<Number>>
        {
            isCaching = false;
            sample    = null;

            if ( bufferLength == -1 )
                bufferLength = AudioSequencer.BUFFER_SIZE;

            var output:Vector.<Vector.<Number>> = BufferGenerator.generate( bufferLength );
            var source:BaseWaveForm             = AudioSequencer.getVoice( voice );

            if ( wave == null ) {
                var wave:BaseWaveForm = IWaveCloner.clone( source );
                wave.active           = false;
            } else {
                wave.setData( source.getData());
                wave.modifiers = source.modifiers;
            }
            wave.frequency = frequency;
            wave.length    = length;
            wave.generate( output );

            return output;
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
