package nl.igorski.lib.audio.model.vo
{
    import flash.events.Event;
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
        public var id           :String;

        /* the cached representation of this event's
         * audio properties, used for output by the
         * Synthesizer class */

        public var sample       :AudioCache;
        private var wave        :BaseWaveForm;

        public var sampleLength :int;
        public var sampleStart  :int;
        public var sampleEnd    :int;

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
                catch ( e:Error ) {
                    trace( "property " + i + " non-existent in VOAudioEvent" );
                }
            }
            // create unique identifier
            id = "V:" + voice + "@" + delta + "l:" + length + "f:" + frequency + "Hz";

            // set positions for sequencer
            calculateLengths();

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

            // 16-note context ( one tick = sixteenth note )
            var sampleLength:int = AudioSequencer.BYTES_PER_TICK * length + 0.5|0;
            sample = new AudioCache( sampleLength );

            wave = IWaveCloner.clone( AudioSequencer.getVoice( voice ), frequency, length );

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
         * when VO is removed or invalidated due to parameters changes
         * we free memory by clearing it's cached contents. An event is
         * dispatched to listening Objects which might store a reference
         * to this VOAudioEvent, such as the BulkCacher */

        public function destroy():void
        {
            if ( sample != null )
                sample.destroy();

            sample = null;
            wave   = null;

            dispatchEvent( new Event( AudioCacheEvent.CACHE_DESTROYED ));
        }

        public function calculateLengths():void
        {
            sampleLength = length * AudioSequencer.BYTES_PER_TICK;
            sampleStart  = delta * AudioSequencer.BYTES_PER_TICK;
            sampleEnd    = sampleStart + sampleLength;
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
