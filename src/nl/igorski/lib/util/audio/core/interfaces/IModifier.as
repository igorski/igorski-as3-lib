package nl.igorski.lib.util.audio.core.interfaces
{
    public interface IModifier
    {
        function process( input:Number ):Number;
        function getData():Object;
    }
}
