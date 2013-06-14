package com.dtree.view.decisiontree
{
	import com.dtree.model.presentation.DtreeModuleModel;
	import spark.components.BorderContainer;
	public interface ITreeCanvas extends ITreeModule
	{
		function hasDTreeItems(): Boolean;
		function save(): void;
		function saveAs(): void;
		function mergeWith(value: *): void
		function get model(): DtreeModuleModel;
		function get canvas(): BorderContainer;
		function updateRange(): void;
	}
}