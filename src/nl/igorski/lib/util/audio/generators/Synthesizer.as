package nl.igorski.lib.util.audio.generators
{
    import nl.igorski.lib.util.audio.AudioSequencer;
    import nl.igorski.lib.util.audio.core.interfaces.IVoice;
    import nl.igorski.lib.util.audio.model.vo.VOAudioEvent;
    import nl.igorski.lib.util.audio.ui.NoteGrid;

    public final class Synthesizer implements IVoice
    {    
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 20-dec-2010
         * Time: 14:29:33
         */
        private var _samples    :Vector.<Vector.<VOAudioEvent>>;
        private var _cached     :Vector.<AudioCache>;
        private var _invalidate :Vector.<int>;

        public var caching      :Boolean;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function Synthesizer( gridAmount:int = 1 ):void
        {
            // create a sample Vector for each instrument / sequencer grid
            _samples = new Vector.<Vector.<VOAudioEvent>>( gridAmount, true );
            
            for ( var i:int = 0; i < _samples.length; ++i )
                _samples[i] = new Vector.<VOAudioEvent>();
            
            // create buffers for caching of samples
            // ( we won't re-synthesize a non-modified loop but read from cached buffers )
            _cached = new Vector.<AudioCache>( _samples.length, true );

            caching = true;
        }
        
        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        /**
         * the addEvent function creates a sample object ( an audio "event" ) and pushes these into the _samples Vector
         * to be processed by the synthesize function, which will write it as audio in the buffer
         */
        public function addEvent( vo:VOAudioEvent, gridNum:int ):void
        {
            // we look if we're not attempting to push a still-caching VO into the samples list
            // to prevent double entries occuring clogging up the list
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
            var cacheBuffer:Vector.<Vector.<Number>>;

            for( var i:int = 0; i < _samples.length; ++i )
            {
                // first check if current cache is to be invalidated and rebuilt...
                if ( _invalidate != null )
                    clearCache( i );

                if ( _cached[ i ] == null )
                    _cached[i] = new AudioCache( 65536/*AudioSequencer.BYTES_PER_BAR*/, false );

                // not cached ? synthesize and write into cache
                if ( !_cached[ i ].valid )
                {
                    cacheBuffer = BufferGenerator.generate();
                    trace( "amount to cache for " + i + " => " + _samples[i].length );
                    for ( var j:int = _samples[i].length - 1; j >= 0; --j )
                    {
                        var vo:VOAudioEvent = _samples[i][j];

                        // if sample has finished it's caching...
                        if ( vo.sample != null && vo.sample.valid )
                        {
                            BufferGenerator.mix( cacheBuffer, vo.sample.read(), 0, 1 / _samples[i].length );

                            // splice event after read has completed full cycle, write in cache
                            if ( vo.sample.readPointer == 0 ) {
                                _samples[i].splice( j, 1 );
                                _cached[i].write( cacheBuffer, vo.delta * AudioSequencer.BUFFER_SIZE );
                            }
                        }

                        // all samples cleared ? cache buffer for voice is valid
                        //if ( _samples[i].length == 0 )
                          //  _cached[i].valid = true;
                    }
                }
                else {
                    trace( "cached " + i + " => valid" );
                    if ( caching )
                        caching = false;

                    cacheBuffer = _cached[ i ].read();
                }
                // cached => write cache into output buffer
                for ( var bi:int = 0, bl:int = cacheBuffer[0].length; bi < bl; ++bi )
                {
                    var l:Vector.<Number> = buffer[0];
                    var r:Vector.<Number> = buffer[1];

                    l[bi] += cacheBuffer[0][bi];
                    r[bi] += cacheBuffer[1][bi];
                }
                cacheBuffer = null;
            }
            if ( _invalidate != null )
                _invalidate = null;
        }
        
        /*
         * invalidate cache(s), called when a grid's
         * content has changed or a new song is loaded
         */
        public function invalidateCache( gridNum:int = -1, invalidateChildren:Boolean = false ):void
        {
            // we keep track of the caches to invalidate in the _invalidate Vector
            // we actually clear them when the synthesize function restarts
            // to prevent reading from cleared buffers while synthesizing
            
            if ( _invalidate == null )
                _invalidate = new Vector.<int>();
            
            // gridNum specified ? invalidate only for that grid
            if ( gridNum > -1 )
            {
                _invalidate.push( gridNum );
                if ( invalidateChildren )
                    invalidateCachedAudioEvents( gridNum );
            }
            // no specific grid number ? invalidate all
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
        
        private function clearCache( gridNum:int ):void
        {
            if ( _invalidate.indexOf( gridNum ) > -1 )
            {
                if ( _cached[ gridNum ] != null )
                {
                    _cached[ gridNum ].destroy();
                    _cached[ gridNum ] = null;
                    //trace( "cleared cache " + gridNum );
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
