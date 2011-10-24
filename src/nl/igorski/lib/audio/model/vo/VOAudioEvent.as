package nl.igorski.lib.audio.model.vo
{
    import flash.events.Event;

    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.events.AudioCacheEvent;
    import nl.igorski.lib.audio.generators.AudioCache;
    import nl.igorski.lib.audio.generators.BufferGenerator;
    import nl.igorski.lib.audio.generators.waveforms.base.BaseWaveForm;
    import nl.igorski.lib.audio.helpers.IWaveCloner;
    import nl.igorski.util.threading.ThreadedFunction;
    import nl.igorski.util.threading.events.ThreadEvent;

    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 12-04-11
     * Time: 19:47
     *
     * for optimum high-performance crunching we let the Flash Player run
     * in green threaded mode. The GreenThread library needs to be included
     * in your project: http://code.google.com/p/greenthreads/
     *
     * you can uncomment the alternate classes / non-threaded approach
     * for using the VOAudioEvent class in non-"threaded" mode
     */
    public final class VOAudioEvent extends ThreadedFunction/*EventDispatcher*/
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

        /* the cached representation of this events
         * audio properties, used for output by the
         * Synthesizer class */

        public var sample       :AudioCache;
        private var wave        :BaseWaveForm;

        public var sampleLength :int;
        public var sampleStart  :int;
        public var sampleEnd    :int;

        /* used for pseudo threading, can be removed when not in use */
        private var cacheBuffer :Vector.<Vector.<Number>>;

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
            /* NON-threaded mode */
            /*
            for ( var i:int = 0; i < sampleLength; i += AudioSequencer.BUFFER_SIZE )
            {
                var cacheBuffer:Vector.<Vector.<Number>> = BufferGenerator.generate();
                wave.generate( cacheBuffer );
                sample.append( cacheBuffer );
            }

            isCaching = false;
            wave      = null;

            dispatchEvent( new AudioCacheEvent( AudioCacheEvent.CACHE_COMPLETED ));
            */
            // threaded mode
            if ( _maximum > 0 )
                stop();

            start();
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
            sampleStart  = delta  * AudioSequencer.BYTES_PER_TICK;
            sampleEnd    = sampleStart + sampleLength;
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        override protected function initialize():void
        {
            cacheBuffer = BufferGenerator.generate( sampleLength );
            _maximum    = sampleLength - 1;
            _progress   = 0;

            addEventListener( ThreadEvent.COMPLETE, threadComplete );
        }

        override final protected function run():Boolean
        {
            // we process the BUFFER_SIZE in samples each threaded pass

            var m:int = _progress + AudioSequencer.BUFFER_SIZE;

            if ( m > _maximum )
                m = _maximum;

            for ( _progress; _progress < m; ++_progress )
                wave.generate( cacheBuffer, _progress );

            return _progress < _maximum;
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        private function threadComplete( e:ThreadEvent ):void
        {
            isCaching = false;
            _maximum  = 0;
            removeEventListener( ThreadEvent.COMPLETE, threadComplete );

            sample.clone( cacheBuffer );
            dispatchEvent( new AudioCacheEvent( AudioCacheEvent.CACHE_COMPLETED ));
        }
    }
}
