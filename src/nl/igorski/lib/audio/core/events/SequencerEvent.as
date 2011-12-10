package nl.igorski.lib.audio.core.events
{
    import flash.events.Event;

    public class SequencerEvent extends Event
    {
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 21-dec-2010
         * Time: 12:04:14
         */
        public static const START           :String = "SequencerEvent::START";
        public static const STOP            :String = "SequencerEvent::STOP";
        public static const PAUSE           :String = "SequencerEvent::PAUSE";
        public static const REGISTER_TEMPO    :String = "SequencerEvent::TEMPO_CHANGE";

        public var value                    :Number;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function SequencerEvent( aType:String = START, aValue:Number = 120 )
        {
            value = aValue;
            super( aType, false );
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
