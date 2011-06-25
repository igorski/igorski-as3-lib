package nl.igorski.views.helpers
{
    import flash.utils.getDefinitionByName;

    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 17-05-11
     * Time: 23:14
     */
    public class AudioVOHelper
    {
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function AudioVOHelper()
        {
            throw new Error( "cannot instantiate WaveFormHelper" );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public static function getClass( className:String ):Class
        {
            className = getClassName( className );

            return getDefinitionByName( className ) as Class;
        }

        public static function getClassName( className:String ):String
        {
             // 17th may 2011, we moved packages
            return className.split( "lib.util.audio" ).join( "lib.audio" );
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
