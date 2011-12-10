package nl.igorski.lib.audio.core.interfaces
{
    public interface IBufferModifier
    {
        function processBuffer( sampleBuffer:Array ):void
        function getData():Object;
        function setData( data:Object ):void;
    }
}
