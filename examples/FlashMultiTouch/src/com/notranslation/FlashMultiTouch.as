package com.notranslation
{
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.net.XMLSocket;
	import flash.system.Security;
	import flash.utils.Dictionary;
	
	public class FlashMultiTouch extends Sprite
	{
		public static const OSC_SOCKET_HOST:String = "localhost";
		public static const OSC_SOCKET_PORT:int = 9110;
		public static const TOUCH_RELEASE_TIME:Number = 100.0;
		
		protected var oscSocket:XMLSocket;
		protected var fingerDict:Dictionary;
		protected var fingersToAdd:Vector.<Finger>;
		protected var fingersToRemove:Vector.<Finger>;
		
		public function FlashMultiTouch()
		{
			oscSocket = new XMLSocket();
			oscSocket.addEventListener(Event.CONNECT, socketConnectHandler);
			oscSocket.addEventListener(Event.CLOSE, socketCloseHandler);
			oscSocket.addEventListener(IOErrorEvent.IO_ERROR, socketErrorHandler);
			oscSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			oscSocket.addEventListener(DataEvent.DATA, socketDataHandler);
			oscSocket.connect(OSC_SOCKET_HOST, OSC_SOCKET_PORT);
			
			fingerDict = new Dictionary();
			fingersToAdd = new Vector.<Finger>();
			fingersToRemove = new Vector.<Finger>();
			
			/*var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0xFF0000);
			sprite.graphics.drawCircle(100, 100, 50);
			sprite.graphics.endFill();
			addChild(sprite);*/
			
			addEventListener(Event.ENTER_FRAME, updateFingers);
		}
		
		protected function updateFingers(event:Event):void
		{
			var finger:Finger;
			var fingerId:int;
			
			for each (finger in fingersToAdd)
			{
				fingerId = finger.id;
				fingerDict[fingerId] = finger;
				addChild(finger.sprite);
			}
			fingersToAdd.length = 0;
			
			var curTime:Number = new Date().time;
			
			for each (finger in fingerDict)
			{
				if (curTime - finger.timeLastTouched > TOUCH_RELEASE_TIME)
				{
					fingersToRemove.push(finger);
				}
				else
				{
					finger.render(stage.stageWidth, stage.stageHeight);
				}
			}
			
			for each (finger in fingersToRemove)
			{
				removeChild(finger.sprite);
				delete fingerDict[finger.id];
			}
			fingersToRemove.length = 0;
		}
		
		protected function socketConnectHandler(event:Event):void
		{
			trace("Connection opened: " + event.toString());
		}
		
		protected function socketCloseHandler(event:Event):void
		{
			trace("Connection closed: " + event.toString());
		}
		
		protected function socketErrorHandler(event:Event):void
		{
			trace("Socket error: " + event.toString());
		}
		
		protected function securityErrorHandler(event:Event):void
		{
			trace("Security error: " + event.toString());
		}
		
		protected function socketDataHandler(event:DataEvent):void
		{
			var oscPacket:XML = new XML(event.data);
			var messages:XMLList = oscPacket.children();
			for each (var oscMsg:XML in messages)
			{
				var type:String = oscMsg.@NAME;
				var values:XMLList = oscMsg.children();
				
				switch (type)
				{
					case "/finger":
						
						if (values.length() != 3 && values.length() != 11)
						{
							continue;
						}
						var curTime:Number = new Date().time;
						var fingerId:int = values[0].@VALUE;
						var posX:Number = values[1].@VALUE;
						var posY:Number = values[2].@VALUE;
						
						var velX:Number = 0.0;
						var velY:Number = 0.0;
						var angle:Number = 90.0;
						var majorAxis:Number = 10.0;
						var minorAxis:Number = 10.0;
						var frame:int = 0;
						var state:int = 0;
						var size:Number = 1.0;
						
						if (values.length() == 11)
						{
							velX = values[3].@VALUE;
							velY = values[4].@VALUE;
							angle = values[5].@VALUE;
							majorAxis = values[6].@VALUE;
							minorAxis = values[7].@VALUE;
							frame = values[8].@VALUE;
							state = values[9].@VALUE;
							size = values[10].@VALUE;
						}
						
						var finger:Finger = fingerDict[fingerId];
						if (finger == null)
						{
							finger = new Finger(fingerId, curTime);
							fingersToAdd.push(finger);
						}
						finger.update(posX, posY, velX, velY, angle, majorAxis, minorAxis, curTime);
						
						break;
					default:
						break;
				}
			}
		}
	}
}