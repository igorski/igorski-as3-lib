package nl.igorski.lib.models
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.utils.ByteArray;

    import flash.utils.clearInterval;
    import flash.utils.setInterval;

    import nl.igorski.lib.View;

    /*
     * Proxy is the default remoting method used in the nl.igorski... framework
     * this method handles all nl.igorski.lib.ui.forms requests as POST data
     * for use with a web server
     *
     * the web server's responses are by default returned as JSON objects ( for
     * use in a wide range of frontend technologies ), feel free to override the
     * formatData function for your own purposes / return types ( XML, AMF, etc. )
     *
     * HOWEVER: as the JSON decoding utilizes the as3corelib serialization methods it
     * has been uncommented here, you can get it at Mike Chamber's gitHub
     *
     * you can use Proxy as a single class for each of your applications models
     * or instantiate several versions for asynchronous calls
     *
     */
    public class Proxy extends EventDispatcher
    {
        private var _url                    :String = '';
        private var _data                   :*;

        private static const MAX_TIMEOUT    :int = 10000;
        private var _timeout                :uint;
        private var _callback               :Function;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        /*
         * @url String location of the remoting service to
         *      communicate with, this can be a script location
         *      or a method within a MVC framework
         */
        public function Proxy( url:String = null ):void
        {
            if ( url != null )
                _url = url;
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        /*
         * load data from an external location
         *
         * @url      String location of either a external file or the path
         *           to a script / MVC method, will default to location set in constructor
         * @callback Function to call after this request receives a result from the server
         */
        public function load( url:String = null, callback:Function = null ):void
        {
            if ( url == null )
                url = _url;

            _callback = callback;

            var loader:URLLoader    = new URLLoader();
            var request:URLRequest  = new URLRequest();
            request.url             = url;

            addListeners( loader );

            setTimeoutHandler();
            loader.load( request );
        }

        /*
         * send a post request
         *
         * @url         String location of the remote location to post data to, when null will default to constructor's URL
         * @data        Array containing objects with "name" ( fieldname ) and "value" ( value, int/float/string/bytearray )
         * @callback    Function to call after this request receives a result from the server
         *
         */
        public function send( url:String, data:Array, callback:Function ):void
        {
            if ( url == null )
                url = _url;

            _callback = callback;

            var request:URLRequest       = new URLRequest( url );
            var requestVars:URLVariables = new URLVariables();

            for each ( var i:Object in data )
            {
                if ( i.type != null && i.type == ByteArray )
                {
                    // empty
                } else {
                    requestVars[ i.name ] = i.value;
                }
            }
            request.data = requestVars;
            request.method = URLRequestMethod.POST;

            var loader:URLLoader = new URLLoader();
            addListeners( loader );

            setTimeoutHandler();
            loader.load( request );
        }

        /*
         * called to retrieve the data returned by the remote service
         */
        public function getData():Object
        {
            return _data;
        }

        /*
         * called by superclass to store data called by
         * the overwritten formatData method
         */
        public function setData( value:Object ):void
        {
            _data = value;
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function handleResult( e:Event ):void
        {
            clearInterval( _timeout );

            formatData( URLLoader( e.target ).data );
            removeListeners( URLLoader( e.target ));

            /* run the callback function if registered
             * else we dispatch a complete event to objects listening
             */
            if ( _callback != null )
                _callback();
            else
                dispatchEvent( new Event( Event.COMPLETE ));
        }

        protected function httpStatusHandler( e:HTTPStatusEvent ):void
        {
            /*
             * if the status is 200 we clear the timeout interval
             * ( in case we're sending large byteArrays )
             */
            if( e.status == 200 ) {
                clearInterval( _timeout );
            } else {
                trace( "Proxy::status " + e.status + " occured." );
                handleRemotingError();
            }
        }

        protected function securityErrorHandler( e:SecurityErrorEvent ):void
        {
            trace( "Proxy::error " + e.type + " occured." );
            handleRemotingError();
        }

        protected function ioErrorHandler( e:IOErrorEvent ):void
        {
            trace( "Proxy::error " + e.type + " occured." );
            handleRemotingError();
        }

        /*
         * if the external server is down, we prevent eternal waits ( and possible
         * application lockups ) by only waiting for a set amount of time
         */
        protected function setTimeoutHandler():void
        {
            _timeout = setInterval( handleRemotingTimeout, MAX_TIMEOUT );
        }

        protected function handleRemotingTimeout():void
        {
            handleRemotingError();
        }

        protected function handleRemotingError():void
        {
            clearInterval( _timeout );

            View.busy = false;
            View.feedback( "a remoting error has occured. Please try again" );
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        /*
         * format the service's response into
         * an object type of your choice, by default JSON, you may
         * override this in your sub class
         */
        protected function formatData( result:* ):void
        {
            //_data = JSON.decode( result ); // com.adobe.serialization.json required!
            _data = result;
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        /*
         * these essentially catch all errors that might occur
         * during transfer / request
         */
        private function addListeners( loader:URLLoader ):void
        {
            loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
            loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
            loader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
            loader.addEventListener( Event.COMPLETE, handleResult );
        }

        private function removeListeners( loader:URLLoader ):void
        {
            loader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
            loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
            loader.removeEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
            loader.removeEventListener( Event.COMPLETE, handleResult );
        }
    }
}
