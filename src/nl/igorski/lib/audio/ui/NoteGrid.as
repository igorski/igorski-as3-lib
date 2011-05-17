package nl.igorski.lib.audio.ui
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.utils.Dictionary;

    import nl.igorski.lib.audio.AudioSequencer;
    import nl.igorski.lib.audio.core.GridManager;
    import nl.igorski.lib.audio.core.events.GridEvent;
    import nl.igorski.lib.audio.definitions.Pitch;
    import nl.igorski.lib.audio.model.vo.VOAudioEvent;

    public class NoteGrid extends Sprite
    {
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 21-dec-2010
         * Time: 11:39:00
         */
        public static const STEPS   :int = 16;
        
        private var grid            :Vector.<Vector.<NoteGridBlock>>;
        private var pitchBlocks     :Vector.<NoteGridBlock>;
        private var frequencies     :Vector.<Dictionary>;

        public var blockMargin      :int = NoteGridBlock.WIDTH + 3;
        public var _octaves         :int = 8;
        public var _curOctave       :int = 3;
        public var tf               :*;

        public var up               :Sprite;
        public var down             :Sprite;
        public var onScreen         :Boolean = true;

        public var _container       :Sprite;
        public var _mask            :Sprite;
        private var _color          :uint;
        public var pointer          :Sprite;

        // the voice this grid is connected to, i.e. this grid's data
        // will be sent to the audio sequencer's voice at corresponding index

        public var _voice           :int = 0;
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function NoteGrid( voice:int = 0, color:uint = 0xCCCCCC ):void
        {
            _voice = voice;
            _color = color;

            // attach this note grid to the requested voice residing in the sequencer class
            AudioSequencer.attachNoteGrid( voice, this );
            addEventListener ( Event.ADDED_TO_STAGE, init );
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

         /**
         * gets frequencies at current sequencer position
         *
         * @return
         */
        public function getFrequencies( position:int ):Dictionary
        {
            if ( onScreen )
                updatePointerPosition( position );
            return frequencies[ position ];
        }

        public function get voice():int
        {
            return _voice;
        }
        
        public function get blocks():Array
        {
            var out:Array = [];
            for ( var i:int = 0; i < _container.numChildren; ++i )
            {
                if ( _container.getChildAt( i ) is NoteGridBlock )
                    out.push( _container.getChildAt( i ));
            }
            return out;
        }
        
        public function createBlocks():void
        {
            if ( pitchBlocks != null )
            {
                for ( var i:int = pitchBlocks.length - 1; i > 0; --i )
                {
                    var block:NoteGridBlock = pitchBlocks[i];
                    if ( _container.contains( block ))
                        _container.removeChild( block );
                    block = null;
                    pitchBlocks.splice( i, 1 );
                }
            }
            var row         :int = 0;
            var col         :int = 0;
            
            grid                 = new Vector.<Vector.<NoteGridBlock>>();
            frequencies          = new Vector.<Dictionary>( STEPS, true );

            for ( i = 0; i < frequencies.length; ++i )
                frequencies[i] = new Dictionary();
            
            // create for each octave a grid
            for ( var octave:int = _octaves; octave > 0; --octave )
            {  
                // create all pitch rows within each octave
                while ( row < Pitch.OCTAVE_SCALE.length )
                {
                    pitchBlocks  = new Vector.<NoteGridBlock>();

                    // create entire row of blocks for this pitch ( for each of the sequencers steps )
                    for ( col = 0; col < STEPS; ++col )
                    {
                        block    = new NoteGridBlock( this, Pitch.note( Pitch.OCTAVE_SCALE[ row ], octave ), octave, pitchBlocks.length, _color, col );
                        block.x  = blockMargin * col;
                        block.y  = blockMargin * ( Pitch.OCTAVE_SCALE.length - row ) - blockMargin;
                        block.y -= octave * ( Pitch.OCTAVE_SCALE.length * blockMargin );
                        
                        pitchBlocks.push( block );
                    }
                    // add the blocks to stage in reverse order ( allows for overlapping notes to be stretched visibly out of block bounds )
                    for ( i = pitchBlocks.length - 1; i >= 0; --i )
                        _container.addChild( pitchBlocks[ i ] );
                    
                    grid.push( pitchBlocks );
                    ++row;
                    col = 0;
                }
                row = 0;
            }
            showPitchText( 3 );
            hideUnseen();
        }
        
        /**
         * called by the NoteGridBlocks to add
         * a note in the frequencies dictionary
         */
        public function setNote( position:int = 0, frequency:Number = 440, length:Number = 1 ):void
        {
            // clear old value if existed - this will effectively remove the old cached value too
            if ( frequencies[ position ][ frequency ] != null )
                delete frequencies[ position ][ frequency ];

            // create value object for the new audio event
            var vo:VOAudioEvent = new VOAudioEvent({ frequency: frequency,
                                                     length:    length,
                                                     delta:     position,
                                                     voice:     _voice });
            frequencies[ position ][ frequency ] = vo;

            // flush the cache for this grid
            AudioSequencer.invalidateCache( _voice );
        }
        
        /**
         * called by the NoteGridBlocks when a note is deleted
         */
        public function clearNote( position:int = 0, frequency:Number = 0 ):void
        {
            if ( frequencies[ position ][ frequency] != null )
            {
                var vo:VOAudioEvent = VOAudioEvent( frequencies[ position ][ frequency ] );
                if ( vo.sample != null )
                    vo.sample.destroy();
                vo = null;
                delete frequencies[ position ][ frequency ];
            }
            // flush the cache for this grid
            AudioSequencer.invalidateCache( _voice );
        }

        /**
         * clears and rebuilds the current cache, called
         * when a grid's attached voice changes properties
         */
        public function resetNotes():void
        {
            for ( var i:int = 0; i < frequencies.length; ++i )
            {
                for each( var vo:VOAudioEvent in frequencies[i] )
                {
                    if ( vo.sample != null )
                    {
                        vo.sample.destroy();
                        vo.sample = null;
                        vo.cache();
                    }
                }
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                        G E T T E R S   /   S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        protected function init( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, init );

            // listen to lock / unlock notifications from the total grid
            GridManager.INSTANCE.addEventListener( GridEvent.LOCK, handleLock, false, 0, true );
            GridManager.INSTANCE.addEventListener( GridEvent.UNLOCK, handleUnlock, false, 0, true );

            // mask
            _mask = new Sprite();
            _mask.graphics.beginFill( 0xFF0000, 1 );
            _mask.graphics.drawRect( -blockMargin, 0, blockMargin * ( STEPS + 2 ), blockMargin * Pitch.OCTAVE_SCALE.length );
            _mask.graphics.endFill();
            addChild( _mask );

            // block container
            _container = new Sprite();
            _container.mask = _mask;
            addChild( _container );
            
            // you can override these in subclasses for skinning purposes
            drawPointer();
            drawScrollButtons();
 
             createBlocks();
            _container.y += Pitch.OCTAVE_SCALE.length * blockMargin * _curOctave;
        }

        private function handleLock( e:GridEvent ):void
        {
            for each ( var b:NoteGridBlock in pitchBlocks )
            {
                if ( b.index != e.activeItem )
                    b.disabled = true;
            }
        }

        private function handleUnlock( e:GridEvent ):void
        {
            for each( var b:NoteGridBlock in pitchBlocks )
                b.disabled = false;
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        protected function handlePagination( e:MouseEvent ):void
        {
            switch( e.target )
            {
                case down:
                    if ( _curOctave > 1 )
                    {
                        showNext( false );
                        _container.y -= Pitch.OCTAVE_SCALE.length * blockMargin;
                        --_curOctave;
                    }
                    break;
                case up:
                    if ( _curOctave < _octaves )
                    {
                        showNext( true );
                        _container.y += Pitch.OCTAVE_SCALE.length * blockMargin;
                        ++_curOctave;
                    }
                    break;
            }
            hideUnseen();
        }
        
        protected function addPitchText( text:String ):*
        {
            if ( tf == null )
            {
                var tf:TextField = new TextField();
                tf.textColor     = 0xFFFFFF;
                tf.selectable    =
                tf.mouseEnabled  = false;
            }
            tf.text = text;
            return tf;
        }
        
        protected function drawPointer():void
        {
            pointer = new Sprite();
            with ( pointer.graphics )
            {
                beginFill( 0xFFFFFF, .3 );
                drawRect( 25, _mask.y, 2, _mask.height );
                endFill();
            }
            pointer.mouseEnabled = false;
            addChild( pointer );
        }
        
        protected function updatePointerPosition( position:int ):void
        {
            pointer.x = position * blockMargin;
        }
        
        protected function drawScrollButtons():void
        {
            up   = new Sprite();
            down = new Sprite();

            up.graphics.beginFill( 0xFF0000, 1 );
            up.graphics.drawCircle( 470, _container.y + 10, 10 );
            up.graphics.endFill();

            down.graphics.beginFill( 0xFF0000, 1 );
            down.graphics.drawCircle( 470, 320, 10 );
            down.graphics.endFill();

            down.buttonMode =
            up.buttonMode   = true;
            down.addEventListener( MouseEvent.CLICK, handlePagination, false, 0, true );
            up.addEventListener( MouseEvent.CLICK, handlePagination, false, 0, true );

            addChild( up );
            addChild( down);
        }
        
        /**
         * showNext: draws the graphics and adds listeners for the grid block that is about to slide into view
         * 
         * @param	upper Boolean set to true for enabling visibility of next ( higher octave )
         *                set to false for enabling visibility of lower octave
         */
        protected function showNext( upper:Boolean ):void
        {
            var next:int;
            
            if ( upper )
                next = _curOctave + 1;
            else
                next = _curOctave - 1;

            if ( next > _octaves || next < 0 )
                return;
            
            for each( var pb:Vector.<NoteGridBlock> in grid )
            {
                for each( var b:NoteGridBlock in pb )
                {
                    if ( b.octave == next )
                        b.wakeUp();
                }
            }
            showPitchText( next );
        }
        
        /**
         * hide all grid blocks that are currently not in the view, remove their
         * graphics and listeners
         */
        protected function hideUnseen():void
        {
            for each( var pb:Vector.<NoteGridBlock> in grid )
            {
                for each( var b:NoteGridBlock in pb )
                {
                    b.octave == _curOctave ? b.wakeUp() : b.sleep();
                }
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
        
        private function showPitchText( octave:int = -1 ):void
        {
            if ( octave == -1 )
                octave = _curOctave;

            var pitchText:String   = "";
            
            for ( var i:int = Pitch.OCTAVE_SCALE.length - 1; i >= 0; --i )
                pitchText += Pitch.OCTAVE_SCALE[ i ] + octave + "\n";

            tf = addPitchText( pitchText );
            
            if ( !contains( tf ))
                addChild( tf );
        }
    }
}
