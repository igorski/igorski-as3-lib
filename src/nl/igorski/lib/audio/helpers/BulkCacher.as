package nl.igorski.lib.audio.helpers
{
    import flash.events.Event;
    import flash.events.EventDispatcher;

import flash.utils.setTimeout;

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
     *
     */
    public final class BulkCacher extends EventDispatcher
    {
        public static var INSTANCE                  :BulkCacher = new BulkCacher();

        public static const EVENT_ADDED_TO_CACHE    :String = "BulkCacher::EVENT_ADDED_TO_CACHE";

        private var _audioEvents                    :Vector.<VOAudioEvent>;
        private var _isCaching                      :Boolean;
        private var _total                          :int;

        private var _delay                          :int;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function BulkCacher()
        {
            if ( INSTANCE != null )
                throw new Error( "cannot instantiate BulkCacher" );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public static function addEvent( vo:VOAudioEvent ):void
        {
            if ( INSTANCE._audioEvents == null )
            {
                INSTANCE._audioEvents = new Vector.<VOAudioEvent>();
                INSTANCE._isCaching   = false;
                INSTANCE._total       = 0;
            }
            // check whether we're not adding the same object twice
            for each( var added:VOAudioEvent in INSTANCE._audioEvents )
            {
                if ( added.id == vo.id )
                    return;
            }
            INSTANCE._audioEvents.push( vo );
            ++INSTANCE._total;
        }

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

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        public static function get total():int
        {
             return INSTANCE._total;
        }

        public static function get remaining():int
        {
            if ( INSTANCE._audioEvents == null )
                return 0;

            return INSTANCE._audioEvents.length;
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
            VOAudioEvent( e.target ).removeEventListener( AudioCacheEvent.CACHE_COMPLETED, handleEventCached );
            _audioEvents.splice( 0, 1 );
            dispatchEvent( new Event( EVENT_ADDED_TO_CACHE ));

            if ( remaining > 0 )
            {
                // let's give the listening object time to update
                // as the caching of a large list can easily hog all resources
                setTimeout( cache, _delay );
            }
            else {
                _total     = 0;
                _isCaching = false;
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
