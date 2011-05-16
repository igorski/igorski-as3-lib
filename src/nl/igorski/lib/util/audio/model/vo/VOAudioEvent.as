package nl.igorski.lib.util.audio.model.vo
{
    import nl.igorski.lib.util.audio.AudioSequencer;
    import nl.igorski.lib.util.audio.generators.AudioCache;
    import nl.igorski.lib.util.audio.generators.BufferGenerator;
    import nl.igorski.lib.util.audio.generators.waveforms.base.BaseWaveForm;
    import nl.igorski.lib.util.audio.helpers.IWaveCloner;

    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 12-04-11
     * Time: 19:47
     */
    public class VOAudioEvent
    {
        // the voice index ( in the AudioSequencer class ) used to
        // shape the timbre of the audio output
        public var voice        :int;

        // unique values to this event
        public var frequency    :Number;
        public var length       :Number;
        public var delta        :int;

        // the cached representation of this events
        // audio properties, used for output by the
        // Synthesizer class
        public var sample       :AudioCache;

        public var id           :String;

        public function VOAudioEvent( data:Object = null )
        {
            if ( data == null )
                return;

            for ( var i:* in data )
            {
                try {
                    this[ i ] = data[ i ];
                }
                catch ( e:Error )
                {
                    trace( "property " + i + " non-existent in VOAudioEvent" );
                }
            }
            // create unique identifier
            id = voice + ":" + frequency + "/" + length + "@" + delta;

            // start caching
            cache();
        }

        public function cache():void
        {
            // the 65536 and 16 show that this is hard-wired to
            // work within a sixteen-step sequencer constraint : TODO ?

            sample = new AudioCache(( 65536 * ( length / 16 )) + 0.5|0);

            var wave:BaseWaveForm = IWaveCloner.clone( AudioSequencer.getVoice( voice ));

            wave.frequency = frequency;
            wave.length    = length;

            // synthesize this event into audio
            while ( !sample.valid )
            {
                var cacheBuffer:Vector.<Vector.<Number>> = BufferGenerator.generate();
                wave.generate( cacheBuffer );
                sample.append( cacheBuffer );
            }
        }
    }
}
