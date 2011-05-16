package nl.igorski.lib.ui.components
{
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    /**
     * ...
     * @author Igor Zinken
     */
    public class ScrollBlock extends Sprite
    {
        private var obj				:*;			// (display)object to scroll

        private var _width			:int;
        private var _height			:int;

        private var background		:MovieClip = new MovieClip();
        private var maskmc			:MovieClip = new MovieClip();
        private var ruler			:MovieClip = new MovieClip();
        private var minY			:Number;
        private var maxY			:Number;
        private var contentstarty	:Number;
        private var percentuale		:Number;
        private var margin			:Number = 10;

        private var _scrollPosition	:int;
        private var _alwaysScroll	:Boolean;

        public function ScrollBlock( inObj:*, inWidth:int = 100, inHeight:int = 100, inScrollPosition:int = 0, inAlwaysScroll:Boolean = false )
        {
            obj = inObj;
            _width = inWidth;
            _height = inHeight;
            _scrollPosition = inScrollPosition;
            _alwaysScroll = inAlwaysScroll;

            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        private function initUI( e:Event = null ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );

            if ( !contains( obj )) addChild( obj );

            if ( background.numChildren == 0 )
            {
                background.addChild( new ScrollTrack( _height ) );
                addChild( background );
            }

            minY = background.y;
            maxY = background.y + background.height - ruler.height;

            if ( !contains( maskmc ))
            {
                maskmc.graphics.beginFill( 0xFFFFFF, 1 );
                maskmc.graphics.drawRect( 0, 0, _width, _height );
                maskmc.graphics.endFill();
                maskmc.x = obj.x;
                addChild( maskmc );
            }

            obj.mask = maskmc;

            if ( !contains( ruler ))
            {
                ruler.addChild( new ScrollHandle() );
                ruler.buttonMode = true;
                ruler.tabEnabled = false;
                addChild( ruler );
            }
            if ( _scrollPosition == 0 )
            {
                background.x = _width + ( margin * 4 );
                ruler.x = background.x - ( ruler.width * .5 ) + 3;
            }
            else
            {
                ruler.x = background.x = _scrollPosition;
            }
            contentstarty = obj.y;

            minY = 0;
            maxY = background.height - ruler.height;

            checkScroll();
        }

        private function checkScroll():void
        {
            // is scrollbar actually required ?
            if ( obj.height >= maskmc.height )
            {
                ruler.addEventListener( MouseEvent.MOUSE_DOWN, clickHandle, false, 0, true );
            //	ruler.addEventListener( MouseEvent.MOUSE_OUT, releaseHandle );
                addEventListener( Event.ENTER_FRAME, enterFrameHandle, false, 0, true );

                if ( _alwaysScroll )
                {
                    stage.addEventListener( MouseEvent.MOUSE_WHEEL, handleWheel, false, 0, true );
                } else {
                    addEventListener( MouseEvent.MOUSE_WHEEL, handleWheel, false, 0, true );
                }
            } else
            {
                hideScroller();
            }
        }

        private function hideScroller():void
        {
            if ( contains( ruler )) removeChild( ruler );
            if ( contains( background )) removeChild( background );
            ruler.removeEventListener( MouseEvent.MOUSE_DOWN, clickHandle );
            removeEventListener( MouseEvent.MOUSE_UP, releaseHandle );
            removeEventListener( Event.ENTER_FRAME, enterFrameHandle );
            if ( _alwaysScroll )
            {
                stage.removeEventListener( MouseEvent.MOUSE_WHEEL, handleWheel );
            } else {
                removeEventListener( MouseEvent.MOUSE_WHEEL, handleWheel );
            }
        }

        private function handleWheel( e:MouseEvent ):void
        {
            releaseHandle();
            if ( ruler.y == 0 ) ruler.y = 1;
            if ( (e.delta > 0 && ruler.y < maxY ) || ( e.delta < 0 && ruler.y > minY ))
            {
                var targetY:Number = ruler.y - ( e.delta * 3 );
                if ( targetY > maxY || targetY < 0 ) return;
                ruler.y = targetY;
            }
        }

        private function scrollData( q:int ):void
        {
            var d:Number;
            var rulerY:Number;

            d = -q * 10;

            if ( d > 0 )
            {
                rulerY = Math.min( maxY, ruler.y + d );
            }
            if ( d < 0 )
            {
                rulerY = Math.max( minY, ruler.y + d );
            }
            ruler.y = rulerY;
            positionContent();
        }

        public function positionContent():void
        {
            var upY:Number;
            var downY:Number;
            var curY:Number;

            percentuale = ( 100 / maxY ) * ruler.y;

            upY = 0;
            downY = obj.height - ( maskmc.height * .5 ) + 20;

            checkContentLength();

            var fx:Number = contentstarty - ((( downY - ( maskmc.height * .5 )) * .01 ) * percentuale );

            var curry:Number = obj.y;
            var finalx:Number = fx;

            if ( curry != finalx )
            {
                var diff:Number = finalx-curry;
                curry += diff / 4;
            }
            obj.y = curry;
        }

        public function checkContentLength():void
        {
            if ( obj.height < maskmc.height )
            {
                ruler.visible = false;
            } else {
                ruler.visible = true;
            }
        }

        public function reset( inObj:* = null ):void
        {
            obj.y = 0;
            ruler.y = 0;
            if ( inObj != null )
            {
                if (contains(obj)) removeChild(obj);
                obj = inObj;
                initUI();
            }
            checkScroll();
        }

        public function scrollTo( inObj:* ):void
        {
            releaseHandle();
            obj.y = -inObj.y;
        }

        public function showRuler():void
        {
            if ( !contains( background ))
                addChild( background );
            if ( !contains( ruler ))
                addChild( ruler );
        }

        public function hideRuler():void
        {
            if ( contains( background ))
                removeChild( background );
            if ( contains( ruler ))
                removeChild( ruler );
        }

        private function clickHandle( e:MouseEvent ):void
        {
            var rect:Rectangle = new Rectangle( background.x - ( ruler.width * .5 ) + 3, minY, 0, maxY );
            ruler.startDrag( false, rect );
            stage.addEventListener( MouseEvent.MOUSE_UP, releaseHandle, false, 0, true );
        }

        private function releaseHandle( e:MouseEvent = null ):void
        {
            ruler.stopDrag();
            if ( stage ) stage.removeEventListener( MouseEvent.MOUSE_UP, releaseHandle );
        }

        private function enterFrameHandle( e:Event ):void
        {
            positionContent();
        }
    }
}
