package nl.igorski.lib.audio.modifiers
{
    import nl.igorski.lib.audio.core.interfaces.IModifier;

    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 01-08-11
     * Time: 18:56
     */
    public final class Distorter implements IModifier
    {
        private var _amount     :Number;
        private var _level      :Number;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function Distorter( amount:Number = 0, level:Number = 1 )
        {
            _amount = amount;
            _level  = level;
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function getData():Object
        {
            var data:Object = {};
            data.amount = _amount;
            data.level  = _level;

            return data;
        }

        public function setData( data:Object ):void
        {
            _amount = data.amount;
            _level  = data.level;
        }

        public function process( input:Number ):Number
        {
            if ( input > 0 )
                    input = input * ( input + _amount ) / ( input * input + ( _amount - 1 ) * input + 1 );
            else
                input = -input * ( _amount - input ) / ( input * input + ( _amount - 1 ) * input + 1 );

            return input * _level;
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        public function get amount():Number
        {
            return _amount;
        }

        public function set amount( value:Number ):void
        {
            _amount = value;
        }

        public function get level():Number
        {
            return _level;
        }

        public function set level( value:Number ):void
        {
            _level = value;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

    }
}
