package ;
import nme.Assets;
import nme.display.BitmapData;
import nme.filters.GlowFilter;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxPoint;
import org.flixel.FlxText;
import org.flixel.FlxTypedGroup;
import org.flixel.FlxObject;
import org.flixel.FlxRect;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxTilemap;
import org.flixel.FlxU;
import org.flixel.plugin.photonstorm.FlxBar;
import org.flixel.plugin.photonstorm.FlxMath;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.misc.Alarm;
import org.flixel.tweens.misc.VarTween;
import org.flixel.tweens.util.Ease;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class GameState extends FlxState
{
	private var player:Player;
	private var map:FlxTilemap;
	private var playerLife:FlxBar;
	private var squids:FlxTypedGroup<Squid>;
	private var numSquids:Int;
	private var gFilter:GlowFilter;
	
	private var bigFishLife:FlxBar;
	private var bossLife:Int;
	private var bigFishes:FlxTypedGroup<BigFish>;
	private var bigFishEncounter:Int;
	public var currentFish:BigFish;
	private var currentLocation:Int;
	
	private var time:Int;
	
	private var enemies:FlxGroup;
	private var entities:FlxGroup;
	private var heroes:FlxGroup;
	private var collisions:FlxGroup;
	
	private var expText:FlxText;
	private var textCounter:Int;
	private var texts:Array<String>;
	
	private var blockerA:FlxSprite;
	private var blockerB:FlxSprite;
	
	private var monsterName:FlxText;
	private var yourLife:FlxText;
	
	private var numDeadSquids:Int;
	private var deadSquids:FlxText;
	
	override public function create():Void
	{
		#if !neko
		FlxG.bgColor = 0xff4aa4ca;
		#else
		FlxG.camera.bgColor = {rgb: 0x131c1b, a: 0xff};
		#end
		
		collisions = new FlxGroup();
		map = new FlxTilemap();
		map.loadMap(Assets.getText("assets/map.txt"), Assets.getBitmapData("assets/tilemap.png"), 32, 32);
		map.setTileProperties(1, FlxObject.ANY, null, null, 16);
		collisions.add(map);
		add(collisions);
		
		player = new Player(400, 200);
		enemies = new FlxGroup();
		
		FlxG.camera.setBounds(0, 0, map.width - 32, map.height);
		FlxG.camera.follow(player, FlxCamera.STYLE_PLATFORMER, null, 12.5);
		FlxG.worldBounds = new FlxRect(0, 0, map.width - 32, map.height);
		
		var squidPositions:Array<String> = Assets.getText("assets/squids_pos.txt").split(";");
		numSquids = squidPositions.length;
		squids = new FlxTypedGroup<Squid>(numSquids);
		for (i in 0...numSquids) {
			var curSquidPos:Array<String> = squidPositions[i].split(",");
			var squid:Squid = new Squid(Std.parseFloat(curSquidPos[0]) * 32, Std.parseFloat(curSquidPos[1]) * 32);
			squids.add(squid);
			squid.foodGroup = enemies;
			squid.stateRef = this;
		}
		add(squids);
		
		bigFishes = new FlxTypedGroup<BigFish>(3);
		bigFishes.add(new BigFish(this, 64, 2976, 1));
		bigFishes.add(new BigFish(this, 2750, 256, -1));
		bigFishes.add(new BigFish(this, 2750, 3008, -1));
		
		bigFishes.setAll("exists", false);
		currentLocation = -1;
		setBigFishLocation();
		
		add(bigFishes);
		bossLife = 100;
		bigFishEncounter = 0;
		numDeadSquids = 0;
		
		yourLife = new FlxText(10, 20, 100, "Health", 12);
		yourLife.scrollFactor.x = 0;
		yourLife.scrollFactor.y = 0;
		add(yourLife);
		
		playerLife = new FlxBar(10, 10, FlxBar.FILL_LEFT_TO_RIGHT, 100, 10, player, "health", 0, 100, true);
		playerLife.scrollFactor.x = 0;
		playerLife.scrollFactor.y = 0;
		add(playerLife);
		
		deadSquids = new FlxText(0, 10, 800, "Dead Squids: " + Std.string(numDeadSquids), 12);
		deadSquids.alignment = "center";
		deadSquids.scrollFactor.x = 0;
		deadSquids.scrollFactor.y = 0;
		add(deadSquids);
		
		monsterName = new FlxText(690, 20, 100, "Red Monster", 12);
		monsterName.scrollFactor.x = 0;
		monsterName.scrollFactor.y = 0;
		add(monsterName);
		monsterName.visible = false;
		bigFishLife = new FlxBar(690, 10, FlxBar.FILL_LEFT_TO_RIGHT, 100, 10, this, "bossLife", 0, 100, true);
		bigFishLife.createFilledBar(0xffff0000, 0xffffd600, true, 0xffffffff);
		bigFishLife.scrollFactor.x = 0;
		bigFishLife.scrollFactor.y = 0;
		add(bigFishLife);
		bigFishLife.visible = false;
		
		enemies.add(bigFishes);
		enemies.add(squids);
		
		entities = new FlxGroup();
		entities.add(bigFishes);
		entities.add(player);
		
		heroes = new FlxGroup();
		heroes.add(player);
		heroes.add(player.shot);
		heroes.add(player.longShot);
		add(heroes);
		
		blockerA = new FlxSprite(0, 0, "assets/blockA.png");
		blockerA.immovable = true;
		blockerA.exists = false;
		heroes.add(blockerA);
		collisions.add(blockerA);
		
		blockerB = new FlxSprite(0, 0, "assets/blockB.png");
		blockerB.immovable = true;
		blockerB.exists = false;
		heroes.add(blockerB);
		collisions.add(blockerB);
		
		time = 0;
		
		expText = new FlxText(0, 50, 800, "null", 16);
		expText.shadow = 0xFF000000;
		expText.useShadow = true;
		expText.scrollFactor.x = 0;
		expText.scrollFactor.y = 0;
		expText.alpha = 0;
		expText.solid = false;
		expText.alignment = "center";
		add(expText);
		
		texts = new Array<String>();
		texts[0] = "Find and kill the red monster who banished you!";
		texts[1] = "Move with the arrow keys. Attack with <SPACE>";
		texts[2] = "If you're low on life, try killing some squids.";
		textCounter = 0;
		expText.addTween(new Alarm(1, showExplanatoryText, FlxTween.ONESHOT), true);
	}
	
	private function showExplanatoryText():Void {
		if (textCounter < texts.length) {
			expText.text = texts[textCounter];
			var at:VarTween = new VarTween(textCooldown, FlxTween.ONESHOT);
			at.tween(expText, "alpha", 1, 0.5, Ease.quadOut);
			expText.addTween(at, true);
			textCounter++;
		}
	}
	
	private function textCooldown():Void {
		expText.addTween(new Alarm(2, hideExplanatoryText, FlxTween.ONESHOT), true);
	}
	
	private function hideExplanatoryText():Void {
		var at:VarTween = new VarTween(showExplanatoryText, FlxTween.ONESHOT);
		at.tween(expText, "alpha", 0, 0.5, Ease.quadOut);
		expText.addTween(at, true);
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		player = null;
		map = null;
		playerLife = null;
		squids = null;
		bigFishLife = null;
		bigFishes = null;
		currentFish = null;
		enemies = null;
		entities = null;
		heroes = null;
		collisions = null;
		expText = null;
		texts = null;
		blockerA = null;
		blockerB = null;
		monsterName = null;
		yourLife = null;
	}

	override public function update():Void
	{
		if (player.health <= 0) {
			FlxG.fade(0xFF000000, 1, showGameOver);
		}
		
		if (time % 3 == 0) {
			detectPlayer();
			checkForBoss();
		}
		
		super.update();
		
		FlxG.collide(collisions, entities);
		
		FlxG.overlap(heroes, enemies, damagePlayer);
		
		time > 999999 ? time = 0 : time++;
	}
	
	private function detectPlayer():Void {
		for (i in 0...numSquids) {
			var dist:Float = FlxU.getDistance(squids.members[i].getMidpoint(), player.getMidpoint());
			var isCoolingDown:Bool = squids.members[i].isCoolingDown;
			if (squids.members[i].exists == false && squids.members[i].onScreen() == false) {
				squids.members[i].exists = true;
			} else if (dist < 240 && !isCoolingDown) {
				squids.members[i].chasePlayer(player);
			}
		}
	}
	
	private function checkForBoss():Void {
		var numBigFishes:Int = bigFishes.members.length;
		for (i in 0...numBigFishes) {
			if (bigFishes.members[i].exists == false) {
				continue;
			}
			var dist:Float = FlxU.getDistance(bigFishes.members[i].getMidpoint(), player.getMidpoint());
			if (dist < 380 && currentFish == null) {
				currentFish = bigFishes.members[i];
				FlxG.play("explo_a", 0.7, false, true);
				
				if (bigFishLife.visible == false) {
					bigFishLife.visible = true;
					monsterName.visible = true;
				}
				
				switch (currentLocation) {
					case 0:
						blockerA.x = 28 * 32;
						blockerA.y = 90 * 32;
						blockerA.exists = true;
					case 1:
						blockerB.x = 69 * 32;
						blockerB.y = 18 * 32;
						blockerB.exists = true;
					case 2:
						blockerA.x = 74 * 32;
						blockerA.y = 90 * 32;
						blockerA.exists = true;
				}
			}
			
			if (dist < 320 && !bigFishes.members[i].active) {
				bigFishes.members[i].activate(player);
			}
		}
	}
	
	private function damagePlayer(hero:FlxObject, enemy:FlxObject):Void {
		if (Type.getClassName(Type.getClass(hero)) == "Player" && cast(hero, Player).isFlickering == false) {
			if (Type.getClassName(Type.getClass(enemy)) == "Squid") {
				var player:Player = cast(hero, Player);
				player.takeDamage(12);
				FlxG.play("p_hit", 0.9);
				FlxG.flash(0xFFFFE640, 0.25, null, false);
				var squid:Squid = cast(enemy, Squid);
				squid.coolDown();
			} else if (Type.getClassName(Type.getClass(enemy)) == "BigFish") {
				var player:Player = cast(hero, Player);
				player.takeDamage(20);
				FlxG.play("p_hit", 0.9);
				FlxG.flash(0xFFFF0000, 0.25, null, false);
			} else if (Type.getClassName(Type.getClass(enemy)) == "Food") {
				player.health += 25;
				if (player.health > 100) {
					player.health = 100;
				}
				FlxG.play("pickup_a", 0.7, false, true);
				enemies.remove(enemy);
				this.remove(enemy);
			}
		} else if (Type.getClassName(Type.getClass(hero)) == "Shot") {
			if (Type.getClassName(Type.getClass(enemy)) == "Squid" && cast(enemy, Squid).isFlickering == false) {
				var squid:Squid = cast(enemy, Squid);
				squid.takeDamage();
				FlxG.play("s_hit", 0.7);
			} else if (Type.getClassName(Type.getClass(enemy)) == "BigFish" && cast(enemy, BigFish).isFlickering == false) {
				var bf:BigFish = cast(enemy, BigFish);
				bf.takeDamage();
				bossLife -= 4;
				FlxG.play("r_hit");
				
				if (bossLife <= 0) {
					
					FlxG.fade(0xff000000, 2.5, false, showEndScreen, true);
					
				} else if (bossLife < 33 && bigFishEncounter == 1) {
					currentFish.flee();
					
					if (currentLocation == 1) {
						blockerB.exists = false;
					} else {
						blockerA.exists = false;
					}
					FlxG.play("explo_a", 0.7, false, true);
					
					player.hasLongShot = true;
					
					texts = new Array<String>();
					texts[0] = "He fled for the last time! He's almost dead, next time will be his last!";
					texts[1] = "Unlocked Long Shot !!! Use it to hit the red monster from a distance!";
					texts[2] = "To use it, press <SPACE>, hold it. When you hear the beep, release the key.";
					textCounter = 0;
					showExplanatoryText();
					bigFishEncounter++;
					
					setBigFishLocation();
					blockerA.exists = false;
					blockerB.exists = false;
					
				} else if (bossLife < 66 && bigFishEncounter == 0) {
					currentFish.flee();
					if (currentLocation == 1) {
						blockerB.exists = false;
					} else {
						blockerA.exists = false;
					}
					FlxG.play("explo_a", 0.7, false, true);
					
					player.hasBoost = true;
					
					texts = new Array<String>();
					texts[0] = "Dammit! He escaped! Gotta keep looking, he's wounded...";
					texts[1] = "Unlocked Fish Boost !!! Use it to dodge red monster's attacks!";
					texts[2] = "To use it, press one of the arrow keys quickly in sucession.";
					textCounter = 0;
					showExplanatoryText();
					bigFishEncounter++;
					
					setBigFishLocation();
					blockerA.exists = false;
					blockerB.exists = false;
				}
			}
		}
	}
	
	private function setBigFishLocation():Void {
		var location:Int = FlxMath.rand(0, 2);
		if (location == currentLocation) {
			return setBigFishLocation();
		} else {
			currentLocation = location;
			var bf:BigFish = bigFishes.members[currentLocation];
			bf.mode = bigFishEncounter;
			bf.exists = true;
			
			return;
		}
	}
	
	public function updateDeadSquids():Void {
		numDeadSquids++;
		deadSquids.text = "Dead Squids: " + Std.string(numDeadSquids);
	}
	
	private function showEndScreen():Void {
		FlxG.switchState(new EndState(0));
	}
	
	private function showGameOver():Void {
		FlxG.switchState(new EndState(1));
	}
}