package nl.igorski.lib.audio.core.interfaces
{
    import nl.igorski.lib.audio.model.vo.VOAudioEvent;

    public interface IVoice
    {
        function synthesize( buffer:Vector.<Vector.<Number>> ):void;
        function presynthesize( data:Vector.<Vector.<VOAudioEvent>> ):void

        function addVoices( totalLength:int = 1 ):void
        function addEvent( vo:VOAudioEvent, voiceNum:int ):void
        function invalidateCache( aVoice:int = -1, invalidateChildren:Boolean = false, immediateFlush:Boolean = false, recacheChildren:Boolean = true ):void
    }
}
