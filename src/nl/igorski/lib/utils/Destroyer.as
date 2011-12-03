package nl.igorski.lib.utils
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;

    import nl.igorski.lib.interfaces.IDestroyable;

    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 03-12-11
     * Time: 15:24
     */
    public class Destroyer
    {
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function Destroyer()
        {
            throw new Error( "cannot instantiate Destroyer" );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /**
         * quick function that iterates through a Sprite's Display List
         * and removes and nullifies all the Objects. If the Objects
         * are DisplayObjects this function will be called upon their
         * children.
         *
         * If the Objects implement the IDestroyable interface, the destroy
         * method is called upon them to clean up their class specific methods
         *
         * WARNING: this is a very crude method, if other methods are running
         * which hold a reference to any of the Objects encountered by this
         * function, errors might occur ( such as animation libraries trying
         * to animate a just-destroyed Object ).
         *
         * @param object    {Sprite}
         * @param recursive {Boolean} optional, when true the display lists of
         *                  underlying DisplayObjects are also destroyed
         *                  using this function for a full and swift cleanup.
         *                  However read the WARNING above when using this, it
         *                  is better practice to have the child Objects implement
         *                  the IDestroyable interface for their custom cleanup
         */
        public static function destroyDisplayList( object:Sprite, recursive:Boolean = false ):void
        {
            while ( object.numChildren > 0 )
            {
                var theChildObject:DisplayObject = object.getChildAt( 0 );

                if ( theChildObject is IDestroyable )
                    IDestroyable( theChildObject ).destroy();

                else if ( theChildObject is Sprite && recursive )
                    destroyDisplayList( theChildObject as Sprite );

                object.removeChildAt( 0 );

                theChildObject = null;
            }
        }

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
