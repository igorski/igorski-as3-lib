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

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function View()
        {
            if ( INSTANCE != null )
                throw new Error( "cannot instantiate View" );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

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

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        /*
         * you can trigger a busy state to alter the appearance of your
         * application ( for instance blinding the application with a semi-transparent
         * overlay or altering mouse cursors during remoting calls )
         */
        public static function get busy():Boolean
        {
            return INSTANCE._busy;
        }

        public static function set busy( value:Boolean ):void
        {
            INSTANCE._busy = value;
            INSTANCE.dispatchEvent( new ViewEvent( ViewEvent.BUSY, null ));
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
