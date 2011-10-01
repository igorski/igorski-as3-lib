package nl.igorski.lib.audio.ui
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.utils.Dictionary;

    import nl.igorski.lib.audio.core.AudioSequencer;
    import nl.igorski.lib.audio.core.AudioTimelineManager;
    import nl.igorski.lib.audio.core.events.AudioTimelineEvent;
    import nl.igorski.lib.audio.definitions.Pitch;
    import nl.igorski.lib.audio.helpers.BulkCacher;
    import nl.igorski.lib.audio.model.vo.VOAudioEvent;
    import nl.igorski.lib.audio.ui.interfaces.IGridBlock;
    import nl.igorski.lib.audio.ui.interfaces.IAudioTimeline;

    public class AudioTimeline extends Sprite implements IAudioTimeline
    {
        /**
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 21-dec-2010
         * Time: 11:39:00
         *
         * AudioTimeline is the visual "drawing board" used to create audio events
         * which are passed to the AudioSequencer. In onebarloop.com this is visualised
         * as a sixteen step grid containg smaller blocks that represent notes */

        public static const STEPS   :int = 16;

        /*
         * override this in you subclass if you plan on using your own custom NoteGridBlocks
         * ( a DisplayObject implementing the IGridBlock interface ) */

        protected var blockClass        :Class = NoteGridBlock;

        protected var pitchBlocks       :Vector.<IGridBlock>;
        protected var frequencies       :Vector.<Dictionary>;

        public var blockMargin          :int = 28;
        protected var _octaves          :int = 8;
        protected var _curOctave        :int = 3;
        protected var tf                :*;

        protected var BTNup             :Sprite;
        protected var BTNdown           :Sprite;
        public var onScreen             :Boolean = true;

        protected var _container        :Sprite;
        protected var _mask             :Sprite;
        protected var _color            :uint;
        protected var _highlightColor   :uint;
        public var pointer              :Sprite;

        // the voice this timeline is connected to, i.e. this timelines data
        // will be sent to the audio sequencer's voice at corresponding index

        public var _voice               :int = 0;
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function AudioTimeline( voice:int = 0, color:uint = 0xCCCCCC, highlightColor:uint = 0xDDDDDD ):void
        {
            _voice          = voice;
            _color          = color;
            _highlightColor = highlightColor;

            // attach this note timeline to the requested voice residing in the sequencer class
            AudioSequencer.attachTimeline( voice, this );
            AudioSequencer.STEPS_PER_BAR = STEPS;

            init();
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

         /**
         * gets frequencies at current sequencer position, also updates the pointer position
         * as this method is called during a step-change in the sequencer
         */
        public function getFrequencies( position:int ):Dictionary
        {
            return frequencies[ position ];
        }

        public function updatePosition( position:int ):void
        {
            if ( onScreen )
                updatePointerPosition( position );
        }

        public function get voice():int
        {
            return _voice;
        }
        
        public function createBlocks():void
        {
            var row         :int = 0;
            var col         :int = 0;
            var block       :DisplayObject;

            pitchBlocks     = new Vector.<IGridBlock>();
            frequencies     = new Vector.<Dictionary>( STEPS, true );

            for ( var i:int = 0; i < frequencies.length; ++i )
                frequencies[i] = new Dictionary();
            
            // create for each octave a grid
            for ( var octave:int = _octaves; octave > 0; --octave )
            {  
                // create all pitch rows within each octave
                while ( row < Pitch.OCTAVE_SCALE.length )
                {
                    // create entire row of blocks for this pitch ( for each of the sequencers steps )
                    // we add the blocks in reverse order as this allows for overlapping notes to be
                    // stretched visibly out of block bounds )

                    for ( col = STEPS - 1; col >= 0; --col )
                    {
                        // every 4 steps we accent the color of the block
                        var theColor:uint = ( col % 4 ) ? _color : _color + 0x32;

                        block    = new blockClass( this, Pitch.note( Pitch.OCTAVE_SCALE[ row ], octave ), octave, col, theColor, col );
                        block.x  = blockMargin * col;
                        block.y  = blockMargin * ( Pitch.OCTAVE_SCALE.length - row ) - blockMargin;
                        block.y -= octave * ( Pitch.OCTAVE_SCALE.length * blockMargin );
                        
                        _container.addChild( block );
                        pitchBlocks.push( block as IGridBlock );
                    }
                    ++row;
                    col = 0;
                }
                row = 0;
            }
            showPitchText( 3 );
            hideUnseen();
        }
        
        /**
         * called by the IGridBlocks to add
         * a note in the frequencies dictionary
         *
         * @param position of the note in the sequencer timeline
         * @param frequency the frequency of the note in Hz
         * @param length the length of the note ( relative to sequencer timeline positions )
         * @param autoCache whether to start caching the note immediately
         * @param fullDestroy whether to destroy currently cached references of the VO in the BulkCacher */

        public function setNote( position:int = 0, frequency:Number = 440, length:Number = 1, autoCache:Boolean = true, fullDestroy:Boolean = true ):void
        {
            // clear old value if existed - this will effectively remove the old cached value too
            if ( frequencies[ position ][ frequency ] != null )
            {
                if ( fullDestroy )
                    frequencies[ position ][ frequency ].destroy();

                delete frequencies[ position ][ frequency ];
            }
            // create value object for the new audio event
            var vo:VOAudioEvent = new VOAudioEvent({ frequency: frequency,
                                                     length:    length,
                                                     delta:     position,
                                                     autoCache: autoCache,
                                                     voice:     _voice });

            frequencies[ position ][ frequency ] = vo;

            // immediately flush the cache for this timeline ( only if this object is autocaching )
            if ( autoCache )
                AudioSequencer.invalidateCache( _voice, false, true );
        }
        
        /**
         * called by the IGridBlocks when a note is deleted
         */
        public function clearNote( position:int = 0, frequency:Number = 0 ):void
        {
            if ( frequencies[ position ][ frequency] != null )            {
                var vo:VOAudioEvent = VOAudioEvent( frequencies[ position ][ frequency ] );

                if ( vo.sample != null )
                    vo.destroy();

                vo = null;
                delete frequencies[ position ][ frequency ];
            }
            // immediately flush the cache for this timeline
            AudioSequencer.invalidateCache( _voice, false, true );
        }

        /**
         * clears all notes that are currently cached, called when a timeline's
         * attached voice changes properties.
         *
         * @param recache Boolean, when true the notes are re-added to the
         *                BulkCacher for immediate recaching */

        public function resetNotes( recache:Boolean = true ):void
        {
            for ( var i:int = 0; i < frequencies.length; ++i )
            {
                for each( var vo:VOAudioEvent in frequencies[i] )
                {
                    if ( vo.sample != null )
                        vo.destroy();

                    if ( recache )
                        BulkCacher.addEvent( vo );
                }
            }
            if ( recache )
                BulkCacher.sequenced = true;
        }

        /*
         * a Timeline can have relations to many objects, thus
         * unnecessarily using vast amounts of memory, so let's wipe
         * all this overhead by clearing the referenced objects
         *
         * @fullDestroy Boolean, when false removes only VO objects and
         *              clears current content, when true removes all
         *              Objects and clears Display List
         */
        public function destroy( fullDestroy:Boolean = true ):void
        {
            if ( pitchBlocks != null )
            {
                var block:DisplayObject;

                for ( var i:int = pitchBlocks.length - 1; i > 0; --i )
                {
                    block = pitchBlocks[i] as DisplayObject;

                    if ( fullDestroy )
                    {
                        IGridBlock( block ).destroy();

                        if ( _container.contains( block ))
                            _container.removeChild( block );

                        block = null;

                        pitchBlocks.splice( i, 1 );
                    }
                    else {
                        IGridBlock( block ).setData( 0 );
                    }
                }
                if ( fullDestroy )
                    pitchBlocks = null;
            }

            if ( frequencies != null )
            {
                for ( i = frequencies.length - 1; i > 0; --i )
                {
                    for each( var vo:VOAudioEvent in frequencies[i])
                    {
                        if ( vo.sample != null )
                            vo.destroy();

                        vo = null;
                    }
                    delete frequencies[i];
                }
                if ( fullDestroy ) {
                    frequencies = null;
                } else {
                    frequencies = new Vector.<Dictionary>( STEPS, true );
                    for ( i = 0; i < frequencies.length; ++i )
                        frequencies[i] = new Dictionary();
                }
            }

            if ( fullDestroy )
            {
                _mask.graphics.clear();
                _container.mask = null;

                while ( numChildren > 0 )
                {
                    var o:* = getChildAt( 0 );
                    removeChildAt( 0 );
                    o = null;
                }

                removeListeners();
            } else {
                _curOctave    = 3;
                _container.y += Pitch.OCTAVE_SCALE.length * blockMargin * _curOctave;
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                        G E T T E R S   /   S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        protected function init():void
        {
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

            addListeners();
        }

        private function handleLock( e:AudioTimelineEvent ):void
        {
            for each ( var b:IGridBlock in pitchBlocks )
            {
                if ( b.index != e.activeItem )
                    b.disabled = true;
            }
        }

        private function handleUnlock( e:AudioTimelineEvent ):void
        {
            for each( var b:IGridBlock in pitchBlocks )
                b.disabled = false;
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        protected function get blocks():Vector.<IGridBlock>
        {
            return pitchBlocks.concat();
        }

        protected function handlePagination( e:MouseEvent ):void
        {
            switch( e.target )
            {
                case BTNdown:
                    if ( _curOctave > 1 )
                    {
                        showNext( false );
                        _container.y -= Pitch.OCTAVE_SCALE.length * blockMargin;
                        --_curOctave;
                    }
                    break;
                case BTNup:
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
            BTNup   = new Sprite();
            BTNdown = new Sprite();

            BTNup.graphics.beginFill( 0xFF0000, 1 );
            BTNup.graphics.drawCircle( 465, _container.y + 10, 10 );
            BTNup.graphics.endFill();

            BTNdown.graphics.beginFill( 0xFF0000, 1 );
            BTNdown.graphics.drawCircle( 465, 320, 10 );
            BTNdown.graphics.endFill();

            BTNdown.buttonMode =
            BTNup.buttonMode   = true;

            addChild( BTNup );
            addChild( BTNdown);
        }
        
        /**
         * showNext: draws the graphics and adds listeners for the timeline that is about to slide into view
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

            for each( var b:IGridBlock in pitchBlocks )
            {
                if ( b.octave == next )
                    b.wakeUp();
            }
            showPitchText( next );

            BTNup.visible = !( next == _octaves );
            BTNdown.visible = !( next == 1 );
        }
        
        /**
         * hide all blocks that are currently not in the view, remove their
         * graphics and listeners
         */
        protected function hideUnseen():void
        {
            for each( var b:IGridBlock in pitchBlocks )
                b.octave == _curOctave ? b.wakeUp() : b.sleep();
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
        
        protected function showPitchText( octave:int = -1 ):void
        {
            if ( octave == -1 )
                octave = _curOctave;

            var pitchText:String = "";
            
            for ( var i:int = Pitch.OCTAVE_SCALE.length - 1; i >= 0; --i )
                pitchText += Pitch.OCTAVE_SCALE[ i ] + octave + "\n";

            tf = addPitchText( pitchText );
            
            if ( !contains( tf ))
                addChild( tf );
        }

        protected function addListeners():void
        {
            // listen to lock / unlock notifications from the total timeline grid
            AudioTimelineManager.INSTANCE.addEventListener( AudioTimelineEvent.LOCK,   handleLock );
            AudioTimelineManager.INSTANCE.addEventListener( AudioTimelineEvent.UNLOCK, handleUnlock );

            BTNdown.addEventListener( MouseEvent.CLICK, handlePagination );
            BTNup.addEventListener( MouseEvent.CLICK, handlePagination );
        }

        protected function removeListeners():void
        {
            AudioTimelineManager.INSTANCE.removeEventListener( AudioTimelineEvent.LOCK,   handleLock );
            AudioTimelineManager.INSTANCE.removeEventListener( AudioTimelineEvent.UNLOCK, handleUnlock );

            BTNdown.removeEventListener( MouseEvent.CLICK, handlePagination );
            BTNup.removeEventListener( MouseEvent.CLICK, handlePagination );
        }
    }
}
