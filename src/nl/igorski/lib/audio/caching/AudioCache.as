package nl.igorski.lib.audio.caching
{
    import com.noteflight.standingwave3.elements.AudioDescriptor;
    import com.noteflight.standingwave3.elements.Sample;

    import flash.events.Event;
    import flash.events.EventDispatcher;

    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.events.AudioCacheEvent;
    import nl.igorski.lib.interfaces.IDestroyable;

    /**
     * @author Igor Zinken
     * 
     * AudioCache stores a synthesized stereo audio signal
     *            for quick reading when looping the same sound
     */
    public final class AudioCache extends EventDispatcher implements IDestroyable
    {
        private var _length                 :int;
        
        private var _cacheFillCounter       :int;
        public var readPointer              :int;

        private var _valid                  :Boolean;
        private var _autoValidate           :Boolean;

        // Sample Class from Standing Wave 3, using Alchemy for fast memory read/writes
        private var _sample                 :Sample;
        
        /**
         * @param length       {int}the length of the audio fragment to cache ( in bytes )
         * @param autoValidate {Boolean} whether the write function will automatically declare this
         *                     cache as valid all cycles have completed to fulfill the declared length
         */
        public function AudioCache( length:int = 0, autoValidate:Boolean = true )
        {
            _length       = length;
            _autoValidate = autoValidate;

            reset();
        }
        
        /**
         * read audio from the cached buffer
         *
         * @param position [int} the position to read from, if not passed this instance will start
         *        at the 0 position, and manage it's internal read pointers accordingly
         *        to the cached audio length and read iteration
         * @paramlength {int} the total size of the fragment to read, if not passed this will
         *              default to the current buffer size
         * @return {Array} containing two Number Vectors
         */
        public function read( position:int = -1, length:int = -1 ):Array
        {
            if ( length == -1 )
                length = AudioSequencer.BUFFER_SIZE;

            if ( position == -1 )
            {
                position = readPointer;
                
                readPointer += length;

                if ( readPointer >= _length )
                    readPointer = 0;
            }

            if ( position + length > _length )
                length = _length - position;

            return [ _sample.getChannelSlice( 0, position, length ),
                     _sample.getChannelSlice( 1, position, length ) ];
        }
        
        /**
         * write audio data into the buffer, note when writing to a non-empty buffer the audio
         * is in essence, mixed together
         *
         * @param data     {Array|AudioCache} either an Array containing two Number Vectors
         *                 ( for each channel in the stereo field ) or another AudioCache
         * @param position {int} the position to write to in the buffer
         * @param length   {int} the total size of the fragment to write, if not entered this will
         *                 default to the size of the data Number Vectors
         */
        public function write( data:* = null, position:int = 0, length:int = -1 ):void
        {
            if ( _valid )
                return;
                
            if ( length == -1 )
                length = data[ 0 ].length;

            if ( position + length > _length )
                length = _length - position;

            if ( _sample == null )
                _sample = new Sample( new AudioDescriptor(), _length );

            if ( data is Array )
            {
                trace( "write from vectors" );

                var channels:Array = _sample.channelData;
                for ( var i:int = position, j:int = position + length; i < j; ++i )
                {
                    channels[ 0 ][ i ] += data[ 0 ][ i - position ];
                    channels[ 1 ][ i ] += data[ 1 ][ i - position ];
                }
                _sample.invalidateSampleMemory();   // facilitates reading from unfinished caches
            }
            else if ( data is AudioCache )
            {
                trace( "write from Sample memory" );

                _sample.mixInDirectAccessSource( AudioCache( data ).sample, 0, 1.0, position, length );
            }

            if ( !_autoValidate )
                return;

            if (( ++_cacheFillCounter * AudioSequencer.BUFFER_SIZE ) > ( _length - length ))
            {
                 // caching complete
                vectorsToMemory();
                _valid = true;

                dispatchEvent( new Event( AudioCacheEvent.CACHE_COMPLETED ));
            }
        }
        
        /**
         * same as write function above, only this will conveniently look up the specified position
         * to start writing at by checking the current cache progress, and appending at the end of
         * the previously written data
         *
         * @param data {Array} containing two Number Vectors
         */
        public function append( data:Array ):void
        {
            var length:int = data[ 0 ].length;

            if ( length > AudioSequencer.BUFFER_SIZE )
                length = AudioSequencer.BUFFER_SIZE;

            write( data, _cacheFillCounter * AudioSequencer.BUFFER_SIZE, length );
        }

        /**
         * copies the contents of the source buffer
         * and immediately sets this cache as valid
         *
         * @source {Array|AudioCache} source to clone, either an Array containing
         *         a stereo Vector of Numbers, or another AudioCache Object. The
         *         AudioCache Object is cloned using Alchemical Labs for higher speed
         */
        public final function clone( source:* ):void
        {
            if ( source is Array )
            {
                trace( "clone from vectors" );

                _length = source[ 0 ].length;
                _sample = new Sample( new AudioDescriptor(), _length );

                _sample.commitSlice( source[ 0 ], 0, 0 );
                _sample.commitSlice( source[ 1 ], 1, 0 );

                vectorsToMemory();
            }
            else if ( source is AudioCache )
            {
                trace( "clone from Sample Memory" );

                _length = AudioCache( source ).length;
                _sample = new Sample( new AudioDescriptor(), _length );
                _sample.mixInDirectAccessSource( AudioCache( source ).sample, 0, 1.0, 0, _length );
            }
            _valid = true;
            dispatchEvent( new Event( AudioCacheEvent.CACHE_COMPLETED ));
        }

        /**
         * copy the contents from the this cache and
         * return it as a new AudioCache
         */
        public final function copy():AudioCache
        {
            var output:AudioCache = new AudioCache( _length, _autoValidate );
            output.clone( _sample );

            return output;
        }

        /**
         * commits the (temporary) data inside the Vectors to
         * the sample memory used for audio output
         */
        public function vectorsToMemory():void
        {
            if ( _sample == null )
                _sample = new Sample( new AudioDescriptor(), _length );

            _sample.commitChannelData();
        }

        public function get sample():Sample
        {
            return _sample;
        }

        public function get length():int
        {
            return _length;
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
            trace( "AudioCache::DESTROY" );

            if ( _sample != null )
                _sample.destroy();

            _sample = null;
            _valid  = false;
        }

        private final function reset():void
        {
            if ( _sample != null )
                _sample.destroy();

            _valid            = false;
            _cacheFillCounter = 0;

            _sample     = new Sample( new AudioDescriptor(), _length );
        }
    }
}
