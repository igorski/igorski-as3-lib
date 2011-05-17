package nl.igorski.lib
{
    import flash.events.EventDispatcher;
    import nl.igorski.lib.events.ViewEvent;
    /**
     * View is a helper which can be attached to the lowest level
     * displayObject ( such as a site container ) for triggering
     * popup / feedback windows or to broadcast busy and resize events
     * to all listening displayObjects, in essence it's a delegate to
     * communicate application wide view events to listening objects
     *
     * @author Igor Zinken
     */
    public class View extends EventDispatcher
    {
        public static var INSTANCE  :View = new View();
        
        private var _busy           :Boolean = false;
        
        public function View()
        {
            if ( INSTANCE != null )
                throw new Error( "cannot instantiate View" );
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

        /*
         * launch a popup window showing @content
         */
        public static function popup( content:* ):void
        {
            INSTANCE.dispatchEvent( new ViewEvent( ViewEvent.POPUP, content ));
        }

        /*
         * display a feedback message @text
         * you may choose to use nl.igorski.lib.ui.components.FeedbackWindow or a similar
         * class to display this message
         */
        public static function feedback( text:String ):void
        {
            INSTANCE.dispatchEvent( new ViewEvent( ViewEvent.FEEDBACK, text ));
        }

        /*
         * dispatched by main displayObjects stage listener
         * all classes listening to this View's instance broadcasting this event
         * can now process their resize callback accordingly
         */
        public static function resize( type:String = ViewEvent.RESIZE_EVENT ):void
        {
            INSTANCE.dispatchEvent( new ViewEvent( type ));
        }
    }
}
