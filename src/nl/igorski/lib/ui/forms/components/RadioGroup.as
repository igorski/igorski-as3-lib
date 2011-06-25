package nl.igorski.lib.ui.forms.components
{
    import flash.display.Sprite;
    import flash.events.Event;

    import nl.igorski.lib.ui.forms.components.interfaces.IFormElement;

    /**
     * a collection of multiple radio buttons, to be used if multiple radio buttons
     * correspond to a single value ( for instance buttons for 'Male' and 'Female'
     * to be used in a 'Gender' group )
     * ...
     * @author Igor Zinken
     */
    public class RadioGroup extends Sprite implements IFormElement
    {

        public static const CHANGE  :String = "RadioGroup::CHANGE";

        protected var _title        :String;
        protected var _options      :Array;
        protected var _maxWidth     :int;
        protected var _radios       :Array;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function RadioGroup( title:String, options:Array, maxWidth:int = 200 )
        {
            _title    = title;
            _maxWidth = maxWidth;
            _options  = options;

            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function activate( num:int ):void
        {
            unselectAll();
            var count:int = 0;

            for each( var r:Radio in _radios )
            {
                if ( count == num )
                    r.check();

                ++count;
            }
            dispatchEvent( new Event( RadioGroup.CHANGE ));
        }

        public function doError():void
        {
            for each ( var r:Radio in _radios )
                r.doError();
        }

        public function undoError():void
        {
            for each ( var r:Radio in _radios )
                r.undoError();
        }

        public function unselectAll():void
        {
            for each( var r:Radio in _radios )
                r.uncheck();
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        public function get val():*
        {
            for each( var r:Radio in _radios )
            {
                if ( r.selected )
                    return r.val;
            }
            return '';
        }

        public function set val( value:*):void
        {
            for each( var r:Radio in _radios )
                 r.selected = ( r.val == value );
        }
        
        override public function set tabIndex( value:int ):void
        {
            --value;

            for each( var r:Radio in _radios )
                r.tabIndex = ++value;
        }

        override public function get tabIndex():int
        {
            return _radios[0].tabIndex;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function initUI( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );
            draw();
        }

        protected function handleClick( e:Event ):void
        {
            undoError();

            unselectAll();
            e.target.check();
            dispatchEvent( new Event( RadioGroup.CHANGE ));
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        // override in subclass for custom skinning
        protected function draw():void
        {
            _radios = [];

            var col         :int = 0;
            var row         :int = 0;
            var maxCols     :int = 2;
            var secondCol   :int = 200;

            for ( var i:int = 0; i < _options.length; ++i )
            {
                ++col;

                var r:Radio = new Radio( _options[i].value, _options[i].label );
                addChild( r );
                r.addEventListener( Radio.ACTIVATE, handleClick );
                r.x = 8;
                if ( i % 2 )
                    r.x += secondCol;
                r.y = ( row * r.height ) + 8;

                _radios.push( r );

                if ( i > 0 && _options.length == 2 )
                    r.x = _radios[i - 1].x + _radios[i - 1].width + 10;

                if ( col >= maxCols ) {
                    col = 0;
                    ++row;
                }
            }

            if ( _options.length <= 2 )
                x = secondCol;
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
