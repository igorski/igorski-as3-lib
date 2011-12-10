package nl.igorski.lib.ui.forms.base
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;

    import nl.igorski.lib.View;
    import nl.igorski.lib.definitions.Fonts;
    import nl.igorski.lib.interfaces.IDestroyable;
    import nl.igorski.lib.models.Proxy;
    import nl.igorski.lib.ui.forms.components.Birthdate;
    import nl.igorski.lib.ui.forms.components.Checkbox;
    import nl.igorski.lib.ui.forms.components.Divider;
    import nl.igorski.lib.ui.components.FeedbackWindow;
    import nl.igorski.lib.ui.forms.components.FormText;
    import nl.igorski.lib.ui.forms.components.Input;
    import nl.igorski.lib.ui.forms.components.Select;
    import nl.igorski.lib.ui.forms.components.RadioGroup;
    import nl.igorski.lib.ui.components.StdTextField;
    import nl.igorski.lib.ui.forms.components.SubmitButton;
    import nl.igorski.lib.ui.forms.components.TextArea;
    import nl.igorski.lib.ui.forms.components.interfaces.IFormElement;
    import nl.igorski.lib.ui.forms.components.interfaces.ITabbableFormElement;
    import nl.igorski.lib.utils.Destroyer;

    /**
     * the Base Form class, to be extended by each form you create. This class
     * includes basic validation ( just to check whether values have been entered according
     * to the values expected of the element type, you should write your own validation in
     * your sub class ), the Input fields may benefit from extra regular expression validations to
     * check their values against patterns. As it is, the real validation of forms extending this class
     * should be performed by the backend storing the data!!
     * ...
     * @author Igor Zinken
     */
    public class BaseForm extends Sprite implements IDestroyable
    {
        public static const CLOSE           :String = "BaseForm::CLOSE";

        public var feedback                 :FeedbackWindow;
        public var form                     :Array;
        public var formElements             :Vector.<DisplayObject>;
        public var margin                   :int = 10;
        public var labelMargin              :int = 0;
        public var inputMargin              :int = 200;
        public var showLabelInInputField    :Boolean = false;
        public var labelFieldBindings       :Vector.<Object>;
        public var _formWidth               :Number = 0;
        public var validated                :Boolean;

        public var p                        :Proxy;
        public var _transfer                :Boolean = false;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function BaseForm()
        {

        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function doSubmit( url:String, data:Array ):void
        {
            // prevent resubmitting while requests are being processed
            if ( _transfer )
                return;

            _transfer     = true;
            View.busy     = true;

            p             = new Proxy();

            /*
             * we declare the callback function here to
             * restore the application's busy state w/o
             * having to restate this in subclass overrides
             */
            p.send( url, data, function():void
            {
                _transfer = false;
                View.busy = false;
                handleResult();
            });
        }

        /*
         * collects the value of a given field name
         * regardless of return type
         */
        public function value( field:String ):*
        {
            var count:int = 0;
            for each ( var item:Object in form )
            {
                if ( item.name == field )
                {
                    switch( item.type )
                    {
                        case Input:
                        case TextArea:
                        case RadioGroup:
                        case Select:
                            return IFormElement( formElements[ count ]).val;
                            break;
                        case Checkbox:
                            return Checkbox( formElements[ count ]).numericVal;
                            break;
                    }
                }
                ++count;
            }
            return false;
        }

        public function getData():Array
        {
            var _data:Array = [];
            for ( var i:int = 0; i < form.length; ++i )
            {
                // collect all form values for the elements that can actually hold a value
                if ( formElements[i] is IFormElement )
                {
                    var data:Object = { name: form[i].name, value: value( form[i].name )};
                    _data.push( data );
                }
            }
            return _data;
        }

        public function array_merge( array:Array ):Array
        {
            var ret:Array = [];

            for each( var arr:Array in array )
            {
                for ( var i:int = 0; i < arr.length; ++i )
                    ret.push( arr[i] );
            }
            return ret;
        }

        public function showFeedback( text:String = "" ):void
        {
            if ( feedback == null )
                feedback = new FeedbackWindow();

            if ( !contains( feedback ))
                addChild( feedback );

            feedback.show( text );

            feedback.x = Math.round( ( _formWidth * .5 ) - ( feedback.width * .5 ) - 25 );
            feedback.y = Math.round( ( height * .5 ) - ( feedback.height * .5 ));

            feedback.addEventListener( FeedbackWindow.CLOSE, closeFeedback );
            setChildIndex( feedback, numChildren - 1 );
        }

        public function destroy():void
        {
            Destroyer.destroyDisplayList( this );
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        // override in subclass calling this as super
        protected function handleSubmit( e:MouseEvent ):void
        {
            validated = validate();
        }

        private function closeFeedback( e:Event ):void
        {
            feedback.removeEventListener( FeedbackWindow.CLOSE, closeFeedback );
            feedback.destroy();
            removeChild( feedback );
            feedback = null;
        }

        private function hideLabel( e:FocusEvent ):void
        {
            var obj:* = e.currentTarget;

            for each( var binding:Object in labelFieldBindings )
            {
                if ( binding.field == obj )
                {
                    if ( contains( binding.lbl ))
                        removeChild( binding.lbl );
                }
            }
        }

        private function finishClose( e:Event = null ):void
        {
            dispatchEvent( new Event( BaseForm.CLOSE ));
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        // override these in your sub class
        protected function handleResult():void
        {

        }

        protected function resetForm():void
        {
            while ( numChildren > 1 )
                removeChildAt( 0 );

            for each( var field:Object in formElements )
                field = null;

            formElements = null;
            buildForm();
        }

        protected function buildForm():void
        {
            var curY        :int = 0;
            var curTabIndex :int = 0;

            labelFieldBindings   = new Vector.<Object>;
            formElements         = new Vector.<DisplayObject>;

            for each ( var item:Object in form )
            {
                var formLabel:StdTextField = new StdTextField( Fonts.LABEL );

                if ( item.label != null )
                    formLabel.text = item.label;

                formLabel.x = labelMargin;
                formLabel.mouseEnabled =
                formLabel.tabEnabled   = false;

                if ( item.required )
                {
                    if ( formLabel.text.indexOf("*") == -1 )
                        formLabel.text += " *";
                }
                var element:*;

                switch( item.type )
                {
                    case Divider:
                        element = new Divider( item.width || ( inputMargin + 190 ), item.height || 18 );
                        break;

                    case Input:
                        element = new Input( item.placeHolderText || "", item.isSmall || false, item.isPassword || false, item.width || 190, item.height || 18 );
                        if ( showLabelInInputField )
                        {
                            formLabel.x = inputMargin + 5;
                            element.addEventListener( FocusEvent.FOCUS_IN, hideLabel, false, 0, true );
                            labelFieldBindings.push( { field: element, lbl: formLabel } );
                        }
                        break;

                    case TextArea:
                        element = new TextArea( item.placeHolderText || "", item.width || 190, item.height || 70 );
                        if ( showLabelInInputField )
                        {
                            formLabel.x = inputMargin + 5;
                            element.addEventListener( FocusEvent.FOCUS_IN, hideLabel, false, 0, true );
                            labelFieldBindings.push( { field: element, lbl: formLabel } );
                        }
                        break;

                    case Birthdate:
                        element = new Birthdate();
                        break;

                    case Checkbox:
                        element = new Checkbox( item.label );
                        break;

                    case RadioGroup:
                        element = new RadioGroup( item.label, item.options, item.maxWidth || 200 );
                        break;

                    case Select:
                        element = new Select( item.label, item.options, item.width || 190, item.height || 125 );
                        break;

                    case SubmitButton:
                        element = new SubmitButton( item.label );
                        element.addEventListener( MouseEvent.CLICK, handleSubmit, false, 0, true );
                        break;

                    case FormText:
                        element = new FormText( item.text );
                        break;

                    case null:
                        formLabel.y = curY;
                        curY = formLabel.y + margin;
                        break;
                }

                // calculate the position of the current object by it's type
                if ( element != null )
                {
                    formLabel.y = element.y = curY;

                    switch( item.type ) {
                        default:
                            element.x = inputMargin;
                            break;
                        case Divider:
                            element.x = labelMargin;
                            break;
                        case RadioGroup:
                            if ( item.options.length > 2 ) {
                                element.y += formLabel.height + margin;
                                element.x = formLabel.x;
                            } else {
                                element.x = inputMargin;
                            }
                            break;
                        case FormText:
                            element.x = formLabel.x;
                            break;
                        case SubmitButton:
                            formLabel.text = "";
                            element.y = curY -( 8 );
                            element.x = inputMargin;
                            break;
                    }
                    addChild( element );
                    addChild( formLabel );

                    // calculate the next Y position according to the current input type
                    switch( item.type )
                    {
                        default:
                            curY = ( element.y + 18 + margin );
                            break;
                        case TextArea:
                            curY = ( element.y + 75 + margin );
                            break;
                        case RadioGroup:
                        case FormText:
                            curY = ( element.y + element.height + margin );
                            break;
                    }
                    formElements.push( element );

                    if ( element is ITabbableFormElement ) {
                        element.tabIndex = curTabIndex;
                        curTabIndex      = element.tabIndex + 1;
                    }
                }
            }
            // here we set the Select elements as the highest children in the DisplayList
            // as they can overlap other form elements when they're opened
            for ( var i:int = formElements.length - 1; i > 0; --i )
            {
                if ( formElements[ i ] is Select )
                    swapChildren( formElements[ i ], getChildAt( numChildren - 1 ));
            }
            _formWidth = width;
        }

        protected function validate():Boolean
        {
            var count:int = 0;
            var error:Boolean = false;

            for each( var item:Object in form )
            {
                switch( item.type )
                {
                    case Input:
                    case TextArea:
                        if ( item.required ) {
                            var el:IFormElement = formElements[ count ] as IFormElement;
                            if ( el.val == "" )
                            {
                                el.doError();
                                error = true;
                            } else {
                                el.undoError();
                            }
                        } else {
                            el.undoError();
                        }
                        break;
                    case Checkbox:
                        if ( item.required )
                        {
                            el = formElements[ count ] as IFormElement;
                            if ( !el.val )
                            {
                                el.doError();
                                error = true;
                            } else {
                                el.undoError();
                            }
                        }
                        break;
                    case RadioGroup:
                        if ( item.required )
                        {
                            el = formElements[ count ] as IFormElement;

                            if ( el.val == "" )
                            {
                                el.doError();
                                error = true;
                            } else {
                                el.undoError();
                            }
                        } else {
                            el.undoError();
                        }
                        break;
                    case SubmitButton:
                        break;
                }
                ++count;
            }
            return !error;
        }

        protected function hideFeedback():void
        {
            feedback.hide();
        }

        protected function close():void
        {

        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

    }
}
