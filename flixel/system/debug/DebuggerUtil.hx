package flixel.system.debug;

import openfl.display.Shape;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;

#if flash
import openfl.text.AntiAliasType;
import openfl.text.GridFitType;
#end

class DebuggerUtil
{
	/**
	 * Helper method for textfield creation.
	 *
	 * @param	X		Textfield x position.
	 * @param	Y		Textfield y position.
	 * @param	Color	Textfield color.
	 * @param	Size	Textfield size.
	 * @return	New label text field at specified position and format.
	 */
	public static function createTextField(X:Float = 0, Y:Float = 0, Color:FlxColor = FlxColor.WHITE, Size:Int = 12):TextField
	{
		var tf:TextField = new TextField();
		tf.x = X;
		tf.y = Y;
		tf.multiline = false;
		tf.wordWrap = false;
		tf.embedFonts = true;
		tf.selectable = false;
		#if flash
		tf.antiAliasType = AntiAliasType.NORMAL;
		tf.gridFitType = GridFitType.PIXEL;
		#end
		tf.defaultTextFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, Size, Color.to24Bit());
		tf.alpha = Color.alphaFloat;
		return tf;
	}
}