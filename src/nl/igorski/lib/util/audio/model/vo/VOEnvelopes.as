package nl.igorski.lib.util.audio.model.vo
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
    }
}
