package nl.igorski.lib.audio.model.vo
{
    /**
     * class VOEnvelopes
     *
     * Created by IntelliJ IDEA.
     * User: igor.zinken
     * Date: 13-4-11
     * Time: 10:06
     */
    public class VOEnvelopes
    {
        public var volume   :Number;
        public var pan      :Number;
        public var attack   :Number;
        public var decay    :Number;
        public var release  :Number;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function VOEnvelopes( data:Object = null )
        {
            if ( data == null )
                return;

            for ( var i:* in data )
            {
                try {
                    this[ i ] = data[ i ];
                }
                catch ( e:Error )
                {
                    trace( "property " + i + " non-existent in VOEnvelopes" );
                }
            }
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
