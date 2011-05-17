package nl.igorski.lib.ui.forms.components
{
    import flash.display.Sprite;
    import flash.events.Event;

    import nl.igorski.lib.ui.forms.components.interfaces.IFormElement;

    /**
     * BirthDate is a work in progress and currently only formats
     * for mySQL date stamps ( Y-m-d format )
     *
     * @author Igor Zinken
     */
    public class Birthdate extends Sprite implements IFormElement
    {

        private var year    :Input = new Input();
        private var month   :Input = new Input();
        private var day     :Input = new Input();

        private var margin  :int = 5;

        public function Birthdate()
        {
            addEventListener(Event.ADDED_TO_STAGE, initUI);
        }

        private function initUI(e:Event):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );

            year.width = month.width = day.width *= 0.31;
            month.x = year.x + year.width + margin;
            day.x = month.x + month.width + margin;

            addChild( year );
            addChild( month );
            addChild( day );
        }

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
    }
}
