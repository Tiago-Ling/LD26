package ;
import nme.filters.GlowFilter;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.misc.Alarm;
import org.flixel.tweens.misc.VarTween;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class Player extends FlxSprite
{
	public var direction:Int;
	public var isFlickering:Bool;
	public var shot:Shot;
	public var longShot:Shot;
	
	private var isShooting:Bool;
	private var hasPressedLeft:Bool;
	private var hasPressedRight:Bool;
	private var hasPressedUp:Bool;
	private var hasPressedDown:Bool;
	
	public var hasBoost:Bool;
	public var hasLongShot:Bool;
	
	private var charge:Float;
	private var canLongShot:Bool;
	
	private var gFilter:GlowFilter;
	
	public function new(X:Float, Y:Float) 
	{
		super(X, Y);
		
		init();
	}
	
	private function init():Void {
		
		loadGraphic("assets/fish.png", false, true, 64, 34);
		acceleration.x = 0;
		acceleration.y = 0;
		maxVelocity.x = 200;
		maxVelocity.y = 200;
		drag.x = 200;
		drag.y = 200;
		health = 100;
		
		facing = FlxObject.RIGHT;
		direction = 1;
		isFlickering = false;
		
		shot = new Shot(0, 0);
		longShot = new Shot(0, 0);
		isShooting = false;
		
		hasPressedLeft = false;
		hasPressedRight = false;
		hasPressedUp= false;
		hasPressedDown = false;
		hasBoost = false;
		hasLongShot = false;
		canLongShot = false;
		charge = 0;
		
		gFilter = new GlowFilter(0xFFE640, 1, 6, 6, 2, 1);
		
		offset.x = 5;
		offset.y = 5;
		width = 56;
		height = 20;
	}
	
	public function takeDamage(dmg:Int):Void {
		health -= dmg;
		flicker(1.5);
		isFlickering = true;
		addTween(new Alarm(1.5, becomeVulnerable, FlxTween.ONESHOT), true);
	}
	
	private function becomeVulnerable():Void {
		isFlickering = false;
	}
	
	override public function update():Void {
		handleInput();
		
		super.update();
		
	}
	
	private function handleInput():Void {
		
		if (FlxG.keys.UP) {
			velocity.y -= 40;
		}
		
		if (FlxG.keys.DOWN) {
			velocity.y += 40;
		}
		
		if (FlxG.keys.justReleased("LEFT")) {
			if (hasPressedLeft && hasBoost) {
				maxVelocity.x = 1000;
				velocity.x -= 800;
			} else {
				hasPressedLeft = true;
				addTween(new Alarm(0.3, resetCombo, FlxTween.ONESHOT), true);
			}
		}
		
		if (FlxG.keys.justReleased("RIGHT")) {
			if (hasPressedRight && hasBoost) {
				maxVelocity.x = 1000;
				velocity.x += 800;
			} else {
				hasPressedRight = true;
				addTween(new Alarm(0.3, resetCombo, FlxTween.ONESHOT), true);
			}
		}
		
		if (FlxG.keys.justReleased("UP")) {
			if (hasPressedUp && hasBoost) {
				maxVelocity.y = 1000;
				velocity.y -= 800;
			} else {
				hasPressedUp = true;
				addTween(new Alarm(0.3, resetCombo, FlxTween.ONESHOT), true);
			}
		}
		
		if (FlxG.keys.justReleased("DOWN")) {
			if (hasPressedDown && hasBoost) {
				maxVelocity.y = 1000;
				velocity.y += 800;
			} else {
				hasPressedDown = true;
				addTween(new Alarm(0.3, resetCombo, FlxTween.ONESHOT), true);
			}
		}
		
		if (FlxG.keys.LEFT) {
			velocity.x -= 40;
			facing = FlxObject.LEFT;
			direction = -1;
		}
		
		if (FlxG.keys.RIGHT) {
			velocity.x += 40;
			facing = FlxObject.RIGHT;
			direction = 1;
		}
		
		if (FlxG.keys.SPACE && hasLongShot && !canLongShot) {
			if (charge < 1) {
				charge += FlxG.elapsed;
			} else {
				canLongShot = true;
				FlxG.play("charge", 0.6, false);
			}
		}
		
		if (FlxG.keys.justReleased("SPACE") && !isShooting) {
			
			if (hasLongShot && canLongShot) {
				isShooting = true;
				longShot.facing = facing;
				longShot.x = x + 64 * direction;
				longShot.y = y;
				longShot.exists = true;
				longShot.play("longshot");
				var vt:VarTween = new VarTween(resetLongShot, FlxTween.ONESHOT);
				vt.tween(longShot, "x", (longShot.x + (400 * direction)), 0.5);
				addTween(vt, true);
				FlxG.play("longshot", 0.7, false, true);
				charge = 0;
			} else {
				isShooting = true;
				shot.facing = facing;
				shot.x = x + 64 * direction;
				shot.y = y;
				shot.exists = true;
				shot.play("shot");
				addTween(new Alarm(0.4, resetShot, FlxTween.ONESHOT), true);
				FlxG.play("hit_a", 0.7, false, true);
				charge = 0;
			}
		}
	}
	
	private function resetCombo():Void {
		maxVelocity.x = 200;
		maxVelocity.y = 200;
		hasPressedUp = false;
		hasPressedDown = false;
		hasPressedLeft = false;
		hasPressedRight = false;
	}
	
	private function resetShot():Void {
		shot.exists = false;
		isShooting = false;
	}
	
	private function resetLongShot():Void {
		longShot.exists = false;
		isShooting = false;
		canLongShot = false;
	}
	
}