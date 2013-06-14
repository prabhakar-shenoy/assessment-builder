package com.dtree.view.decisiontree
{
	import com.dtree.common.ResourceStrings;
	import mx.collections.XMLListCollection;
	import mx.utils.StringUtil;
	import mx.utils.UIDUtil;
	import spark.components.BorderContainer;
	public class DTreeGlobals
	{
		public static function contains(xml: XML, container: BorderContainer): Boolean
		{
			var result: Boolean = false;
			if(container != null)
			{
				var isQuestion: Boolean = String(xml.name()).toLowerCase() == "question";
				for(var i:int = 0; i < container.numElements; i++)
				{
					var grp: IDTreeGroup = container.getElementAt(i) as IDTreeGroup;
					if(grp != null)
					{
						if(isQuestion && grp is IQuestionGroup)
						{
							var qg: IQuestionGroup = IQuestionGroup(grp);
							if(qg.xml != null && qg.xml.QuestionID == xml.QuestionID)
							{
								result = true;
								break;
							}
						}
						if(!isQuestion && grp is ITAGroup)
						{
							var tg: ITAGroup = ITAGroup(grp);
							if(tg.xml != null && tg.xml.TerminatingOptionID == xml.TerminatingOptionID)
							{
								result = true;
								break;
							}
						}
					}
				}
			}
			return result;
		}
		public static function getCopyXML(copies: Number): XML
		{
			var result: XML = <ncopy/>
			result.appendChild(copies);
			return result;
		}
		private static const YES_STR: String = 'yes';
		public static function isYes(s: String): Boolean
		{
			return s != null && s.toLowerCase() == YES_STR;
		}
		public static function isOOPS(data: *): Boolean
		{
			return false; // data != null && isYes(data.@OOPS);
		}
		public static function yn(data: *): Boolean
		{
			return data != null && isYes(data.@IsBestAnswer);
		}
		public static function yesNo(value: Boolean): String
		{
			return value ? YES_STR : "no";
		}
		public static function addOOPS(oops: Boolean, xml: XML): XML
		{
			if(xml != null)
			{
				xml.@['OOPS'] = yesNo(oops);
			}
			return xml;
		}
		private static function createLevelOptionXML(oops: Boolean, isCorrect: Boolean):XML
		{
			var result:XML = <OptionName/>;
			result.@['OptionText'] = oops ? ResourceStrings.OOPS_STR: (isCorrect ? ResourceStrings.CORRECT_ANS : ResourceStrings.WRONG_ANS);
			result.@['IsBestAnswer'] = yesNo(isCorrect);
			//result = addOOPS(oops, result);
			return result;
		}
		public static function getLevelXMLForLevel(level: int): XML
		{
			var result: XML = <QuestionLevel/>;
			result.appendChild(level);
			return result;
		}
		public static function getLevelXML(level: int, list: Boolean = false): XML
		{
			var result: XML = <Question/>;
			var xml: XML = getLevelXMLForLevel(level);
			result.appendChild(xml);
			if(list)
			{
				result.appendChild(getCopyXML(4));
			}
			else
			{
				xml = <QuestionID/>;
				xml.appendChild(UIDUtil.createUID());
				result.appendChild(xml);
			}
			xml = <QuestionName/>;
			xml.appendChild(StringUtil.substitute(ResourceStrings.LEVEL_STR, level));
			result.appendChild(xml);
			var options: XML = <Options/>
			options.appendChild(createLevelOptionXML(false, true));
			options.appendChild(createLevelOptionXML(false, false));
			//options.appendChild(createLevelOptionXML(true, false));
			result.appendChild(options);
			return result;
		}
		private static function getLevelXMLFor(minLevel: int, maxLevel: int): XML
		{
			var result: XML = <Questions/>;
			if(minLevel > maxLevel)
			{
				minLevel += maxLevel;
				maxLevel = minLevel - maxLevel;
				minLevel = minLevel - maxLevel;
			}
			for(var i: int = minLevel; i <= maxLevel; i++)
			{
				result.appendChild(getLevelXML(i, true));
			}
			return result;
		}
		public static const LEVELS: XML = getLevelXMLFor(1, 1000);
		public static function getxmLList(data: *): XMLListCollection
		{
			return new XMLListCollection(data.xml..Question);
		}
		public static function getDefaultCategoryXML(): XML
		{
			var result: XML = <CategoryList/>
			result.@['AssessmentQuestionCategoryId'] = -1;
			result.@['CategoryName'] = ResourceStrings.ALL_CATEGORY;
			result.@['CategoryDescription'] = ResourceStrings.ALL_CATEGORY;
			return result;
		}
	}
}