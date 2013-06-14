package
{
	internal final class ConfigConsts
	{
		import com.dtree.model.presentation.DtreeModel;
		import flash.external.ExternalInterface;
		private static const LANUNCH_URL: String = "/AssessmentBuilder/Default.aspx".toLowerCase();
		private static function getRootContextFor(model: DtreeModel, url: String, isLocal: Boolean): void
		{
			const http: String = 'http://';
			const https: String = 'https://';
			const SEP: String = '/';
			var endIndex: int = url.indexOf(SEP, (url.indexOf(https) > -1 ? https.length : http.length));
			var rootContext: String = url.substr(0, endIndex);
			url = url.substr(endIndex + 1);
			var context: String = url.substr(0, url.indexOf(SEP, 0)); 
			rootContext += SEP + context;
			model.rootHost = rootContext;
			model.isDemo = !isLocal;
			if(model.isDemo)
			{
				url = url.substr(context.length);
				model.isDemo = LANUNCH_URL != url;
			}
			else
			{
				//model.isDemo = true;
			}
		}
		private static const RELATIVE_WSDL_URL: String = '/WebService.asmx?wsdl';
		private static const ASSESSMENTTREE: String = 'http://www.assessmenttree.com';
		private static const CONTEXTROOT: String = '/Admin';
		private static const DBL: String = 'http://www.developmentbeyondlearning.com';
		private static const DBL_CONTEXTROOT: String = '/DBLAssessmentStagingAdmin';
		private static const P_WSDL_URL: String = ASSESSMENTTREE + CONTEXTROOT + RELATIVE_WSDL_URL;
		private static const S_WSDL_URL: String = DBL + DBL_CONTEXTROOT + RELATIVE_WSDL_URL;
		private static const WSDL_URL: String = S_WSDL_URL;
		private static const LOCAL_URL_MAC: String = 'file:///users/prabhakar/dev/flexmodule/dtree/dtreews/bin-debug/dtree.html';
		private static const LOCAL_URL_WIN: String = 'file:///c:/users/m.prabhakar/desktop/dev/flexmodule/dtree/dtreews/bin-debug/dtree.html';
		public static function getWSDLURL(model: DtreeModel): String
		{
			var url: String = String(ExternalInterface.call("eval", "window.location.href")).toLowerCase();
			var result: String = "";
			if(url != null && model != null)
			{
				url = url.toLocaleLowerCase();
				var isLocal: Boolean = url == LOCAL_URL_MAC || url == LOCAL_URL_WIN;
				if(isLocal)
				{
					url = WSDL_URL;
				}
				getRootContextFor(model, url, isLocal);
				result = model.rootHost + RELATIVE_WSDL_URL;
			}
			return result;
		}
	}
}