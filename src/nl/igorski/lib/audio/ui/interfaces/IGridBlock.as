package nl.igorski.lib.audio.ui.interfaces
{
    /**
     * Created by IntelliJ IDEA.
     * User: igorzinken
     * Date: 06-07-11
     * Time: 19:02
     */
    public interface IGridBlock
    {
        function setData( length:Number ):void;
        function getFrequency():Number;
        function highlight():void;
        function sleep():void;
        function wakeUp():void;

        function get frequency():Number;
        function get index():int;
        function get length():Number;
        function get octave():int;

        function set disabled( value:Boolean ):void;
    }
}
