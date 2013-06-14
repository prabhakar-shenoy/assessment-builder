package com.dtree.view.decisiontree
{
	import com.dtree.model.vo.DTreeData;
	import com.dtree.view.IHost;
	import mx.modules.IModule;
	public interface ITreeModule extends IModule
	{
		function get host(): IHost;
		function set host(value: IHost): void;
		function openDecisionTreeData(value: DTreeData): void
	}
}