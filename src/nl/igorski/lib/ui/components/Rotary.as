package nl.igorski.lib.ui.components
{
    import flash.display.Sprite;
    import flash.events.Event;

    import flash.utils.clearInterval;
    import flash.utils.setInterval;

    import nl.igorski.lib.ui.components.events.RotaryEvent;
    import nl.igorski.lib.ui.components.events.SliderBarEvent;

    /**
     * ...
     * @author Igor Zinken
     */
    public class Rotary extends Sprite
    {
        private const MAX_ROTATION      :Number = 260;

        protected var knob              :Sprite;
        protected var handle            :SliderBar;
        protected var bar               :Sprite;
        protected var bg                :Sprite;

        private var _min				:Number;
        private var _max				:Number;
        private var _size				:Number;
        private var _default			:Number;
        private var _enabled			:Boolean;
        private var _callbackDelay      :Number;
        private var _callbackIval       :uint;

        private var _lastValue          :Number;

        //_________________________________________________________________________________________________________________
        //                                                                                            C O N S T R U C T O R

        /*
         * @size            the size of the Rotary element, this should be seen as circle radius
         * @min             the value corresponding to the Rotary's zero degree state
         * @max             the value corresponding to the Rotary's maximum degree state
         * @defaultValue    the initial value of the Rotary element
         * @enabled         whether the Rotary element is interactive
         * @delayCallback   when the Rotary shouldn't fire it's change event on each move ( to prevent
         *                  clogging up resources by triggering a process ) a delay ( in milliseconds )
         *                  can be specified here. While the user drags the element no change events
         *                  are dispatched until the dragging halts and the specified delay time has passed
         */
        public function Rotary( size:Number = 100, min:Number = 0, max:Number = 100, defaultValue:Number = 0, enabled:Boolean = true, delayCallback:Number = 0 ):void
        {
            _size 	       = size * .5;
            _min	       = min;
            _max	       = max;
            _enabled       = enabled;
            _callbackDelay = delayCallback;

            if ( defaultValue == 0 )
                defaultValue = _min;

            _default   = defaultValue;
            _lastValue = defaultValue;

            addEventListener( Event.ADDED_TO_STAGE, init );
        }

        //_________________________________________________________________________________________________________________
        //                                                                                      P U B L I C   M E T H O D S

        //_________________________________________________________________________________________________________________
        //                                                                                      P U B L I C   M E T H O D S

        //_________________________________________________________________________________________________________________
        //                                                                                  G E T T E R S  /  S E T T E R S

        public function get value():Number
        {
            var pct		:Number = rotationToPercentage( knob.rotation );
            var dev		:Number = _max - _min;

            return pct * dev;
        }

        public function set value( v:Number ):void
        {
            var pct     :Number = v / _max;
            handle.value  = pct;
            knob.rotation = percentageToRotation( pct );
            drawCurve( value );
            dispatchEvent( new RotaryEvent( RotaryEvent.CHANGE, value ));
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
                handle.enabled = true;
                handle.addEventListener( SliderBarEvent.CHANGE, rotate, false, 0, true );
                handle.addEventListener( SliderBarEvent.INTERACTION_START, handleStart, false, 0, true );
                alpha = 1;
            }
            else {
                handle.enabled = false;
                if ( handle.hasEventListener( SliderBarEvent.CHANGE )) {
                    handle.removeEventListener( SliderBarEvent.CHANGE, rotate );
                    handle.removeEventListener( SliderBarEvent.INTERACTION_START, handleStart );
                    if ( handle.hasEventListener( SliderBarEvent.INTERACTION_END ))
                        handle.removeEventListener( SliderBarEvent.INTERACTION_END, handleEnd );
                }
                alpha = .35;
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

        private function rotate( e:SliderBarEvent ):void
        {
            knob.rotation = percentageToRotation( e.value );
            drawCurve( value );

            if ( _callbackDelay == 0 ) {
                if ( _lastValue != value )
                    dispatchEvent( new RotaryEvent( RotaryEvent.CHANGE, value ));
                _lastValue = value;
            }
            else {
                clearInterval( _callbackIval );
                _callbackIval = setInterval( function():void
                {
                    clearInterval( _callbackIval );
                    if ( _lastValue != value )
                        dispatchEvent( new RotaryEvent( RotaryEvent.CHANGE, value ));
                    _lastValue = value;
                }, _callbackDelay );
            }
        }

        private function handleStart( e:SliderBarEvent ):void
        {
            dispatchEvent( new RotaryEvent( RotaryEvent.INTERACTION_START ));
            handle.addEventListener( SliderBarEvent.INTERACTION_END, handleEnd, false, 0, true );
        }

        private function handleEnd( e:SliderBarEvent ):void
        {
            handle.removeEventListener( SliderBarEvent.INTERACTION_END, handleEnd );

            if ( value != _lastValue )
            {
                _lastValue = value;
                dispatchEvent( new RotaryEvent( RotaryEvent.CHANGE, value ));
            }

            dispatchEvent( new RotaryEvent( RotaryEvent.INTERACTION_END, value ));
        }

        //_________________________________________________________________________________________________________________
        //                                                                                P R O T E C T E D   M E T H O D S

        // override these in your subclass for custom skinning
        protected function draw():void
        {
            // knob - used for visual reference of current rotation
            knob               = new Sprite();
            knob.mouseEnabled  = false;
            with ( knob.graphics )
            {
                beginFill( 0xFFFFFF, 1 );
                drawCircle( 0, 0, _size );
                drawCircle( -( _size * .5 ), _size * .5, 3 );
            }
            knob.alpha       = 0;
            addChild( knob );

            drawBG();
            bar              = new Sprite();
            bar.mouseEnabled = false;
            bar.rotation     = bg.rotation;
            addChild( bar );

            handle           = new SliderBar( SliderBar.VERTICAL, _size, 0, 1, 0, false, 40 );
            addChild( handle );
            handle.alpha     = 0;
            handle.width     = _size * 2;
            handle.x         = _size;
        }

        protected function drawCurve( v:Number ):void
        {
            v = rotationToPercentage( knob.rotation ) * .82;

            var dir				:Number = 1;
            var r				:Number = _size - 1;

            bar.graphics.clear();

            var startAngle  :Number = 0;
            var endAngle    :Number = 2 * Math.PI * v;
            var diff        :Number = Math.abs( endAngle - startAngle );

            var divs        :Number = Math.floor( diff / ( Math.PI * .25 )) + 1;
            var span        :Number = Number( dir ) * diff / ( 2 * divs );
            var rc          :Number = Number( r ) / Math.cos( span );

            bar.graphics.lineStyle( 4, 0xE7161C );
            bar.graphics.moveTo( Math.cos( startAngle ) * Number( r ), Math.sin( startAngle ) * Number( r ));

            for ( var i:int = 0; i < divs; ++i )
            {
                endAngle = startAngle + span;
                startAngle = endAngle + span;
                bar.graphics.curveTo( Math.cos( endAngle ) * rc, Math.sin(endAngle) * rc, Math.cos(startAngle) * Number(r), Math.sin(startAngle) * Number(r));
            }
        }

        protected function drawBG():void
        {
            bg = new Sprite();
            bg.rotation = 120;
            addChild( bg );

            var dir         :Number = 1;
            var r           :Number = _size - 1;
            var startAngle  :Number = 0;
            var endAngle    :Number = 2 * Math.PI * .82;
            var diff        :Number = Math.abs( endAngle - startAngle );

            var divs        :Number = Math.floor( diff / ( Math.PI * .25 )) + 1;
            var span        :Number = Number( dir ) * diff / ( 2 * divs );
            var rc          :Number = Number( r ) / Math.cos( span );

            bg.graphics.lineStyle( 4, 0x484848 );
            bg.graphics.moveTo( Math.cos( startAngle ) * Number( r ), Math.sin( startAngle ) * Number( r ));

            for ( var i:int = 0; i < divs; ++i )
            {
                endAngle = startAngle + span;
                startAngle = endAngle + span;
                bg.graphics.curveTo( Math.cos( endAngle ) * rc, Math.sin(endAngle) * rc, Math.cos(startAngle) * Number(r), Math.sin(startAngle) * Number(r));
            }
        }

        //_________________________________________________________________________________________________________________
        //                                                                                    P R I V A T E   M E T H O D S

        private function rotationToPercentage( rotation:Number ):Number
        {
            if ( rotation < 0 )
                rotation = 180 + ( rotation + 180 );
            
            return rotation / MAX_ROTATION;
        }

        private function percentageToRotation( value:Number ):Number
        {
            return value * MAX_ROTATION;
        }
    }
}
