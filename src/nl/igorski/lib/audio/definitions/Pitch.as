package nl.igorski.lib.audio.definitions
{
    public class Pitch
    {
        /**
         * static class containing definitions that contain musical note-specific frequencies
         * 
         * Created by IntelliJ IDEA.
         * User: igor.zinken
         * Date: 20-dec-2010
         * Time: 13:16:28
         */

        /**
         *  initial variables set @ 4th octave where "middle C" resides
         *  these are used for calculating requested notes, we differentiate
         *  between whole-notes and enharmonic notes by using 'sharp' ( while
         *  these might not be "musically correct" in regard to scales and theory,
         *  the returned frequencies are the same!
         *
         *  note: we calculate from the 4th octave as way of moving from "center"
         *  pitches outward ( to lower / higher ranges ) as the changes in Hz feature
         *  slight deviations, which would become more apparent by calculating powers of n.
          */
        public static const C               :Number = 261.626;
        public static const Csharp          :Number = 277.183;
        public static const D               :Number = 293.665;
        public static const Dsharp          :Number = 311.127;
        public static const E               :Number = 329.628;
        public static const F               :Number = 349.228;
        public static const Fsharp          :Number = 369.994;
        public static const G               :Number = 391.995;
        public static const Gsharp          :Number = 415.305;
        public static const A               :Number = 440;
        public static const Asharp          :Number = 466.164;
        public static const B               :Number = 493.883;

        public static const OCTAVE          :Array = [ C, Csharp, D, Dsharp, E, F, Fsharp, G, Gsharp, A, Asharp, B ];
        public static const OCTAVE_SCALE    :Array = [ "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" ];

        public static const FLAT            :String = 'b';
        public static const SHARP           :String = '#';
        
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function Pitch() {
        }

        //_________________________________________________________________________________________________________
        //                                                                                              P U B L I C

        /**
         * @param note - musical note to return ( A, B, C, D, E, F, G with
         *               possible enharmonic notes ( 'b' meaning 'flat', '#' meaning 'sharp' )
         *               NOTE: flats are CASE sensitive ( to prevent seeing the note 'B' instead of 'b' )
         * @param octave - the octave to return ( acceptated range 0 - 9 )
         * @return Number containing exact frequency in Hz for requested note
         */
        public static function note( aNote:String = 'C', aOctave:int = 4 ):Number
        {
            var f           :Number;
            var i           :int = 0;
            var freq        :Number;
            var enharmonic  :int = 0;

            // detect flat enharmonic
            i = aNote.indexOf( FLAT );
            if ( i > -1 )
            {
                aNote = aNote.substr( i - 1, 1 );
                enharmonic = -1;
            }
            // detect sharp enharmonic
            i = aNote.indexOf( SHARP );
            if ( i > -1 )
            {
                aNote = aNote.substr( i - 1, 1 );
                enharmonic = 1;
            }
            freq = getOctaveIndex( aNote, enharmonic );
            
            if ( aOctave == 4 )
            {
                return freq;
            }
            else
            {
                // translate the pitches to the requested octave
                var d:int = aOctave - 4;
                var j:int = Math.abs( d );
                for ( i = 0; i < j; ++i )
                {
                    d > 0 ? freq *= 2 : freq *= .5;
                }
                return freq;
            }
        }

        //_________________________________________________________________________________________________________
        //                                                                        G E T T E R S   /   S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S

        /**
         * retrieves the index in the octave array for a given note
         * modifier enharmonic returns the previous ( for a 'flat' note )
         * or next ( for a 'sharp' note ) index
         *  
         * @param note ( A, B, C, D, E, F, G )
         * @param enharmonic ( 0, -1 for flat, 1 for sharp )
         * @return
         */
        private static function getOctaveIndex( note:String, enharmonic:int = 0 ):int
        {
            for ( var i:int = 0, j:int = OCTAVE.length; i < j; ++i )
            {
                if ( OCTAVE_SCALE[ i ] == note )
                {
                    var k:int = i + enharmonic;
                    if ( k > j ) return OCTAVE[0];
                    if ( k < 0 ) return OCTAVE[ OCTAVE.length - 1 ];
                    return OCTAVE[k];
                }
            }
            return NaN;
        }
    }
}
