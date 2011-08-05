package nl.igorski.lib.ui.components
{
    import flash.display.DisplayObject;
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
        private var scrollContent   :DisplayObject;

        private var _width          :int;
        private var _height         :int;

        protected var background    :Sprite;
        protected var maskmc        :Sprite;
        private var ruler           :Sprite;
        private var minY            :Number;
        private var maxY            :Number;
        private var contentstarty   :Number;
        private var percentuale     :Number;
        private var margin          :Number = 10;

        private var _scrollPosition :int;
        private var _alwaysScroll   :Boolean;

        /*
         * inScrollContent  a DisplayObject container holding the content to be masked and scrolled
         * inWidth          maximum width this object may occupy
         * inHeight         maximum height this object may occopy
         * inScrollPosition x-position of the scrollbar ( 0 defaults to right side of content ) in pixels
         * inAlwaysScroll   when set to true, this block will also scroll when the mousewheel is used outside it's area
         */

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function ScrollBlock( inScrollContent:DisplayObject, inWidth:int = 100, inHeight:int = 100, inScrollPosition:int = 0, inAlwaysScroll:Boolean = false )
        {
            scrollContent   = inScrollContent;
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
            downY = scrollContent.height - ( maskmc.height * .5 ) + 20;

            checkContentLength();

            var endPosition     :Number = contentstarty - ((( downY - ( maskmc.height * .5 )) * .01 ) * percentuale );
            var currentPosition :Number = scrollContent.y;

            if ( currentPosition != endPosition )
            {
                var diff:Number = endPosition - currentPosition;
                currentPosition += diff / 4;
            }
            scrollContent.y = currentPosition;
        }

        public function checkContentLength():void
        {
            ruler.visible = ( scrollContent.height >= maskmc.height );
        }

        /*
         * reset the scroller ( when changing content length, for instance )
         *
         * @param aScrollContent optional new scroll content that should replace
         *        the current content
         */
        public function reset( aScrollContent:* = null ):void
        {
            scrollContent.y   = 0;
            ruler.y           = 0;

            if ( aScrollContent != null )
            {
                if ( contains( scrollContent ))
                    removeChild( scrollContent );

                scrollContent = aScrollContent;
                initUI();

            } else {
                checkScroll();
            }
        }

        /*
         * scrollTo can be called when a specific displayObject
         * ( within the scrollContent container ) should be visible
         * on-screen
         *
         * @param inObj, a DisplayObject within the scrollContent container */

        public function scrollTo( inObj:* ):void
        {
            handleRelease();
            scrollContent.y = -inObj.y;
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

        /**
         * if you update the dimensions of your scroller's container, you may
         * wish to adjust the scroller's dimensions, you can adjust them
         * without creating a new scroller
         * @param aWidth  the preferred width, leave empty ( -1 ) to keep current width
         * @param aHeight the preferred height, leave empty ( -1 ) to keep current height
         */
        public function updateDimensions( aWidth:int = -1, aHeight:int = -1 ):void
        {
            var oldHeight:Number = _height;

            if ( aWidth > -1 )
                _width = aWidth;

            if ( aHeight > -1 )
                _height = aHeight;

            if ( contains( background ))
                removeChild( background );

            background = null;

            scrollContent.mask = null;

            if ( contains( maskmc ))
                removeChild( maskmc );

            maskmc = null;

            scrollContent.y = scrollContent.y / oldHeight * _height;

            initUI();
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function initUI( e:Event = null ):void
        {
            if ( hasEventListener( Event.ADDED_TO_STAGE ))
                removeEventListener( Event.ADDED_TO_STAGE, initUI );

            if ( !contains( scrollContent ))
                addChild( scrollContent );

            if ( background == null )
            {
                background = new Sprite();
                background.addChild( new ScrollTrack( _height ) );
                addChild( background );
            }

            draw();

            minY = background.y;
            maxY = background.y + ( background.height - ruler.height );

            contentstarty = scrollContent.y;

            minY = 0;
            maxY = background.height - ruler.height;

            checkScroll();
        }

        protected function handleClick( e:MouseEvent ):void
        {
            var rect:Rectangle = new Rectangle( background.x, minY, 0, maxY );
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

            // prevent getting stuck to the limits...
            if ( ruler.y == 0 )
                ruler.y = 1;

            if (( e.delta > 0 && ruler.y < maxY ) || ( e.delta < 0 && ruler.y > minY ))
            {
                var targetY:Number = ruler.y - ( e.delta * 3 );

                if ( targetY > maxY )
                    targetY = maxY;
                else if ( targetY < minY )
                    targetY = minY;

                ruler.y = targetY;
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        /*
         * override in subclass for custom skinning
         * note we are checking whether objects exist as the
         * draw method runs when the inner content resets */

        protected function draw():void
        {
            if ( maskmc == null )
            {
                maskmc = new Sprite();

                maskmc.graphics.beginFill( 0xFFFFFF, 1 );
                maskmc.graphics.drawRect( 0, 0, _width, _height );
                maskmc.graphics.endFill();
                maskmc.x = scrollContent.x;
                addChild( maskmc );
            }
            scrollContent.mask = maskmc;

            if ( ruler == null )
            {
                ruler = new Sprite();
                ruler.addChild( new ScrollHandle());
                ruler.buttonMode = true;
                ruler.tabEnabled = false;
            }

            if ( _scrollPosition == 0 )
            {
                ruler.x      =
                background.x = _width + ( margin * 4 );
            }
            else
            {
                ruler.x      =
                background.x = _scrollPosition;
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        /*
         * checks whether the scrollbar is actually needed
         * to display the current content in the set window dimensions
         */
        private function checkScroll():void
        {
            if ( scrollContent.height >= maskmc.height )
            {
                ruler.addEventListener( MouseEvent.MOUSE_DOWN, handleClick, false, 0, true );
            //	ruler.addEventListener( MouseEvent.MOUSE_OUT, releaseHandle );
                addEventListener( Event.ENTER_FRAME, handleEnterFrame, false, 0, true );

                if ( _alwaysScroll )
                    stage.addEventListener( MouseEvent.MOUSE_WHEEL, handleWheel, false, 0, true );
                else
                    addEventListener( MouseEvent.MOUSE_WHEEL, handleWheel, false, 0, true );

                showRuler();

            } else {

                ruler.removeEventListener( MouseEvent.MOUSE_DOWN, handleClick );
                removeEventListener( MouseEvent.MOUSE_UP, handleRelease );
                removeEventListener( Event.ENTER_FRAME, handleEnterFrame );

                if ( _alwaysScroll )
                    stage.removeEventListener( MouseEvent.MOUSE_WHEEL, handleWheel );
                else
                    removeEventListener( MouseEvent.MOUSE_WHEEL, handleWheel );

                hideRuler();
            }
        }

        private function scrollData( q:int ):void
        {
            var d       :Number;
            var rulerY  :Number;

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
