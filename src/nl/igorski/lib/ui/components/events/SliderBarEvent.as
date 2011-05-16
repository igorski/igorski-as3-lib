package nl.igorski.lib.ui.components.events
{
	import flash.events.Event;
    /**
     * Project:    One Bar Loop
     * Package:    nl.igorski.ui.components.events
     * Class:      SliderEvent
     *
     *
     *
     * @author     igor.zinken@usmedia.nl
     * @version    0.1
     * @since      23-12-2010 10:23
    */	
	public class SliderBarEvent extends Event
	{
		public static const CHANGE	:String = 'SliderBarEvent::CHANGE';
		public var value			:Number;
        //_________________________________________________________________________________________________________________
        //                                                                                            C O N S T R U C T O R

		public function SliderBarEvent( type:String = CHANGE, newValue:Number = 0 ):void
		{
            value = newValue;
			super( type );
		}

        //_________________________________________________________________________________________________________________
        //                                                                                      P U B L I C   M E T H O D S

        //_________________________________________________________________________________________________________________
        //                                                                                  G E T T E R S  /  S E T T E R S

        //_________________________________________________________________________________________________________________
        //                                                                                      E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________________
        //                                                                                P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________________
        //                                                                                    P R I V A T E   M E T H O D S

	}
}
