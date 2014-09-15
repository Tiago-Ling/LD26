package ;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.misc.Alarm;
import org.flixel.tweens.misc.VarTween;
import org.flixel.tweens.util.Ease;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class IntroState extends FlxState
{
	private var introText:FlxText;
	private var texts:Array<String>;
	private var textCounter:Int;
	
	public function new() 
	{
		super();
	}
	
	override public function create():Void {
		
		texts = new Array<String>();
		texts[0] = "All he wanted was to live a minimalist life at home";
		texts[1] = "But they beat him, almost to death...";
		texts[2] = "And banished him to the farther depths";
		texts[3] = "But now he's back, to make all of them pay!";
		texts[4] = "He is...";
		textCounter = 0;
		
		introText = new FlxText(0, 50, 800, "null", 16);
		introText.shadow = 0xFF000000;
		introText.useShadow = true;
		introText.scrollFactor.x = 0;
		introText.scrollFactor.y = 0;
		introText.alpha = 0;
		introText.solid = false;
		introText.alignment = "center";
		add(introText);
		
		introText.addTween(new Alarm(0.5, showExplanatoryText, FlxTween.ONESHOT), true);
	}
	
	private function showExplanatoryText():Void {
		if (textCounter < texts.length) {
			
			switch (textCounter) {
				case 0:
					introText.y += 50;
					introText.size = 24;
				case 1:
					introText.y += 60;
					introText.size = 30;
				case 2:
					introText.y += 60;
					introText.size = 36;
				case 3:
					introText.y += 60;
					introText.size = 42;
				case 4:
					
			}
			
			FlxG.flash(0xffffffff, 0.5, null);
			FlxG.play("explo_a", 1, false, true);
			
			introText.text = texts[textCounter];
			var at:VarTween = new VarTween(textCooldown, FlxTween.ONESHOT);
			at.tween(introText, "alpha", 1, 0.5, Ease.quadOut);
			introText.addTween(at, true);
			textCounter++;
		} else {
			FlxG.switchState(new MenuState());
		}
	}
	
	private function textCooldown():Void {
		introText.addTween(new Alarm(1, hideExplanatoryText, FlxTween.ONESHOT), true);
	}
	
	private function hideExplanatoryText():Void {
		var at:VarTween = new VarTween(showExplanatoryText, FlxTween.ONESHOT);
		at.tween(introText, "alpha", 0, 0.5, Ease.quadOut);
		introText.addTween(at, true);
	}
	
	override public function update():Void {
		
		if (FlxG.keys.justReleased("ESCAPE") || FlxG.keys.justReleased("SPACE")) {
			FlxG.play("select", 0.7);
			FlxG.switchState(new MenuState());
		}
		
		super.update();
	}
	
	override public function destroy():Void {
		introText = null;
		super.destroy();
	}
	
}