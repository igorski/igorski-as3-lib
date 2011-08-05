package nl.igorski.lib.audio.core.interfaces
{
    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 27-07-11
     * Time: 22:38
     */
    public interface IOscillator
    {
        function generate():Number;
        function getData():Object;
        function setData( data:Object ):void;

        function get rate():Number;
        function set rate( value:Number ):void;

        function get wave():String;
        function set wave( value:String ):void;
    }
}
