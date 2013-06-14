package com.dtree.view.comps
{
	import spark.components.Button;
	import spark.primitives.BitmapImage;

	public class IconButton extends Button
	{
		public function IconButton()
		{
			super();
		}

		private var _icon:Class;
		private var _overIcon:Class;
		private var _disabledIcon:Class;
		private var _downIcon:Class;

		public function get icon():Class
		{
		    return _icon;
		}

		public function set icon(val:Class):void
		{
		    _icon = val;
			if (iconElement != null)
			{
	            iconElement.source = _icon;
			}
		}

		public function get overIcon():Class
		{
			return _overIcon;
		}

		public function set overIcon(value:Class):void 
		{
			_overIcon = value;
			if (iconOverElement != null)
			{
				iconOverElement.source = _overIcon;
			}
		}

		public function get downIcon():Class
		{
			return _downIcon;
		}

		public function set downIcon(value:Class):void
		{
			_downIcon = value;
			if (iconDownElement != null)
			{
				iconDownElement.source = _downIcon;
			}
		}

		public function get disabledIcon():Class
		{
			return _disabledIcon;
		}
		
		public function set disabledIcon(value:Class):void
		{
			_disabledIcon = value;
			if (iconDownElement != null)
			{
				iconDownElement.source = _disabledIcon;
			}
		}

		[SkinPart(required="false")]
	    public var iconElement:BitmapImage;

	    [SkinPart(required="false")]
	    public var iconOverElement:BitmapImage;

	    [SkinPart(required="false")]
	    public var iconDownElement:BitmapImage;

		[SkinPart(required="false")]
		public var iconDisabledElement:BitmapImage;

	    override protected function partAdded(partName:String, instance:Object):void
	    {
	        super.partAdded(partName, instance);
	        if (icon !== null && instance == iconElement)
			{
	            iconElement.source = icon;
			}
			if (disabledIcon !== null && instance == iconDisabledElement)
			{
				iconDisabledElement.source = disabledIcon;
			}
	        if (overIcon !== null && instance == iconOverElement)
			{
	            iconOverElement.source = overIcon;
			}
	        if (downIcon !== null && instance == iconDownElement)
			{
	            iconDownElement.source = downIcon;
			}
	    }
	}
}