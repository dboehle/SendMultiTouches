package com.notranslation
{
	import flash.display.Sprite;
	import flash.geom.Point;

	public class Finger
	{
		public static const FINGER_SCALE:Number = 0.003;
		
		public var id:int;
		public var pos:Point;
		public var vel:Point;
		public var angle:Number;
		public var majorAxis:Number;
		public var minorAxis:Number;
		public var timeLastTouched:Number;
		
		public var sprite:Sprite;
		
		public function Finger(id:int, time:Number)
		{
			this.id = id;
			this.timeLastTouched = time;
			
			this.pos = new Point(0.5, 0.5);
			this.vel = new Point(0.5, 0.5);
			this.angle = 0.0;
			this.majorAxis = 0.0;
			this.minorAxis = 0.0;
			
			sprite = new Sprite();
			sprite.graphics.beginFill(0x000000);
			sprite.graphics.drawCircle(0, 0, 1.0);
			sprite.graphics.endFill();
		}
		
		public function update(posX:Number, posY:Number, velX:Number, velY:Number,
			angle:Number, majorAxis:Number, minorAxis:Number, time:Number):void
		{
			this.pos.x = posX;
			this.pos.y = posY;
			this.vel.x = velX;
			this.vel.y = velY;
			this.angle = angle;
			this.majorAxis = majorAxis;
			this.minorAxis = minorAxis;
			this.timeLastTouched = time;
		}
		
		public function render(width:Number, height:Number):void
		{
			var absX:Number = pos.x * width;
			var absY:Number = height - (pos.y * height);
			
			sprite.x = absX;
			sprite.y = absY;
			sprite.rotation = -angle;
			sprite.scaleX = majorAxis * width * FINGER_SCALE;
			sprite.scaleY = minorAxis * width * FINGER_SCALE;
		}
	}
}