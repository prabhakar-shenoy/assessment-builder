package com.dtree.view.decisiontree
{
	public interface ILevels extends ITreeModule
	{
		function get minLevel(): Number;
		function get maxLevel(): Number;
		function set minLevel(value: Number): void;
		function set maxLevel(value: Number): void;
	}
}