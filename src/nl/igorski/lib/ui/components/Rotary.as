package nl.igorski.lib.ui.components
{
    import com.greensock.TweenLite;
    import flash.display.Sprite;
    import flash.events.Event;

import flash.utils.clearInterval;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import nl.igorski.lib.ui.components.events.RotaryEvent;
    import nl.igorski.lib.ui.components.events.SliderBarEvent;
    import nl.igorski.managers.ColorSchemeManager;
    /**
     * ...
     * @author Igor Zinken
     */
    public class Rotary extends Sprite
    {
        private const MAX_ROTATION      :Number = 260;

        private var _knob               :Sprite;
        private var _handle             :SliderBar;
        private var _bar                :Sprite;
        private var _bg                 :Sprite;

        private var _min				:Number;
        private var _max				:Number;
        private var _size				:Number;
        private var _default			:Number;
        private var _enabled			:Boolean;
        private var _callbackDelay      :Number;
        private var _callbackIval       :uint;

        //_________________________________________________________________________________________________________________
        //                                                                                            C O N S T R U C T O R

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
            var pct		:Number = rotationToPercentage( _knob.rotation );
            var dev		:Number = _max - _min;

            return pct * dev;
        }

        public function set value( v:Number ):void
        {
            var pct     :Number = v / _max;
            _handle.value  = pct;
            _knob.rotation = percentageToRotation( pct );
            draw( value );
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
                _handle.enabled = true;
                _handle.addEventListener( SliderBarEvent.CHANGE, rotate, false, 0, true );
                TweenLite.to( this, .65, { alpha: 1 } );
            }
            else {
                _handle.enabled = false;
                if ( _handle.hasEventListener( SliderBarEvent.CHANGE ))
                    _handle.removeEventListener( SliderBarEvent.CHANGE, rotate );
                TweenLite.to( this, .65, { alpha: .35 } );
            }
        }

        //_________________________________________________________________________________________________________________
        //                                                                                      E V E N T   H A N D L E R S

        private function init( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, init );

            // knob - used for visual reference of current rotation
            _knob               = new Sprite();
            _knob.mouseEnabled  = false;
            with ( _knob.graphics )
            {
                beginFill( 0xFFFFFF, 1 );
                drawCircle( 0, 0, _size );
                drawCircle( -( _size * .5 ), _size * .5, 3 );
            }
            _knob.alpha       = 0;
            addChild( _knob );

            drawBG();
            _bar              = new Sprite();
            _bar.mouseEnabled = false;
            _bar.rotation     = _bg.rotation;
            addChild( _bar );

            _handle           = new SliderBar( SliderBar.VERTICAL, _size, 0, 1, 0, false, 40 );
            addChild( _handle );
            _handle.alpha     = 0;
            _handle.width     = _size * 2;
            _handle.x         = _size;

            value	= _default;
            enabled = _enabled;
        }

        private function rotate( e:SliderBarEvent ):void
        {
            _knob.rotation = percentageToRotation( e.value );
            draw( value );

            if ( _callbackDelay == 0 ) {
                dispatchEvent( new RotaryEvent( RotaryEvent.CHANGE, value ));
            }
            else {
                clearInterval( _callbackIval );
                _callbackIval = setInterval( function():void
                {
                    clearInterval( _callbackIval );
                    dispatchEvent( new RotaryEvent( RotaryEvent.CHANGE, value ));
                }, _callbackDelay );
            }
        }

        //_________________________________________________________________________________________________________________
        //                                                                                P R O T E C T E D   M E T H O D S

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

        private function draw( v:Number ):void
        {
            v = rotationToPercentage( _knob.rotation ) * .82;

            var dir				:Number = 1;
            var r				:Number = _size - 1;

            _bar.graphics.clear();

            var startAngle  :Number = 0;
            var endAngle    :Number = 2 * Math.PI * v;
            var diff        :Number = Math.abs( endAngle - startAngle );

            var divs        :Number = Math.floor( diff / ( Math.PI * .25 )) + 1;
            var span        :Number = Number( dir ) * diff / ( 2 * divs );
            var rc          :Number = Number( r ) / Math.cos( span );

            _bar.graphics.lineStyle( 6, ColorSchemeManager.INTERFACE );
            _bar.graphics.moveTo( Math.cos( startAngle ) * Number( r ), Math.sin( startAngle ) * Number( r ));

            for ( var i:int = 0; i < divs; ++i )
            {
                endAngle = startAngle + span;
                startAngle = endAngle + span;
                _bar.graphics.curveTo( Math.cos( endAngle ) * rc, Math.sin(endAngle) * rc, Math.cos(startAngle) * Number(r), Math.sin(startAngle) * Number(r));
            }
        }

        private function drawBG():void
        {
            _bg = new Sprite();
            _bg.rotation = 120;
            addChild( _bg );

            var dir			:Number = 1;
            var r			:Number = _size - 1;
            var startAngle  :Number = 0;
            var endAngle    :Number = 2 * Math.PI * .82;
            var diff        :Number = Math.abs( endAngle - startAngle );

            var divs        :Number = Math.floor( diff / ( Math.PI * .25 )) + 1;
            var span        :Number = Number( dir ) * diff / ( 2 * divs );
            var rc          :Number = Number( r ) / Math.cos( span );

            _bg.graphics.lineStyle( 6, 0x484848 );
            _bg.graphics.moveTo( Math.cos( startAngle ) * Number( r ), Math.sin( startAngle ) * Number( r ));

            for ( var i:int = 0; i < divs; ++i )
            {
                endAngle = startAngle + span;
                startAngle = endAngle + span;
                _bg.graphics.curveTo( Math.cos( endAngle ) * rc, Math.sin(endAngle) * rc, Math.cos(startAngle) * Number(r), Math.sin(startAngle) * Number(r));
            }
        }
    }
}
