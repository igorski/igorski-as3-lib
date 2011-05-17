package nl.igorski.lib.audio.core.interfaces
{
    import flash.utils.ByteArray;

    public interface IBusModifier
    {
        function process( sourceLeft:Number, sourceRight:Number, buffer:ByteArray ):void
        function getData():Object;
    }
}
