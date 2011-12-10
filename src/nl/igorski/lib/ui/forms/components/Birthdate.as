package nl.igorski.lib.ui.forms.components
{
    import flash.display.Sprite;
    import flash.events.Event;

    import nl.igorski.lib.ui.forms.components.interfaces.IFormElement;
    import nl.igorski.lib.ui.forms.components.interfaces.ITabbableFormElement;

    /**
     * BirthDate is a work in progress and currently only formats
     * for mySQL date stamps ( Y-m-d format )
     *
     * @author Igor Zinken
     */
    public class Birthdate extends Sprite implements IFormElement, ITabbableFormElement
    {
        private var year    :Input;
        private var month   :Input;
        private var day     :Input;

        private var margin  :int = 5;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function Birthdate()
        {
            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function doError():void
        {
            year.doError();
            month.doError();
            day.doError();
        }

        public function undoError():void
        {
            year.undoError();
            month.undoError();
            day.undoError();
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        /*
         * dates must be in yyyy-mm-dd format
         */
        public function set val( value:* ):void
        {
            var date:Array = String( value ).split( "-" );

            year.val  = date[0];
            month.val = date[1];
            day.val   = date[2];
        }

        public function get val():*
        {
            return year.val + "-" + month.val + "-" + day.val;
        }

        override public function set tabIndex( value:int ):void
        {
            year.tabIndex  = value;
            month.tabIndex = ++value;
            day.tabIndex   = ++value;
        }

        override public function get tabIndex():int
        {
            // return last element's index
            return day.tabIndex;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function initUI(e:Event):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );
            draw();
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        protected function draw():void
        {
            year    = new Input();
            month   = new Input();
            day     = new Input();

            year.width  = month.width = day.width *= 0.31;
            month.x     = year.x + year.width + margin;
            day.x       = month.x + month.width + margin;

            addChild( year );
            addChild( month );
            addChild( day );
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
