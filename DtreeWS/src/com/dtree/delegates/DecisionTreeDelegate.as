package com.dtree.delegates
{
	import com.dtree.common.ResourceStrings;
	import com.dtree.common.Util;
	import com.dtree.events.DTreeEvent;
	import com.dtree.events.DecisionTreeEvent;
	import com.dtree.model.presentation.DtreeModel;
	import com.dtree.model.vo.DTreeData;
	import com.dtree.view.common.AssetLocator;
	import com.dtree.view.decisiontree.DTreeGlobals;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import mx.collections.XMLListCollection;
	import mx.controls.Alert;
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.Operation;
	public class DecisionTreeDelegate extends EventDispatcher
	{		
		[Inject] public var dtreeModel: DtreeModel;
		private var _service: AbstractService;
		public function DecisionTreeDelegate(service: AbstractService)
		{
			_service = service;
		}
		private function refreshDescriptionList(): void
		{
			dtreeModel.updateEnabled(true);
			dispatchEvent(new DecisionTreeEvent(null, DecisionTreeEvent.REFRESH_LIST));
		}
		private static const GET_Q_DATA: String = 'getQuestionData';
		private static const GET_QDATA_FOR: String = 'getQuestionDataFor';
		private static const GET_ATREE_EDIT: String = "getAssessmentTreeForEdit";
		private static const SAVE_ATREE_DATA: String = 'saveDecisionTreeData';
		private function execOp(e: DTreeEvent, opStr: String, responder: IResponder): void
		{
			dtreeModel.updateEnabled(false);
			var op: Operation = Operation(_service.getOperation(opStr));
			//trace(String(e.data));
			var param: Array = [];
			switch(opStr)
			{
				case GET_Q_DATA: param = [String(e.data.srarchStr), int(e.data.categoryID)]; break;
				case GET_QDATA_FOR: param = [int(e.data)]; break;
				case GET_ATREE_EDIT: param = [dtreeData.ID]; break;
				case SAVE_ATREE_DATA: param = [String(e.data.xml)]; break;
				default : param = [String(e.data)];
			}
			var token: AsyncToken = op.send.apply(null, param);
			token.remoteID = opStr;
			switch(opStr)
			{
				case SAVE_ATREE_DATA:
					token.sa = e.data.sa;
					if(!token.sa && e.data.dtreeData != null && e.data.dtreeData.ID == 0)
					{
						token.assessmentName = e.data.assessmentName;
						token.dtreeData = e.data.dtreeData;
					}
					break;
			}
			token.addResponder(responder);
		}
		private function delegateFault(e: FaultEvent): void
		{
			Alert.show(ResourceStrings.ERROR_STATUS_STR /* + '\n' + e.fault.faultString */, ResourceStrings.ERROR_STR, Alert.OK, null, null, AssetLocator.ERROR);
			dtreeModel.updateEnabled(true);
			trace(e.token.remoteID, e.fault.faultString);
			if(dtreeData != null)
			{
				dtreeData = null;
			}
		}
		public function handlerQuestionList(e: DecisionTreeEvent): void
		{
			dtreeModel.questions = new XMLListCollection();
			execOp(e, GET_Q_DATA, new Responder(resultHandlerQuestionList, delegateFault));
		}
		private function resultHandlerQuestionList(e: ResultEvent): void
		{
			dtreeModel.questions = new XMLListCollection(XMLList(e.result)..Question);
			Util.sortXLC(dtreeModel.questions, "QuestionName");
			refreshDescriptionList();
		}
		public function handlerTerminationActionList(e: DecisionTreeEvent): void
		{
			dtreeModel.terminatingActions = new XMLListCollection();
			execOp(e, 'getTerminatingActions', new Responder(resultHandlerTerminatingActionList, delegateFault));
		}
		private function resultHandlerTerminatingActionList(e: ResultEvent): void
		{
			dtreeModel.terminatingActions = new XMLListCollection(XMLList(e.result)..TerminatingOption);
			Util.sortXLC(dtreeModel.terminatingActions, "TerminatingOptionText");
			refreshDescriptionList();
		}
		public function handleCategoryList(e: DecisionTreeEvent): void
		{
			dtreeModel.categoryList = new XMLListCollection();
			execOp(e, 'getCategoryList', new Responder(resultHandlerCategoryList, delegateFault));
		}
		private function resultHandlerCategoryList(e: ResultEvent): void
		{
			var xml: XMLList = XMLList(e.result);
			if(xml.toString() == "")
			{
				xml += DTreeGlobals.getDefaultCategoryXML();
			}
			else
			{
				xml.appendChild(DTreeGlobals.getDefaultCategoryXML());
			}
			dtreeModel.categoryList = new XMLListCollection(xml..CategoryList);
			dispatchEvent(new DecisionTreeEvent(null, DecisionTreeEvent.REFRESH_CATEGORY_LIST));
			refreshDescriptionList();
		}
		public function saveDecisionTree(e: DecisionTreeEvent): void
		{
			execOp(e, SAVE_ATREE_DATA, new Responder(resultHandlerSave, delegateFault));
		}
		public function saveQuestionFor(e: DecisionTreeEvent): void
		{
			execOp(e, 'saveQuestionDataFor', new Responder(resultHandlerSave, delegateFault));
		}
		private function resultHandlerSave(e: ResultEvent): void
		{
			switch(e.token.remoteID)
			{
				case SAVE_ATREE_DATA:
					if(!e.token.sa && e.token.dtreeData != null && e.token.dtreeData.ID == 0)
					{
						e.token.dtreeData.ID = e.result;
						e.token.dtreeData.Name = e.token.assessmentName;
					}
					break;
			}
			Alert.show(ResourceStrings.SUCCSS_SAVE_STR, ResourceStrings.INFORMATION_STR, Alert.OK, null, null, AssetLocator.INFO);
			dtreeModel.updateEnabled(true);
		}
		public function handlerDecisionList(e: DecisionTreeEvent): void
		{
			dtreeModel.decisionTrees = new XMLListCollection();
			execOp(e, 'getAssessmentsList', new Responder(resultHandlerGetDecisionTreeData, delegateFault));
		}
		private function resultHandlerGetDecisionTreeData(e: ResultEvent): void
		{
			dtreeModel.decisionTrees = new XMLListCollection(XMLList(e.result)..AssessmentList);
			Util.sortXLC(dtreeModel.decisionTrees, "@AssessmentName");
			dispatchEvent(new DecisionTreeEvent(null, DecisionTreeEvent.LISTCHANGE_DECISIONTREE));
			refreshDescriptionList();
		}
		private var dtreeData: DTreeData;
		private var pt: Point;
		private var dtreedata: *;
		private var overrideProperties: Boolean;
		public function editDecisionTree(e: DTreeEvent): void
		{
			var isEdit: Boolean = e.type == DecisionTreeEvent.EDIT_DECISIONTREE;
			dtreeData = new DTreeData();
			if(isEdit)
			{
				dtreeData.ID = XML(e.data).@AssessmentTreeID;
				dtreeData.Name = XML(e.data).@AssessmentName;
			}
			else
			{
				dtreeData.ID = XML(e.data.xml).@AssessmentTreeID;
				pt = e.data.pt;
				dtreedata = e.data.dtree;
				overrideProperties = e.data.overrideProperties;
			}
			execOp(e, GET_ATREE_EDIT, new Responder(isEdit ? resultHandlerEditDecisionTree : resultHandlerEditDecisionTreeMerge, delegateFault));
		}
		private function resultHandlerEditDecisionTree(e: ResultEvent): void
		{
			dtreeData.xml = XMLList(e.result);
			dispatchEvent(new DecisionTreeEvent(dtreeData, DecisionTreeEvent.OPEN_DECISIONTREE));
		}
		private function resultHandlerEditDecisionTreeMerge(e: ResultEvent): void
		{
			var data: * = {};
			data.xml = XMLList(e.result);
			data.pt = pt;
			data.dtree = dtreedata;
			data.overrideProperties = overrideProperties;
			dispatchEvent(new DecisionTreeEvent(data, DecisionTreeEvent.OPEN_DECISIONTREE));
		}
		public function editQuestionFor(e: DecisionTreeEvent): void
		{
			execOp(e, GET_QDATA_FOR, new Responder(resultHandlerGetQuestionDataFor, delegateFault));
		}
		private function resultHandlerGetQuestionDataFor(e: ResultEvent): void
		{
			dtreeModel.updateEnabled(true);
			dispatchEvent(new DecisionTreeEvent(XML(e.result), DecisionTreeEvent.OPEN_QUESTION));
		}
	}
}