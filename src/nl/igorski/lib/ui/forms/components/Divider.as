package nl.igorski.lib.ui.forms.components
{
    import flash.display.GradientType;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix;

    /**
     * Divider simply adds a line break between form elements
     * ...
     * @author Igor Zinken
     */
    public class Divider extends Sprite
    {
        private var _width   :int;
        private var _height  :int;
        private var line     :Sprite;

        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function Divider( width:int = 100, height:int = 1 )
        {
            _height = height;
            _width  = width;

            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function initUI( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );
            draw();
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        // override in subclass for custom skinning
        protected function draw():void
        {
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox( _width, 1, 0, 0, 0 );

            line = new Sprite();
            with( line.graphics )
            {
                lineStyle( 1 );
                lineGradientStyle( GradientType.LINEAR, [0xFFFFFF, 0x666666], [0.65, 0.65], [0, 255], matrix );
                lineTo( _width, 0 );
            }
            line.y = _height * .5;

            tabEnabled = false;

            addChild( line );
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
