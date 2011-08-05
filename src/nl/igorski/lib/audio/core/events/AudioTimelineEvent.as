package nl.igorski.lib.audio.core.events
{
    import flash.events.Event;

    public class AudioTimelineEvent extends Event
    {
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 21-dec-2010
         * Time: 12:04:14
         */
        public static const LOCK    :String = 'AudioTimelineEvent::LOCK';
        public static const UNLOCK  :String = 'AudioTimelineEvent::UNLOCK';

        // the index number of the grid block to remain active
        public var activeItem       :int = 0;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function AudioTimelineEvent( eType:String = LOCK, eActiveItem:int = 0 )
        {
            activeItem = eActiveItem;
            super( eType, false );
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        //_________________________________________________________________________________________________________
        //                                                                        G E T T E R S   /   S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
