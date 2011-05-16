package nl.igorski.lib.util.audio.core.interfaces
{
    public interface IVoice
    {
        function synthesize( buffer:Vector.<Vector.<Number>> ):void;
    }
}
