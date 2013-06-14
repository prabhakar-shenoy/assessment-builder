package com.dtree.view
{
	import com.dtree.view.decisiontree.ILevels;
	import com.dtree.view.decisiontree.ITreeCanvas;
	public interface IHost
	{
		function get levels(): ILevels;
		function get treeCanvas(): ITreeCanvas;
	}
}