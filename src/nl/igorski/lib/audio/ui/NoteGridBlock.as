package nl.igorski.lib.audio.ui
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.ui.Mouse;
    import flash.ui.MouseCursor;
    import flash.utils.setTimeout;
    import nl.igorski.lib.audio.core.AudioTimelineManager;
    import nl.igorski.lib.audio.ui.interfaces.IGridBlock;

    public class NoteGridBlock extends Sprite implements IGridBlock
    {
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 21-dec-2010
         * Time: 11:35:03
         */
        private var bg                      :Sprite;
        private var hover                   :Sprite;
        private var icon                    :Sprite;

        private var _pitch                  :Number;
        private var _octave                 :int;
        private var _length                 :Number;
        private var _index                  :int;        
        private var _color                  :uint;
        private var _active                 :Boolean = false;
        private var _grid                   :AudioTimeline;
        private var _position               :int;

        public static const WIDTH           :int = 25;
        public static const ICON_SIZE       :int = 10;
        
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        
        public function NoteGridBlock( myGrid:AudioTimeline = null, pitch:Number = 440, myOctave:int = 0, myIndex:int = 0, myColor:uint = 0xCCCCCC, myPosition:int = 0 )
        {
            _grid     = myGrid;
            _pitch    = pitch;
            _octave   = myOctave;
            _index    = myIndex;
            _color    = myColor;
            _position = myPosition;
            
            init();
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        public function highlight():void
        {
            handleRollOver( null );
            setTimeout( function():void
            {
                handleRollOut( null );
            }, 100 );
        }
        
        public function setData( length:Number ):void
        {
            if ( length == 0 ) {
                if ( _active )
                    clearIcon();

                return;
            }

            if ( icon == null )
            {
                icon = new Sprite();
                addChild( icon );
            }
            icon.graphics.clear();
            icon.graphics.beginFill( 0xFFFFFF, 1 );
            
            var w:Number = ICON_SIZE * length;
            if ( length > 1 )
                w = WIDTH * length;

            icon.graphics.drawRoundRect( WIDTH * .5 - ICON_SIZE * .5, WIDTH * .5 - ICON_SIZE * .5, w, ICON_SIZE, 5 );
            icon.graphics.endFill();
            _length = length;

            _active = true;

            _grid.setNote( _position, frequency, length, false, false );
        }
        
        /**
         * always returns the frequency of the note, regardless of
         * block state => use this for reference outside NoteGrid class
         * 
         * @return pitch floating number
         */
        public function getFrequency():Number
        {
            return _pitch;
        }
        
        /**
         * when block is off-screen, it's grid will call
         * this function to remove graphics and listeners and
         * reduce the footprint on the CPU
         */
        public function sleep():void
        {
            removeListeners();
            
            while ( numChildren > 0 )
                removeChildAt( 0 );
            
            bg      = null;
            hover   = null;
            icon    = null;
        }
        
        /**
         * when block is on-screen, it's grid will redraw it's
         * graphics and re-add the listeners
         */
        public function wakeUp():void
        {
            init();
            
            if ( !isNaN( _length ) && _active )
                setData( _length );
            
            if ( icon != null )
                setChildIndex( icon, numChildren - 1 );
        }

        public function destroy():void
        {
            removeListeners();

            while ( numChildren > 0 ) {
                var o:* = getChildAt(0);
                removeChildAt(0);
                o = null;
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                        G E T T E R S   /   S E T T E R S

        /**
         * returns the frequency of the set note, only if the block is active
         * this method is used by the AudioSequencer class to detect whether this
         * block contains an audio event to process
         * @return Number
         */
        public function get frequency():Number
        {
            if ( _active )
                return _pitch;

            return 0;
        }
        
        public function get octave():int
        {
            return _octave;
        }

        /**
         * returns the length of the set note, only if the block is active
         * @return Number
         */
        public function get length():Number
        {
            if ( _active )
                return _length;
            return 1;
        }

        public function get index():int
        {
            return _index;
        }

        public function set disabled( value:Boolean ):void
        {
            if ( value )
            {
                mouseEnabled = false;
                removeEventListener( MouseEvent.ROLL_OVER, handleRollOver );
                removeEventListener( MouseEvent.MOUSE_DOWN, handleMouseDown );
            }
            else {
                mouseEnabled = true;
                if ( !hasEventListener( MouseEvent.ROLL_OVER ))
                {
                    addEventListener( MouseEvent.ROLL_OVER, handleRollOver );
                    addEventListener( MouseEvent.MOUSE_DOWN, handleMouseDown );
                }
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function init():void
        {
            bg = new Sprite();
            hover = new Sprite();
            
            with ( bg.graphics )
            {
                beginFill( _color );
                drawRect( 0, 0, WIDTH, WIDTH );
                endFill();
            }
            with ( hover.graphics )
            {
                beginFill( 0xFFFFFF, 1 );
                drawRect( 0, 0, WIDTH, WIDTH );
                endFill();
            }
            addChild( bg );
            hover.alpha = 0;
            addChild( hover );

            mouseChildren = false;

            addListeners();
        }

        protected function handleRollOver( e:MouseEvent ):void
        {
            Mouse.cursor = MouseCursor.HAND;
            hover.alpha = .5;
        }

        protected function handleRollOut( e:MouseEvent ):void
        {
            Mouse.cursor = MouseCursor.AUTO;
            hover.alpha = 0;
        }

        protected function handleMouseDown( e:MouseEvent ):void
        {
            switch( _active )
            {
                case true:
                    clearIcon();
                    break;
                case false:
                    _active = true;
                    _length = 0;
                    AudioTimelineManager.lockTimeline( _index );
                    clearIcon();
                    icon = new Sprite();
                    addChild( icon );
                    stage.addEventListener( MouseEvent.MOUSE_MOVE, handleIconDraw );
                    stage.addEventListener( MouseEvent.MOUSE_UP, handleDrawComplete );
                    break;
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        protected function correctPos( pos:int ):int
        {
            // sixteen step sequencer context
            var maxWidth:int = ( 15 - _index ) * ( WIDTH + 4 );

            if ( pos > maxWidth )
                pos = maxWidth;

            if ( pos < 0 )
                pos = 0;

            return pos;
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        private function clearIcon():void
        {
            if ( icon != null )
            {
                if ( contains( icon ))
                    removeChild( icon );
                
                icon    = null;
                _active = false;
                
                _grid.clearNote( _position, _pitch );
            }
        }

        private function handleIconDraw( e:MouseEvent ):void
        {
            var pos:int = e.stageX - ( this as DisplayObject ).localToGlobal(new Point()).x;

            with ( icon.graphics )
            {
                clear();
                beginFill( 0xFFFFFF, 1 );
                drawRoundRect( WIDTH * .5 - ICON_SIZE * .5, WIDTH * .5 - ICON_SIZE * .5, correctPos( pos ), ICON_SIZE, 5 );
                endFill();
            }
        }

        private function handleDrawComplete( e:MouseEvent ):void
        {
            AudioTimelineManager.unlockTimeline();
            
            stage.removeEventListener( MouseEvent.MOUSE_MOVE, handleIconDraw );
            stage.removeEventListener( MouseEvent.MOUSE_UP, handleDrawComplete );

            // set icon at minimum length if below
            if ( icon.width < WIDTH )
            {
                with ( icon.graphics )
                {
                    clear();
                    beginFill( 0xFFFFFF, 1 );
                    drawRoundRect( WIDTH * .5 - ICON_SIZE * .5, WIDTH * .5 - ICON_SIZE * .5, ICON_SIZE, ICON_SIZE, 5 );
                    endFill();
                }
                _length = 1;
            }
            else {
                // set note length accordingly to icon length ( or rather: the amount of gridblocks it overlaps )
                _length = icon.width / WIDTH;
            }
            _grid.setNote( _position, frequency, length );
        }
        
        private function addListeners():void
        {
            if ( hasEventListener( MouseEvent.ROLL_OVER ))
                return;
            
            addEventListener( MouseEvent.ROLL_OVER,  handleRollOver );
            addEventListener( MouseEvent.ROLL_OUT,   handleRollOut );
            addEventListener( MouseEvent.MOUSE_DOWN, handleMouseDown );
        }
        
        private function removeListeners():void
        {
            removeEventListener( MouseEvent.ROLL_OVER,  handleRollOver );
            removeEventListener( MouseEvent.ROLL_OUT,   handleRollOut );
            removeEventListener( MouseEvent.MOUSE_DOWN, handleMouseDown );

            if ( stage != null && stage.hasEventListener( MouseEvent.MOUSE_MOVE )) {
                stage.removeEventListener( MouseEvent.MOUSE_MOVE, handleIconDraw );
                stage.removeEventListener( MouseEvent.MOUSE_UP, handleDrawComplete );
            }
        }
    }
}
