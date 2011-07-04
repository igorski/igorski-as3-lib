package nl.igorski.lib.ui.forms
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    import nl.igorski.lib.ui.forms.base.BaseForm;
    import nl.igorski.lib.View;
    import nl.igorski.lib.ui.forms.components.Checkbox;
    import nl.igorski.lib.ui.forms.components.Divider;
    import nl.igorski.lib.ui.forms.components.FormText;
    import nl.igorski.lib.ui.forms.components.Input;
    import nl.igorski.lib.ui.forms.components.RadioGroup;
    import nl.igorski.lib.ui.forms.components.Select;
    import nl.igorski.lib.ui.forms.components.SubmitButton;
    import nl.igorski.lib.ui.forms.components.TextArea;

    /**
     * ExampleForm demonstrates how to quickly build a form with all
     * available elements. In this example we simulate a much used
     * contact form.
     * ...
     * @author Igor Zinken
     */
    public class ExampleForm extends BaseForm
    {
        private var _serviceURL    :String = 'path/to/service';

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        /*
         * here we define the contents of the form Array
         *
         * each form elements is added as a object, the object parameter 'type' is required
         * as it specifies the formElement to create. Note that when an element that
         * allows user input is defined, the parameter 'name' is required so the form element
         * can be identified and it's value collected. The optional parameter 'label' creates
         * a label that precedes the input element in the form. The parameter 'required' specifies
         * whether this element requires a value ( note that for further validation such as regular
         * expression matching you can override the handleSubmit and validate methods )
         *
         * the additional parameters specified below are the argument names specified in the
         * formElements constructor function, note the 'options' array for radioGroups and
         * Select elements...
         *
         */
        public function ExampleForm()
        {
            form = [
                    { type: Input,      name: "name",   label: "Your name",   required: true },
                    { type: Input,      name: "email",  label: "Your e-mail", required: true },
                    { type: RadioGroup, name: "gender", label: "Your gender", required: true,
                      options: [{ value: "M", label: "Male" }, { value: "F", label: "Female" }]
                    },
                    { type: Select,    name: "subject", label: "Message subject:", required: true,
                      options: [{ value: "bug", label: "Bug report" }, { value: "feedback", label: "Feedback / suggestions" }]
                    },
                    { type: TextArea,     name: "message", label: "Your message:" },
                    { type: Divider,      width: 400 },
                    { type: FormText,     text: "Would you like to subscribe to our newsletter?:" },
                    { type: Checkbox,     label: "Yes, keep me updated" },
                    { type: SubmitButton, label: "Submit" }
                   ];

            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        override protected function handleSubmit( e:MouseEvent ):void
        {
            super.handleSubmit( e );
            switch( validated )
            {
                case true:
                    var data:Array = getData();
                    doSubmit( _serviceURL, data );
                   break;
                case false:
                    showErrors();
                    break;
            }
        }

        override protected function handleResult():void
        {
            _transfer         = false;
            var result:Object = p.getData();

            switch ( result.success )
            {
                default:
                case false:
                    showErrors();
                    break;
                case true:
                    resetForm();
                    showFeedback( 'Form sent' );
                    break;
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function initUI( e:Event ):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, initUI);
            buildForm();
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        private function showErrors():void
        {
            View.feedback( 'Make sure all mandatory fields and e-mail addresses are valid' );
        }
    }
}
