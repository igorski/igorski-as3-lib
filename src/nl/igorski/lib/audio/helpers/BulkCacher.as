package nl.igorski.lib.audio.helpers
{
    import flash.events.Event;
    import flash.events.EventDispatcher;

    import flash.utils.setTimeout;

    import nl.igorski.lib.audio.core.AudioSequencer;

    import nl.igorski.lib.audio.core.events.AudioCacheEvent;
    import nl.igorski.lib.audio.model.vo.VOAudioEvent;

    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 21-05-11
     * Time: 19:02
     *
     * BulkCacher collects references to VOAudioEvents and caches
     * them sequentially ( allowing for creation of progress visualisers )
     * this class also doubles as storage, to be queried by the Synthesizer class
     *
     */
    public final class BulkCacher extends EventDispatcher
    {
        private static var INSTANCE                 :BulkCacher = new BulkCacher();

        public static const EVENT_ADDED_TO_CACHE    :String = "BulkCacher::EVENT_ADDED_TO_CACHE";

        private var _audioEvents                    :Vector.<VOAudioEvent>;
        private var _cachedEvents                   :Vector.<VOAudioEvent>;
        private var _totalSamples                   :int;
        private var _isCaching                      :Boolean;
        private var _total                          :int;
        private var _sequenced                      :Boolean = false;

        private var _delay                          :int;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function BulkCacher()
        {
            if ( INSTANCE != null )
                throw new Error( "cannot instantiate BulkCacher" );

            _cachedEvents = new Vector.<VOAudioEvent>();
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /**
         * we use the BulkCacher as a static class, as such no references to the INSTANCE
         * are made, we wrap these event functions to the instance internally */

        public static function addEventListener( type:String, listener:Function ):void
        {
            INSTANCE.addEventListener( type, listener );
        }

        public static function removeEventListener( type:String, listener:Function ):void
        {
            INSTANCE.removeEventListener( type, listener );
        }

        public static function addEvent( vo:VOAudioEvent ):void
        {
            if ( INSTANCE._audioEvents == null )
            {
                INSTANCE._audioEvents = new Vector.<VOAudioEvent>();
                INSTANCE._isCaching   = false;
                INSTANCE._total       = 0;
            }
            // check whether we're not adding the same object twice
            for each( var existing:VOAudioEvent in INSTANCE._audioEvents )
            {
                if ( existing.id == vo.id )
                    return;
            }
            INSTANCE._audioEvents.push( vo );
            ++INSTANCE._total;

            vo.calculateLengths();
            INSTANCE._totalSamples += vo.sampleLength;
        }

        /*
         * process the queue from the beginning
         */
        public static function cache( delay:int = 5 ):void
        {
            INSTANCE._delay = delay;

            if ( remaining == 0 )
            {
                INSTANCE._isCaching = false;
                return;
            }
            INSTANCE._isCaching = true;
            var vo:VOAudioEvent = INSTANCE._audioEvents[0];

            vo.addEventListener( AudioCacheEvent.CACHE_COMPLETED, INSTANCE.handleEventCached );
            vo.cache();
        }

        /*
         * here we specifically cache the VO's belonging
         * to a certain sequencer step position
         */
        public static function cacheBySequencerStep( step:int = 0 ):void
        {
            if ( remaining == 0 )
            {
                INSTANCE._isCaching = false;
                return;
            }
            for ( var i:int = 0; i < INSTANCE._audioEvents.length; ++i )
            {
                var vo:VOAudioEvent = INSTANCE._audioEvents[i];

                if ( vo.delta == step && vo.sample == null && !vo.isCaching )
                {
                    INSTANCE._isCaching = true;
                    vo.addEventListener( AudioCacheEvent.CACHE_COMPLETED, INSTANCE.handleEventCached );
                    vo.cache();
                }
            }
        }

        public static function addCachedSample( vo:VOAudioEvent ):void
        {
            /*
             * VOAudioEvents have a unique identifier, we first check
             * if this VO existed in the Vector, if so replace it */

            INSTANCE.removeCachedSample( vo.id );

            vo.addEventListener( AudioCacheEvent.CACHE_DESTROYED, INSTANCE.handleSampleDestroy );
            INSTANCE._cachedEvents.push( vo );
        }

        public static function getCachedSample( id:String ):VOAudioEvent
        {
            var vo:VOAudioEvent;

            for ( var i:int = 0; i < INSTANCE._cachedEvents.length; ++i )
            {
                vo = INSTANCE._cachedEvents[i];

                if ( vo.id == id )
                    return vo;
            }
            return null;
        }

        public static function flushCachedSamples( voiceNum:int = -1 ):void
        {
            var vo:VOAudioEvent;

            // no specific voice requested ? flush for all
            if ( voiceNum == - 1 )
            {
                for ( var i:int = 0; i < AudioSequencer.AMOUNT_OF_VOICES; ++i ) {
                    flushCachedSamples( i );
                }
                return;
            }

            for ( i = INSTANCE._cachedEvents.length - 1; i >= 0; --i )
            {
                vo = INSTANCE._cachedEvents[i];

                if ( vo.voice == voiceNum )
                {
                    if ( vo.sample != null )
                        vo.sample.destroy();

                    if ( vo.hasEventListener( AudioCacheEvent.CACHE_DESTROYED ))
                        vo.removeEventListener( AudioCacheEvent.CACHE_DESTROYED, INSTANCE.handleSampleDestroy );

                    vo = null;

                    INSTANCE._cachedEvents.splice( i,  1 );
                }
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        public static function get total():int
        {
             return INSTANCE._total;
        }

        public static function get remaining():int
        {
            if ( INSTANCE._audioEvents == null || INSTANCE._audioEvents.length == 0 )
                return 0;

            return INSTANCE._audioEvents.length;
        }

        /**
         * you can calculate whether or not to show progress bars
         * by requesting the amount of bytes left to sample */

        public static function get totalSamples():int
        {
            return INSTANCE._totalSamples;
        }

        /*
         * remove the current queue
         */
        public static function flush():void
        {
            if ( remaining == 0 )
            {
                INSTANCE._audioEvents  = new Vector.<VOAudioEvent>();
                INSTANCE._isCaching    = false;
                INSTANCE._total        = 0;
                INSTANCE._totalSamples = 0;
            }
            flushCachedSamples();
            sequenced = false;
        }

        /*
         * by setting the sequenced Boolean to true, instead of
         * caching everything at once, we let the synthesizer
         * manually call the cache per sequencer step
         */
        public static function get sequenced():Boolean
        {
            return INSTANCE._sequenced;
        }

        public static function set sequenced( value:Boolean ):void
        {
            INSTANCE._sequenced = value;
        }

        public static function get processed():int
        {
            return total - remaining;
        }

        public static function get isCaching():Boolean
        {
            return INSTANCE._isCaching;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function handleEventCached( e:AudioCacheEvent ):void
        {
            var vo:VOAudioEvent = e.target as VOAudioEvent;

            vo.removeEventListener( AudioCacheEvent.CACHE_COMPLETED, handleEventCached );

            var found:Boolean = false;

            for ( var i:int = _audioEvents.length - 1; i >= 0; --i )
            {
                if ( _audioEvents[i] == e.target )
                {
                    found = true;
                    _audioEvents.splice( i, 1 );
                    _totalSamples -= vo.sampleLength;
                    break;
                }
            }
            // store sample
            addCachedSample( vo );

            if ( remaining > 0 )
            {
                // when loading all, let's give the listening object time to update
                // as the caching of a large list can easily hog all resources
                if ( !_sequenced )
                    setTimeout( cache, _delay );
            }
            else {
                _total     = 0;
                _isCaching = false;
                _sequenced = false;
            }
            dispatchEvent( new Event( EVENT_ADDED_TO_CACHE ));
        }

        private function handleSampleDestroy( e:Event ):void
        {
            var vo:VOAudioEvent = e.target as VOAudioEvent;

            vo.removeEventListener( AudioCacheEvent.CACHE_DESTROYED, handleSampleDestroy );
            removeCachedSample( vo.id, true );
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        /*
         * removes a cached sample from the cache Vector
         *
         * @sampleId  unique String identifier for the VOAudioEvent
         * @always    Boolean, when false only remove sample if it's cached contents aren't valid
         */
        private function removeCachedSample( sampleId:String = "", always:Boolean = false ):void
        {
            var existing:VOAudioEvent;

            for ( var i:int = _cachedEvents.length - 1 ; i >= 0; --i )
            {
                existing = _cachedEvents[i];
                if ( existing.id == sampleId )
                {
                    if (( existing.sample == null || !existing.sample.valid ) || always )
                        _cachedEvents.splice( i, 1 );
                    else
                        break;
                }
            }
        }
    }
}
