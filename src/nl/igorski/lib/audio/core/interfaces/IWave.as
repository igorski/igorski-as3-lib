package nl.igorski.lib.audio.core.interfaces
{
    import nl.igorski.lib.audio.model.vo.VOEnvelopes;

    public interface IWave
    {
        // setters for note-related instructions
        function set delta( value:Number ):void;
        function set frequency( value:Number ):void;
        function set length( value:Number ):void;

        // getters / setters for the individual envelopes
        function get volume():Number;
        function set volume( value:Number ):void;

        function get pan():Number;
        function set pan( value:Number ):void;

        function get attack():Number;
        function set attack( value:Number ):void;

        function get decay():int;
        function set decay( value:int ):void;

        function get release():Number;
        function set release( value:Number ):void;

        // function to set and retrieve all envelopes via a value object
        function setData( envelopes:VOEnvelopes ):void;
        function getData():VOEnvelopes;

        // and modulators
        function getAllModulators():Vector.<IModulator>
        function setAllModulators( value:Vector.<IModulator> ):void

        // ...and modifiers
        function getAllModifiers():Vector.<IModifier>
        function setAllModifiers( value:Vector.<IModifier> ):void

        // generation related
        function get active():Boolean;
        function set active( value:Boolean ):void;

        function generate( buffer:Array, pointer:int = -1 ):void;
    }
}
