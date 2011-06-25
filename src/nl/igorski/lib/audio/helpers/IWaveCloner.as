package nl.igorski.lib.audio.helpers
{
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    import nl.igorski.lib.audio.generators.waveforms.base.BaseWaveForm;

    /**
     * class IWaveCloner
     *
     * Created by IntelliJ IDEA.
     * User: igor.zinken
     * Date: 13-4-11
     * Time: 9:58
     */
    public final class IWaveCloner
    {
        //_________________________________________________________________________________________________________
        //                                                                                    C O N S T R U C T O R

        public function IWaveCloner()
        {
            throw new Error( "cannot instantiate IWaveCloner" );
        }

        //_________________________________________________________________________________________________________
        //                                                                              P U B L I C   M E T H O D S

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

        //_________________________________________________________________________________________________________
        //                                                                            G E T T E R S / S E T T E R S

        //_________________________________________________________________________________________________________
        //                                                                              E V E N T   H A N D L E R S

        //_________________________________________________________________________________________________________
        //                                                                        P R O T E C T E D   M E T H O D S

        //_________________________________________________________________________________________________________
        //                                                                            P R I V A T E   M E T H O D S
    }
}
