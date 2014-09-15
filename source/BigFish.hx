package ;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxPath;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxU;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.misc.Alarm;
import org.flixel.tweens.misc.MultiVarTween;
import org.flixel.tweens.motion.LinearPath;
import org.flixel.tweens.motion.QuadPath;
import org.flixel.tweens.util.Ease;

/**
 * 
 * @author Tiago Ling Alexandre
 */
class BigFish extends FlxSprite
{
	private var direction:Int;
	public var mode:Int;
	private var playerRef:Player;
	private var isCharging:Bool;
	private var isCooling:Bool;
	private var isAttacking:Bool;
	private var justActivated:Bool;
	
	public var isFleeing:Bool;
	public var isFlickering:Bool;
	private var initialPos:FlxPoint;
	
	private var stateRef:FlxState;
	
	public function new(sRef:FlxState, X:Float, Y:Float, dir:Int, ?mode:Int = 0) 
	{
		super(X, Y);
		stateRef = sRef;
		dir < 0 ? facing = FlxObject.LEFT : facing = FlxObject.RIGHT;
		direction = dir;
		this.mode = mode;
		isCharging = false;
		isCooling = false;
		isAttacking = false;
		justActivated = false;
		isFlickering = false;
		isFleeing = false;
		initialPos = new FlxPoint(X, Y);
		init();
	}
	
	private function init():Void {
		
		loadGraphic("assets/big_fish.png", false, true);
		
		maxVelocity.x = 300;
		maxVelocity.y = 300;
		drag.x = 12.5;
		drag.y = 12.5;
		active = false;
		
		/**
		 * BigFish will appear at three selected locations (NE, SW, SE)
		 * After some time, or after losing part of its life (33%), BigFish will run away.
		 * After it flees, the player will have to find it throughout the map. After each
		 * defeat, BigFish will change its movement pattern.
		 * 
		 * Each location in which BigFish appears will have the same size 24x12 tiles (BigFish's size is 256x116)
		 */
		
		/**
		 * Pattern 0:
			 * 1. adjust Y with player, moving relatively slow;
			 * 2. charge (wait for x secs);
			 * 3. Cross the screen fast (don't know if it's best to use a fixed distance or player.x);
			 * 4. cooldown (wait for x secs);
			 * 5. set facing & direction;
			 * 6. repeat from 1.
		 */
		
		/**
		 * Pattern 1:
			 * 1. charge;
			 * 2. Go to player's Y at the same time as cross the screen really fast;
			 * 3. cooldown;
			 * 4. set facing & direction;
			 * 5. repeat from 1.
			 * 
		 */
		
		/**
		 * Pattern 2:
			 * 1. charge;
			 * 2. Cross the screen in zig-zag mode faster than patternB;
			 * 3. set facing & direction;
			 * 4. repeat from 1.
		 */
	}
	
	public function activate(target:Player):Void {
		playerRef = target;
		if (mode == 0) {
			adjustY();
		} else {
			charge();
		}
		active = true;
		justActivated = true;
	}
	
	public function charge():Void {
		if (isCharging || isCooling || isAttacking) {
			return;
		}
		isCharging = true;
		switch (mode) {
			case 0:
				addTween(new Alarm(1, adjustY, FlxTween.ONESHOT), true);
			case 1:
				addTween(new Alarm(0.75, attackB, FlxTween.ONESHOT), true);
			case 2:
				addTween(new Alarm(0.5, attackC, FlxTween.ONESHOT), true);
			default:
				
		}
	}
	
	public function cooldown():Void {
		isAttacking = false;
		isCooling = true;
		switch (mode) {
			case 0:
				addTween(new Alarm(1.25, adjustFacing, FlxTween.ONESHOT), true);
			case 1:
				addTween(new Alarm(0.90, adjustFacing, FlxTween.ONESHOT), true);
			case 2:
				addTween(new Alarm(0.65, adjustFacing, FlxTween.ONESHOT), true);
			default:
				
		}
	}
	
