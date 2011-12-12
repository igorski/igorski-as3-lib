package nl.igorski.lib.utils.pagination
{
    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 09-12-11
     * Time: 21:43
     *
     * creates a series of numbered buttons for paging between large data lists
     * the pages are shown in a 3 4 .. 8 9 10 manner for easier overview and skipping
     */
    public class Pagination
    {
        private var _currentPage     :int;
        private var _buttonClass     :Class;
        private var _totalPages      :int;
        private var _items_per_page  :int;

        private var _buttons         :Vector.<IPaginatorButton>;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        /**
         *
         * @param currentPage   {int} number of the current page
         * @param totalPages    {int} amount of pages
         * @param itemsPerPage  {int} the max. amount of buttons in the paginator
         * @param buttonClass   {Class} the Class to use for the buttons, must implement
         *                      the IPaginatorButton interface
         */
        public function Pagination( currentPage:int = 0, totalPages:int = 0, itemsPerPage:int = 5, buttonClass:Class = null )
        {
            _currentPage    = currentPage;
            _buttonClass    = buttonClass;
            _totalPages       = Math.ceil( totalPages / itemsPerPage );
            _items_per_page = itemsPerPage;

            _buttons        = new <IPaginatorButton>[];

            if ( _totalPages > 1 )
                createButtons();
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /**
         * update the current paginator button list
         * @param currentPage   {int} number of the current page
         * @param totalPages    {int} amount of pages
         */
        public function update( currentPage:int = 0, totalPages:int = 0 ):void
        {
            destroyButtons();

             _currentPage   = currentPage;
            _totalPages     = totalPages;

            if ( _totalPages > 1 )
                createButtons();
        }
        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        public function get buttons():Vector.<IPaginatorButton>
        {
            return _buttons;
        }

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        protected function createButton( pageNum:int = 0, title:String = "", clickable:Boolean = true ):void
        {
            var theButton:IPaginatorButton = new _buttonClass();
            theButton.page                 = pageNum;
            theButton.title                = title;
            theButton.active               = !clickable;

            theButton.init();

            _buttons.push( theButton );
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        private function createButtons():void
        {
            // the amount of direct pages to show previous / next the current one
            var theStep:int = Math.ceil( _items_per_page * .5 ) - 1;

            // create stepped paginator
            var min:int = _currentPage - theStep;

            if ( min < 0 )
                min = 0;

            var max:int = min + _items_per_page;

            if ( max > _totalPages )
                max = _totalPages;

            if ( min > 0 )
            {
                if ( max - 1 < _totalPages + 1 )
                    ++min;

                if ( _totalPages > _items_per_page ) {
                    createButton( 0, "1..." );
                }
            }
            var doLast:Boolean = false;

            if ( max < _totalPages ) {
                --max;
                doLast = true;
            }
            else {

                if ( _currentPage == _totalPages - 1 )
                    min -= ( _totalPages + theStep ) - max;

                else if ( _currentPage == ( _totalPages - theStep ))
                    min -= ( _totalPages + 1 ) - max;

                if ( min < 0 )
                    min = 0;
            }

            for ( var i:int = min; i < max; ++i )
            {
                if ( i == _currentPage )
                    createButton( i, ( i + 1 ).toString(), false );
                else
                    createButton( i, ( i + 1 ).toString());
            }

            if ( doLast )
                createButton( _totalPages - 1, "..." + _totalPages );
        }

        private function destroyButtons():void
        {
            var i:int = _buttons.length;

            while ( i-- )
            {
                _buttons[ i ] = null;
                _buttons.splice( i, 1 );
            }
        }
    }
}
