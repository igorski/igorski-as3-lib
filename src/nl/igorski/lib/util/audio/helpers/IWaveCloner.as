package nl.igorski.lib.util.audio.helpers
{
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    import nl.igorski.lib.util.audio.generators.waveforms.base.BaseWaveForm;

    /**
     * class IWaveCloner
     *
     * Created by IntelliJ IDEA.
     * User: igor.zinken
     * Date: 13-4-11
     * Time: 9:58
     */
    public class IWaveCloner
    {
        public function IWaveCloner()
        {
            throw new Error( "cannot instantiate IWaveCloner" );
        }

        /*
         * creates a new instance of the source object ( must extend
         * the BaseWaveForm Class ) containing all the properties of the source
         *
         * @source object extending the BaseWaveForm class
         */
        public static function clone( source:BaseWaveForm ):BaseWaveForm
        {
            var output:BaseWaveForm;

            var sourceClass:Class = getDefinitionByName( getQualifiedClassName( source )) as Class;
            output = new sourceClass();

            output.setData( source.getData());
            output.modifiers = source.modifiers;

            return output;
        }
    }
}
