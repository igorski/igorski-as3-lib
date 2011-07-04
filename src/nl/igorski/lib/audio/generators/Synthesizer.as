package nl.igorski.lib.audio.generators
{
    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.interfaces.IVoice;
    import nl.igorski.lib.audio.model.vo.VOAudioEvent;
    import nl.igorski.lib.audio.ui.NoteGrid;

    public final class Synthesizer implements IVoice
    {    
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 20-dec-2010
         * Time: 14:29:33
         */
        private var _samples        :Vector.<Vector.<VOAudioEvent>>;
        private var _cachedVoices   :Vector.<AudioCache>;
        private var _invalidate     :Vector.<Object>;

        public var caching          :Boolean;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function Synthesizer( voiceAmount:int = 1 ):void
        {
            // create a sample Vector for each instrument / sequencer grid
            _samples = new Vector.<Vector.<VOAudioEvent>>( voiceAmount, true );
            
            for ( var i:int = 0; i < _samples.length; ++i )
                _samples[i] = new Vector.<VOAudioEvent>();
            
            // create buffers for the caching of each voice's samples
            // ( we won't re-synthesize a non-modified loop but read from cached buffers )
            _cachedVoices = new Vector.<AudioCache>( _samples.length, true );

            caching = true;
        }
        
        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        /**
         * the addEvent function creates a sample object ( an audio "event" ) and pushes this into the _samples Vector
         * to be processed by the synthesize function, which will write it as audio in the buffer
         */
        public function addEvent( vo:VOAudioEvent, voiceNum:int ):void
        {
            // don't add event to samples Vector if voice's cache is valid
            // ( no need to re-synthesize unless you want to unnecessarily hog CPU cycles )
            if ( _cachedVoices != null ) {
                if ( _cachedVoices[ voiceNum ].valid ) {
                    return;
                }
            }

            // we look if we're not attempting to push a ( still-caching ) VO into the samples list
            // to prevent double entries occurring and clogging up the list

            var found:Boolean = false;
            for each( var oVo:VOAudioEvent in _samples[ voiceNum ])
            {
                if ( oVo.id == vo.id )
                    found = true;
            }
            if ( !found )
                _samples[ voiceNum ].push( vo );
        }
        
        /**
         * the synthesize function processes the added events and outputs these in
         * the current audio stream, so we can actually HEAR things
         *  
         * @param buffer
         *        the current sampleDataEvent's data, pass it to ISample classes
         *        for generating output in the buffer
         */
        public function synthesize( buffer:Vector.<Vector.<Number>> ):void
        {
            var audioBuffer:Vector.<Vector.<Number>>;

            for( var i:int = 0; i < _samples.length; ++i )
            {
                // first check if current cache is to be invalidated and rebuilt...
                if ( _invalidate != null )
                    clearCache( i );

                if ( _cachedVoices[i] == null )
                    _cachedVoices[i] = new AudioCache( AudioSequencer.BYTES_PER_BAR, false );

                var doCache:Boolean = AudioSequencer.getVoice(i).active;

                /*
                 * voice isn't cached ? synthesize it's samples into a temporary
                 * buffer we use to write into the currently streaming buffer
                 */
                if ( !_cachedVoices[i].valid )
                {
                    audioBuffer = BufferGenerator.generate();

                    for ( var j:int = _samples[i].length - 1; j >= 0; --j )
                    {
                        var vo:VOAudioEvent = _samples[i][j];

                        // cache this sample?
                        if ( doCache )
                        {
                            // write sample's buffer to voice cache if it's full
                            if ( vo.sample != null && vo.sample.valid )
                            {
                                BufferGenerator.mix( audioBuffer, vo.sample.read(), 0/*, 1 / _samples[i].length*/ );

                                // splice event after read has completed full cycle, write in voice's cache
                                if ( vo.sample.readPointer == 0 ) {
                                    _samples[i].splice( j, 1 );
                                    _cachedVoices[i].write( vo.sample.read( 0, vo.sample.length ),
                                                            vo.delta * AudioSequencer.BYTES_PER_TICK );
                                }
                            }
                            // sample's buffer not full ? start it's caching ( when it's idle )
                            else {
                                if ( !vo.isCaching )
                                    vo.cache();
                            }
                        }
                    }
                    // all voice samples cleared ? if we're on the final step of the
                    // sequencer's loop and the current voice isn't queued for invalidation,
                    // the cache buffer for voice is set as valid
                    if ( _samples[i].length == 0 && AudioSequencer.stepPosition == 15
                            && getInvalidationDataForVoice( i ) == null ) {
                        _cachedVoices[i].valid = true;
                    }
                }
                /*
                 * current voice has all it's samples cached, read
                 * from straight from cache into output buffer
                 */
                else
                {
                    if ( caching )
                        caching = false;

                    audioBuffer = _cachedVoices[i].read();
                }
                /*
                 * audioBuffer filled ?
                 * write it into the currently streaming SampleDataEvent
                 * this is what creates the actual output into the AudioSequencer
                 */
                for ( var bi:int = 0, bl:int = audioBuffer[0].length; bi < bl; ++bi )
                {
                    var l:Vector.<Number> = buffer[0];
                    var r:Vector.<Number> = buffer[1];

                    l[bi] += audioBuffer[0][bi];
                    r[bi] += audioBuffer[1][bi];
                }
                audioBuffer = null;
            }
        }
        
        /*
         * invalidate cache(s), called when a grid's content has changed
         * ( notes added / deleted ) or a new song has been loaded
         *
         * @aVoice             int index of the voice in the AudioSequencer
         * @invalidateChildren invalidate all voice's VO's ( when voice properties have changed
         *                     such as envelopes and inserts )
         * @immediateFlush     Boolean whether to flush ( actual invalidation ) on first sequencer step
         *                    ( when false ) or to flush on next synthesize cycle ( when true )
         */
        public function invalidateCache( aVoice:int = -1, invalidateChildren:Boolean = false, immediateFlush:Boolean = false ):void
        {
            // we keep track of the caches to invalidate in the _invalidate Vector
            // we actually clear them when the synthesize function restarts
            // to prevent reading from cleared buffers while synthesizing!
            
            if ( _invalidate == null )
                _invalidate = new Vector.<Object>();
            
            // voice index specified ? invalidate only for that voice
            if ( aVoice > -1 )
            {
                // unless it's already queued for invalidation
                if (  getInvalidationDataForVoice( aVoice ) == null )
                {
                    _invalidate.push({ voice: aVoice, immediate: immediateFlush, children: invalidateChildren });
                }
            }
            // no specific voice number ? invalidate all
            else {
                for ( var i:int = 0; i < _samples.length; ++i )
                {
                    if ( getInvalidationDataForVoice( i ) == null )
                        _invalidate.push({ voice: i, children: invalidateChildren });
                }
            }
            caching = true;
        }

        //_________________________________________________________________________________________________________
        //                                                                        G E T T E R S   /   S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        /*
         * quick lookup if current voice is queued in the invalidation Vector
         * returns Object w/ invalidation properties when true, returns null
         * when not in invalidation Vector
         */
        private function getInvalidationDataForVoice( voice:int ):Object
        {
            if ( _invalidate == null )
                return null;

            var output  :Object;

            for ( var i:int = 0; i < _invalidate.length; ++i )
            {
                output = _invalidate[i];
                if ( output.voice == voice ) {
                    output.index = i;
                    return output;
                }
            }
            return null;
        }
        /*
         * actual invalidation of cache and clearing of cached buffers
         * called by synthesize method
         */
        private function clearCache( voice:int ):void
        {
            var invalidation:Object = getInvalidationDataForVoice( voice );

            if ( invalidation == null )
                return;

            // queried voice is to be invalidated
            // perform validation either when immediate flush has been requested
            // or when the sequencer's loop position is at the first step
            if ( invalidation.immediate || AudioSequencer.stepPosition == 0 )
            {
                if ( _cachedVoices[ voice ] != null )
                {
                    _cachedVoices[ voice ].destroy();
                    _cachedVoices[ voice ] = null;
                }
                // sequencer's first position ? remove voice from invalidation array
                if ( !invalidation.immediate )
                {
                    _invalidate.splice( invalidation.index, 1 );
                } else {
                    // immediate flush ? keep voice in invalidation array for
                    // sequencer's next pass on start of loop
                    invalidation.immediate = false;
                }
                caching = true;
            }
            if ( invalidation.children )
                invalidateCachedAudioEvents( invalidation.index );
        }

        /*
         * invalidate the cached VOAudioEvents
         * and immediately restart caching them w/ their new properties
         */
        private function invalidateCachedAudioEvents( num:int ):void
        {
            var grid:NoteGrid = AudioSequencer.retrieveNoteGrid( num );

            if ( grid != null )
                grid.resetNotes();
        }
    }
}
