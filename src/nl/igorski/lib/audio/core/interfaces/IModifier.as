package nl.igorski.lib.audio.core.interfaces
{
    public interface IModifier
    {
        function process( input:Number ):Number;
        function getData():Object;
        function setData( data:Object ):void;
    }
}
