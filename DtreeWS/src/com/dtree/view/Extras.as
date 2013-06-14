package com.dtree.view
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import mx.core.IDataRenderer;
	public class Extras
	{
		public static function intellistats(data: *):void
		{
			if(data != null && ExternalInterface.available)
			{
				ExternalInterface.marshallExceptions = true;
				ExternalInterface.call("js_intellistats", XML(data).QuestionID);
			}
		}
		public static function intelliStatsHandler(e: MouseEvent):void
		{
			var renderer: IDataRenderer = null;
			if(e != null && e.target != null && e.target is DisplayObject)
			{
				var obj: DisplayObject = DisplayObject(e.target);
				while(obj != null)
				{
					if(obj is IDataRenderer)
					{
						renderer = IDataRenderer(obj);
						break;
					}
					obj = obj.parent;
				}
			}
			if(renderer != null)
			{
				intellistats(renderer.data);
			}
		}
	}
}