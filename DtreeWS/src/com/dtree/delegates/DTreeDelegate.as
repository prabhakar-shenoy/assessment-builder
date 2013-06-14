package com.dtree.delegates
{
	import com.dtree.common.ResourceStrings;
	import com.dtree.events.DTreeTabEvent;
	import com.dtree.model.presentation.DtreeModel;
	import com.dtree.model.vo.DTreeData;
	import com.dtree.view.DTreeTabContent;
	import com.dtree.view.DTreeTabNavigator;
	import com.dtree.view.common.AssetLocator;
	import com.dtree.view.decisiontree.ITreeCanvas;
	import org.spicefactory.parsley.core.context.Context;
	public class DTreeDelegate
	{
		[Inject] public var tabNavigator: DTreeTabNavigator;
		[Inject] public var dtreeModel: DtreeModel;
		[Inject] public var context: Context;
		public function execute(e: DTreeTabEvent): void
		{
			var data: * = e.data;
			var caption: String = data;
			if(caption == "" || caption == null)
			{
				caption = ResourceStrings.NEW_DTREE;
			}
			var tab: DTreeTabContent;
			var isNew: Boolean = data is DTreeData || data == null;
			if(isNew)
			{
				if(data == null)
				{
					data = new DTreeData();
					data.ID = 0;
				}
				tab = new DTreeTabContent();
				tab.setStyle("closable", true);
				tab.label = caption;
				tab.icon = AssetLocator.DOCICON;
				// context.viewManager.addViewRoot(tab);
			}
			else if(data.dtree != null)
			{
				for (var i:int = 0; i < tabNavigator.numElements; i++)
				{
					var obj: DTreeTabContent = DTreeTabContent(tabNavigator.getElementAt(i))
					if(obj != null)
					{
						var cvas: ITreeCanvas = obj.treeCanvas;
						if(cvas != null && data.dtree == cvas)
						{
							tab = obj;
							var o: * = {};
							o.pt = data.pt;
							o.xml = data.xml;
							o.overrideProperties = data.overrideProperties;
							cvas.mergeWith(o);
							break;
						}
					}
				}
			}
			if(tab != null)
			{
				if(isNew)
				{
					tab.dtreeData = data;
					tabNavigator.addElement(tab);
				}
				tabNavigator.selectedChild = tab;
				dtreeModel.updateEnabled(dtreeModel.enabled);
			}
		}
	}
}