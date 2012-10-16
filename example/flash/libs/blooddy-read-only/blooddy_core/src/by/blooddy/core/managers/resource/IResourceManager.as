////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.resource {

	import by.blooddy.core.net.loading.ILoadable;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.04.2010 1:08:39
	 */
	public interface IResourceManager {

		function loadResourceBundle(url:String, priority:int=0.0):ILoadable;

		function hasResource(bundleName:String, resourceName:String=null):Boolean;

		function getResource(bundleName:String, resourceName:String=null):*;

	}

}