package ;
import org.flixel.FlxSprite;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class Shot extends FlxSprite
{

	public function new(X:Float, Y:Float) 
	{
		super(X, Y);
		init();
	}
	
	private function init():Void {
		loadGraphic("assets/fish_shot_b.png", true, true, 57, 34);
		addAnimation("shot", [0, 1, 2, 3], 30, false);
		addAnimation("longshot", [4, 4, 5, 5], 30, true);
		//visible = false;
		exists = false;
	}
	
	override public function update():Void {
		
		super.update();
	}
	
}