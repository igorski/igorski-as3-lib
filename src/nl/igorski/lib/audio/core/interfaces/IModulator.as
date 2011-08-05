package nl.igorski.lib.audio.core.interfaces
{
    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 27-07-11
     * Time: 22:38
     */
    public interface IModulator
    {
        function modulate( value:Number ):Number;
        function getData():Object;
        function setData( data:Object ):void;
    }
}
