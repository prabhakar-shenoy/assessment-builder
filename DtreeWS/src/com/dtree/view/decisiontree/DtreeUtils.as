package com.dtree.view.decisiontree
{
	import com.dtree.view.decisiontree.core.DTreeInputJack;
	import com.dtree.view.decisiontree.core.DTreeOutputJack;
	import com.flextoolbox.controls.WireJack;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import org.spicefactory.parsley.core.context.Context;
	import spark.components.BorderContainer;
	internal class DtreeUtils
	{
		/**
		 * Variable used to Generate XML with Default Value
		 * if true Questions and Options descriptions are *not* included for the XML generated For Save and SaveAs to make it light-weight
		 */
		public static var GENERATE_WITH_DEFAULT: Boolean = true;
		public static function getDTreeGroupBox(xml: XML, container: BorderContainer): DTreeGroup
		{
			var result: DTreeGroup = null;
			if(container != null)
			{
				var isQuestion: Boolean = String(xml.name()).toLowerCase() == "question";
				for(var i: int = 0; i < container.numElements; i++)
				{
					var grp: DTreeGroup = container.getElementAt(i) as DTreeGroup;
					if(grp != null)
					{
						if(isQuestion && grp is QuestionGroup)
						{
							var qg: QuestionGroup = QuestionGroup(grp);
							if(qg.xml != null && qg.xml.QuestionID == xml.QuestionID)
							{
								result = qg;
								break;
							}
						}
						if(!isQuestion && grp is TAGroup)
						{
							var tg: TAGroup = TAGroup(grp);
							if(tg.xml != null && tg.xml.TerminatingOptionID == xml.TerminatingOptionID)
							{
								result = tg;
								break;
							}
						}
					}
				}
			}
			return result;
		}
		public static function getDTreeGroup(clazz: Class, ctx: Context): DTreeGroup
		{
			var result:DTreeGroup = DTreeGroup(new clazz());
			if(result)
			{
				//ctx.viewManager.addViewRoot(result);
			}
			return result;
		}
		private static function getDTreeBox(xml: XML, ctx: Context, container: BorderContainer, isQ: Boolean): DTreeGroup
		{
			var result: DTreeGroup;
			if(!DTreeGlobals.contains(xml, container))
			{
				result = getDTreeGroup(isQ ? QuestionGroup : TAGroup, ctx);
				if(isQ)
				{
					QuestionGroup(result).xml = xml;
					QuestionGroup(result).startingQuestionRB.selected = xml.IsStartingQuestion == "1";
				}
				else
				{
					TAGroup(result).xml = xml;
				}
			}
			return result;
		}
		public static function getQuestionGroupBox(xml: XML, ctx: Context, container: BorderContainer): QuestionGroup
		{
			return QuestionGroup(getDTreeBox(xml, ctx, container, true));
		}
		public static function getTAGroupBox(xml: XML, ctx: Context, container: BorderContainer): TAGroup
		{
			return TAGroup(getDTreeBox(xml, ctx, container, false));
		}
		public static function removeDtreeGroupBox(grp: DTreeGroup): void
		{
			grp.exitView();
			const f: Function = function disconnectQuestionJack(jack: DTreeOutputJack): void
				{
					for each(var inputJack: DTreeInputJack in jack.connectedJacks)
					{
						inputJack.disconnect(jack);
					}
				}
			if(grp is QuestionGroup)
			{
				var box: QuestionGroup = QuestionGroup(grp);
				for(var i:int = 0; i < box.options.dataGroup.numElements; i++)
				{
					var renderer: OptionRenderer = box.options.dataGroup.getElementAt(i) as OptionRenderer;
					if(renderer != null && renderer.optionJack != null && renderer.optionJack.connectedJacks.length > 0)
					{
						renderer.disConnectAll();
					}
				}
				f(box.questionJack);
			}
			if(grp is TAGroup)
			{
				f(TAGroup(grp).taJack);
			}
			(grp.owner as BorderContainer).removeElement(grp);
			grp = null;
		}
		private static function createOptionXML(dtreeID: int, container: BorderContainer, qID: String,  inputJack: DTreeInputJack, isRandom: Boolean):XML
		{
			var xml: XML = XML(inputJack.dtreeData);
			var result:XML = <OptionName/>;
			if(!isRandom)
			{
				result.@['AssessmentTreeID'] = dtreeID;
				result.@['OptionID'] = xml.@OptionID;
			}
			else
			{
				//result = DTreeGlobals.addOPS(xml.@OOPS, result);
			}
			if(!GENERATE_WITH_DEFAULT)
			{
				result.@['OptionQuestionID'] = xml.@OptionQuestionID;
				result.@['OptionText'] = xml.@OptionText;
				result.@['IsBestAnswer'] = xml.@IsBestAnswer;
			}
			result.@['QuestionID'] = qID;
			if(isRandom)
			{
				result.@['IsBestAnswer'] = xml.@IsBestAnswer;
			}
			var ar: Array = inputJack.connectedJacks;
			var lContinue: Boolean = ar.length > 0;
			var nextQuestionID: * = 0;
			var isQuestion: Boolean = true;
			var _x: * = 0;
			var _y: * = 0;
			var _width:* = 0;
			if(lContinue)
			{
				for each(var o:WireJack in ar)
				{
					if(o is DTreeOutputJack)
					{
						var jack: DTreeOutputJack = DTreeOutputJack(o);
						var tdata:XML = XML(jack.dtreeData);
						isQuestion = String(tdata.name()).toLowerCase() == "question";
						nextQuestionID = isQuestion ? tdata.QuestionID.toString() : tdata.TerminatingOptionID.toString();
						if(!isQuestion)
						{
							var dGrp:DTreeGroup = getTAGroupByID(nextQuestionID, container);
							if(dGrp != null)
							{
								_x = dGrp.x;
								_y = dGrp.y;
								_width = dGrp.width;
							}
						}
					}
				}
			}
			if(!isQuestion)
			{
				result.@['x'] = _x;
				result.@['y'] = _y;
				result.@['width'] = _width;
			}
			result.@['GoToQuestionID'] = isQuestion ? nextQuestionID : 0;
			result.@['TerminatingActionID'] = !isQuestion ? nextQuestionID : 0;
			return result;
		}
		private static function createOptionsXML(dtreeID: int, container: BorderContainer, qg: QuestionGroup, isRandom: Boolean): XML
		{
			var result: XML = <Options/>;
			var xml: XML;
			const f: Function = function(jack: DTreeInputJack): XML
				{
					return createOptionXML(dtreeID, container, qg.xml.QuestionID.toString(), jack, isRandom);
				}
			for(var i:int = 0; i < qg.options.dataGroup.numElements; i++)
			{
				xml = null;
				if(qg.collapseBtn.selected)
				{
					xml = f((qg.options.dataGroup.getElementAt(i) as OptionRenderer).optionJack);
				}
				else
				{
					var aElement: IVisualElement = qg.jacksContainer.getElementAt(i);
					if(aElement is DTreeInputJack)
					{
						xml = f(aElement as DTreeInputJack);
					}
				}
				if(xml != null)
				{
					result.appendChild(xml);
				}
			}
			return result;
		}
		private static function createQuestionXML(dtreeID: int, container: BorderContainer, qg: QuestionGroup, isRandom: Boolean): XML
		{
			var result: XML = <Question/>;
			result.@['x'] = qg.x;
			result.@['y'] = qg.y;
			result.@['width'] = qg.width;
			result.@['height'] = qg.height;
			result.@['minimized'] = qg.collapseBtn.selected;
			var xml: XML = <QuestionID/>;
			xml.appendChild(qg.xml.QuestionID.toString());
			result.appendChild(xml);
			if(isRandom)
			{
				xml = DTreeGlobals.getLevelXMLForLevel(qg.xml.QuestionLevel);
				result.appendChild(xml);
			}
			if(!GENERATE_WITH_DEFAULT)
			{
				xml = <QuestionName/>;
				xml.appendChild(qg.xml.QuestionName);
				result.appendChild(xml);
			}
			xml = <IsStartingQuestion/>;
			xml.appendChild(qg.startingQuestionRB.selected ? "1" : "0");
			result.appendChild(xml);
			if(!isRandom)
			{
				xml = <QuestionType/>;
				xml.appendChild(qg.xml.QuestionType.toString());
				result.appendChild(xml);
			}
			result.appendChild(createOptionsXML(dtreeID, container, qg, isRandom));
			return result;
		}
		public static function isDTreeGroup(c: *): Boolean
		{
			var result: Boolean = false;
			if(c != null && c is UIComponent)
			{
				var comp: UIComponent = UIComponent(c);
				while(!result && comp != null)
				{
					result = comp is DTreeGroup;
					if(result)
					{
						break;
					}
					else
					{
						comp = comp.owner as UIComponent;
					}
				}
			}
			return result;
		}
		public static function getTAXML(option: XML): XML
		{
			var result:XML = null;
			if(option.attribute("TerminatingActionID").length() > 0 && option.@TerminatingActionID != 0)
			{
				result = <TerminatingOption/>;
				result.@['x'] = option.@x.toString();
				result.@['y'] = option.@y.toString();
				result.@['width'] = option.@width.toString();
				var xml: XML = <TerminatingOptionID/>;
				xml.appendChild(option.@TerminatingActionID.toString());
				result.appendChild(xml);
				xml = <TerminatingOptionText/>
				xml.appendChild(option.@TerminatingActionText.toString());
				result.appendChild(xml);
			}
			return result;
		}
		public static function getDTreeXML(dtreeID: int, container: BorderContainer, isRandom: Boolean, levels: ILevels, description: String = null): XML
		{
			var result: XML = <AssessmentTree/>;
			result.@['AssessmentTreeID'] = dtreeID;
			if(dtreeID == 0)
			{
				result.@['AssessmentName'] = description;
			}
			result.@['isRandom'] = isRandom ? 1 : 0; //DTreeGlobals.yesNo(isRandom);
			if(isRandom)
			{
				result.@['minimumLevel'] = levels.minLevel;
				result.@['maximumLevel'] = levels.maxLevel;
			}
			for(var i: int = 0; i < container.numElements; i++)
			{
				var qg: QuestionGroup = container.getElementAt(i) as QuestionGroup;
				if(qg != null && qg.xml != null)
				{
					result.appendChild(createQuestionXML(dtreeID, container, qg, isRandom));
				}
			}
			return result;
		}
		public static function getQuestionGroupByID(id: *, container: BorderContainer): QuestionGroup
		{
			var result: QuestionGroup = null;
			for(var i: int = 0; i < container.numElements; i++)
			{
				var qg: QuestionGroup = container.getElementAt(i) as QuestionGroup;
				if(qg != null && qg.xml.QuestionID == id)
				{
					result = qg;
					break;
				}
			}
			return result
		}
		public static function getTAGroupByID(id: *, container: BorderContainer): TAGroup
		{
			var result: TAGroup = null;
			for(var i: int = 0; i < container.numElements; i++)
			{
				var tg: TAGroup = container.getElementAt(i) as TAGroup;
				if(tg != null && tg.xml.TerminatingOptionID == id)
				{
					result = tg;
					break;
				}
			}
			return result
		}
		public static function getQXMLFor(xml: XML): Vector.<Object>
		{
			var result: Vector.<Object> = new Vector.<Object>();
			for(var i: int = 0; i < xml.ncopy; i++)
			{
				result.push(DTreeGlobals.getLevelXML(xml.QuestionLevel));
			}
			return result;
		}
	}
}