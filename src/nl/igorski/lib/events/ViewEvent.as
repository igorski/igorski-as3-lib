package nl.igorski.lib.events
{
    import flash.events.Event;
    /**
     * ...
     * @author ...
     */
    public class ViewEvent extends Event
    {
        public static const RESIZE_EVENT    :String = "ViewEvent::RESIZE_EVENT";
        public static const MAXIMIZE_EVENT  :String = "ViewEvent::MAXIMIZE_EVENT";
        public static const CHECK_EVENT     :String = "ViewEvent::CHECK_EVENT";
        public static const POPUP           :String = "ViewEvent::POPUP";
        public static const FEEDBACK        :String = "ViewEvent::FEEDBACK";
        public static const BUSY            :String = "ViewEvent::BUSY";
        
        public var content              :*;
        
        public function ViewEvent( type:String = RESIZE_EVENT, content:* = null )
        {
            this.content = content;
            super( type, true );
        }
    }
}
