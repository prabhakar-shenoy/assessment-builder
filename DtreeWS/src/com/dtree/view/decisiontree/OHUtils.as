package com.dtree.view.decisiontree
{
	import com.dtree.model.vo.QVO;
	import com.roguedevelopment.objecthandles.CircleHandle;
	import com.roguedevelopment.objecthandles.Flex4ChildManager;
	import com.roguedevelopment.objecthandles.ObjectHandles;
	import com.roguedevelopment.objecthandles.constraints.SizeConstraint;
	import com.roguedevelopment.objecthandles.decorators.AlignmentDecorator;
	import com.roguedevelopment.objecthandles.decorators.DecoratorManager;
	import flash.display.Sprite;
	import mx.core.ClassFactory;
	import spark.components.BorderContainer;
	internal class OHUtils
	{
		public static const MAX_HW: Number = 3500;
		public static function getObjectHandle(canvas: BorderContainer): ObjectHandles
		{
			var constraint: SizeConstraint = new SizeConstraint();
			constraint.minWidth = QVO._WIDTH;
			constraint.minHeight = QVO._HEIGHT;
			constraint.maxWidth = MAX_HW;
			constraint.maxHeight = MAX_HW;
			var result: ObjectHandles = new ObjectHandles(canvas, null, new ClassFactory(CircleHandle), new Flex4ChildManager(), false, [constraint]);
			constraint = new SizeConstraint();
			constraint.maxWidth = QVO.MAX_WIDTH;
			constraint.maxHeight = QVO.MAX_HEIGHT;
			result.addDefaultConstraint(constraint);
			result.enableMultiSelect = true;
			return result;
		}
		
		public static function getDecorationManager(oh: ObjectHandles, drawLayer: Sprite): DecoratorManager
		{
			var result: DecoratorManager = new DecoratorManager(oh, drawLayer);
			result.addDecorator(new AlignmentDecorator());
			return result;
		}
	}
}