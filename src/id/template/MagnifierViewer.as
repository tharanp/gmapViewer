﻿////////////////////////////////////////////////////////////////////////////////
//
//  OPEN EXHIBITS
//  Copyright 2011 Open Exhibits
//  All Rights Reserved.
//
//  Magnifier Viewer Class
//
//  File:     MagnifierViewer.as
//  Authors:    David Heath (davidh(at)ideum(dot)com) but is based on prior work by Chris Gerber at Ideum.
//
//  NOTICE: Open Exhibits permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
//
////////////////////////////////////////////////////////////////////////////////
package id.template
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	import gl.events.GestureEvent;
	import gl.events.TouchEvent;
	
	import id.component.Content;
	import id.core.ApplicationGlobals;
	import id.core.TouchComponent;
	import id.core.TouchSprite;
	import id.core.id_internal;
	import id.element.ContentParser;
	import id.element.TextDisplay;
	import id.module.FlickrViewer;
	import id.utils.BitmapDataUtil;
	FlickrViewer;
	import id.module.ImageViewer;
	ImageViewer;
	import id.module.VideoViewer;
	VideoViewer;
	import id.module.YouTubeViewer;
	YouTubeViewer;
	import id.module.KeyViewer;
	KeyViewer;
	import id.module.GMapViewer;
	import id.component.StaticGMapDisplay;
	import flash.display.LoaderInfo;
	import flash.utils.setTimeout;

	//import flash.events.GestureEvent;

	GMapViewer;
	/**
	     *  Constructor.
	     *  
	     * @langversion 3.0
	     * @playerversion AIR 1.5
	     * @playerversion Flash 10
	     * @playerversion Flash Lite 4
	     * @productversion GestureWorks 1.5
	     */
	public class MagnifierViewer extends TouchComponent
	{
		protected var templates:Object;
		protected var modules:Object;
		
		private var _id:int;
		private var count:int;
		private var moduleClass:Class;
		private var module:DisplayObject;
		private var txt:TextDisplay;
		public var loadingTimer:Timer;
		private var layoutCalled:Boolean;
		private var secondTime:Boolean;
		private var templateLoaded:Boolean;
		private var objects:Array = new Array();
		private var isTemplateLoaded:Boolean;
		private var moduleDictionary:Dictionary = new Dictionary();
		private var moduleID:Array = new Array();
		private var moduleNameArray:Array = new Array();
		public var magnifiers:Array = new Array();
		private var contentHolders:Array = new Array();
		private var _moduleName:String = "";

		protected var splashScreenTimeout:Number;
		public static const SPLASHSCREEN_TIMEOUT:Number = 5000; // 5sec
		
		private var _displayMask:Sprite;
		private var _magnifier:Magnifier;
		private var stageWidth:int;
		private var stageHeight:int;
		private var alreadyMoving:int = 0;

		private var container:TouchComponent;
		private var containerGlass:TouchComponent;

		public var containerContent:TouchSprite = new TouchSprite();
		private var contentHolder:Content;

		private var markerlijst:Array= new Array();
		private var counter = 0;
		private var naam:Number = new Number();
		private var eigenKlasse;

		public var numMagnifiers:int = 1; //number of magnifier glasses
		private var addMa:TouchSprite = new TouchSprite();
		private var addMag:TouchSprite = new TouchSprite();
		private var ring1:TouchSprite  = new TouchSprite();

		private var testHolder:TouchSprite = new TouchSprite();
		private var firstTime:Boolean = false;

		private var test:Boolean = true;
		private var markerLijst:Array = new Array();
		private var bt;
		private var vout = 0;
		private var zout = 0;
		private var prevNum:String = "";
		private var nummerArray:Array = new Array("","","","","","");
		private var nogGoed = 0;
		
		private var friction:Number = 0.9;
		private var dx:Number = 0;
		private var dy:Number = 0;
		private var updateLensTimer:Timer;
		
		public var gMapViewer:GMapViewer;
		
		public var mapAndContentLayer:TouchSprite;
		public var mapViewerLayer:Sprite;
		public var contentLayer:TouchSprite;
		public var magnifierLayer:TouchSprite;
		public var splashScreenLayer:Sprite;


		public function MagnifierViewer()
		{
			super();
			
			width = stageWidth = ApplicationGlobals.application.stage.stageWidth;
			height = stageHeight = ApplicationGlobals.application.stage.stageHeight;
			numMagnifiers = parseInt(ApplicationGlobals.dataManager.data.Template.magnifier.number);
			
			mapAndContentLayer = new TouchSprite();
			addChild(mapAndContentLayer);
			
			mapViewerLayer = new Sprite();
			mapViewerLayer.graphics.beginFill(0xFFFFFF);
			mapViewerLayer.graphics.drawRect(0,0,stageWidth,stageHeight);
			mapAndContentLayer.addChild(mapViewerLayer);
			
			if ( Global.MAGNIFIER_ON_TOP ) {
				contentLayer = new TouchSprite();
				mapAndContentLayer.addChild(contentLayer);
			}
			
			var pitLogo:PITLogo = new PITLogo();	
			pitLogo.x = width - 150;
			pitLogo.y = 50;
			addChild(pitLogo);
			
			magnifierLayer = new TouchSprite();
			addChild(magnifierLayer);
			
			if ( !Global.MAGNIFIER_ON_TOP ) {
				contentLayer = new TouchSprite();
				addChild(contentLayer);
			}
			
			templates = ApplicationGlobals.dataManager.data.Template;
			initModules(templates[0]);
			
			splashScreenTimeout = setTimeout( function(){ splashScreenLayer.visible = false; }, SPLASHSCREEN_TIMEOUT );
			splashScreenLayer = new Sprite();
			addChild(splashScreenLayer);
			var splashScreenLoader:Loader = new Loader();
			splashScreenLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
				(e.target as LoaderInfo).content.width = stageWidth;
				(e.target as LoaderInfo).content.height = stageHeight;
			}, false, 0, true);
			splashScreenLoader.load(new URLRequest(templates.background));
			splashScreenLayer.addChild(splashScreenLoader);
			
			for ( var i:int=0; i<numMagnifiers; i++ ) {
				var m:Magnifier = new Magnifier();
				m.x = Math.random() * width;
				m.y = Math.random() * height;
				
				m.minSize = 1;
				m.maxSize = 3;
				m.scaleAdjustable = false;
				m.continuousRenderer = false;
				m.vectorRenderer = true;
				m.captureTarget = mapAndContentLayer;
				m.contentLayer = contentLayer;
				
				m.addEventListener(TouchEvent.TOUCH_DOWN, magnifier_touchDownHandler, false, 0, true);
				m.addEventListener(TouchEvent.TOUCH_UP, magnifier_touchUpHandler, false, 0, true);
				m.addEventListener(TouchEvent.TOUCH_MOVE,  magnifier_touchMove, false, 0, true);
				m.addEventListener(GestureEvent.GESTURE_FLICK,flickGestureHandler, false, 0, true);
				
				m.init();
				
				magnifiers.push( m );
				
				magnifierLayer.addChild( m );
			}
		}
		
		protected function initModules(template:Object):void {	
			modules = template.module;
			
			for ( var i:int=0; i<modules.length(); i++) {
				var moduleClass:Class = getDefinitionByName("id.module." + modules[i]) as Class;
				moduleDictionary[module] = modules[i];
				switch(String(modules[i])) {
					case "GMapViewer":
						var settingsPath:String = "config/"+Global.environment+"/GMapViewer.xml";
						gMapViewer = new GMapViewer(settingsPath);
						mapViewerLayer.addChild(gMapViewer);
						break;
				}
			}
		}
		
		public function reset():void {
			trace('MagnifierViewer.reset()');
			
			// clear all content of screen
			
			for (var i:int=0; i<magnifiers.length; i++) {
				var m:Magnifier = magnifiers[i] as Magnifier;
				m.content.clearAllContent();
			}
		}

		override public function get id():int
		{
			return _id;
		}
		override public function set id(value:int):void
		{
			_id = value;
		}

		override public function get moduleName():String
		{
			return _moduleName;
		}
		override public function set moduleName(value:String):void
		{
			_moduleName = value;
		}

		protected function magnifier_touchMove(event:TouchEvent):void
		{
			if ( gMapViewer ) {			
				if ( StaticGMapDisplay.DEBUG_COLLISION_DETECTION ) 		gMapViewer.mapDisplay.graphics.clear();
				
				for each( var magnifier:Magnifier in magnifiers) {
					//magnifier.captureBitmap();
					
					var target:Marker = gMapViewer.mapDisplay.collisionDetect(magnifier.x, magnifier.y);
					if ( target )	{
						// show content if not shown yet
						var contentId:int = target.contentId;
						magnifier.expand(contentId);
					} else {
						magnifier.collapse();
					}
				}
			}
		}

		protected function magnifier_touchDownHandler(event:TouchEvent):void
		{
			if ( event.target is Magnifier ) {
				(event.target as Magnifier).startTouchDrag(-1, true, new Rectangle(0, 0,stageWidth,stageHeight));
			}
		}
		
		protected function magnifier_touchUpHandler(event:TouchEvent):void
		{
			if ( event.target is Magnifier ) {
				(event.target as Magnifier).stopTouchDrag(-1);
			}
		}
		
		private function flickGestureHandler(e:GestureEvent):void
		{
			dx = e.velocityX;
			dy = e.velocityY;
			//addEventListener(Event.ENTER_FRAME,onEnterFrameHandler);
		}
		
		public function updateAllMagnifiers():void {
			var magnifiers_length:int = magnifiers.length;
			for ( var i:int=0; i<magnifiers_length; i++ ) {
				 (magnifiers[i] as Magnifier).captureBitmap();
			}	
		}
		
		override public function Dispose():void {
			if ( gMapViewer )			gMapViewer.Dispose();
		
			trace(this + ".Dispose()");
			
			super.Dispose();
		}
	}
}