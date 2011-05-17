package nl.igorski.lib.ui.forms.components
{
    import flash.display.Sprite;
    import flash.events.Event;
    import nl.igorski.views.components.StdTextField;
    /**
     * button that triggers submit event for the entire form
     * ...
     * @author Igor Zinken
     */
    public class SubmitButton extends Sprite
    {
        private var bg		:Sprite;
        private var title	:StdTextField;
        private var _text	:String;

        public function SubmitButton( text:String )
        {
            _text = text;
            addEventListener( Event.ADDED_TO_STAGE, initUI );
        }

        private function initUI( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, initUI );

            draw();

            useHandCursor = buttonMode = true;
            mouseChildren = false;
        }

        // override in subclass for custom skinning
        protected function draw():void
        {
            title = new StdTextField();
            title.x = 10;
            title.y = -1;
            title.text = _text;

            bg = new Sprite();
            with( bg.graphics )
            {
                lineStyle( 1, 0xFFFFFF );
                drawRect( 0, 0, title.width + 20, 16 );
                endFill();
            }
            addChild( bg );

            addChild( title );
        }
    }
}
