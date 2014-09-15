package ;
import org.flixel.FlxObject;
import org.flixel.FlxPath;
import org.flixel.FlxSprite;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class Food extends FlxSprite
{

	public function new(X:Float, Y:Float) 
	{
		super(X, Y);
		init();
	}
	
	private function init():Void {
		loadGraphic("assets/food.png");
		
		path = new FlxPath();
		path.add(this.x, this.y - 16);
		path.add(this.x, this.y);
		path.add(this.x, this.y + 16);
		followPath(path, 16, FlxObject.PATH_YOYO, false);
	}
	
}