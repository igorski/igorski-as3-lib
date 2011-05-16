package nl.igorski.lib
{
    import flash.events.EventDispatcher;
    import nl.igorski.events.ViewEvent;
    /**
     * ...
     * @author Igor Zinken
     */
    public class View extends EventDispatcher
    {
        public static var INSTANCE  :View = new View();
        
        private var _busy           :Boolean = false;
        
        public function View()
        {
            
        }
        
        public static function get busy():Boolean
        {
            return INSTANCE._busy;
        }
        
        public static function set busy( value:Boolean ):void
        {
            INSTANCE._busy = value;
            INSTANCE.dispatchEvent( new ViewEvent( ViewEvent.BUSY, null ));
        }
        
        public static function popup( content:* ):void
        {
            INSTANCE.dispatchEvent( new ViewEvent( ViewEvent.POPUP, content ));
        }
        
        public static function feedback( text:String ):void
        {
            INSTANCE.dispatchEvent( new ViewEvent( ViewEvent.FEEDBACK, text ));
        }

        public static function resize( type:String = ViewEvent.RESIZE_EVENT ):void
        {
            INSTANCE.dispatchEvent( new ViewEvent( type ));
        }
    }
}
