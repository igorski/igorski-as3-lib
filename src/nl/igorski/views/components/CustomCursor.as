package nl.igorski.views.components
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    /**
     * ...
     * @author Igor Zinken
     */
    public class CustomCursor extends Sprite
    {   
        public function CustomCursor()
        {
            addEventListener( Event.ADDED_TO_STAGE, init );
        }
        
        public function destroy():void
        {
            stage.removeEventListener( MouseEvent.MOUSE_MOVE, customCursorMove );
        }
        
        private function init( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, init );
            
            x = mouseX;
            y = mouseY;
                
            stage.addEventListener( MouseEvent.MOUSE_MOVE, customCursorMove );
        }
        
        private function customCursorMove( e:MouseEvent ):void
        {
            x = e.stageX;
            y = e.stageY;
        }
    }
}
