package com.dtree.events
{
	import flash.events.Event;
	public class DTreeEvent extends Event
	{
		public function DTreeEvent(data: *, type: String)
		{
			super(type, true, false);
			this.data = data;
		}
		public var data:*;
		override public function clone(): Event
		{
			return new DTreeEvent(data, type);
		}
	}
}