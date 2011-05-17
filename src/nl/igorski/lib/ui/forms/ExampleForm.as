package nl.igorski.lib.ui.forms
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    import nl.igorski.lib.ui.forms.base.BaseForm;
    import nl.igorski.lib.View;
    import nl.igorski.lib.ui.forms.components.Input;
    import nl.igorski.lib.ui.forms.components.RadioGroup;
    import nl.igorski.lib.ui.forms.components.SubmitButton;
    import nl.igorski.lib.ui.forms.components.TextArea;

    /**
     * ...
     * @author Igor Zinken
     */
    public class ExampleForm extends BaseForm
    {
        private var _url	    	:String = 'path/to/service';

        public function ExampleForm()
        {
            form = [
                    [ 'name',        'Your name',        Input, true ],
                    [ 'email',       'Your e-mail',      Input, true, [ [ 'M','Male'],
                                                                        [ 'F','Female']]],
                    [ 'gender',      'Your gender',      RadioGroup, true ],
                    [ 'message',     'Your message',     TextArea, true ],
                    [ '', 'Submit', SubmitButton ]
                   ];

            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        private function initUI( e:Event ):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, initUI);
            buildForm();
        }

        override public function handleSubmit( e:MouseEvent ):void
        {
            super.handleSubmit( e );
            switch( validated )
            {
                case true:
                    var data:Array = getData();
                    doSubmit( _url, data );
                   break;
                case false:
                    showErrors();
                    break;
            }
        }

        override public function handleResult( e:Event ):void
        {
            _transfer = false;
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

        private function showErrors():void
        {
            View.feedback( 'Make sure all mandatory fields and e-mail addresses are valid' );
        }
    }
}
