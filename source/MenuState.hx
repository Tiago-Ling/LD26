package;

import nme.Assets;
import nme.geom.Rectangle;
import nme.net.SharedObject;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxPath;
import org.flixel.FlxSave;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxTilemap;
import org.flixel.FlxU;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.misc.Alarm;
import org.flixel.tweens.misc.VarTween;

class MenuState extends FlxState
{	
	override public function create():Void
	{
		#if !neko
		FlxG.bgColor = 0xff131c1b;
		#else
		FlxG.camera.bgColor = {rgb: 0x131c1b, a: 0xff};
		#end		
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		var blueHead:FlxSprite = new FlxSprite(0, 120, "assets/blue_head.png");
		add(blueHead);
		
		var redHead:FlxSprite = new FlxSprite(0, 80, "assets/red_head.png");
		add(redHead);
		redHead.x = 830 - redHead.width;
		
		var texts:Array<String> = new Array<String>();
		texts[0] = "He thought i was dead...";
		texts[1] = "Left ";
		var subTitle:FlxText = new FlxText(0, 20, 800, "A fish called", 32);
		subTitle.alignment = "center";
		add(subTitle);
		
		var title:FlxText = new FlxText(0, 40, 800, "Revenge", 150);
		title.alignment = "center";
		title.shadow = 0xffff0000;
		title.useShadow = true;
		add(title);
		
		var instruction:FlxText = new FlxText(0, 350, 800, "Press <SPACE> to play\nPress <ESC> to play intro", 16);
		instruction.alignment = "center";
		add(instruction);
		
		var credit:FlxText = new FlxText(0, 450, 800, "A simple game by Tiago Ling Alexandre", 10);
		credit.alignment = "center";
		add(credit);
		
		var bt:VarTween = new VarTween(null, FlxTween.PINGPONG);
		bt.tween(instruction, "alpha", 0, 0.5);
		instruction.addTween(bt, true);
		
		this.addTween(new Alarm(0.25, showFlash, FlxTween.ONESHOT), true);
		
	}
	
	private function showFlash():Void {
		FlxG.flash(0xffffffff, 0.5, null);
		FlxG.play("explo_c", 1, false, true);
	}
	
	private function startGame():Void {
		FlxG.play("select", 0.7);
		FlxG.switchState(new GameState());
	}
	
	private function showIntro():Void {
		//FlxG.switchState(new GameState());
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		if (FlxG.keys.justReleased("SPACE")) {
			startGame();
		}
		
		if (FlxG.keys.justReleased("ESCAPE")) {
			FlxG.switchState(new IntroState());
		}
		
		super.update();
	}	
}