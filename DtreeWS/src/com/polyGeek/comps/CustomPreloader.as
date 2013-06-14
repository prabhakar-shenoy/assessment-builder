package com.polyGeek.comps {
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.events.RSLEvent;
	import mx.preloaders.SparkDownloadProgressBar;
	import mx.preloaders.DownloadProgressBar;
	
	
	public class CustomPreloader extends SparkDownloadProgressBar {
		private var _progressText:TextField;
		private var _textFormat:TextFormat;
		
		private var _barBG:Sprite;
		private var _bar:Sprite;
		
		public function CustomPreloader() {
			super();
		}
		
		override protected function createChildren():void {
			var w:int = stageWidth
			var h:int = stageHeight;
			
			// Text Display
			_progressText = new TextField();
			_progressText.text = "LOADING";
			_progressText.width = 550;
			_progressText.height = 400;
			
			_textFormat = new TextFormat();
			_textFormat.font = 'Arial';
			_textFormat.size = 16;
			
			_progressText.setTextFormat( _textFormat );
			
			_progressText.x = 20;
			_progressText.y = h/2 + 50;
			
			this.addChild( _progressText );
			
			// preload bar background
			_barBG = new Sprite();
			_barBG.graphics.beginFill( 0x000000 );
			_barBG.graphics.drawRect( 0, 0, w - 20, 20 );
			_barBG.x = 10;
			_barBG.y = h/2;
			this.addChild( _barBG );
			
			// preload bar
			_bar = new Sprite();
			_bar.x = 10;
			_bar.y = h/2 + 2;
			this.addChild( _bar );	
		}
		
		override protected function rslProgressHandler( e:RSLEvent ):void {
			if ( e.rslIndex && e.rslTotal ) {
				if( _progressText == null ) {
					_progressText = new TextField();
					this.addChild( _progressText );
				}
				_progressText.text = "loading RSL " + e.rslIndex + " of " + e.rslTotal + ": ";
			}
		}
		
		override protected function setDownloadProgress( completed:Number, total:Number ):void {
			_bar.graphics.clear();
			_bar.graphics.beginFill( 0xFFFFFF, 0.5 );
			_bar.graphics.drawRect( 0, 0, ( stageWidth - 20 ) * ( completed / total ), 16 );
			_progressText.text = Math.round( ( completed / total ) * 100 ) + "% completed";
		}
	}
}