package nl.igorski.lib.audio.generators
{
    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.interfaces.IVoice;
import nl.igorski.lib.audio.helpers.BulkCacher;
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
        private var _invalidate     :Vector.<int>;

        public var caching          :Boolean;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function Synthesizer( gridAmount:int = 1 ):void
        {
            // create a sample Vector for each instrument / sequencer grid
            _samples = new Vector.<Vector.<VOAudioEvent>>( gridAmount, true );
            
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
        public function addEvent( vo:VOAudioEvent, gridNum:int ):void
        {
            // we look if we're not attempting to push a still-caching VO into the samples list
            // to prevent double entries occurring and clogging up the list

            var found:Boolean = false;

            for each( var oVo:VOAudioEvent in _samples[ gridNum ])
            {
                if ( oVo.id == vo.id )
                    found = true;
            }
            if ( !found )
                _samples[ gridNum ].push( vo );
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
            // don't do anything if the BulkCacher is crunching
            if ( BulkCacher.isCaching )
                return;

            var audioBuffer:Vector.<Vector.<Number>>;

            for( var i:int = 0; i < _samples.length; ++i )
            {
                // first check if current cache is to be invalidated and rebuilt...
                if ( _invalidate != null )
                    clearCache( i );

                if ( _cachedVoices[i] == null )
                    _cachedVoices[i] = new AudioCache( 65536/*AudioSequencer.BYTES_PER_BAR*/, false );

                var doCache:Boolean = AudioSequencer.getVoice(i).active;

                /*
                 * voice isn't cached ? synthesize it's samples into a temporary
                 * buffer we use to write into the currently streaming buffer
                 */
                if ( !_cachedVoices[i].valid )
                {
                    audioBuffer = BufferGenerator.generate();

                    // trace( "amount to cache for " + i + " => " + _samples[i].length );

                    for ( var j:int = _samples[i].length - 1; j >= 0; --j )
                    {
                        var vo:VOAudioEvent = _samples[i][j];

                        // cache this sample?
                        if ( doCache )
                        {
                            // write sample's buffer to voice cache if it's full
                            if ( vo.sample != null && vo.sample.valid )
                            {
                                BufferGenerator.mix( audioBuffer, vo.sample.read(), 0, 1 / _samples[i].length );

                                // splice event after read has completed full cycle, write in voice's cache
                                if ( vo.sample.readPointer == 0 ) {
                                    _samples[i].splice( j, 1 );
                                    _cachedVoices[i].write( audioBuffer, vo.delta * AudioSequencer.BUFFER_SIZE );
                                }
                            }
                            // sample's buffer not full ? start it's caching ( when it's idle )
                            else {
                                if ( !vo.isCaching )
                                    vo.cache();
                            }
                        }
                        // TODO: maybe not, keep handleTick(); addition of samples , but why again??
                        // all samples cleared ? cache buffer for voice is valid
                        //if ( _samples[i].length == 0 )
                          //  _cached[i].valid = true;
                    }
                }
                /*
                 * current voice is cached, read cache into buffer
                 */
                else {
                    trace( "cached voice " + i + " => valid" );
                    if ( caching )
                        caching = false;

                    audioBuffer = _cachedVoices[i].read();
                }
                /*
                 * audioBuffer filled ?
                 * write it into the current streaming SampleDataEvent
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
            if ( _invalidate != null )
                _invalidate = null;
        }
        
        /*
         * invalidate cache(s), called when a grid's
         * content has changed or a new song is loaded
         */
        public function invalidateCache( voice:int = -1, invalidateChildren:Boolean = false ):void
        {
            // we keep track of the caches to invalidate in the _invalidate Vector
            // we actually clear them when the synthesize function restarts
            // to prevent reading from cleared buffers while synthesizing!
            
            if ( _invalidate == null )
                _invalidate = new Vector.<int>();
            
            // voice index specified ? invalidate only for that voice
            if ( voice > -1 )
            {
                _invalidate.push( voice );
                if ( invalidateChildren )
                    invalidateCachedAudioEvents( voice );
            }
            // no specific voice number ? invalidate all
            else {
                for ( var i:int = 0; i < _samples.length; ++i )
                {
                    _invalidate.push( i );
                    invalidateCachedAudioEvents( i );
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
        
        private function clearCache( voice:int ):void
        {
            if ( _invalidate.indexOf( voice ) > -1 )
            {
                if ( _cachedVoices[ voice ] != null )
                {
                    _cachedVoices[ voice ].destroy();
                    _cachedVoices[ voice ] = null;
                    //trace( "cleared cache " + voice );
                }
            }
            caching = true;
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
