package nl.igorski.lib.ui.forms.components.interfaces
{
    public interface IFormElement
    {
        function get val():*;
        function set val( value:* ):void;

        function doError():void;
        function undoError():void;
    }
}
