package nl.igorski.lib.audio.helpers
{
    import flash.utils.Dictionary;

    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 10-12-11
     * Time: 14:46
     *
     * when caching multiple VOAudioEvents into a single cache, we keep
     * track of the present written samples to prevent double writing
     *
     * NOTE: this is a debugging tool, the aforementioned problem shouldn't occur!
     *
     */
    public class CachedEventsList
    {
        private var _cacheIndexes   :Dictionary;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function CachedEventsList()
        {
            _cacheIndexes = new Dictionary();
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /**
         * registers a index for a (new) AudioCache
         * @param cacheNum {int} number to identify this cache in subsequent methods.
         *        When not given, the index is appended at the end of the current list
         */
        public function addCache( cacheNum:int = -1 ):void
        {
            if ( cacheNum == -1 )
                cacheNum = _cacheIndexes.length;

            _cacheIndexes[ cacheNum ] = new Vector.<String>();
        }

        /**
         * clear the list for a given AudioCache index
         * @param cacheNum  {int} the identifier of the cache
         */
        public function flushCache( cacheNum:int = 0 ):void
        {
            _cacheIndexes[ cacheNum ] = new Vector.<String>();
        }

        public function flushAllCaches():void
        {
            for ( var i:int = 0; i < _cacheIndexes.length; ++i )
                flushCache( i );
        }

        /**
         * register a VOAudioEvent into the cache index
         * @param cacheNum {int} identifier of the cache
         * @param id {String} unique VOAudioEvent identifier
         */
        public function setEvent( cacheNum:int,  id:String ):void
        {
            _cacheIndexes[ cacheNum ].push( id );
        }

        /**
         * query the cache index whether an event has been cached
         * @param cacheNum {int} identifier of the cache
         * @param id {String} unique VOAudioEvent identifier
         *
         * @return {Boolean}
         */
        public function hasEvent( cacheNum:int, id:String ):Boolean
        {
            return _cacheIndexes[ cacheNum ].indexOf( id ) > -1;
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

    }
}
