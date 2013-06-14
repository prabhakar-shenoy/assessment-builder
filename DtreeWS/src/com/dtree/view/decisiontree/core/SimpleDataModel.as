package com.dtree.view.decisiontree.core
{
	import com.roguedevelopment.objecthandles.IMoveable;
	import com.roguedevelopment.objecthandles.IResizeable;
	
	import spark.components.BorderContainer;

	public class SimpleDataModel implements IResizeable, IMoveable
	{
		[Inject(id="dtreeCanvas")]
		public var canvas: BorderContainer;

		private function updateCanvasSize(): void
		{
			if(canvas != null)
			{
				var updatedWidth: Number = x + width + 10;
				if(updatedWidth > canvas.minWidth)
				{
					canvas.minWidth = updatedWidth;
				}
				var updatedHeight: Number = y + height + 10;
				if(updatedHeight > canvas.minHeight)
				{
					canvas.minHeight = updatedHeight;
				}
			}
		}

		[Init]
		public function initModel(): void
		{
			updateCanvasSize();
		}

		private static const MIN_LIMIT: Number = 0;

		private var _x: Number = 10;

		[Bindable]
		public function get x(): Number
		{
			return _x;
		}

		public function set x(value: Number): void
		{
			if(value < MIN_LIMIT)
			{
				value = MIN_LIMIT;
			}
			if(_x != value)
			{
				_x = value;
				updateCanvasSize();
			}
		}

		private var _y: Number  = 10;

		[Bindable]
		public function get y(): Number
		{
			return _y;
		}

		public function set y(value: Number): void
		{
			if(value < MIN_LIMIT)
			{
				value = MIN_LIMIT;
			}
			if(_y != value)
			{
				_y = value;
				updateCanvasSize();
			}
		}

		private static const MIN_DEFAULT:Number = 50;

		private var _height: Number = MIN_DEFAULT;

		[Bindable]
		public function get height(): Number
		{
			return _height;
		}

		public function set height(value: Number): void
		{
			_height = value;
			updateCanvasSize();
		}

		private var _width: Number = MIN_DEFAULT;

		[Bindable]
		public function get width(): Number
		{
			return _width;
		}

		public function set width(value: Number): void
		{
			_width = value;
			updateCanvasSize();
		}

		[Bindable] public var rotation: Number = 0;
		[Bindable] public var isLocked: Boolean = false;
	}
}