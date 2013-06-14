package com.dtree.model.presentation
{
	import spark.components.SkinnableContainer;
	import com.dtree.view.decisiontree.DTreeGlobals;
	import mx.collections.XMLListCollection;
	[Bindable]
	public class DtreeModel
	{
		public var questions: XMLListCollection = new XMLListCollection();
		public var terminatingActions: XMLListCollection = new XMLListCollection();
		public var categoryList: XMLListCollection = new XMLListCollection();
		public var decisionTrees: XMLListCollection = new XMLListCollection();
		public var randomQuestionLevels: XMLListCollection = new XMLListCollection(XMLList(DTreeGlobals.LEVELS)..Question);
		public var isDemo: Boolean = true;
		public var saveEnabled: Boolean = false;
		public var enabled: Boolean = false;
		public var tBar: * = null;
		public function refreshCollection(): void
		{
			questions.refresh();
			terminatingActions.refresh();
			decisionTrees.refresh();
			randomQuestionLevels.refresh();
			updateEnabled(enabled);
		}
		public var rootHost: String;
		[Inject(id="tabNav")] public var nav: SkinnableContainer;
		public function updateEnabled(value: Boolean): void
		{
			enabled = value;
			saveEnabled = nav != null && nav.numElements > 0 ? enabled && !isDemo : false;
		}
		public var addNewFlag: Boolean = false;
	}
}