	private function adjustY():Void {
		var varTween:MultiVarTween = new MultiVarTween(null, FlxTween.ONESHOT);
		varTween.complete = cooldown;
		var properties:Dynamic = { y:playerRef.y };
		varTween.tween(this, properties, 0.5, null);
		addTween(varTween);
		
		addTween(new Alarm(0.6, attackA, FlxTween.ONESHOT), true);
	}
	
	private function attackA():Void {
		isCharging = false;
		isAttacking = true;
		
		var varTween:MultiVarTween = new MultiVarTween(cooldown, FlxTween.ONESHOT);
		var properties:Dynamic = { x:(x + (384 * direction)) };
		varTween.tween(this, properties, 0.75, Ease.quadOut);
		addTween(varTween);
		
		addTween(new Alarm(0.7, cooldown, FlxTween.ONESHOT), true);
	}
	
	private function attackB():Void {
		isCharging = false;
		isAttacking = true;
		
		var varTween:MultiVarTween = new MultiVarTween(cooldown, FlxTween.ONESHOT);
		var properties:Dynamic = { x:(x + (384 * direction)), y:playerRef.y };
		varTween.tween(this, properties, 0.6, Ease.quadOut);
		addTween(varTween);
	}
	
	private function attackC():Void {
		isCharging = false;
		isAttacking = true;
		
		if (FlxU.getDistance(this.getMidpoint(), playerRef.getMidpoint()) >= 400) {
			var quadTween:LinearPath = new LinearPath(cooldown, FlxTween.ONESHOT);
			quadTween.addPoint(this.x, this.y);
			quadTween.addPoint(this.x + (192 * direction), this.y + 144);
			quadTween.addPoint(this.x + (384 * direction), this.y - 144);
			quadTween.addPoint(playerRef.x, playerRef.y);
			quadTween.setMotion(1.25, Ease.quadOut);
			quadTween.setObject(this);
			addTween(quadTween);
		} else {
			var varTween:MultiVarTween = new MultiVarTween(cooldown, FlxTween.ONESHOT);
			var properties:Dynamic = { x:(x + (384 * direction)), y:playerRef.y };
			varTween.tween(this, properties, 0.5, Ease.quadOut);
			addTween(varTween);
		}
	}
	
	private function adjustFacing():Void {
		isCooling = false;
		if (this.x < playerRef.x) {
			facing = FlxObject.RIGHT;
			direction = 1;
		} else {
			facing = FlxObject.LEFT;
			direction = -1;
		}
		
		charge();
	}
	
	public function takeDamage():Void {
		isFlickering = true;
		x += 16 * direction;
		
		//FlxG.play("hit_a", 0.7, false, true);
		
		addTween(new Alarm(0.4, becomeVulnerable, FlxTween.ONESHOT), true);
	}
	
	private function becomeVulnerable():Void {
		isFlickering = false;
	}
	
	public function flee():Void {
		clearTweens(true);
		isFleeing = true;
		solid = false;
		//Invert facing
		if (this.x < playerRef.x) {
			facing = FlxObject.LEFT;
			direction = -1;
		} else {
			facing = FlxObject.RIGHT;
			direction = 1;
		}
		
		var varTween:MultiVarTween = new MultiVarTween(null, FlxTween.ONESHOT);
		varTween.complete = resetBoss;
		var properties:Dynamic = { x:(x + (512 * direction)) };
		varTween.tween(this, properties, 1, Ease.quadOut);
		addTween(varTween);
	}
	
	private function resetBoss():Void {
		isFleeing = false;
		exists = false;
		isFlickering = false;
		active = false;
		solid = true;
		
		isCharging = false;
		isCooling = false;
		isAttacking = false;
		justActivated = false;
		
		this.x = initialPos.x;
		this.y = initialPos.y;
		cast(stateRef, GameState).currentFish = null;
	}
	
	override public function update():Void {
		
		super.update();
		
	}
	
}