package nl.igorski.lib.events
{
    import flash.events.Event;
    /**
     * ...
     * @author Igor Zinken
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

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function ViewEvent( type:String = RESIZE_EVENT, content:* = null )
        {
            this.content = content;
            super( type, true );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

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
