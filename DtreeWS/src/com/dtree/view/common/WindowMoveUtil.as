package com.dtree.view.common
{
	import mx.core.IUIComponent;
	internal class WindowMoveUtil
	{
		public static function winMoveHandler(c: IUIComponent):void
		{
			if(c.x < 0)
			{
				c.x = 0;
			}
			if(c.y < 0)
			{
				c.y = 0;
			}
		}
	}
}