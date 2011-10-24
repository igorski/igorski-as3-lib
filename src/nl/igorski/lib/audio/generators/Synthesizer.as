package nl.igorski.lib.audio.generators
{
    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.interfaces.IVoice;
    import nl.igorski.lib.audio.helpers.BulkCacher;
    import nl.igorski.lib.audio.model.vo.VOAudioEvent;
    import nl.igorski.lib.audio.ui.interfaces.IAudioTimeline;

    public class Synthesizer implements IVoice
    {    
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 20-dec-2010
         * Time: 14:29:33 */

        protected var _voiceSamples             :Vector.<Vector.<VOAudioEvent>>;
        protected var _cachedVoices             :Vector.<AudioCache>;
        protected var _invalidate               :Vector.<Object>;

        protected var _oldCaches                :Vector.<AudioCache>;
        protected var _oldCacheReadSteps        :Vector.<int>;

        private const CACHE_RELEASE_TIME        :int = 8;

        /* temporary buffer used for writing in each cycle */
        private var _audioBuffer                :Vector.<Vector.<Number>>;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function Synthesizer( voiceAmount:int = 1 ):void
        {
            // create a sample Vector for each instrument / sequencer timeline
            // this is where the notes for synthesis are queued
            _voiceSamples = new Vector.<Vector.<VOAudioEvent>>();

            // create buffers for the caching of each voice's samples as we don't
            // re-synthesize a non-modified loop but read it from a cached buffer
            _cachedVoices = new Vector.<AudioCache>();

            // caches for "old" ( rather: just-invalidated ) audio to be read from
            // during the (re)building of the new caches
            _oldCaches = new Vector.<AudioCache>();
            _oldCacheReadSteps = new Vector.<int>();

            _audioBuffer = BufferGenerator.generate();

            addVoices( voiceAmount );
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
                if ( _cachedVoices[ voiceNum ] != null && _cachedVoices[ voiceNum ].valid )
                    return;
            }

            // we look if we're not attempting to push a ( still-caching ) VO into the samples list
            // to prevent double entries occurring and clogging up the list
            // OBSOLETE ? this shouldn't be occurring!
            /*
            var found:Boolean = false;

            for each( var oVo:VOAudioEvent in _samples[ voiceNum ])
            {
                if ( oVo.id == vo.id )
                    found = true;
            }

            if ( !found )*/
                _voiceSamples[ voiceNum ].push( vo );
        }

        /**
         * in case of dynamic addition of voices, you can increase the size of the
         * cache Vectors for including the voices in the current synthesizer
         *
         * @param {int} totalLength the total amount of voices required, only the difference
         *        between the old and new length will be added, existing indices remain as is
         */
        public function addVoices( totalLength:int = 1 ):void
        {
            while ( _voiceSamples.length < totalLength )
            {
                _voiceSamples.push( new Vector.<VOAudioEvent>());
                _cachedVoices.push( new AudioCache( AudioSequencer.BYTES_PER_BAR, false ));
                _oldCaches.push( new AudioCache( AudioSequencer.BYTES_PER_BAR, false ));
                _oldCacheReadSteps.push( 0 );
            }
        }

        /**
         * the synthesize function processes the added events and outputs these in
         * the current audio stream, so we can actually HEAR things
         *  
         * @param {Vector.<Vector.<Number>>} buffer
         *        the current sampleDataEvent's data, pass it to ISample classes
         *        for generating output in the buffer
         */

        public final function synthesize( buffer:Vector.<Vector.<Number>> ):void
        {
            // local reference for a bit more speed
            var audioBuffer:Vector.<Vector.<Number>> = _audioBuffer;

            var bufferSize :int = AudioSequencer.BUFFER_SIZE;
            var position   :int = AudioSequencer.position;

            /*
             * rather than taking the current step position from the sequencer, we
             * calculate the step by the current sequencer buffer position ( which is
             * a more accurate "playhead" as the steps are incremented by the AudioSequencer
             * after the previous synthesize() method ran */

            var step       :int = position / AudioSequencer.BYTES_PER_TICK;
            var multiplier :int = ( step == 0 && position > 0 ) ? 1 : step;

            // calculate the amount of bytes we are past the last tick, and the end position for this cycle
            var offset     :int = Math.abs( position - ( AudioSequencer.BYTES_PER_TICK *  multiplier ));
            var endPosition:int = position + bufferSize;
            var readLength :int;

            for( var i:int = 0; i < _voiceSamples.length; ++i )
            {
                // first check if current cache is to be invalidated and rebuilt...
                if ( _invalidate != null )
                    clearCache( i );

                if ( _cachedVoices[i] == null )
                    _cachedVoices[i] = new AudioCache( AudioSequencer.BYTES_PER_BAR, false );

                var doCache:Boolean = AudioSequencer.getVoice( i ).active;
                var theSamples:Vector.<VOAudioEvent> = _voiceSamples[ i ];
                var theCache  :AudioCache            = _cachedVoices[ i ];

                /*
                 * voice isn't cached ? synthesize its samples into a temporary
                 * buffer we use to write into the currently streaming buffer */

                if ( !theCache.valid )
                {
                    // if a cache for the previous series of events exists, read
                    // from this cache during the creation of the new one
                    var readOld:Boolean = ( _oldCaches[i] != null );

                    if ( BulkCacher.isCaching )
                    {
                        // no synthesis during non-sequenced Bulk Caching!
                        if ( !BulkCacher.sequenced )
                            return;
                    }
                    else if ( BulkCacher.remaining > 0 && BulkCacher.sequenced )
                    {
                        // sequenced caching activated ? let's cache
                        // ahead for the next sequencer step position
                        var cacheStep:int = step + 1;
                        if ( cacheStep > 15 )
                            cacheStep = 0;

                        BulkCacher.cacheBySequencerStep( cacheStep );
                    }

                    /*
                     * read previously cached content into the currently
                     * streaming output buffer to prevent silences on
                     * previously set notes */

                    // when we're repeatedly adding notes we're continuously forcing a rebuild of the current cache
                    // so we read from the _oldCaches Vector during this rebuild until we can read from the
                    // cached Vector representing the audio currently in use
                    if ( !readOld ) {
                        mix( audioBuffer, theCache.read( position, bufferSize ), 0 );
                    }
                    else {
                        if ( _oldCacheReadSteps[i] > 0 ) {
                            mix( audioBuffer, _oldCaches[i].read( position, bufferSize ), 0 );
                            --_oldCacheReadSteps[i];
                        } else {
                            mix( audioBuffer, theCache.read( position, bufferSize ), 0 );
                        }
                    }
                    for ( var j:int = theSamples.length - 1; j >= 0; --j )
                    {
                        var vo:VOAudioEvent = theSamples[j];

                        // cache this sample?
                        if ( doCache )
                        {
                            /*
                             * sample's buffer is full ? read its currently audible audio content
                             * into the audioBuffer for direct output and cache its full contents
                             * in the voice's cache */

                            if ( vo.sample != null && vo.sample.valid )
                            {
                                if (( vo.sampleStart >= position && vo.sampleStart <= endPosition )
                                        || ( vo.sampleStart < position && vo.sampleEnd > position ))
                                {
                                    readLength = vo.sampleEnd - position;

                                    if ( readLength > bufferSize )
                                        readLength = bufferSize;

                                    readLength -= offset;

                                    if ( readLength < 0 )
                                        readLength = 0;

                                    mix( audioBuffer, vo.sample.read( offset, readLength ));
                                }/*
                                else {*/
                                /*
                                 * we splice the audio event from the list after its caching has completed
                                 * and write the sample's cached contents in the voice's buffer, note
                                 * we don't write it into the current audioBuffer for direct output as
                                 * we're caching a step ahead ! */

                                    theSamples.splice( j, 1 );
                                    BulkCacher.addCachedSample( vo );

                                    theCache.write( vo.sample.read( 0, vo.sample.length ),
                                                    vo.delta * AudioSequencer.BYTES_PER_TICK );

                                //}
                            }
                            // sample's buffer not full ? start caching the sample
                            // unless we're sequentially caching from the BulkCacher
                            else {
                                if ( !vo.isCaching/* && !BulkCacher.sequenced*/ )
                                    vo.cache();
                            }
                        }
                    }
                    /*
                     * all voice samples cleared ? if we're on the final step of the
                     * sequencer's loop and the current voice isn't queued for invalidation,
                     * the cache buffer for this voice is set as valid, note we use
                     * the stepPosition as set by the AudioSequencer and not calculated by
                     * the current buffer position! */

                    if ( theSamples.length == 0 && AudioSequencer.stepPosition == 15
                        && getInvalidationDataForVoice( i ) == null )
                    {
                        theCache.valid = true;
                        trace( "CACHE " + i + "  VALID TRUE" );
                        if ( _oldCaches[i] != null ) {
                            _oldCaches[i].destroy();
                            _oldCaches[i] = null;
                        }
                    }
                }
                /*
                 * current voice has all its samples cached, read
                 * straight from the cache into the output buffer */
                else
                {
                    mix( audioBuffer, theCache.read( position, bufferSize ), 0 );
                }
            }
            /*
             * audioBuffer filled ?
             * write it into the currently streaming SampleDataEvent
             * this is what creates the actual output into the AudioSequencer */

            var l:Vector.<Number> = buffer[0];
            var r:Vector.<Number> = buffer[1];

            for ( i = 0, j = audioBuffer[0].length; i < j; ++i )
            {
                l[i] += audioBuffer[0][i];
                r[i] += audioBuffer[1][i];
            }

            // clear write buffer for next cycle
            i = audioBuffer[0].length;

            while( i-- )
            {
                audioBuffer[0][i] = 0.0;
                audioBuffer[1][i] = 0.0;
            }
        }

        /*
         * presynthesize takes all currently cached VOAudioEvents from
         * the voice timelines and writes their cache into the cachedVoices
         * Vector.
         *
         * use when synthesizer is idle
         *
         * @param data a Vector containing a Vector with Audio Events for each voice
         */
        public function presynthesize( data:Vector.<Vector.<VOAudioEvent>> ):void
        {
            _invalidate = null;

            for ( var i:int = 0; i < data.length; ++i )
            {
                _cachedVoices[i] = new AudioCache( AudioSequencer.BYTES_PER_BAR, false );

                for each( var re:VOAudioEvent in data[i] )
                {
                    var vo:VOAudioEvent = BulkCacher.getCachedSample( re.id );

                    _cachedVoices[i].write( vo.sample.read( 0, vo.sample.length ),
                                            vo.delta * AudioSequencer.BYTES_PER_TICK );

                }
                _cachedVoices[i].valid = true;
            }
        }
        
        /*
         * invalidate cache(s), called when a timeline's content has changed
         * ( notes added / deleted ) or a new song has been loaded
         *
         * @param aVoice             int index of the voice in the AudioSequencer
         * @param invalidateChildren invalidate all voice's VO's ( when voice properties have changed
         *                           such as envelopes and inserts )
         * @param immediateFlush     Boolean whether to flush ( the actual invalidation and discarding of previously
         *                           cached samples ) on the first step of the next bar ( when false ) or to flush on
         *                           next synthesize cycle ( when true )
         * @param recacheChildren    when children are to be invalidated, this Boolean dictates whether their
         *                           caches are to be rebuilt immediately by addition to the BulkCacher
         */
        public function invalidateCache( aVoice:int = -1, invalidateChildren:Boolean = false, immediateFlush:Boolean = false, recacheChildren:Boolean = true ):void
        {
            // we keep track of the caches to invalidate in the _invalidate Vector
            // we actually clear them when the synthesize function restarts
            // to prevent reading from cleared buffers while synthesizing!

            if ( _invalidate == null )
                _invalidate = new <Object>[];

            // voice index specified ? invalidate only for that voice
            if ( aVoice > -1 )
            {
                // unless it's already queued for invalidation
                if (  getInvalidationDataForVoice( aVoice ) == null )
                    _invalidate.push({ voice: aVoice, immediate: immediateFlush, children: invalidateChildren, recache: recacheChildren });

            }
            // no specific voice number ? invalidate all
            else
            {
                // remove all from BulkCacher as we have to rebuild everything
                BulkCacher.flush();

                for ( var i:int = 0; i < _voiceSamples.length; ++i )
                {
                    if ( getInvalidationDataForVoice( i ) == null )
                        _invalidate.push({ voice: i, children: invalidateChildren, recache: recacheChildren });
                }
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                        G E T T E R S   /   S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        /*
         * quick lookup if current voice is queued in the invalidation Vector
         * returns Object w/ invalidation properties when true, returns null
         * when not in invalidation Vector
         */
        protected function getInvalidationDataForVoice( voice:int ):Object
        {
            if ( _invalidate == null )
                return null;

            var output:Object;

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
        protected function clearCache( voice:int ):void
        {
            var invalidation:Object = getInvalidationDataForVoice( voice );

            if ( invalidation == null )
                return;

            // queried voice is to be invalidated
            // perform validation either when immediate flush has been requested
            // or when the sequencer's loop position is at the first step
            if ( invalidation.immediate || AudioSequencer.stepPosition == 0 )
            {
                var theCache:AudioCache = _cachedVoices[ voice ];

                if ( theCache != null )
                {
                    // the voice contained an audio cache, write it's contents to
                    // a temporary "oldCache" for reading during repeated clearing
                    // of the currently building cache ( by adding / removing notes
                    // from the timeline or altering the voice's audio parameters )\

                    if ( _oldCaches[ voice ] == null )
                    {
                        _oldCaches[ voice ] = new AudioCache( theCache.length );
                        _oldCaches[ voice ].write( theCache.read( 0, theCache.length ));

                        if ( _oldCacheReadSteps[ voice ] == 0 )
                            _oldCacheReadSteps[ voice ] = CACHE_RELEASE_TIME;
                    }
                    theCache.destroy();
                    theCache = null;
                }

                // sequencer's first position ? remove voice from invalidation array
                // so we can cache its contents
                if ( !invalidation.immediate )
                {
                    _invalidate.splice( invalidation.index, 1 );

                    if ( invalidation.children )
                        invalidateCachedAudioEvents( voice, invalidation.recache );

                } else {
                    // immediate flush ? keep voice in invalidation array for
                    // sequencer's next pass on start of loop
                    invalidation.immediate = false;
                }
            }
        }

        /*
         * invalidate the cached VOAudioEvents
         * and immediately restart caching them w/ their new properties
         */
        protected function invalidateCachedAudioEvents( num:int, recache:Boolean ):void
        {
            var timeline:IAudioTimeline = AudioSequencer.retrieveTimeline( num );

            if ( timeline != null )
                timeline.resetNotes( recache );
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        /*
         * mixes two audio buffers into one
         *
         * @output source buffer which should be used as the output by the synthesizer class
         * @merge  buffer to be merged with the source / output buffer
         *
         * @level  optional : set the mix level of the merge buffer
         */
        private function mix( output:Vector.<Vector.<Number>>, merge:Vector.<Vector.<Number>>, position:Number = 0, level:Number = 1 ):void
        {
            var length:int = output[0].length;

            if ( length > merge[0].length )
                length = merge[0].length;

            length -= position;

            var i:int = position;

            // 15 % faster, so avoid the need for multiplying by 1...
            if ( level == 1 )
            {
                for ( i; i < length; ++i )
                {
                    output[0][i] += merge[0][i];
                    output[1][i] += merge[1][i];
                }
            } else {
                for ( i; i < length; ++i )
                {
                    output[0][i] += ( merge[0][i] * level );
                    output[1][i] += ( merge[1][i] * level );
                }
            }
        }
    }
}
