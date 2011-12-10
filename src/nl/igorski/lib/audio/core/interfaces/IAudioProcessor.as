package nl.igorski.lib.audio.core.interfaces
{
    import com.noteflight.standingwave3.elements.Sample;

    import nl.igorski.lib.audio.model.vo.VOAudioEvent;

    public interface IAudioProcessor
    {
        function synthesize( consolidateVoices:Boolean = true ):void
        function presynthesize( data:Vector.<Vector.<VOAudioEvent>> ):void

        function processBufferModifiers():void

        function get sample():Sample
        function clearTemporaryBuffers():void

        function addVoices( totalLength:int = 1 ):void
        function addEvent( vo:VOAudioEvent, voiceNum:int ):void
        function invalidateCache( aVoice:int = -1, invalidateChildren:Boolean = false, immediateFlush:Boolean = false, recacheChildren:Boolean = true, destroyOldCache:Boolean = false ):void
    }
}
