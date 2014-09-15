package ;import org.flixel.FlxObject;
import nme.Assets;
import nme.filters.GlowFilter;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxPath;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.plugin.photonstorm.FlxMath;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.misc.Alarm;
import org.flixel.tweens.misc.ColorTween;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class Squid extends FlxSprite
{
	public var isChasing:Bool;
	public var isCoolingDown:Bool;
	public var isFlickering:Bool;
	private var idlePath:FlxPath;
	private var chasePath:FlxPath;
	private var playerRef:FlxSprite;
	private var direction:Int;
	
	private var ct:ColorTween;
	
	private var initialPosition:FlxPoint;
	
	public var foodGroup:FlxGroup;
	public var stateRef:FlxState;
	
	public function new(X:Float, Y:Float) 
	{
		super(X, Y);
		
		init();
	}
	
	private function init():Void {
		loadGraphic("assets/squid.png", false, true);
		
		maxVelocity.x = 150;
		maxVelocity.y = 150;
		drag.x = 100;
		drag.y = 100;
		facing = FlxObject.RIGHT;
		direction = 1;
		isChasing = false;
		isCoolingDown = false;
		isFlickering = false;
		this.elasticity = 2;
		health = 30;
		
		//IDLE Movement
		idlePath = new FlxPath();
		idlePath.add(this.x, this.y - 16);
		idlePath.add(this.x, this.y + 16);
		followPath(idlePath, 16, FlxObject.PATH_YOYO, false);
		
		initialPosition = new FlxPoint(this.x, this.y);
		
		offset.x = 23;
		offset.y = 3;
		width = 20;
		height = 93;
	}
	
	public function chasePlayer(target:FlxSprite):Void {
		if (exists == false) {
			return;
		}
		
		playerRef = target;
		stopFollowingPath(false);
		
		//CHASE Movement
		chasePath = new FlxPath();
		chasePath.add(target.x, target.y);
		followPath(chasePath, 60, FlxObject.PATH_FORWARD, false);
		isChasing = true;
		isCoolingDown = false;
	}
	
	public function coolDown():Void {
		if (exists == false) {
			return;
		}
		
		isChasing = false;
		isCoolingDown = true;
		stopFollowingPath(false);
		addTween(new Alarm(2, resumeChase, FlxTween.ONESHOT), true);
	}
	
	private function resumeChase():Void {
		if (exists == false) {
			return;
		}
		
		isChasing = true;
		if (chasePath == null) {
			chasePath = new FlxPath();
			chasePath.add(playerRef.x, playerRef.y);
		}
		followPath(chasePath, 75, FlxObject.PATH_FORWARD, false);
	}
	
	public function takeDamage():Void {
		flicker(0.4);
		isFlickering = true;
		x += 16 * direction;
		health -= 10;
		
		var tweenColor:Int = 0xFF00FF;
		if (health == 20) {
			tweenColor = 0xFFCCCC;
		} else if (health == 10) {
			tweenColor = 0xFF6666;
		}
		
		ct = new ColorTween(becomeVulnerable, FlxTween.ONESHOT);
		ct.tween(0.4, this.color, tweenColor, 1, 1);
		addTween(ct, true);
	}
	
	private function becomeVulnerable():Void {
		isFlickering = false;
		
		if (health <= 0) {
			
			if (FlxMath.chanceRoll(40)) {
				spawnFood();
			}
			
			cast(stateRef, GameState).updateDeadSquids();
			exists = false;
			stopFollowingPath(false);
			color = 0xffffff;
			this.x = initialPosition.x;
			this.y = initialPosition.y;
			isChasing = false;
			isCoolingDown = false;
			isFlickering = false;
			health = 30;
			ct = null;
		}
	}
	
	public function spawnFood():Void {
		var food:Food = new Food(this.getMidpoint().x, this.getMidpoint().y);
		foodGroup.add(food);
		stateRef.add(food);
	}
	
	override public function update():Void {
		
		if (ct != null) {
			color = ct.color;
		}
		
		if (isChasing == true) {
			
			if (onScreen() == false) {
				isChasing = false;
				stopFollowingPath(false);
				followPath(idlePath, 16, FlxObject.PATH_YOYO, false);
			}
			
			chasePath.nodes[0] = playerRef.getMidpoint();
			
			if (velocity.x > 0) {
				facing = FlxObject.RIGHT;
				direction = -1;
			} else {
				facing = FlxObject.LEFT;
				direction = 1;
			}
		}
		
		super.update();
	}
	
}