package nl.igorski.models
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import nl.igorski.config.Config;
    import nl.igorski.controllers.UrlController;
    import nl.igorski.lib.View;
    import nl.igorski.models.JSONProxy;
    import nl.igorski.models.VOInstrument;
    import nl.igorski.models.VOSequencer;
    import nl.igorski.models.VOSongData;
    import nl.igorski.models.VOSongEntry;
    import nl.igorski.lib.utils.GoogleAnalytics;
	/**
     * ...
     * @author Igor Zinken
     */
    public class SongProxy extends EventDispatcher
    {
        public static var INSTANCE  :SongProxy = new SongProxy();
        
        public static const LOAD    :String = "SongManager::LOADED";
        
        private var _song           :VOSongEntry;
        
        public function SongProxy()
        {
            
        }
        
        public static function getData():VOSongData
        {
            return INSTANCE._song.data;
        }
        
        public static function load( seo:String ):void
        {
            var p:JSONProxy = new JSONProxy();
            View.busy = true;
            p.load( Config.BASE_URL + "/song/load/" + seo, function():void
            {
                if ( !p.getData().success )
                {
                    UrlController.change( "/loop/browser" );
                    View.feedback( "Couldn't load requested song. The URL is either erroneous or the song has been removed." );
                }
                else {
                    UrlController.setAddress( "/loop/" + seo );
                    View.popup( null );
                    song = new VOSongEntry( p.getData().data );

                    GoogleAnalytics.event( "song", "loaded", song.seo );
                }
                p = null;
                View.busy = false;
            });
        }
        
        public static function reset():void
        {
            GoogleAnalytics.event( "song", "reset", "click" );
            song = null;
        }
        
        public static function getGrid( index:int ):Array
        {
            return VOSequencer( INSTANCE._song.data.sequencers[ index ]).gridBlocks;
        }
        
        public static function getInstrument( index:int ):VOInstrument
        {
            return VOSequencer( INSTANCE._song.data.sequencers[ index ]).instrument;
        }
        
        public static function get song():VOSongEntry
        {
            return INSTANCE._song;
        }
        
        public static function set song( vo:VOSongEntry ):void
        {
            INSTANCE._song = vo;
            INSTANCE.dispatchEvent( new Event( SongProxy.LOAD ));
        }    
    }
}
