package nl.igorski.lib.utils
{
    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.net.URLRequest;

    /*
     * another image loading facility, catches all errors and
     * after loading can function as the displayObject itself
     */
    public class LoadImage extends Sprite
    {
        public static const READY	:String = 'LoadImage::READY';
        public static const ERROR	:String = 'LoadImage::ERROR';

        private var loader			:Loader;
        private var _file			:String;
        private var _smoothing		:Boolean = true;
        private var _content		:Bitmap;
        private var _cacheAsBitmap	:Boolean = false;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function LoadImage( inFile:String, inSmoothing:Boolean = true, inCacheAsBitmap:Boolean = false ):void
        {
            _smoothing     = inSmoothing;
            _cacheAsBitmap = inCacheAsBitmap;
            _file = inFile;
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        public function load():void
        {
            loader = new Loader();
            addListeners( loader.contentLoaderInfo );
            loader.load( new URLRequest(_file) );
        }

        public function get():Bitmap
        {
            return _content;
        }

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function loadComplete( e:Event ):void
        {
            loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, loadComplete );
            _content = loader.content as Bitmap;
            _content.smoothing = _smoothing;
            _content.cacheAsBitmap = _cacheAsBitmap;
            removeListeners( loader.contentLoaderInfo );
            loader = null;
            dispatchEvent( new Event( READY ));
        }

        private function ioErrorHandler( e:IOErrorEvent ):void
        {
            removeListeners( loader.contentLoaderInfo );
            dispatchEvent( new Event( ERROR ));
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        private function addListeners( obj:IEventDispatcher ):void
        {
            obj.addEventListener( Event.COMPLETE, loadComplete, false, 0, true );
            obj.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true );
        }

        private function removeListeners( obj:IEventDispatcher ):void
        {
            obj.removeEventListener( Event.COMPLETE, loadComplete );
            obj.removeEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
        }
    }
}
