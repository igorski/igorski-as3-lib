package nl.igorski.lib.audio.core.interfaces
{
    public interface IBusModifier
    {
        function process( sampleBuffer:Array ):void
        function getData():Object;
    }
}
