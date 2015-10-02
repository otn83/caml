package jp.coremind.view.interaction
{
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    
    import jp.coremind.core.Application;
    
    /**
     * フリック時の座標計算を行うクラス.
     * 正確にはFlickAccelerationクラスで計算した結果を然るべきコールバック関数へ返すフリック制御クラス。
     * Drugクラスの派生であるので同様にStage座標に依存ことを留意。
     */
    public class Flick extends Drug
    {
        private var
            _flickX:FlickAcceleration,
            _flickY:FlickAcceleration,
            _destroy:Boolean;
        
        public function Flick()
        {
            super(0);
            
            _destroy = false;
            _flickX = new FlickAcceleration();
            _flickY = new FlickAcceleration();
        }
        
        override public function destory():void
        {
            _destroy = true;
            _flickX = _flickY = null;
            
            super.destory();
        }
        
        override public function observe(offset:Rectangle, drugArea:Rectangle, drugListener:Function, dropListener:Function = null):void
        {
            if (_druging)
                return;
            
            _flickX.terminate();
            _flickY.terminate();
            
            super.observe(offset, drugArea, drugListener, dropListener);
        }
        
        override protected function _createTracker(offset:Rectangle, drugArea:Rectangle):void
        {
            super._createTracker(offset, drugArea);
            
            _trackX.enabledRound = false;
            _trackY.enabledRound = false;
        }
        
        override protected function _onUp(e:MouseEvent):void
        {
            Application.stage.removeEventListener(MouseEvent.MOUSE_UP, _onUp);
            
            //terminate drug loop.
            _druging = false;
            
            if (_dropListener is Function)
                _dropListener(_trackX, _trackY);
            
            if (_flickX.requireUpdate(_trackX) || _flickY.requireUpdate(_trackY))
            {
                _flickX.initialize(_trackX);
                _flickY.initialize(_trackY);
                $.loop.highResolution.setInterval(_update);
            }
        }
        
        protected function _update(elapsed:int):Boolean
        {
            if (_destroy) return true;
            
            var _changedX:Boolean = _flickX.update(_trackX, elapsed);
            var _changedY:Boolean = _flickY.update(_trackY, elapsed);
            
            if (_changedX || _changedY)
            {
                _drugListener(_trackX, _trackY);
                return false;
            }
            else
                return true;
        }
    }
}