package nl.igorski.lib.utils.pagination
{
    public interface IPaginatorButton
    {
        function init():void

        function get active():Boolean
        function set active( value:Boolean ):void

        function get page():int
        function set page( value:int ):void

        function get title():String
        function set title( value:String ):void
    }
}
