package nl.igorski.lib.audio.core
{
    import flash.events.EventDispatcher;
    import nl.igorski.lib.audio.core.events.AudioTimelineEvent;

    public class AudioTimelineManager extends EventDispatcher
    {
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 22-dec-2010
         * Time: 10:49:42
         *
         * AudioTimelineManager acts as a broadcaster to all audio timelines
         * to lock / unlock their active states during interaction */

        public static const INSTANCE    :AudioTimelineManager = new AudioTimelineManager();

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function AudioTimelineManager()
        {
            if ( INSTANCE != null )
                throw new Error( "cannot instantiate AudioTimelineManager" );
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        /*
         * @exception index of the grid block that should remain interactive
         *            during the locked state of the timeline
         */
        public static function lockTimeline( exception:int ):void
        {
            INSTANCE.dispatchEvent( new AudioTimelineEvent( AudioTimelineEvent.LOCK, exception ));
        }

        public static function unlockTimeline():void
        {
            INSTANCE.dispatchEvent( new AudioTimelineEvent( AudioTimelineEvent.UNLOCK ));
        }

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
