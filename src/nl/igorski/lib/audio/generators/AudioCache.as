package nl.igorski.lib.audio.generators
{
    import flash.events.Event;
    import flash.events.EventDispatcher;

    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.events.AudioCacheEvent;

    /**
     * ...
     * @author Igor Zinken
     * 
     * AudioCache stores a synthesized stereo audio signal
     *            for quick reading when looping the same sound
     */
    public final class AudioCache extends EventDispatcher
    {
        private var _length                 :int;
        
        private var _cachedWave             :Vector.<Vector.<Number>>;
        private var _cacheFillCounter       :int;
        public var readPointer              :int;

        private var _valid                  :Boolean;
        private var _autoValidate           :Boolean;
        
        /*
         * @length the length of the audio fragment to cache ( in bytes )
         * @autoValidate whether the write function will automatically declare this cache as valid
         *               after enough cycles have completed the full cache length
         */
        public function AudioCache( length:int = 0, autoValidate:Boolean = true )
        {
            _length       = length;
            _autoValidate = autoValidate;
            clear();
        }
        
        /*
         * read audio from the cached buffer
         * @position the position to read from, if not passed this instance will start
         *           at the 0 position, and manage it's internal read pointers accordingly
         *           to the cached audio length and read iteration
         * @length the total size of the fragment to read, if not passed this will
         *         default to the current buffer size
         */
        public function read( position:int = -1, length:int = -1 ):Vector.<Vector.<Number>>
        {
            if ( length == -1 )
                length = AudioSequencer.BUFFER_SIZE;
            
            if ( position == -1 )
            {
                position = readPointer;
                
                readPointer += length;
                //trace( "reading " + length + " bytes from position " + position );
                if ( readPointer >= _length )
                    readPointer = 0;
            }
            var out:Vector.<Vector.<Number>> = BufferGenerator.generate( length );

            if ( _cachedWave != null ) {
                out[0] = _cachedWave[0].slice( position, position + length );
                out[1] = _cachedWave[1].slice( position, position + length );
            }
            return out;
        }
        
        /*
         * write audio data into the buffer, note when writing to a non-empty buffer the audio
         * is in essence, mixed together
         *
         * @data     a Vector containing two Number Vectors ( for each channel in the stereo field )
         * @position the position to write to in the buffer
         * @length   the total size of the fragment to write, if not entered this will
         *           default to the size of the data Number Vectors
         */
        public function write( data:Vector.<Vector.<Number>> = null, position:int = 0, length:int = -1 ):void
        {
            if ( _valid )
                return;
                
            if ( length == -1 )
                length = data[0].length;

            if ( position + length > _length )
                length = _length - position;
            
            // trace( "writing "+ length + " bytes at " + position );
            for ( var i:int = position, j:int = position + length; i < j; ++i )
            {
                _cachedWave[0][i] += data[0][i - position];
                _cachedWave[1][i] += data[1][i - position];
            }
            if ( !_autoValidate )
                return;

            if (( ++_cacheFillCounter * AudioSequencer.BUFFER_SIZE ) > ( _length - length ))
            {
                 // caching complete
                _valid = true;
                dispatchEvent( new Event( AudioCacheEvent.CACHE_COMPLETED ));
            }
        }
        
        /*
         * same as write function above, only this will conveniently look up the specified position
         * to start writing at by checking the current cache progress, and appending at the end of
         * the previously written data
         */
        public function append( data:Vector.<Vector.<Number>> ):void
        {
            var length:int = data[0].length;

            if ( length > AudioSequencer.BUFFER_SIZE )
                length = AudioSequencer.BUFFER_SIZE;

            write( data, _cacheFillCounter * AudioSequencer.BUFFER_SIZE, length );
        }
        
        /*
         * getters and setters for checking whether this instance's cache
         * is full and ready for reading
         */
        public function get valid():Boolean
        {
            return _valid;
        }
        
        public function set valid( value:Boolean ):void
        {
            _valid = value;
        }

        // clear memory
        public function destroy():void
        {
            if ( _cachedWave != null )
            {
                _cachedWave[0] = null;
                _cachedWave[1] = null;
                _cachedWave    = null;
            }
            _valid = false;
        }
        
        /*
         * creates a new buffer to cache into
         */
        private function clear():void
        {
            _valid            = false;
            _cacheFillCounter = 0;
            _cachedWave       = BufferGenerator.generate( _length );
        }
    }
}
