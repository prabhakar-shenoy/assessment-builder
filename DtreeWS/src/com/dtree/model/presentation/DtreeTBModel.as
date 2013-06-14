package com.dtree.model.presentation
{
	import mx.collections.XMLListCollection;

	[Bindable]
	public class DtreeTBModel
	{
		public var questions: XMLListCollection = new XMLListCollection();

		public function refreshCollection(): void
		{
			questions.refresh();
		}
	}
}