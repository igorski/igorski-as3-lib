package nl.igorski.lib.ui.components
{
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.text.TextField;

    /**
     * ScrollBlock is a self-masking container which provides a simple
     * scrollbar when a given DisplayObject exceeds the given dimensions
     * ...
     * @author Igor Zinken
     */
    public class ScrollBlock extends Sprite
    {
        private var obj				:*; // (display)object to scroll

        private var _width			:int;
        private var _height			:int;

        protected var background	:Sprite;
        protected var maskmc		:Sprite;
        private var ruler			:Sprite;
        private var minY			:Number;
        private var maxY			:Number;
        private var contentstarty	:Number;
        private var percentuale		:Number;
        private var margin			:Number = 10;

        private var _scrollPosition	:int;
        private var _alwaysScroll	:Boolean;

        /*
         * inObj            a DisplayObject container holding the content to be masked and scrolled
         * inWidth          maximum width this object may occupy
         * inHeight         maximum height this object may occopy
         * inScrollPosition x-position of the scrollbar ( 0 defaults to right side of content ) in pixels
         * inAlwaysScroll   when set to true, this block will also scroll when the mousewheel is used outside it's area
         */

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function ScrollBlock( inObj:*, inWidth:int = 100, inHeight:int = 100, inScrollPosition:int = 0, inAlwaysScroll:Boolean = false )
        {
            obj             = inObj;
            _width          = inWidth;
            _height         = inHeight;
            _scrollPosition = inScrollPosition;
            _alwaysScroll   = inAlwaysScroll;

            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

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
            handleRelease();
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

        // make sure all scrollable elements in the object aren't scroll enabled
        // as it's pane should be scrollable.. kind of the point of this class...
        public function removeWheelListeners( object:DisplayObjectContainer ):void
        {
            var amount:int = object.numChildren;
            for ( var i:int = 0; i < amount; ++i )
            {
                var child:* = object.getChildAt(i);

                if ( child is DisplayObjectContainer )
                    removeWheelListeners( child as DisplayObjectContainer );

                if ( child is TextField )
                    TextField( child ).mouseWheelEnabled = false;
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function initUI( e:Event = null ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );

            if ( !contains( obj ))
                addChild( obj );

            background = new Sprite();

            if ( background.numChildren == 0 )
            {
                background.addChild( new ScrollTrack( _height ) );
                addChild( background );
            }

            draw();

            minY = background.y;
            maxY = background.y + background.height - ruler.height;

            contentstarty = obj.y;

            minY = 0;
            maxY = background.height - ruler.height;

            checkScroll();
        }

        protected function handleClick( e:MouseEvent ):void
        {
            var rect:Rectangle = new Rectangle( background.x - ( ruler.width * .5 ) + 3, minY, 0, maxY );
            ruler.startDrag( false, rect );
            stage.addEventListener( MouseEvent.MOUSE_UP, handleRelease, false, 0, true );
        }

        protected function handleRelease( e:MouseEvent = null ):void
        {
            ruler.stopDrag();

            if ( stage )
                stage.removeEventListener( MouseEvent.MOUSE_UP, handleRelease );
        }

        protected function handleEnterFrame( e:Event ):void
        {
            positionContent();
        }

        protected function handleWheel( e:MouseEvent ):void
        {
            handleRelease();

            if ( ruler.y == 0 )
                ruler.y = 1;

            if (( e.delta > 0 && ruler.y < maxY ) || ( e.delta < 0 && ruler.y > minY ))
            {
                var targetY:Number = ruler.y - ( e.delta * 3 );

                if ( targetY > maxY || targetY < 0 )
                    return;

                ruler.y = targetY;
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        // override in subclass for custom skinning
        protected function draw():void
        {
            maskmc = new Sprite();

            if ( !contains( maskmc ))
            {
                maskmc.graphics.beginFill( 0xFFFFFF, 1 );
                maskmc.graphics.drawRect( 0, 0, _width, _height );
                maskmc.graphics.endFill();
                maskmc.x = obj.x;
                addChild( maskmc );
            }
            obj.mask = maskmc;

            ruler = new Sprite();

            if ( !contains( ruler ))
            {
                ruler.addChild( new ScrollHandle());
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
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        private function checkScroll():void
        {
            // is scrollbar actually required ?
            if ( obj.height >= maskmc.height )
            {
                ruler.addEventListener( MouseEvent.MOUSE_DOWN, handleClick, false, 0, true );
            //	ruler.addEventListener( MouseEvent.MOUSE_OUT, releaseHandle );
                addEventListener( Event.ENTER_FRAME, handleEnterFrame, false, 0, true );

                if ( _alwaysScroll )
                    stage.addEventListener( MouseEvent.MOUSE_WHEEL, handleWheel, false, 0, true );
                else
                    addEventListener( MouseEvent.MOUSE_WHEEL, handleWheel, false, 0, true );
            } else {
                hideScroller();
            }
        }

        private function hideScroller():void
        {
            if ( contains( ruler ))
                removeChild( ruler );
            
            if ( contains( background ))
                removeChild( background );
            
            ruler.removeEventListener( MouseEvent.MOUSE_DOWN, handleClick );
            removeEventListener( MouseEvent.MOUSE_UP, handleRelease );
            removeEventListener( Event.ENTER_FRAME, handleEnterFrame );

            if ( _alwaysScroll )
                stage.removeEventListener( MouseEvent.MOUSE_WHEEL, handleWheel );
            else
                removeEventListener( MouseEvent.MOUSE_WHEEL, handleWheel );
        }

        private function scrollData( q:int ):void
        {
            var d:Number;
            var rulerY:Number;

            d = -q * 10;

            if ( d > 0 )
                rulerY = Math.min( maxY, ruler.y + d );

            if ( d < 0 )
                rulerY = Math.max( minY, ruler.y + d );

            ruler.y = rulerY;
            positionContent();
        }
    }
}
