﻿package id.element
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.system.Security;

	/**
	 * This is the FlickrParser class.
	 * 
	 * @langversion 3.0
	 * @playerversion AIR 2
	 * @playerversion Flash 10
	 * @playerversion Flash Lite 4
	 * @productversion GestureWorks 2.0
	 */
	public class FlickrDisplayParser extends EventDispatcher
	{
		public static var settings:XML;
		public static var dataSet:Array = new Array();
		public static var flickr:Array = new Array();
		private static var _settingsPath:String = "";
		private static var _settingsId:String = "";
		private static var settingsLoader:URLLoader;
		protected static var dispatch:EventDispatcher;


		public static function get settingsPath():String
		{
			return _settingsPath;
		}
		public static function set settingsId(value:String):void
		{
			//trace("geklikt: ",value);
			_settingsId = value;
		}
		public static function set settingsPath(value:String):void
		{
			settingsLoader = new URLLoader();
			settingsLoader.addEventListener(Event.COMPLETE, settingsLoader_completeHandler);
			_settingsPath = value;
			settingsLoader.load(new URLRequest(_settingsPath));
		}

		private static function settingsLoader_completeHandler(event:Event):void
		{
			settings = new XML(settingsLoader.data);
			//trace(amountToShow);}
			settingsLoader.removeEventListener(Event.COMPLETE, settingsLoader_completeHandler);
			settingsLoader = null;
		}




		public static function addEventListener(p_type:String, p_listener:Function, p_useCapture:Boolean=false, p_priority:int=0, p_useWeakReference:Boolean=false):void
		{
			if (dispatch == null)
			{
				dispatch = new EventDispatcher();
			}
			dispatch.addEventListener(p_type, p_listener, p_useCapture, p_priority, p_useWeakReference);
		}

		public static function removeEventListener(p_type:String, p_listener:Function, p_useCapture:Boolean=false):void
		{
			if (dispatch == null)
			{
				return;
			}
			dispatch.removeEventListener(p_type, p_listener, p_useCapture);
		}

		public static function dispatchEvent(event:Event):void
		{
			if (dispatch == null)
			{
				return;
			}
			dispatch.dispatchEvent(event);
		}
	}
}
