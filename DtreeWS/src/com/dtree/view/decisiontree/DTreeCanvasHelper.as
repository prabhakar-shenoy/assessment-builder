package com.dtree.view.decisiontree
{
	import com.dtree.common.Util;
	import com.dtree.model.presentation.DtreeModel;
	import com.dtree.model.vo.DTreeData;
	import com.dtree.model.vo.QVO;
	import flash.geom.Point;
	import mx.collections.XMLListCollection;
	import org.spicefactory.parsley.core.context.Context;
	public final class DTreeCanvasHelper
	{
		[Inject] public var tree: DecisionTree;
		[Inject] public var dtreeModel: DtreeModel;
		[Inject] public var context: Context;
		public function addToCanvas(xmlList: XMLListCollection, overrideProperties: Boolean = false, pt: Point = null): void
		{
			if(xmlList != null && xmlList.length > 0)
			{
				var qvo: QVO = new QVO();
				var ctr: int = 0;
				var qg: QuestionGroup;
				var g: DTreeGroup;
				var tg: TAGroup;
				var intValx: Number = 10;
				for each (var q:XML in xmlList)
				{
					if(overrideProperties)
					{
						g = DtreeUtils.getDTreeGroupBox(q, tree.canvas);
						if(g != null)
						{
							DtreeUtils.removeDtreeGroupBox(g);
						}
					}
					qg = DtreeUtils.getQuestionGroupBox(q, context, tree.canvas);
					if(qg != null)
					{
						//trace(q.@x, q.@y, q.@width, q.@height, q.@minimized);
						if(q.@x == undefined)
						{
							if(ctr > 4)
							{
								ctr = 0;
								qvo.pt.x = 10;
								qvo.pt.y += QVO._HEIGHT + 10;
							}
							qvo.height = QVO._HEIGHT;
							qg.setModel(tree.canvas, qvo);
							qvo.pt.x += 160;
							ctr++;
						}
						else
						{
							qvo.pt.x = q.@x;
							qvo.pt.y = q.@y;
							if(pt != null)
							{
								qvo.pt.x += pt.x;
								qvo.pt.y += pt.y;
							}
							if(q.@minimized == 1)
							{
								qvo.height = q.@height;
								qvo.width = q.@width;
							}
							qg.setModel(tree.canvas, qvo);
						}
						var list:XMLListCollection = new XMLListCollection(q.Options..OptionName);
						for each(var o:XML in list)
						{
							var tXML: XML = DtreeUtils.getTAXML(o);
							if(tXML != null)
							{
								if(overrideProperties)
								{
									g = DtreeUtils.getDTreeGroupBox(tXML, tree.canvas);
									if(g != null)
									{
										DtreeUtils.removeDtreeGroupBox(g);
									}
								}
								tg = DtreeUtils.getTAGroupBox(tXML, context, tree.canvas);
								if(tg != null)
								{
									if(tXML.@x == undefined)
									{
										if(ctr > 4)
										{
											ctr = 0;
											qvo.pt.x = 10;
											qvo.pt.y += QVO._HEIGHT + 10;
										}
										qvo.height = TAGroup.LEN;
										tg.setModel(tree.canvas, qvo);
										qvo.pt.x += (QVO._WIDTH + 10);
										ctr++;
									}
									else
									{
										qvo.pt.x = tXML.@x;
										qvo.pt.y = tXML.@y;
										qvo.width = tXML.@width;
										qvo.height = TAGroup.LEN;
										tg.setModel(tree.canvas, qvo);
									}
								}
							}
						}
					}
				}
				tree.callLater(connectJacks, [overrideProperties]);
			}
			else
			{
				modelRefresh();
			}
		}
		private function connectJacks(overrideProperties: Boolean): void
		{
			Util.execWithBusyCursor(
				function (): void {
					for(var i: int = 0; i < tree.canvas.numElements; i++)
					{
						var qg: QuestionGroup = tree.canvas.getElementAt(i) as QuestionGroup;
						if(qg != null && qg.xml != null)
						{
							tree.callLater(connectQuestionGroup, [qg, overrideProperties]);
						}
					}
					modelRefresh();
				});
		}
		private function connectQuestionGroup(qg: QuestionGroup, overrideProperties: Boolean): void
		{
			Util.execWithBusyCursor(
				function ():void {
					for(var j:int = 0; j < qg.options.dataGroup.numElements; j++)
					{
						var renderer: OptionRenderer = OptionRenderer(qg.options.dataGroup.getElementAt(j));
						var lContinue: Boolean = renderer.optionJack.connectedJacks.length == 0;
						if(overrideProperties && !lContinue)
						{
							renderer.disConnectAll();
							lContinue = true;
						}
						if(lContinue)
						{
							var oXML: XML = XML(renderer.data);
							var nqID:* = oXML.@GoToQuestionID;
							var nextGrp: DTreeGroup = null;
							if(nqID != null && nqID != "" && nqID != 0)
							{
								nextGrp = DtreeUtils.getQuestionGroupByID(nqID, tree.canvas);
							}
							else
							{
								nqID = oXML.@TerminatingActionID;
								if(nqID != null && nqID != "" && nqID != 0)
								{
									nextGrp = DtreeUtils.getTAGroupByID(nqID, tree.canvas);
								}
							}
							if(nextGrp != null)
							{
								renderer.optionJack.connectToJack(nextGrp.jack);
							}
						}
					}
					qg.collapse();
				});
		}
		public function modelRefresh(value: Boolean = true): void
		{
			dtreeModel.refreshCollection();
			dtreeModel.updateEnabled(value);
		}
		public function openDecisionTreeData(value: DTreeData): void
		{
			if(value != null)
			{
				Util.execWithBusyCursor(function ():void 
				{
					tree.openData(value);
				});
			}
			else
			{
				modelRefresh();
			}
		}
	}
}