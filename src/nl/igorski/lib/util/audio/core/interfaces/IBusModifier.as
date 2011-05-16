package nl.igorski.lib.util.audio.core.interfaces
{
    import flash.utils.ByteArray;

    public interface IBusModifier
    {
        function process( sourceLeft:Number, sourceRight:Number, buffer:ByteArray ):void
        function getData():Object;
    }
}
