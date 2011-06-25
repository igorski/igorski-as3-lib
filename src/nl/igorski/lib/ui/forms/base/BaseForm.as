package nl.igorski.lib.ui.forms.base
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;

    import nl.igorski.lib.View;
    import nl.igorski.lib.definitions.Fonts;
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
    public class BaseForm extends Sprite
    {
        public static const CLOSE           :String = "BaseForm::CLOSE";

        public var feedback                 :FeedbackWindow;
        public var form                     :Array;
        public var formElements             :Array;
        public var margin                   :int = 10;
        public var labelMargin              :int = 0;
        public var inputMargin              :int = 200;
        public var showLabelInInputField    :Boolean = false;
        public var labelFieldBindings       :Array;
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
                            return formElements[count].val;
                            break;
                        case Checkbox:
                            return Checkbox( formElements[count] ).numericVal;
                            break;
                        case RadioGroup:
                        case Select:
                            return formElements[count].val;
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
            for each( var item:Object in form )
            {
                // collect all form values for the elements that can actually hold a value
                if ( item.type != SubmitButton && item.type != Divider && item.type != FormText )
                {
                    var data:Object = { name: item.name, value: value( item.name ) };
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

        public function showFeedback( inText:String = '' ):void
        {
            if ( feedback == null )
                feedback = new FeedbackWindow();

            if ( !contains( feedback ))
                addChild( feedback );

            feedback.show( inText );

            feedback.x = Math.round( ( _formWidth * .5 ) - ( feedback.width * .5 ) - 25 );
            feedback.y = Math.round( ( height * .5 ) - ( feedback.height * .5 ));

            feedback.addEventListener( FeedbackWindow.CLOSE, closeFeedback );
            setChildIndex( feedback, numChildren - 1 );
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

            for each( var field:* in formElements )
                field = null;

            formElements = null;
            buildForm();
        }

        protected function buildForm():void
        {
            var curY        :int = 0;
            var curTabIndex :int = 0;

            labelFieldBindings   = [];
            formElements         = [];

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
                var input:*;

                switch( item.type )
                {
                    case Divider:
                        input = new Divider( item.width || ( inputMargin + 190 ), item.height || 18 );
                        break;
                    case Input:
                        input = new Input( item.placeHolderText || "", item.isSmall || false, item.isPassword || false, item.width || 190, item.height || 18 );
                        if ( showLabelInInputField )
                        {
                            formLabel.x = inputMargin + 5;
                            input.addEventListener( FocusEvent.FOCUS_IN, hideLabel );
                            labelFieldBindings.push( { field: input, lbl: formLabel } );
                        }
                        break;
                    case TextArea:
                        input = new TextArea( item.placeHolderText || "", item.width || 190, item.height || 70 );
                        if ( showLabelInInputField )
                        {
                            formLabel.x = inputMargin + 5;
                            input.addEventListener( FocusEvent.FOCUS_IN, hideLabel );
                            labelFieldBindings.push( { field: input, lbl: formLabel } );
                        }
                        break;
                    case Birthdate:
                        input = new Birthdate();
                        break;
                    case Checkbox:
                        input = new Checkbox( item.label );
                        break;
                    case RadioGroup:
                        input = new RadioGroup( item.label, item.options, item.maxWidth || 200 );
                        break;
                    case Select:
                        input = new Select( item.label, item.options, item.width || 190, item.height || 125 );
                        break;
                    case SubmitButton:
                        input = new SubmitButton( item.label );
                        input.addEventListener( MouseEvent.CLICK, handleSubmit );
                        break;
                    case FormText:
                        input = new FormText( item.label );
                        break;
                    case null:
                        formLabel.y = curY;
                        curY = formLabel.y + margin;
                        break;
                }

                // calculate the position of the current object by it's type
                if ( input != null )
                {
                    formLabel.y = input.y = curY;

                    switch( item.type ) {
                        default:
                            input.x = inputMargin;
                            break;
                        case Divider:
                            input.x = labelMargin;
                            break;
                        case RadioGroup:
                            if ( item.options.length > 2 ) {
                                input.y += formLabel.height + margin;
                                input.x = formLabel.x;
                            } else {
                                input.x = inputMargin;
                            }
                            break;
                        case FormText:
                            input.x = formLabel.x;
                            break;
                        case SubmitButton:
                            formLabel.text = "";
                            input.y = curY -( 8 );
                            input.x = inputMargin;
                            break;
                    }
                    addChild( input );
                    addChild( formLabel );

                    // calculate the next Y position according to the current input type
                    switch( item.type )
                    {
                        default:
                            curY = ( input.y + 18 + margin );
                            break;
                        case TextArea:
                            curY = ( input.y + 75 + margin );
                            break;
                        case RadioGroup:
                        case FormText:
                            curY = ( input.y + input.height + margin );
                            break;
                    }
                    formElements.push( input );
                }
                input.tabIndex = curTabIndex;
                curTabIndex    = input.tabIndex + 1;
            }
            // here we set the Select elements as the highest children in the DisplayList
            // as they can overlap other form elements when they're opened
            for ( var i:int = formElements.length - 1; i > 0; --i )
            {
                if ( formElements[i] is Select )
                    swapChildren( formElements[i], getChildAt( numChildren - 1 ));
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
                            if (formElements[count].val == '')
                            {
                                formElements[count].doError();
                                error = true;
                            } else {
                                formElements[count].undoError();
                            }
                        } else {
                            formElements[count].undoError();
                        }
                        break;
                    case Checkbox:
                        if ( item.required ) {
                            if ( !Checkbox( formElements[count] ).val )
                            {
                                formElements[count].doError();
                                error = true;
                            } else {
                                formElements[count].undoError();
                            }
                        }
                        break;
                    case RadioGroup:
                        if ( item.required ) {
                            if ( RadioGroup( formElements[count] ).val == "" )
                            {
                                formElements[count].doError();
                                error = true;
                            } else {
                                formElements[count].undoError();
                            }
                        } else {
                            formElements[count].undoError();
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
