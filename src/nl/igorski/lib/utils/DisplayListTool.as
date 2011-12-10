package nl.igorski.lib.utils
{
    import flash.display.DisplayObjectContainer;
    import flash.geom.Rectangle;

    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 04-12-11
     * Time: 14:55
     */
    public class DisplayListTool
    {
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function DisplayListTool()
        {
            throw new Error( "cannot instantiate DisplayListTool" );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /**
         * add multiple DisplayObjects to the given Objects DisplayList
         *
         * @param displayObject {DisplayObjectContainer}
         * @param children      {DisplayObjectContainer} comma separated list
         */
        public static function addChildren( displayObject:DisplayObjectContainer, ... children ):void
        {
            for ( var i:int = 0; i < children.length; ++i )
            {
                displayObject.addChild( children[ i ]);
            }
        }

        /**
         * removes multiple DisplayObjects to the given Objects DisplayList
         *
         * @param displayObject {DisplayObjectContainer}
         * @param children      {DisplayObjectContainer} comma separated list
         */
        public static function removeChildren( displayObject:DisplayObjectContainer, ... children ):void
        {
            for ( var i:int = 0; i < children.length; ++i )
            {
                displayObject.removeChild( children[ i ]);
            }
        }

        /**
         * removes all children of the given displayObject
         * @param displayObject {DisplayObjectContainer}
         */
        public static function removeAllChildren( displayObject:DisplayObjectContainer ):void
        {
            while ( displayObject.numChildren > 0 )
            {
                displayObject.removeChildAt( 0 );
            }
        }

        /**
         * returns an Object describing the properties of the Objects occupying area
         *
         * @param displayObject {DisplayObjectContainer} the displayObject
         * @param absolute      {Boolean} optional, when true the returned Rectangle is absolute to
         *                      the Stage, not relative to the Objects parent container
         * @return {Object} w/ parameters left, right, top, bottom
         */
        public static function getBounds( displayObject:DisplayObjectContainer, absolute:Boolean = false ):Object
        {
            var out:Object = { left: displayObject.x, top: displayObject.y };

            if ( absolute )
            {
                var theObject:DisplayObjectContainer = displayObject;

                while ( theObject.parent )
                {
                    theObject = theObject.parent;

                    out.left += theObject.x;
                    out.top  += theObject.y;
                }
            }

            out.right  = out.left + displayObject.width;
            out.bottom = out.top  + displayObject.height;

            return out;
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
