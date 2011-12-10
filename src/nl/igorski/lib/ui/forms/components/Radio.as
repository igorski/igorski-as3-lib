package nl.igorski.lib.ui.forms.components
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import nl.igorski.lib.definitions.Fonts;
    import nl.igorski.lib.interfaces.IDestroyable;
    import nl.igorski.lib.ui.forms.components.interfaces.IFormElement;
    import nl.igorski.lib.ui.components.StdTextField;
    import nl.igorski.lib.ui.forms.components.interfaces.ITabbableFormElement;

    /**
     * a single RadioButton, to be used in a RadioGroup, not standalone.
     * ...
     * @author Igor Zinken
     */
    public class Radio extends Sprite implements IFormElement, ITabbableFormElement, IDestroyable
    {
        public static const ACTIVATE	:String = "Radio::ACTIVATE";

        protected var _tabIndex         :int;
        protected var bg				:Sprite;
        protected var checked_bg		:Sprite;
        protected var error_bg			:Sprite;

        private var _checked			:Boolean = false;
        private var _value				:String;
        private var _label				:String;

        protected var label				:StdTextField = new StdTextField( Fonts.LABEL );

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function Radio( value:String = "", label:String = "" )
        {
            _value = value;
            _label = label;

            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function check():void
        {
            _checked = true;

            if ( checked_bg.alpha < 1 )
                checked_bg.alpha = 1;
        }

        public function uncheck():void
        {
            _checked = false;

            if ( checked_bg.alpha > 0 )
                checked_bg.alpha = 0;
        }

        public function doError():void
        {
            uncheck();
            bg.alpha = 0;
            error_bg.alpha = 1;
        }

        public function undoError():void
        {
            bg.alpha = 1;
            error_bg.alpha = 0;
        }

        public function destroy():void
        {
            removeListeners();
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        public function get selected():Boolean
        {
            return _checked;
        }

        public function set selected( value:Boolean ):void
        {
            if ( value )
                check();
            else
                uncheck();
        }

        override public function get tabIndex():int
        {
            return _tabIndex;
        }

        override public function set tabIndex( value:int ):void
        {
            _tabIndex          = value;
            super.tabIndex     = _tabIndex;
            tabEnabled         = true;
        }

        public function get val():*
        {
            return _value;
        }

        public function set val( value:* ):void
        {
            _value = value;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function initUI( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );

            draw();

            addListeners();
        }

        protected function handleClick( e:MouseEvent ):void
        {
            switch( _checked )
            {
                case true:
                    uncheck();
                    break;
                case false:
                    check();
                    dispatchEvent( new Event( Radio.ACTIVATE ));
                    break;
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        // override in subclass for custom skinning
        protected function draw():void
        {
            bg         = new Sprite();
            checked_bg = new Sprite();
            error_bg   = new Sprite();

            with( bg.graphics )
            {
                lineStyle( 1, 0xFFFFFF, 0.3 );
                beginFill( 0xa8a7a7, 1 );
                drawCircle( 0, 0, 7 );
                endFill();
            }
            with( error_bg.graphics )
            {
                lineStyle( 1, 0xFFFFFF, 1 );
                beginFill( 0x000000, 1 );
                drawCircle( 0, 0, 7 );
                endFill();
            }
            error_bg.alpha = 0;

            with ( checked_bg.graphics )
            {
                beginFill( 0x000000, 1 );
                drawCircle( 0, 0, 3 );
                endFill();
            }
            checked_bg.alpha = 0;
            checked_bg.x = 0;
            checked_bg.y = 0;

            addChild( bg );
            addChild( error_bg );
            addChild( checked_bg );

            label.text = _label;
            label.x = 10;
            label.y = -9;

            addChild( label );

            buttonMode    = true;
            mouseChildren = false;
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        private function addListeners():void
        {
            addEventListener( MouseEvent.CLICK, handleClick );
        }

        private function removeListeners():void
        {
            removeEventListener( MouseEvent.CLICK, handleClick );
        }
    }
}
