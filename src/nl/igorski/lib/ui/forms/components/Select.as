package nl.igorski.lib.ui.forms.components
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import nl.igorski.lib.ui.components.ScrollBlock;
    import nl.igorski.lib.ui.forms.components.interfaces.IFormElement;

    /**
     * Select acts as the HTML SelectBox ( i.e. a pulldown menu )
     * masks several options within a container and shows them after user interaction
     *
     * @author Igor Zinken
     */
    public class Select extends Sprite implements IFormElement
    {
        protected var arrowUp   :Sprite;
        protected var arrowDown :Sprite;

        protected var _title    :String;
        protected var _options  :Array;
        protected var _elements :Array;

        protected var _width    :int;
        protected var _height   :int;
        protected var toggle    :Sprite;
        private var opened      :Boolean = false;

        protected var _mask     :Sprite;
        protected var bg        :Sprite;
        protected var container :ScrollBlock;
        private var current     :Bitmap;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        
        public function Select( title:String, options:Array, width:int = 190, height:int = 125 )
        {
            _title   = title;
            _options = options;
            _width   = width;
            _height  = height;

            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function doError():void
        {

        }

        public function undoError():void
        {

        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        public function get val():*
        {
            for each( var b:SelectOption in _elements )
            {
                if ( b.checked )
                    return b.val;
            }
            return '';
        }

        public function set val( value:* ):void
        {
            for each( var b:SelectOption in _elements )
                b.checked = ( b.val == value );
        }

        override public function set tabIndex( value:int ):void
        {
            --value;

            for each( var s:SelectOption in _elements )
                s.tabIndex = ++value;
        }

        override public function get tabIndex():int
        {
            return _elements[0].tabIndex;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function initUI(e:Event):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );
            draw();

            buildList();
            toggle.addEventListener( MouseEvent.CLICK, handleToggle );
        }

        private function handleOptionSelect( e:Event ):void
        {
            for each( var b:SelectOption in _elements )
                b.deactivate();

            var curButton:SelectOption = SelectOption( e.target );

            curButton.activate();
            cloneSelection( curButton );

            container.scrollTo( curButton );
            hideList();
        }

        private function cloneSelection( b:SelectOption ):void
        {
            if ( b == null )
                return;

            try
            {
                if ( current != null )
                    current.bitmapData.dispose();

                var bmpd:BitmapData = new BitmapData( b.width, b.height, true, 0x00000000 );
                bmpd.draw( b );
                current = new Bitmap( bmpd );
                current.x = 6;
                current.y = 0;

                if ( !contains( current ))
                    addChild( current );

            } catch ( e:Error ) { }
        }


        private function handleToggle( e:MouseEvent ):void
        {
            switch( opened )
            {
                case true:
                    hideList();
                    break;
                case false:
                    showList();
                    break;
            }
        }

        private function hideList( e:MouseEvent = null ):void
        {
            opened = false;

            if ( container != null )
                container.mask = _mask;

            with ( bg.graphics )
            {
                clear();
                lineStyle( 1, 0xFFFFFF, 0.5 );
                beginFill( 0x000000, 1 );
                drawRect( _mask.x, _mask.y, _mask.width, 18 );
                endFill();
            }

            if ( current != null )
                addChild( current );

            container.alpha = 0;
            arrowDown.alpha = 1;
            arrowUp.alpha   = 0;
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        // override these in subclass for skinning purposes
        protected function draw():void
        {
            _mask     = new Sprite();
            arrowUp   = new Sprite();
            arrowDown = new Sprite();

            with( arrowDown.graphics )
            {
                beginFill( 0xFFFFFF, 1 );
                lineTo( 14, 0 );
                lineTo( 7, 8 );
                lineTo( 0, 0 );
                endFill();
            }
            with( arrowUp.graphics )
            {
                beginFill( 0xFFFFFF, 1 );
                moveTo( 0, 8 );
                lineTo( 14, 8 );
                lineTo( 7, 0 );
                lineTo( 0, 8 );
                endFill();
            }
            with( _mask.graphics )
            {
                beginFill( 0xFF0000, 0 );
                drawRect( 0, 0, _width - 20, 18 );
                endFill();
            }
            addChild( _mask );

            bg = new Sprite();
            addChild( bg );

            toggle = new Sprite();
            toggle.y = 5;
            toggle.x = _width - 15;
            arrowUp.alpha = 0;
            toggle.addChild( arrowUp );
            toggle.addChild( arrowDown );
            toggle.buttonMode    = true;
            toggle.mouseChildren = false;

            addChild( toggle );
        }

        protected function buildList():void
        {
            var count   :int = 0;
            var margin  :int = 20;
            _elements         = [];

            var window:Sprite = new Sprite();

            for each( var item:Object in _options )
            {
                var input:SelectOption = new SelectOption( item.value, item.label );
                input.addEventListener( SelectOption.SELECTED, handleOptionSelect );
                window.addChild( input );
                input.x = 6;
                input.y = count * margin;
                _elements.push( input );
                ++count;
            }

            container = new ScrollBlock( window, _width - 20, _height, 0, true );
            // container.addEventListener( MouseEvent.ROLL_OUT, hideList );
            container.mask = _mask;
            container.alpha = 0;
            addChild(container);

            if (_elements.length > 0) {
                _elements[0].activate();
                cloneSelection( _elements[0] );
            }
            hideList();
        }

        protected function update( items:Array ):void
        {
            _options =  items;

            if ( _options.length == 0 || !_options )
                _options = [];

            if ( container != null )
            {
                if ( contains( container ))
                    removeChild( container );

                container.removeEventListener( MouseEvent.ROLL_OUT, hideList );
                container = null;
            }

            for each(var b:SelectOption in _elements)
            {
                if ( b != null ) {
                    b.removeEventListener( SelectOption.SELECTED, handleOptionSelect );
                    b = null;
                }
            }

            if ( current != null ) {
                if (contains( current ))
                    removeChild( current );
            }
            _elements = null;
            buildList();
        }


        protected function showList():void
        {
            opened = true;

            if ( container != null )
                container.mask = null;

            with( bg.graphics )
            {
                clear();
                lineStyle( 1, 0xFFFFFF, 0.5 );
                beginFill( 0x000000, 1 );
                drawRect( _mask.x, _mask.y, _mask.width, _height );
                endFill();
            }
            if ( current != null )
                removeChild( current );

            container.alpha = 1;
            arrowDown.alpha = 0;
            arrowUp.alpha   = 1;
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
