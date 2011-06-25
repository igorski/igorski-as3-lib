package nl.igorski.lib.audio.core
{
    import flash.events.EventDispatcher;
    import nl.igorski.lib.audio.core.events.GridEvent;

    public class GridManager extends EventDispatcher
    {
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 22-dec-2010
         * Time: 10:49:42
         *
         * GridManager acts as a broadcaster to all grid blocks
         * to lock / unlock their active states during interaction
         */

        public static const INSTANCE    :GridManager = new GridManager();

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function GridManager()
        {
            if ( INSTANCE != null )
                throw new Error( "cannot instantiate GridManager" );
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        /*
         * @exception index of the grid block that should remain interactive
         *            during the locked state of the grid
         */
        public static function lockGrid( exception:int ):void
        {
            INSTANCE.dispatchEvent( new GridEvent( GridEvent.LOCK, exception ));
        }

        public static function unlockGrid():void
        {
            INSTANCE.dispatchEvent( new GridEvent( GridEvent.UNLOCK ));
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
