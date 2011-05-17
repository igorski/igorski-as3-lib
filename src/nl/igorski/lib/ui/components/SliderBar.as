package nl.igorski.lib.ui.components
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;

    import nl.igorski.lib.ui.components.events.SliderBarEvent;

    /**
     * Project:    One Bar Loop
     * Package:    nl.igorski.ui.components
     * Class:      SliderBar
     *
     *
     *
     * @author     igor.zinken@igorski.nl
     * @version    0.1
     * @since      23-12-2010 9:58
    */
    public class SliderBar extends Sprite
    {
        public static const HORIZONTAL	:String = 'SliderBar::HORIZONTAL';
        public static const VERTICAL	:String = 'SliderBar::VERTICAL';

        private const HANDLE_SIZE		:int = 10;
        private var HANDLE_SIZE_HEIGHT  :int;

        private var _min				:Number;
        private var _max				:Number;
        private var _size				:Number;
        private var _direction			:String;
        private var _default			:Number;
        private var _enabled			:Boolean;

        private var track				:Sprite;
        private var handle				:Sprite;
        //_________________________________________________________________________________________________________________
        //                                                                                            C O N S T R U C T O R

        public function SliderBar( direction:String = HORIZONTAL, size:Number = 100, min:Number = 0, max:Number = 100, defaultValue:Number = 0, enabled:Boolean = true, altHandleHeight:int = HANDLE_SIZE ):void
        {
            _direction          = direction;
            _size 	            = size;
            _min	            = min;
            _max	            = max;
            _enabled            = enabled;

            HANDLE_SIZE_HEIGHT  = altHandleHeight;

            if ( defaultValue == 0 )
                defaultValue = _min;

            _default   = defaultValue;

            addEventListener( Event.ADDED_TO_STAGE, init );
        }

        //_________________________________________________________________________________________________________________
        //                                                                                      P U B L I C   M E T H O D S

        //_________________________________________________________________________________________________________________
        //                                                                                  G E T T E R S  /  S E T T E R S

        public function get value():Number
        {
            var pct		:Number;
            var dev		:Number = _max - _min;

            switch( _direction )
            {
                case HORIZONTAL:
                    pct = handle.x / _size;
                break;
                case VERTICAL:
                    pct = handle.y / _size;
                break;
            }
            return ( dev * pct ) + _min;
        }

        public function set value( v:Number ):void
        {
            var pct:Number = ( v - _min ) / ( _max - _min );

            switch( _direction )
            {
                case HORIZONTAL:
                    handle.x = pct * _size;
                break;
                case VERTICAL:
                    handle.y = pct * _size;
                break;
            }
            dispatchEvent( new SliderBarEvent( SliderBarEvent.CHANGE, value ));
        }

        public function get min():Number
        {
            return _min;
        }

        public function set min( value:Number ):void
        {
            _min = value;
        }

        public function get max():Number
        {
            return _max;
        }

        public function set max( value:Number ):void
        {
            _max = value;
        }

        public function get enabled():Boolean
        {
            return _enabled;
        }

        public function set enabled( value:Boolean ):void
        {
            _enabled = value;
            if ( value )
            {
                handle.buttonMode = handle.useHandCursor = true;
                handle.addEventListener( MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true );
                track.alpha = 1;
            }
            else {
                handle.buttonMode = handle.useHandCursor = false;
                if ( handle.hasEventListener( MouseEvent.MOUSE_DOWN ))
                    handle.removeEventListener( MouseEvent.MOUSE_DOWN, handleMouseDown );
                track.alpha = .65;
            }
        }

        //_________________________________________________________________________________________________________________
        //                                                                                      E V E N T   H A N D L E R S

        private function init( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, init );

            draw();

            value	= _default;
            enabled = _enabled;
        }

        private function handleMouseDown( e:MouseEvent ):void
        {
            switch( _direction )
            {
                case HORIZONTAL:
                    handle.startDrag( false, new Rectangle( track.x, track.y, _size, 0 ));
                    break;
                case VERTICAL:
                    handle.startDrag( false, new Rectangle( track.x, track.y, 0, _size ));
                    break;
            }
            stage.addEventListener( MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true );
            addEventListener( MouseEvent.MOUSE_MOVE, handleDrag , false, 0, true );
        }

        private function handleMouseUp( e:MouseEvent ):void
        {
            handle.stopDrag();
            stage.removeEventListener( MouseEvent.MOUSE_UP, handleMouseUp );
            removeEventListener( MouseEvent.MOUSE_MOVE, handleDrag );
        }

        private function handleDrag( e:MouseEvent ):void
        {
            dispatchEvent( new SliderBarEvent( SliderBarEvent.CHANGE, value ));
        }

        //_________________________________________________________________________________________________________________
        //                                                                                P R O T E C T E D   M E T H O D S

        // override in subclass for custom skinning
        protected function draw():void
        {
            track = new Sprite();
            track.graphics.beginFill( 0xFFFFFF, 1 );

            switch( _direction )
            {
                case HORIZONTAL:
                    track.graphics.drawRoundRect( 0, 0, _size + HANDLE_SIZE, 10, 5 );
                break;
                case VERTICAL:
                    track.graphics.drawRoundRect( 0, 0, 10, _size + HANDLE_SIZE, 5 );
                    rotation = 180;
                    y += _size;
                break;
            }
            track.graphics.endFill();

            handle = new Sprite();

            handle.graphics.beginFill( 0xCCCCCC, 1 );
            handle.graphics.drawRoundRect( 0, 0, HANDLE_SIZE, HANDLE_SIZE_HEIGHT, 5 );
            handle.graphics.endFill();

            addChild( track );
            addChild( handle );
        }
        //_________________________________________________________________________________________________________________
        //                                                                                    P R I V A T E   M E T H O D S
    }
}
