package nl.igorski.lib.audio.core
{
    import com.noteflight.standingwave3.elements.AudioDescriptor;
    import com.noteflight.standingwave3.elements.Sample;

    import nl.igorski.lib.audio.caching.AudioCache;

    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.interfaces.IBufferModifier;
    import nl.igorski.lib.audio.core.interfaces.IAudioProcessor;
    import nl.igorski.lib.audio.helpers.BulkCacher;
    import nl.igorski.lib.audio.model.vo.VOAudioEvent;
    import nl.igorski.lib.audio.ui.interfaces.IAudioTimeline;

    public class AudioProcessor implements IAudioProcessor
    {    
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 20-dec-2010
         * Time: 14:29:33 */

        protected var _voiceEvents              :Vector.<Vector.<VOAudioEvent>>;

        // cached buffers - synthesizing is expensive, re-use when possible !!

        /**
         * _cachedVoices - used when all events for a voice have been cached, this
         *                 buffer is read from when all events for a voice have been
         *                 cached and remain unchanged during playback
         * _oldCaches    - used for reading when rebuilding a _cachedVoice when the
         *                 voices properties / events change
         * _voiceBuffers - short buffers used when the voices have IBufferModifiers
         *                 processing them, which occur "live"
         */
        protected var _cachedVoices             :Vector.<AudioCache>;
        protected var _oldCaches                :Vector.<AudioCache>;
        protected var _voiceBuffers             :Vector.<Sample>;

        protected var _invalidate               :Vector.<Object>;
        protected var _oldCacheReadSteps        :Vector.<int>;

        private const CACHE_RELEASE_TIME        :int = 12; // the amount of synthesize() cycles we rely upon
                                                           // reading from the old cache during recaching

        /* temporary buffer used for writing in each cycle */
        private var _buffer                     :Sample;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function AudioProcessor( voiceAmount:int = 1 ):void
        {
            // create a sample Vector for each instrument / sequencer timeline
            // this is where the notes for synthesis are queued
            _voiceEvents       = new <Vector.<VOAudioEvent>>[];

            _cachedVoices      = new <AudioCache>[];
            _voiceBuffers      = new <Sample>[];
            _oldCaches         = new <AudioCache>[];
            _oldCacheReadSteps = new <int>[];

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

            for each( var oVo:VOAudioEvent in _voiceEvents[ voiceNum ])
            {
                if ( oVo.id == vo.id )
                    found = true;
            }

            if ( !found )*/
                _voiceEvents[ voiceNum ].push( vo );
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
            while ( _voiceEvents.length < totalLength )
            {
                _voiceEvents.push ( new Vector.<VOAudioEvent>());
                _cachedVoices.push( new AudioCache( AudioSequencer.BYTES_PER_BAR, false ));
                _oldCaches.push   ( new AudioCache( AudioSequencer.BYTES_PER_BAR, false ));
                _voiceBuffers.push( new Sample( new AudioDescriptor(), AudioSequencer.BUFFER_SIZE ));
                _oldCacheReadSteps.push( 0 );
            }
        }

        /**
         * the synthesize function processes the added events and outputs these in
         * the current audio stream, so we can actually HEAR things
         *
         * @param consolidateVoices {Boolean} optional, defaults to true
         *        to save resources we immediately mix all voice outputs into
         *        a single Sample. If we need to reprocess the voices individually
         *        after synthesis, pass false
         */

        public final function synthesize( consolidateVoices:Boolean = true ):void
        {
            var bufferSize :int = AudioSequencer.BUFFER_SIZE;
            var position   :int = AudioSequencer.position;

            _buffer              = new Sample( new AudioDescriptor(), bufferSize );
            var mixTarget:Sample = _buffer; // local reference - overridden when not consolidating to a single voice

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

            var mixQueue   :Vector.<AudioCache> = new Vector.<AudioCache>();

            for( var i:int = 0; i < _voiceEvents.length; ++i )
            {
                if ( !consolidateVoices )
                {
                    mixTarget = _voiceBuffers[ i ];
                    mixTarget.setSamples( 0.0, 0, bufferSize );
                }

                // first check if current cache is to be invalidated and rebuilt...
                if ( _invalidate != null )
                    clearCache( i );

                if ( _cachedVoices[ i ] == null )
                    _cachedVoices[ i ] = new AudioCache( AudioSequencer.BYTES_PER_BAR, false );

                var doCache:Boolean = AudioSequencer.getVoice( i ).active;
                var theSamples:Vector.<VOAudioEvent> = _voiceEvents[ i ];
                var theCache  :AudioCache            = _cachedVoices[ i ];

                /*
                 * voice isn't cached ? synthesize its samples into a temporary
                 * buffer we use to write into the currently streaming buffer */

                if ( !theCache.valid )
                {
                    // if a cache for the previous series of events exists, read
                    // from this cache during the creation of the new one
                    var readOld:Boolean = ( _oldCaches[ i ] != null );

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
                        mix( theCache, mixTarget, position, bufferSize );
                    }
                    else {
                        if ( _oldCacheReadSteps[ i ] > 0 ) {
                            trace( "read from OLD cache");
                            mix( _oldCaches[ i ], mixTarget, position, bufferSize );
                            --_oldCacheReadSteps[ i ];
                        } else {
                            trace( "read from the cache, (still invalid)");
                            mix( theCache, mixTarget, position, bufferSize );
                        }
                    }
                    for ( var j:int = theSamples.length - 1; j >= 0; --j )
                    {
                        var vo:VOAudioEvent = theSamples[ j ];

                        // cache this sample?
                        if ( doCache )
                        {
                            /*
                             * samples buffer is full ? read its currently audible audio content
                             * into the audioBuffer for direct output and cache its full contents
                             * in the voices cache */

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
                                     //TODO: was this the source of poppin' weird behaviour ? ( apply envelope ? )
                                   // mix( vo.sample, offset, readLength );
                                }/*
                                else {*/
                                /*
                                 * we splice the audio event from the list after its caching has completed
                                 * and write the samples cached contents in the voices buffer, note
                                 * we don't write it into the current audioBuffer for direct output as
                                 * we're caching a step ahead ! */

                                    theSamples.splice( j, 1 );
                                    BulkCacher.addCachedSample( vo );

                                    theCache.write( vo.sample, vo.delta * AudioSequencer.BYTES_PER_TICK, vo.sample.length );

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
                        theCache.vectorsToMemory();
                        theCache.valid = true;

                        trace( "CACHE " + i + "  VALID TRUE" );

                        if ( _oldCaches[ i ] != null )
                            _oldCaches[ i ].destroy();
                    }
                }
                /*
                 * current voice has all its samples cached, queue so we can
                 * read straight from the cache into the output buffer */
                else
                {
                    mixQueue.push( theCache );
                }
            }

            if ( !consolidateVoices )
                return;

            // process mix queue
            i = mixQueue.length;

            while ( i-- )
            {
                _buffer.mixInDirectAccessSource( mixQueue[ i ].sample, position, 1.0, 0, bufferSize );
            }
            /* the audioBuffer is now filled with sample data, the AudioSequencer
             * class can now write it back into the currently streaming SampleDataEvent for
             * actual audio output */
        }

        public function processBufferModifiers():void
        {
            var bufferSize :int = AudioSequencer.BUFFER_SIZE;
            var position   :int = AudioSequencer.position;

            for ( var i:int = 0, j:int = _cachedVoices.length; i < j; ++i )
            {
                var tempCache:Sample     = _voiceBuffers[ i ];
                var theCache :AudioCache = _cachedVoices[ i ];
                var modifiers:Vector.<IBufferModifier> = AudioSequencer.getVoice( i ).getAllBufferModifiers();

                for ( var k:int = 0; k < modifiers.length; ++k )
                {
                    var m:IBufferModifier = modifiers[ k ];

                    // cache for current voice complete and valid ?
                    if ( theCache != null && theCache.valid )
                    {
                        if ( k == 0 )
                            tempCache.setSamples( 0.0, 0, bufferSize );

                        tempCache.mixInDirectAccessSource( theCache.sample, position, 1.0, 0, bufferSize );
                    }
                    m.processBuffer( tempCache.channelData );
                }
                if ( tempCache )
                {
                    if ( modifiers.length > 0 )
                    {
                        tempCache.invalidateSampleMemory();
                        tempCache.commitChannelData();
                    } else {
                        if ( theCache != null && theCache.valid ) {
                            tempCache.setSamples( 0.0, 0, bufferSize );
                            tempCache.mixInDirectAccessSource( theCache.sample, position, 1.0, 0, bufferSize );
                        }
                    }
                    _buffer.mixInDirectAccessSource( tempCache, 0, 1.0, 0, bufferSize );
                }
            }
        }

        /**
         * presynthesize takes all currently cached VOAudioEvents from
         * the voice timelines and writes their cache into the cachedVoices
         * Vector.
         *
         * use when synthesizer is idle
         *
         * @param data {Vector.<Vector.<VOAudioEvent>>} a collection containing Vectors with Audio Events for each voice
         */
        public function presynthesize( data:Vector.<Vector.<VOAudioEvent>> ):void
        {
            _invalidate = null;

            for ( var i:int = 0; i < data.length; ++i )
            {
                _cachedVoices[ i ] = new AudioCache( AudioSequencer.BYTES_PER_BAR, false );

                for each( var re:VOAudioEvent in data[ i ] )
                {
                    var vo:VOAudioEvent = BulkCacher.getCachedSample( re.id );

                    _cachedVoices[ i ].write( vo.sample, vo.delta * AudioSequencer.BYTES_PER_TICK, vo.sample.length );
                }
                _cachedVoices[ i ].valid = true;
                _cachedVoices[ i ].vectorsToMemory();
            }
        }

        /**
         * invalidate cache(s), called when a timeline's content has changed
         * ( notes added / deleted ) or a new song has been loaded
         *
         * @param aVoice             {int} index of the voice in the AudioSequencer
         * @param invalidateChildren {Boolean} invalidate all voice's VO's ( when voice properties have changed
         *                           such as envelopes and inserts )
         * @param immediateFlush     {Boolean} whether to flush ( the actual invalidation and discarding of previously
         *                           cached samples ) on the first step of the next bar ( when false ) or to flush on
         *                           next synthesize cycle ( when true )
         * @param recacheChildren    {Boolean} when children are to be invalidated, this Boolean dictates whether their
         *                           caches are to be rebuilt immediately by addition to the BulkCacher
         * @param destroyOldCache    {Boolean} whether we disallow cloning the current ( to be invalidated )
         *                           cache into an old cache ( which is read from during the building of a new
         *                           cache ). Defaults to false
         */
        public function invalidateCache( aVoice:int = -1, invalidateChildren:Boolean = false, immediateFlush:Boolean = false, recacheChildren:Boolean = true, destroyOldCache:Boolean = false ):void
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
                    _invalidate.push({ voice:      aVoice,
                                       immediate:  immediateFlush,
                                       children:   invalidateChildren,
                                       recache:    recacheChildren,
                                       destroyOld: destroyOldCache });

            }
            // no specific voice number ? invalidate all
            else
            {
                // remove all from BulkCacher as we have to rebuild everything
                BulkCacher.flush();

                for ( var i:int = 0; i < _voiceEvents.length; ++i )
                {
                    if ( getInvalidationDataForVoice( i ) == null )
                        _invalidate.push({ voice: i, children: invalidateChildren, recache: recacheChildren });
                }
            }
        }

        public function clearTemporaryBuffers():void
        {
            for ( var i:int = 0; i < _oldCaches.length; ++i )
            {
                if ( _oldCaches[ i ] != null )
                    _oldCaches[ i ].destroy();

                _oldCaches[ i ] = null;
            }
            for ( i = 0; i < _cachedVoices.length; ++i )
            {
                if ( _cachedVoices[ i ] != null )
                    _cachedVoices[ i ].destroy();

                _cachedVoices[ i ] = null;
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                        G E T T E R S   /   S E T T E R S

        public function get sample():Sample
        {
            return _buffer;
        }

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

                if ( theCache != null && theCache.valid )
                {
                    // the voice contained an audio cache, write its contents to
                    // a temporary "oldCache" for reading during repeated clearing
                    // of the currently building cache ( by adding / removing notes
                    // from the timeline or altering the voices audio parameters )

                    if ( _oldCaches[ voice ] == null )
                        _oldCaches[ voice ] = new AudioCache( theCache.length );
                     else
                        _oldCaches[ voice ].buildSample( true ); // in case of tempo change

                    // TODO: when inactive, we hear notes we just removed!! however, when
                    // we do uncomment this, we hear nothing during rebuild... BLEH!
                    // fix how ?
//                    if ( !invalidation.destroyOld )
                        _oldCaches[ voice ].clone( theCache );
//                    else
//                        trace( "no cloning!");

                    if ( _oldCacheReadSteps[ voice ] == 0 )
                        _oldCacheReadSteps[ voice ] = CACHE_RELEASE_TIME;

                    theCache.destroy();
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

        /**
         * mixes two audio buffers into one
         *
         * @param source   {AudioCache} containing audio to mix in
         * @param target   {Sample} current buffer used for streaming SampleDataEvent
         * @param position {int} read position in merge cache
         * @param length   {int} total amount of samples to mix in
         */
        private function mix( source:AudioCache, target:Sample, position:int = 0, length:int = 0 ):void
        {
            if ( source.sample != null )
                target.mixInDirectAccessSource( source.sample, position, 1.0, 0, length );
        }
    }
}
