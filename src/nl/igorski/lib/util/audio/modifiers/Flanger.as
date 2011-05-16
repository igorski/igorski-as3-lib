package nl.igorski.lib.util.audio.modifiers
{
    import nl.igorski.lib.util.audio.core.interfaces.IModifier;
	/**
	 * @author Antti Kupila
	 */
	public class Flanger implements IModifier
    {	
		//---------------------------------------------------------------------
		//
		//  Variables
		//
		//---------------------------------------------------------------------
		
		private var _feedback : Number;
		private var _delay : Number;
		private var _length : Number;
		
		private var offset : Number;
		
		private var i : int = 0;
		
		private var buffer : Vector.<Number>;
		
		
		//---------------------------------------------------------------------
		//
		//  Constructor
		//
		//---------------------------------------------------------------------
		
		public function Flanger( length : int = 17600, delay : Number = 880, feedback : Number = 0.7 ) {
			_feedback = feedback;
			_delay = delay;
			this.length = length;
		}
		
		
		//---------------------------------------------------------------------
		//
		//  Public methods
		//
		//---------------------------------------------------------------------
        
        public function getData():Object
        {
            var data:Object = { };
            data.length     = length;
            data.delay      = delay;
            data.feedback   = feedback;
            
            return data;
        }
		
		public function process( input:Number ):Number
        {
			offset = i - delay;
			if ( offset < 0 ) offset += _length;
			
			var index0 : int = int( offset ),
				index_1 : int = index0 - 1,
				index1 : int = index0 + 1,
				index2 : int = index0 + 2;
				
			if ( index_1 < 0 ) index_1 = _length - 1;
			if ( index1 >= _length ) index1 = 0; 
			if ( index2 >= _length ) index2 = 0; 
			
			var y_1 : Number = buffer[ index_1 ],
				y0 : Number = buffer[ index0 ],
				y1 : Number = buffer[ index1 ],
				y2 : Number = buffer[ index2 ];
				
			var x : Number = offset - index0;
				
			var c0 : Number = y0,
				c1 : Number = 0.5 * ( y1 - y_1 ),
				c2 : Number = y_1 - 2.5 * y0 + 2 * y1 - 0.5 * y2,
				c3 : Number = 0.5 * ( y2 - y_1 ) + 1.5 * ( y0 - y1 );
				
			var output : Number = ( ( c3 * x + c2 ) * x + c1 ) * x + c0;
			
			buffer[ i ] = input + output * feedback;
			
			if ( ++i == _length ) i = 0;
			
			return output;
		}
		
		public function get feedback() : Number {
			return _feedback;
		}
		
		public function set feedback(feedback : Number) : void {
			_feedback = feedback;
		}
		
		public function get delay() : Number {
			return _delay;
		}
		
		public function set delay(delay : Number) : void {
			_delay = delay;
		}
		
		public function get length() : Number {
			return _length;
		}
		
		public function set length(length : Number) : void
        {
			_length = length;
			buffer = new Vector.<Number>( _length, true );
		}
	}
}
