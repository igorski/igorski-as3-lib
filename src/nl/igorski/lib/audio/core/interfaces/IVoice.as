package nl.igorski.lib.audio.core.interfaces
{
    public interface IVoice
    {
        function synthesize( buffer:Vector.<Vector.<Number>> ):void;
    }
}
