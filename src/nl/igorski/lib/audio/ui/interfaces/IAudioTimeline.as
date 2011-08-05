package nl.igorski.lib.audio.ui.interfaces
{
    import flash.utils.Dictionary;

    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 08-07-11
     * Time: 16:49
     */
    public interface IAudioTimeline
    {
        function getFrequencies( position:int ):Dictionary
        function updatePosition( position:int ):void;
        function resetNotes( recache:Boolean = true ):void;
        function get voice():int;
    }
}
