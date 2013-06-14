package com.dtree.view.comps.skins
{
	import spark.skins.spark.TitleWindowSkin;
	public class MyTitleWindowSkin extends TitleWindowSkin
	{
		override public function MyTitleWindowSkin() 
		{
			super();
			titleDisplay.minHeight = 15;
		}
	}
}