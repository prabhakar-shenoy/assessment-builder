package com.dtree.common
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
	import mx.styles.StyleManager;
	public class Util
	{
		public static function execWithBusyCursor(f: Function): void
		{
			if(f != null)
			{
				var cursorId: Number = CursorManager.setCursor(StyleManager.getStyleManager(null).getStyleDeclaration("mx.managers.CursorManager").getStyle("busyCursor"), CursorManagerPriority.HIGH);
				try
				{
					f();
				}
				finally
				{
					CursorManager.removeCursor(cursorId);
				}
			}
		}
		public static function killEvent(e: Event): void
		{
			e.preventDefault();
			e.stopImmediatePropagation();
		}
		public static function sortXLC(xmlList: XMLListCollection, sortField: String): void
		{
			var sort: Sort = new Sort();
			sort.fields = [new SortField(sortField, true)];
			xmlList.sort = sort;
			xmlList.refresh();
		}
		public static function smoothen(bData: BitmapData): void
		{
			var bmp: Bitmap = new Bitmap(bData)
			if(bmp && !bmp.smoothing)
			{
				bmp.smoothing = true;
			}
		}
	}
}