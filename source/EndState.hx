package ;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.misc.VarTween;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class EndState extends FlxState
{
	private var type:Int;
	
	public function new(t:Int) {
		super();
		
		type = t;
	}
	
	override public function create():Void {
		
		#if !neko
		FlxG.bgColor = 0xff131c1b;
		#else
		FlxG.camera.bgColor = {rgb: 0x131c1b, a: 0xff};
		#end		
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		var title:FlxText = new FlxText(0, 40, 800, "Game Over", 100);
		title.alignment = "center";
		title.shadow = 0xff0000ff;
		title.useShadow = true;
		add(title);
		
		var bt:VarTween = new VarTween(null, FlxTween.PINGPONG);
		bt.tween(title, "alpha", 0, 0.5);
		title.addTween(bt, true);
		
		if (type == 0) { //ENDGAME
			var instruction:FlxText = new FlxText(0, 300, 800, "Congratulations! You finally got rid of the red monster! Now go on to live your new minimalist fish life!
			\nPress <SPACE> to play again\n\nPress <ESC> to go to the menu", 16);
			instruction.alignment = "center";
			add(instruction);
		} else { //GAME OVER
			var instruction:FlxText = new FlxText(0, 300, 800, "You died at the fins of the fiendish red monster! Now you won't be able to live your so desired minimalist life...\n
			\nPress <SPACE> to avenge yourself!\n\nPress <ESC> to go to the menu...", 16);
			instruction.alignment = "center";
			add(instruction);
		}
	}
	
	override public function update():Void {
		
		if (FlxG.keys.justReleased("SPACE")) {
			startGame();
		}
		
		if (FlxG.keys.justReleased("ESCAPE")) {
			gotoMenu();
		}
		
		super.update();
	}
	
	private function startGame():Void {
		FlxG.switchState(new GameState());
	}
	
	private function gotoMenu():Void {
		FlxG.switchState(new MenuState());
	}
	
	override public function destroy():Void {
		
		super.destroy();
	}
	
}