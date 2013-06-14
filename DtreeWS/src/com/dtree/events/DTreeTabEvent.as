package com.dtree.events
{
	import flash.events.Event;
	public class DTreeTabEvent extends DTreeEvent
	{
		public static const NEW_DTREE: String = 'NEW_DTREE';
		public static const SAVE_DTREE:String = 'SAVE_DTREE';
		public static const SAVEAS_DTREE:String = 'SAVEAS_DTREE';
		public static const MERGE_DTREE: String = 'MERGE_DTREE';
		public static const MODULE_LOADED: String = 'MODULE_LOADED';
		public static const DTREE_TYPE_CHANGE: String = 'DTREE_TYPE_CHANGE';
		public static const REFRESH_DESCRIPTION_LIST: String = "REFRESH_DESCRIPTION_LIST";
		public function DTreeTabEvent(data: *, type: String = NEW_DTREE)
		{
			super(data, type);
		}
		override public function clone(): Event
		{
			return DTreeTabEvent(super.clone());
		}
	}
}