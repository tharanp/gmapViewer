package
{
	import flash.system.Capabilities;
	
	public class Player
	{
		public static var isAir:Boolean = (Capabilities.playerType == "Desktop");
		public static var isFlashPlayer:Boolean = (Capabilities.playerType == "StandAlone");
		public static var isBrowser:Boolean = (Capabilities.playerType == "ActiveX" || Capabilities.playerType == "PlugIn");
		public static var isOther:Boolean = (Capabilities.playerType == "External");
		
		public static var useSecureDomain:Boolean = false;
		public static var runFullscreen:Boolean = false;
		public static var runOffline:Boolean = false;
		public static var offlineHost:String = "";
		public static var videoHD:Boolean = false;
		public static var isTUIO:Boolean = false;
	}
}