/**
 * Created by IntelliJ IDEA.
 * User: igorzinken
 * Date: 12-04-11
 * Time: 19:00
 * To change this template use File | Settings | File Templates.
 */
package nl.igorski.lib.util.audio.core.events
{
    import flash.events.Event;

    public class AudioCacheEvent extends Event
    {
        public static const CACHE_STARTED   :String = "AudioCacheEvent::CACHE_STARTED";
        public static const CACHE_COMPLETED :String = "AudioCacheEvent::CACHE_COMPLETED";

        public function AudioCacheEvent( type:String )
        {
            super( type );
        }
    }
}
