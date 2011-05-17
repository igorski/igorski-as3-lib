package nl.igorski.views.forms.base
{
import nl.igorski.lib.View;
import nl.igorski.lib.ui.forms.base.BaseForm;

    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 17-05-11
     * Time: 22:38
     */
    public class BaseOBLForm extends BaseForm
    {
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R
        public function BaseOBLForm() {
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S
        override public function doSubmit( url:String, data:Array ):void
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

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

    }
}
