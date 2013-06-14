package com.dtree.events
{
	import flash.events.Event;
	public class DecisionTreeEvent extends DTreeEvent
	{
		public static const QUESTION_LIST: String = 'QUESTION_LIST';
		public static const REFRESH_LIST: String = 'REFRESH_LIST';
		public static const DECISIONTREE_LIST: String = 'DECISIONTREE_LIST';
		public static const TERMINATINGACTION_LIST: String = "TERMINATINGACTION_LIST";
		public static const CATEGORY_LIST: String = "CATEGORY_LIST";
		public static const REFRESH_CATEGORY_LIST: String = 'REFRESH_CATEGORY_LIST';
		public static const UPDATE_DECISIONTREE: String = 'UPDATE_DECISIONTREE';
		public static const EDIT_DECISIONTREE: String = 'EDIT_DECISIONTREE';
		public static const OPEN_DECISIONTREE: String = 'OPEN_DECISIONTREE';
		public static const LISTCHANGE_DECISIONTREE: String = 'LISTCHANGE_DECISIONTREE';
		public static const CONNECT_STATUS_CHANGE: String = 'CONNECT_STATUS_CHANGE';
		public static const STARTING_QUESTION_CHANGE: String = 'STARTING_QUESTION_CHANGE';
		public static const QUESTION_SAVE: String = 'QUESTION_SAVE';
		public static const QUESTION_EDIT: String = 'QUESTION_EDIT';
		public static const OPEN_QUESTION: String = 'OPEN_QUESTION';
		public static const INTELLI_STATS: String = 'INTELLI_STATS';
		public function DecisionTreeEvent(data: *, type: String = QUESTION_LIST)
		{
			super(data, type);
		}
		override public function clone(): Event
		{
			return DecisionTreeEvent(super.clone());
		}
	}
}