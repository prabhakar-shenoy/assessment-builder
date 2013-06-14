package com.dtree.view.decisiontree
{
	import com.adobe.cairngorm.popup.PopUpEvent;
	import com.adobe.cairngorm.popup.PopUpWrapper;
	import com.dtree.common.ResourceStrings;
	import com.dtree.events.DTreeTabEvent;
	import com.dtree.events.DecisionTreeEvent;
	import com.dtree.model.presentation.DtreeModel;
	import com.dtree.model.presentation.DtreeModuleModel;
	import com.dtree.model.vo.QVO;
	import com.dtree.view.common.AssetLocator;
	import com.dtree.view.common.InputBox;
	import com.dtree.view.decisiontree.core.SimpleDataModel;
	import com.roguedevelopment.objecthandles.VisualElementHandle;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import mx.collections.XMLListCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	import mx.managers.DragManager;
	import mx.utils.StringUtil;
	import spark.components.Group;
	import org.spicefactory.parsley.core.context.Context;
	public final class DTreeHelper extends EventDispatcher
	{
		[Inject] public var tree: DecisionTree;
		[Inject] public var model: DtreeModuleModel;
		[Inject] public var dtreeModel: DtreeModel;
		[Inject] public var context: Context;
		[Inject(id="inputBox")] public var inputBoxPopUp: PopUpWrapper;
		public var treeCanvas: ITreeCanvas;
		private var _dtData: *;
		[Inject] public var canvasHelper: DTreeCanvasHelper;
		private function mergeDTree(flag: Boolean): void
		{
			_dtData.overrideProperties = flag;
			dispatchEvent(new DTreeTabEvent(_dtData, DTreeTabEvent.MERGE_DTREE));
		}
		private function get isRandom(): Boolean
		{
			return model.isRandom;
		}
		private function contains(xml: XML): Boolean
		{
			return DTreeGlobals.contains(xml, tree.canvas)
		}
		private function getTreeGroups(isQuestion: Boolean, xml: XML): Array
		{
			var result: Array = [];
			var grp: DTreeGroup;
			const f: Function = function(grp: DTreeGroup): void
					{
						if(grp != null)
						{
							result.push(grp);
						}
					}
			if(isQuestion)
			{
				if(isRandom)
				{
					var items: Vector.<Object> = DtreeUtils.getQXMLFor(xml);
					for each(var qxml: XML in items)
					{
						f(DtreeUtils.getQuestionGroupBox(qxml, context, tree.canvas));
					}
				}
				else
				{
					f(DtreeUtils.getQuestionGroupBox(xml, context, tree.canvas));
				}
			}
			else
			{
				f(DtreeUtils.getTAGroupBox(xml, context, tree.canvas));
			}
			return result;
		}
		public function dragDropHandler(e: DragEvent): void
		{
			e.preventDefault();
			var errorString: String = "";
			var resStr: String = ResourceStrings.DUPLICATE_ERROR;
			CursorManager.setBusyCursor()
			var items: Vector.<Object> = e.dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
			var qvo: QVO = new QVO();
			var pt:Point = tree.canvas.globalToContent(e.target.localToGlobal(new Point(e.localX, e.localY)));
			_dtData = {};
			_dtData.pt = pt;
			qvo.pt = pt;
			const f: Function = function(grp: DTreeGroup, isQ: Boolean): void
				{
					if(!isQ)
					{
						qvo.height = TAGroup.LEN;
					}
					else if(isRandom)
					{
						qvo.height = QVO.MAX_RANDOMQ_HEIGHT;
					}
					grp.setModel(tree.canvas, qvo);
				}
			var isQuestion: Boolean;
			var lContinue: Boolean = true;
			for each(var xml: XML in items)
			{
				switch(String(xml.name()).toLowerCase())
				{
					case "question": isQuestion = true; break;
					case "terminatingoption": isQuestion = false; break;
					default: _dtData.xml = xml; _dtData.dtree = treeCanvas; lContinue = false;
				}
				if(lContinue)
				{
					var grps: Array = getTreeGroups(isQuestion, xml);
					if(grps.length > 0)
					{
						if(grps.length == 1)
						{
							f(grps[0], isQuestion);
							qvo.pt.x += 50;
						}
						else // isRandom
						{
							var x_: Number = qvo.pt.x;
							for each(var grp: DTreeGroup in grps)
							{
								f(grp, true);
								qvo.pt.x += qvo.width + 10;
							}
							qvo.pt.x = x_ + 50;
						}
						qvo.pt.y += 50;
					}
					else
					{
						if(errorString != "")
						{
							resStr = ResourceStrings.DUPLICATES_ERROR;
						}
						errorString += (errorString == "" ? "" : "\n") + (isQuestion ? xml.QuestionName : xml.TerminatingOptionText);
					}
				}
				else
				{
					if(treeCanvas.hasDTreeItems())
					{
						CursorManager.removeBusyCursor();
						var defYesLabel: String = Alert.yesLabel;
						try
						{
							Alert.yesLabel = ResourceStrings.OVERRIDE;
							Alert.show(ResourceStrings.OVERRIDE_ASSESSMENT_TREE_MESSAGE, ResourceStrings.CONFIRMATION_STR, Alert.YES | Alert.NO | Alert.CANCEL, null,
								function(e: CloseEvent): void
								{
									if(e.detail != Alert.CANCEL)
									{
										mergeDTree(e.detail == Alert.YES);
									}
								}, AssetLocator.INFO);
						}
						finally
						{
							Alert.yesLabel = defYesLabel;
						}
					}
					else
					{
						mergeDTree(true);
					}
					break;
				}
			}
			if(lContinue)
			{
				if(isQuestion)
				{
					dtreeModel.questions.refresh();
				}
				else
				{
					dtreeModel.terminatingActions.refresh();
				}
				if(errorString != "")
				{
					Alert.show(StringUtil.substitute(resStr, [errorString]), ResourceStrings.ERROR_STR, Alert.OK, null, null, AssetLocator.ERROR);
				}
			}
		}
		public function dragEnterHandler(e: DragEvent): void
		{
			if(e.dragSource.hasFormat("itemsByIndex"))
			{
				var items: Vector.<Object> = e.dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
				var isFlag: Boolean = model != null && model.isRandom;
				var canAccept: Boolean = false;
				for each(var xml:XML in items)
				{
					var tagName: String = String(xml.name()).toLowerCase();
					if(isFlag)
					{
						switch(tagName)
						{
							case "question": canAccept = true; break;
							case "terminatingoption": canAccept = !contains(xml); break;
							default: canAccept = false;
						}
					}
					else
					{
						canAccept = tagName == "assessmentlist" && xml.@IsRandom == 1 ? false : !contains(xml);
					}
					if(canAccept)
					{
						break;
					}
				}
				if(canAccept)
				{
					DragManager.acceptDragDrop(Group(e.currentTarget));
				}
			}
		}
		public function dragOverHandler(e: DragEvent): void
		{
			if(e.dragSource.hasFormat("itemsByIndex"))
			{
				DragManager.showFeedback(DragManager.COPY);
			}
		}
		private function newSaveAsPopUpClosed(event: PopUpEvent):void
		{
			var inputBox: InputBox = event.popup as InputBox;
			if(inputBox.isOk)
			{
				dtreeSave(0, inputBox.input.text);
			}
			inputBoxPopUp.removeEventListener(PopUpEvent.CLOSED, newSaveAsPopUpClosed);
		}
		public var sa: Boolean = false;
		private function dtreeSave(id: int, assessmentName: String = null): void
		{
			var data: * = {};
			data.xml = DtreeUtils.getDTreeXML(id, tree.canvas, isRandom, treeCanvas.host.levels, assessmentName);
			data.sa = sa;
			if(!data.sa && id == 0)
			{
				data.assessmentName = assessmentName;
				data.dtreeData = tree.dtreeData;
			}
			dispatchEvent(new DecisionTreeEvent(data, DecisionTreeEvent.UPDATE_DECISIONTREE));
		}
		public function save_doc(id: *, sa: Boolean = false): void
		{
			if(tree.dTreeGroup.selection != null)
			{
				if(id == 0)
				{
					inputBoxPopUp.addEventListener(PopUpEvent.CLOSED, newSaveAsPopUpClosed);
					inputBoxPopUp.open = true;
				}
				else
				{
					dtreeSave(id, null);
				}
			}
			else
			{
				Alert.show(ResourceStrings.START_QUESTION_ERROR, ResourceStrings.ERROR_STR, Alert.OK, null, null, AssetLocator.ERROR);
			}
		}
		public function canvasKeyUpHandler(e: KeyboardEvent): void
		{
			var selItems: Array = tree.oh.selectionManager.currentlySelected;
			var selObjs: Array = [];
			var grp: DTreeGroup;
			if(e.keyCode == Keyboard.DELETE)
			{
				for each(var m: Object in selItems)
				{
					for(var i: int = 0; i < tree.canvas.numElements; i++)
					{
						grp = tree.canvas.getElementAt(i) as DTreeGroup;
						if(grp != null && grp.model == m)
						{
							selObjs.push(grp);
							break;
						}
					}
				}
			}
			if(selObjs.length > 0)
			{
				Alert.show(ResourceStrings.CONFIRM_MULTIDELETE_MESSAGE, ResourceStrings.CONFIRMATION_STR, Alert.YES | Alert.NO, null,
					function (e: CloseEvent): void
					{
						if(e.detail == Alert.YES)
						{
							for each(grp in selObjs)
							{
								DtreeUtils.removeDtreeGroupBox(grp);
							}
							canvasHelper.modelRefresh();
						}
					}, AssetLocator.INFO);
			}
		}
		private function clearObjectHandlesSelection(): void
		{
			for each (var model: * in tree.oh.modelList)
			{
				if(model is SimpleDataModel)
				{
					SimpleDataModel(model).isLocked = false;
				}
			}
			tree.oh.selectionManager.clearSelection();
		}
		public function clickHandler(e: MouseEvent):void
		{
			if(DtreeUtils.isDTreeGroup(e.target)) return;
			if(e.target is VisualElementHandle) return;
			clearObjectHandlesSelection();
		}
		public function removeAllDtreeGroups(qOnly: Boolean = false): void
		{
			var grp: DTreeGroup;
			for(var i: int = tree.canvas.numElements - 1; i > -1; i--)
			{
				grp = tree.canvas.getElementAt(i) as (qOnly ? QuestionGroup : DTreeGroup);
				if(grp != null)
				{
					DtreeUtils.removeDtreeGroupBox(grp);
				}
			}
			tree.dTreeGroup.selection = null;
			clearObjectHandlesSelection();
		}
		public function updateCompleteHandler(e: FlexEvent): void
		{
			CursorManager.removeBusyCursor();
		}
		public function getDTreeGrpXML(): XMLListCollection
		{
			var result: XMLListCollection = DTreeGlobals.getxmLList(tree.dtreeData);
			if(tree.dtreeData.xml.@isRandom == 1)
			{
				var xml: XML;
				for each(var e: XML in result)
				{
					xml = <QuestionName/>;
					xml.appendChild(StringUtil.substitute(ResourceStrings.LEVEL_STR, e.QuestionLevel));
					e.appendChild(xml);
					for each(var o: XML in e.Options..OptionName)
					{
						o.@['OptionText'] = DTreeGlobals.isYes(o.@IsBestAnswer) ? ResourceStrings.CORRECT_ANS : ResourceStrings.WRONG_ANS;
						if(o.@GoToQuestionID == 0)
						{
							if(!o.hasOwnProperty('@width'))
							{
								o.@['width'] = QVO._WIDTH;
							}
							if(!o.hasOwnProperty('@TerminatingActionText'))
							{
								var taTxt: String = ResourceStrings.REFRESH_TA_LIST;
								for each(var x: XML in dtreeModel.terminatingActions)
								{
									//trace(o.@TerminatingActionID, x.TerminatingOptionID, o.@TerminatingActionID == x.TerminatingOptionID);
									if(o.@TerminatingActionID == x.TerminatingOptionID)
									{
										taTxt = x.TerminatingOptionText;
										break;
									}
								}
								o.@['TerminatingActionText'] = taTxt;
							}
						}
					}
				}
			}
			return result
		}
	}
}