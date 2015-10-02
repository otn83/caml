package jp.coremind.view.implement.starling
{
    import jp.coremind.model.module.StatusConfigure;
    import jp.coremind.model.module.StatusGroup;
    import jp.coremind.model.module.StatusModel;
    import jp.coremind.model.module.StatusModelConfigure;
    import jp.coremind.model.transaction.UpdateRule;
    import jp.coremind.utility.data.Status;
    import jp.coremind.view.builder.IBackgroundBuilder;
    import jp.coremind.view.layout.LayoutCalculator;
    
    import starling.events.Touch;
    import starling.events.TouchEvent;
    
    public class InteractiveElement extends StatefulElement
    {
        override protected function get _statusModelConfigureKey():Class { return InteractiveElement }
        
        StatusModelConfigure.registry(InteractiveElement, [
            new StatusConfigure(StatusGroup.LOCK, UpdateRule.LESS_THAN_PRIORITY, 100, Status.UNLOCK, true, [Status.UNLOCK])
        ]);
        
        protected var
            _button:Boolean,
            _touchHandling:Boolean,
            _touch:Touch;
        
        public function InteractiveElement(
            layoutCalculator:LayoutCalculator,
            backgroundBuilder:IBackgroundBuilder = null)
        {
            super(layoutCalculator, backgroundBuilder);
            button = false;
            touchHandling = false;
        }
        
        override public function destroy(withReference:Boolean = false):void
        {
            disablePointerDeviceControl();
            
            super.destroy(withReference);
        }
        
        override public function initialize(actualParentWidth:int, actualParentHeight:int, storageId:String = null):void
        {
            super.initialize(actualParentWidth, actualParentHeight, storageId);
            
            enablePointerDeviceControl();
        }
        
        override protected function _initializeStatus():void
        {
            super._initializeStatus();
            
            _elementModel.getModule(StatusModel).update(StatusGroup.LOCK, null);
        }
        
        public function get button():Boolean
        {
            return _button;
        }
        
        public function set button(v:Boolean):void
        {
            _button = v;
            if (v && touchable) useHandCursor = true;
        }
        
        public function get touchHandling():Boolean
        {
            return _touchHandling;
        }
        
        public function set touchHandling(v:Boolean):void
        {
            _touchHandling = v;
            if (v && touchable) addEventListener(TouchEvent.TOUCH, _onTouch);
        }
        
        override public function enablePointerDeviceControl():void
        {
            touchable = true;
            if (_button) useHandCursor = true;
            if (_touchHandling) addEventListener(TouchEvent.TOUCH, _onTouch);
        }
        
        override public function disablePointerDeviceControl():void
        {
            useHandCursor = touchable = false;
            removeEventListener(TouchEvent.TOUCH, _onTouch);
        }
        
        /**
         * フレームワークから発生するタッチイベントのハンドリングを行う.
         */
        protected function _onTouch(e:TouchEvent):void
        {
            _touch = e.getTouch(this);
            
            if (_touch)
            {
                this[_touch.phase]();
                _touch = null;
            }
        }
        
        /** TouchPhase.HOVERハンドリング */
        protected function hover():void {}
        
        /** TouchPhase.BEGANハンドリング */
        protected function began():void　{}
        
        /** TouchPhase.MOVEDハンドリング */
        protected function moved():void　{}
        
        /** TouchPhase.STATIONARYハンドリング */
        protected function stationary():void {}
        
        /** TouchPhase.ENDEDハンドリング */
        protected function ended():void　{}
        
        override protected function _applyStatus(group:String, status:String):Boolean
        {
            switch (group)
            {
                case StatusGroup.LOCK:
                    switch(status)
                    {
                        case Status.UNLOCK: _onEnable(); return true;
                        case Status.LOCK  : _onDisable(); return true;
                    }
                    break;
            }
            
            return super._applyStatus(group, status);
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_LOCK
         * value : Status.UNLOCK
         */
        protected function _onEnable():void
        {
            //Log.info("_onEnable");
        }
        
        /**
         * statusオブジェクトが以下の状態に変わったときに呼び出されるメソッド.
         * group : GROUP_LOCK
         * value : Status.LOCK
         */
        protected function _onDisable():void
        {
            //Log.info("_onDisable");
        }
    }
}