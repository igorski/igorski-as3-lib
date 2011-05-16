package nl.igorski.lib.util.audio.modifiers
{
    import nl.igorski.lib.util.audio.AudioSequencer;
    import nl.igorski.lib.util.audio.core.interfaces.IModifier;
    
	public class MoogFilter implements IModifier
    {
		//---------------------------------------------------------------------
		//
		//  Variables
		//
		//---------------------------------------------------------------------
		
		private var cutoff : Number;
		private var res : Number;
		private var fs : Number = AudioSequencer.SAMPLE_RATE;

		private var x : Number;
		private var y1 : Number;
		private var y2 : Number;
		private var y3 : Number;
		private var y4 : Number;
		private var oldx : Number;
		private var oldy1 : Number;
		private var oldy2 : Number;
		private var oldy3 : Number;
		private var f : Number;
		private var p : Number;
		private var k : Number;
		private var t : Number;
		private var t2 : Number;
		private var r : Number;

		
		//---------------------------------------------------------------------
		//
		//  Constructor
		//
		//---------------------------------------------------------------------
		
		public function MoogFilter( cutoffFrequency : Number = 8000, resonance : Number = Math.SQRT2 )
        {
			cutoff = cutoffFrequency;
			res = resonance;
			
			init( );
		}


		//---------------------------------------------------------------------
		//
		//  Private methods
		//
		//---------------------------------------------------------------------
		
		private function init( ) : void {
			y1 = y2 = y3 = y4 = oldx = oldy1 = oldy2 = oldy3 = 0;
			calc( );
		}

		private function calc( ) : void {
			f = cutoff * 2 / fs; 
			p = f * ( 1.8 - 0.8 * f );
			k = p + p - 1;
			
			t = ( 1 - p ) * 1.386249;
			t2 = 12 + t * t;
			r = res * ( t2 + 6 * t ) / ( t2 - 6 * t );
		}

		
		//---------------------------------------------------------------------
		//
		//  Public methods
		//
		//---------------------------------------------------------------------
        
        public function getData():Object
        {
            var data:Object = { };
            data.cutoff    = cutoff;
            data.resonance = resonance;
            
            return data;
        }
		
		public function process( input:Number ):Number
        {
			// process input
			x = input - r * y4;
			
			//Four cascaded onepole filters (bilinear transform)
			y1 = x * p + oldx * p - k * y1;
			y2 = y1 * p + oldy1 * p - k * y2;
			y3 = y2 * p + oldy2 * p - k * y3;
			y4 = y3 * p + oldy3 * p - k * y4;
			
			//Clipper band limited sigmoid
			y4 -= ( y4 * y4 * y4 ) / 6;
			
			oldx = x; 
			oldy1 = y1; 
			oldy2 = y2; 
			oldy3 = y3;
			
			return y4;
		}

		public function set cutoffFrequency( frequency : Number ):void
        {
			if ( frequency <= 0 || frequency > fs * .5 )
                frequency = fs * .5 - 1;
            
            cutoff = frequency;
			calc();
		}

		public function get cutoffFrequency():Number
        {
			return cutoff;
		}

		public function set resonance( resonance:Number ):void
        {
			if ( resonance < 0.1 || resonance > Math.SQRT2 )
                resonance = 0.1;
			res = resonance;
			calc();
		}

		public function get resonance():Number
        {
			return res;
		}
	}
}