package by.blooddy.core.managers.remote {

	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;

	public interface IRemoteModuleManager extends IEventDispatcher {

		function get applicationDomain():ApplicationDomain;

		function load(request:URLRequest, applicationDomain:ApplicationDomain=null):void;

		function loadBytes(bytes:ByteArray, applicationDomain:ApplicationDomain=null):void;

		function hasModule(id:String):Boolean;

		function unload():void;

		function unloadModule(id:String):void;

	}

}