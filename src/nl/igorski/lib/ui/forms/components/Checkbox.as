﻿package nl.igorski.lib.ui.forms.components
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
     * ...
     * @author Igor Zinken
     */
    public class Checkbox extends Sprite implements IFormElement, ITabbableFormElement, IDestroyable
    {
        protected var bg            :Sprite;
        protected var checked_bg    :Sprite;
        protected var error_bg      :Sprite;

        protected var _tabIndex     :int = 0;
        protected var _checked      :Boolean = false;
        protected var _title        :String = "";
        protected var _labelWidth   :int = 0;

        protected var label         :StdTextField = new StdTextField( Fonts.FORM_TEXT );

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function Checkbox( title:String = null, labelWidth:int = 250 )
        {
            if ( title != null)
                _title  = title;

            _labelWidth = labelWidth;

            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function check():void
        {
            _checked = true;

            if ( !contains( checked_bg ))
                addChild( checked_bg );
        }

        public function uncheck():void
        {
            _checked = false;

            if ( contains( checked_bg ))
                removeChild( checked_bg );
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

        public function get val():*
        {
            return _checked;
        }

        public function set val( value:* ):void
        {
            _checked = value;
        }

        // "HTML properties"
        public function get checked():Boolean
        {
            return _checked;
        }

        public function set checked( value:Boolean ):void
        {
            _checked = value;
        }

        /*
         * returns bit values instead of Boolean values
         * for this object's checked state
         */
        public function get numericVal():int
        {
            return ( _checked ) ? 1 : 0;
        }

        public function set numericVal( value:int ):void
        {
            _checked = ( value == 1 );
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

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function initUI(e:Event):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );
            addListeners();
            draw();
        }

        private function handleClick(e:MouseEvent):void
        {
            switch( _checked )
            {
                case true:
                    uncheck();
                    break;

                case false:
                    check();
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

            with ( bg.graphics )
            {
                lineStyle(1, 0x000000, 0.3);
                beginFill(0xFFFFFF, 1);
                drawRect(0, 0, 15, 15)
                endFill();
            }
            with( checked_bg.graphics )
            {
                beginFill(0x33384f, 1);
                drawRect(0, 0, 7, 7);
                endFill();
            }
            checked_bg.x = 4;
            checked_bg.y = 4;

            with( error_bg.graphics )
            {
                lineStyle(1, 0xFFFFFF, 1);
                beginFill(0x000000, 1);
                drawRect(0, 0, 10, 10);
                endFill();
            }
            error_bg.alpha = 0;

            addChild( bg );
            addChild( error_bg );

            label.wordWrap = true;
            label.width = _labelWidth;
            label.text = _title;
            label.x = 22;
            label.y = -2;

            // addChild(label);
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
