﻿package nl.igorski.lib.ui.components
{
    import flash.display.Sprite;

    /**
     * ...
     * @author Igor Zinken
     */
    public class ScrollHandle extends Sprite
    {
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function ScrollHandle()
        {
            initUI();
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        private function initUI():void
        {
            draw();
        }

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        // override in subclass for custom skinning
        protected function draw():void
        {
            with( graphics )
            {
                beginFill( 0x000000, 1 );
                drawRect( 0, 0, 10, 50 );
                endFill();
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

    }
}
