﻿package flixel.tweens.misc;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

/**
 * Tweens a color's red, green, and blue properties
 * independently. Can also tween an alpha value.
 */
class ColorTween extends FlxTween
{
	public var color(default, null):FlxColor;
	private var startColor:FlxColor;
	private var endColor:FlxColor;
	
	/**
	 * Optional sprite object whose color to tween
	 */
	public var sprite(default, null):FlxSprite;

	/**
	 * Clean up references
	 */
	override public function destroy() 
	{
		super.destroy();
		sprite = null;
	}

	/**
	 * Tweens the color to a new color and an alpha to a new alpha.
	 * 
	 * @param	Duration		Duration of the tween.
	 * @param	FromColor		Start color.
	 * @param	ToColor			End color.
	 * @param	Sprite			Optional sprite object whose color to tween.
	 * @return	The ColorTween.
	 */
	public function tween(Duration:Float, FromColor:FlxColor, ToColor:FlxColor, ?Sprite:FlxSprite):ColorTween
	{
		color = startColor = FromColor;
		endColor = ToColor;
		duration = Duration;
		sprite = Sprite;
		start();
		return this;
	}
	
	override private function update():Void
	{
		super.update();
		color = FlxColor.interpolate(startColor, endColor, scale);
		
		if (sprite != null)
		{
			sprite.color = color;
			sprite.alpha = color.alphaFloat;
		}
	}
}