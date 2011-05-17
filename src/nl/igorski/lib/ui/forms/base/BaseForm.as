package nl.igorski.lib.ui.forms.base
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;

    import nl.igorski.definitions.OBLFonts;
    import nl.igorski.lib.View;
    import nl.igorski.lib.models.Proxy;
    import nl.igorski.lib.ui.forms.components.Birthdate;
    import nl.igorski.lib.ui.forms.components.Checkbox;
    import nl.igorski.lib.ui.forms.components.Divider;
    import nl.igorski.lib.ui.components.FeedbackWindow;
    import nl.igorski.lib.ui.forms.components.FormText;
    import nl.igorski.lib.ui.forms.components.Input;
    import nl.igorski.lib.ui.forms.components.PullDown;
    import nl.igorski.lib.ui.forms.components.RadioGroup;
    import nl.igorski.views.components.StdTextField;
    import nl.igorski.lib.ui.forms.components.SubmitButton;
    import nl.igorski.lib.ui.forms.components.TextArea;

    /**
     * the Base Form class, to be extended by each form you create. This class
     * includes basic validation ( just to check whether values have been entered ), the Input
     * fields may benefit from extra regular expression validations to check their values
     * against patterns. As it is, the real validation of forms extending this class should be
     * performed by the backend storing the data!!
     * ...
     * @author Igor Zinken
     */
    public class BaseForm extends Sprite
    {
        public static const CLOSE		:String = 'BaseForm::CLOSE';

        public var feedback				:FeedbackWindow;
        public var form					:Array;
        public var formObjects			:Array;
        public var margin				:int = 10;
        public var labelMargin			:int = 200;
        public var inputMargin			:int = 0;
        public var validated			:Boolean;

        public var p					:Proxy;

        public var _transfer			:Boolean = false;
        public var labelInfield			:Boolean = true;		// whether labels are displayed inside input fields
        public var labelFieldBindings	:Array;

        public var _formWidth			:Number = 0;

        public function BaseForm()
        {

        }

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

        public function handleResult():void
        {
            // override in subclass
        }

        public function buildForm():void
        {
            var curY:int = 0;

            labelFieldBindings = [];
            formObjects = [];

            for each ( var item:Array in form )
            {
                var formLabel:StdTextField = new StdTextField( OBLFonts.DEFAULT );
                formLabel.text = item[1];
                formLabel.x = labelMargin;
                formLabel.mouseEnabled = false;
                if ( item[ 3 ] )
                {
                    if ( formLabel.text.indexOf("*") == -1 )
                        formLabel.text += " *";
                }
                var input:*;

                switch( item[2] )
                {
                    case Divider:
                        input = new Divider(18, 200);
                        break;
                    case Input:
                        input = new Input();
                        if ( labelInfield )
                        {
                            formLabel.x = inputMargin + 5;
                            input.addEventListener( FocusEvent.FOCUS_IN, hideLabel );
                            labelFieldBindings.push( { field: input, lbl: formLabel } );
                        }
                        break;
                    case TextArea:
                        input = new TextArea();
                        if ( labelInfield )
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
                        input = new Checkbox(item[1]);
                        break;
                    case RadioGroup:
                        input = new RadioGroup(item[1], item[4]);
                        break;
                    case PullDown:
                        input = new PullDown(item[1], item[4]);
                        break;
                    case SubmitButton:
                        input = new SubmitButton(item[1]);
                        input.addEventListener( MouseEvent.CLICK, handleSubmit );
                        break;
                    case FormText:
                        input = new FormText(item[1]);
                        break;
                    case null:
                        formLabel.y = curY;
                        curY = formLabel.y + margin;
                        break;
                }

                if ( input != null )
                {
                    formLabel.y = input.y = curY;

                    switch( item[2] ) {
                        default:
                            input.x = inputMargin;
                            break;
                        case Divider:
                            input.x = 3;
                            break;
                        case RadioGroup:
                            if (item[4].length > 2) {
                                input.y += formLabel.height + margin;
                                input.x = formLabel.x;
                            } else {
                                input.x = inputMargin;
                            }
                            break;
                        case FormText:
                            input.x = formLabel.x;
                            removeChild(formLabel);
                            break;
                        case SubmitButton:
                            formLabel.text = '';
                            input.y = curY -( 8 );
                            input.x = inputMargin;
                            break;
                    }

                    addChild( input );
                    addChild( formLabel );

                    switch( item[2] )
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
                    formObjects.push( input );
                }
            }
            _formWidth = width;
        }

        public function resetForm():void
        {
            while ( numChildren > 1 )
                removeChildAt( 0 );
            for each( var field:* in formObjects )
                field = null;

            formObjects = null;
            buildForm();
        }

        public function handleSubmit( e:MouseEvent ):void
        {
            validated = validate();
            // override in subclass calling this as super
        }

        public function validate():Boolean
        {
            var count:int = 0;
            var error:Boolean = false;

            for each( var item:Array in form )
            {
                switch(item[2]) {
                    case Input:
                    case TextArea:
                        if ( item[3] ) {
                            if (formObjects[count].val == '')
                            {
                                formObjects[count].doError();
                                error = true;
                            } else {
                                formObjects[count].undoError();
                            }
                        } else {
                            formObjects[count].undoError();
                        }
                        break;
                    case Checkbox:
                        if ( item[3] ) {
                            if ( !Checkbox( formObjects[count] ).val )
                            {
                                formObjects[count].doError();
                                error = true;
                            } else {
                                formObjects[count].undoError();
                            }
                        }
                        break;
                    case RadioGroup:
                        if ( item[3] ) {
                            if ( RadioGroup( formObjects[count] ).val == "")
                            {
                                formObjects[count].doError();
                                error = true;
                            } else {
                                formObjects[count].undoError();
                            }
                        } else {
                            formObjects[count].undoError();
                        }
                        break;
                    case SubmitButton:
                        break;
                }
                ++count;
            }
            switch( error )
            {
                case true:
                    return false;
                    break;
                case false:
                    return true;
                    break;
            }
            return false;
        }

        /*
         * collects the value of a given field name
         * regardless of return type
         */
        public function value( field:String ):*
        {
            var count:int = 0;
            for each ( var item:Array in form )
            {
                if (item[0] == field) {
                    switch( item[2] )
                    {
                        case Input:
                        case TextArea:
                            return formObjects[count].val;
                            break;
                        case Checkbox:
                            return Checkbox( formObjects[count] ).numericVal;
                            break;
                        case RadioGroup:
                        case PullDown:
                            return formObjects[count].val;
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
            for each( var item:Array in form )
            {
                if ( item[2] != SubmitButton && item[2] != Divider && item[2] != FormText )
                {
                    var data:Object = { name: item[0], value: value( item[0] ) };
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

        public function hideFeedback():void
        {
            feedback.hide();
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

        public function close():void
        {

        }

        private function finishClose( e:Event = null ):void
        {
            dispatchEvent( new Event( BaseForm.CLOSE ));
        }
    }
}
