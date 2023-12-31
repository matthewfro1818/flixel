package flixel.system.render.tile;

import flixel.graphics.FlxMaterial;
import flixel.graphics.FlxTrianglesData;
import flixel.graphics.frames.FlxFrame;
import flixel.system.render.common.DrawCommand.FlxDrawItemType;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.render.common.FlxCameraView;
import flixel.system.render.common.FlxDrawBaseCommand;
import flixel.util.FlxColor;
import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.TriangleCulling;
import openfl.geom.ColorTransform;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawTrianglesCommand extends FlxDrawBaseCommand<FlxDrawTrianglesCommand>
{
	private static var point:FlxPoint = FlxPoint.get();
	private static var rect:FlxRect = FlxRect.get();
	
	public var vertices:Vector<Float> = new Vector<Float>();
	public var indices:Vector<Int> = new Vector<Int>();
	public var uvtData:Vector<Float> = new Vector<Float>();
	public var colors:Vector<Int> = new Vector<Int>();
	
	// variables for drawing non-textured triangles:
	public var color:FlxColor;
	public var alpha:Float;
	
	public var vertexPos:Int = 0;
	public var indexPos:Int = 0;
	public var colorPos:Int = 0;
	
	public function new() 
	{
		super();
		type = FlxDrawItemType.TRIANGLES;
	}
	
	override public function render(view:FlxCameraView):Void 
	{
		if (!FlxG.renderTile)
			return;
		
		if (numTriangles <= 0)
			return;
		
		if (!textured)
		{
			view.canvas.graphics.beginFill(color, alpha);
			view.canvas.graphics.drawTriangles(vertices, indices, null, TriangleCulling.NONE);
		}
		else
		{
			view.canvas.graphics.beginBitmapFill(bitmap, null, material.repeat, (view.smoothing || material.smoothing));
			#if !openfl_legacy
			view.canvas.graphics.drawTriangles(vertices, indices, uvtData, TriangleCulling.NONE);
			#else
			view.canvas.graphics.drawTriangles(vertices, indices, uvtData, TriangleCulling.NONE, (colored) ? colors : null, FlxDrawBaseCommand.blendToInt(material.blendMode));
			#end
		}
		
		view.canvas.graphics.endFill();
		
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
		{
			var gfx:Graphics = cast(view, FlxTileView).debugLayer.graphics;
			gfx.lineStyle(1, FlxColor.BLUE, 0.5);
			gfx.drawTriangles(vertices, indices);
		}
		#end
		
		FlxCameraView.drawCalls++;
	}
	
	override public function reset():Void 
	{
		super.reset();
		vertices.splice(0, vertices.length);
		indices.splice(0, indices.length);
		uvtData.splice(0, uvtData.length);
		colors.splice(0, colors.length);
		
		vertexPos = 0;
		indexPos = 0;
		colorPos = 0;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		vertices = null;
		indices = null;
		uvtData = null;
		colors = null;
	}
	
	override public function equals(type:FlxDrawItemType, bitmap:BitmapData, colored:Bool, hasColorOffsets:Bool = false, material:FlxMaterial):Bool
	{
		return (this.type == type 
			&& this.bitmap == bitmap 
			&& this.colored == colored
			&& this.material.blendMode == material.blendMode
			&& this.material.smoothing == material.smoothing);
	}
	
	public function addTriangles(data:FlxTrianglesData, ?matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		var drawVertices = this.vertices;
		var verticesLength:Int = data.vertices.length;
		var numberOfVertices:Int = Std.int(verticesLength / 2);
		var prevUVTDataLength:Int = this.uvtData.length;
		var prevNumberOfVertices:Int = this.numVertices;
		
		var px:Float, py:Float;
		var i:Int = 0;
		
		while (i < verticesLength)
		{
			px = data.vertices[i]; 
			py = data.vertices[i + 1];
			
			drawVertices[i] = px * matrix.a + py * matrix.c + matrix.tx;
			drawVertices[i + 1] = px * matrix.b + py * matrix.d + matrix.ty;
			
			vertexPos += 2;
			i += 2;
		}
		
		var uvtDataLength:Int = data.uvs.length;
		for (i in 0...uvtDataLength)
		{
			this.uvtData[prevUVTDataLength + i] = data.uvs[i];
		}
		
		var indicesLength:Int = numberOfVertices;
		if (data.indices != null)
		{
			indicesLength = data.indices.length;
			for (i in 0...indicesLength)
			{
				this.indices[indexPos++] = prevNumberOfVertices + data.indices[i];
			}
		}
		else
		{
			for (i in 0...indicesLength)
			{
				this.indices[indexPos++] = prevNumberOfVertices + i;
			}
		}
		
		#if openfl_legacy
		if (colored)
		{
			var tr:Float = 1.0;
			var tg:Float = 1.0;
			var tb:Float = 1.0;
			var ta:Float = 1.0;
			
			if (transform != null)
			{
				tr = transform.redMultiplier;
				tg = transform.greenMultiplier;
				tb = transform.blueMultiplier;
				ta = transform.alphaMultiplier;
			}
			
			var color:FlxColor;
			
			for (i in 0...numberOfVertices)
			{
				color = data.colors[i];
				this.colors[colorPos++] = FlxColor.fromRGBFloat(tr * color.redFloat, tg * color.greenFloat, tb * color.blueFloat, ta * color.alphaFloat);
			}
		}
		#end
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform, material:FlxMaterial):Void
	{
		addUVQuad(frame.parent.bitmap, frame.frame, frame.uv, matrix, transform, material);
	}
	
	override public function addUVQuad(bitmap:BitmapData, rect:FlxRect, uv:FlxRect, matrix:FlxMatrix, ?transform:ColorTransform, material:FlxMaterial):Void
	{
		var prevVerticesPos:Int = vertexPos;
		var prevIndicesPos:Int = indexPos;
		var prevColorsPos:Int = colorPos;
		var prevNumberOfVertices:Int = numVertices;
		
		var point = FlxPoint.get();
		point.transform(matrix);
		
		vertices[prevVerticesPos] = point.x;
		vertices[prevVerticesPos + 1] = point.y;
		
		uvtData[prevVerticesPos] = uv.x;
		uvtData[prevVerticesPos + 1] = uv.y;
		
		point.set(rect.width, 0);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 2] = point.x;
		vertices[prevVerticesPos + 3] = point.y;
		
		uvtData[prevVerticesPos + 2] = uv.width;
		uvtData[prevVerticesPos + 3] = uv.y;
		
		point.set(rect.width, rect.height);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 4] = point.x;
		vertices[prevVerticesPos + 5] = point.y;
		
		uvtData[prevVerticesPos + 4] = uv.width;
		uvtData[prevVerticesPos + 5] = uv.height;
		
		point.set(0, rect.height);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 6] = point.x;
		vertices[prevVerticesPos + 7] = point.y;
		
		point.put();
		
		uvtData[prevVerticesPos + 6] = uv.x;
		uvtData[prevVerticesPos + 7] = uv.height;
		
		indices[prevIndicesPos] = prevNumberOfVertices;
		indices[prevIndicesPos + 1] = prevNumberOfVertices + 1;
		indices[prevIndicesPos + 2] = prevNumberOfVertices + 2;
		indices[prevIndicesPos + 3] = prevNumberOfVertices + 2;
		indices[prevIndicesPos + 4] = prevNumberOfVertices + 3;
		indices[prevIndicesPos + 5] = prevNumberOfVertices;
		
		#if openfl_legacy
		if (colored)
		{
			var red = 1.0;
			var green = 1.0;
			var blue = 1.0;
			var alpha = 1.0;
			
			if (transform != null)
			{
				red  = transform.redMultiplier;
				green = transform.greenMultiplier;
				blue = transform.blueMultiplier;
				
				#if !neko
				alpha = transform.alphaMultiplier;
				#end
			}
			
			var color = FlxColor.fromRGBFloat(red, green, blue, alpha);
			
			colors[prevColorsPos] = color;
			colors[prevColorsPos + 1] = color;
			colors[prevColorsPos + 2] = color;
			colors[prevColorsPos + 3] = color;
			
			colorPos += 4;
		}
		#end
		
		vertexPos += 8;
		indexPos += 6;
	}
	
	override private function get_elementsPerVertex():Int 
	{
		return 2;
	}
	
	override private function get_numVertices():Int 
	{
		return Std.int(vertexPos / elementsPerVertex);
	}
	
	override private function get_numTriangles():Int
	{
		return Std.int(indexPos / FlxCameraView.INDICES_PER_TRIANGLE);
	}
	
	public function canAddTriangles(numTriangles:Int):Bool
	{
		return (this.numTriangles + numTriangles <= FlxCameraView.TRIANGLES_PER_BATCH);
	}
	
	public function addColorQuad(rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0, material:FlxMaterial):Void
	{
		var prevVerticesPos:Int = vertexPos;
		var prevIndicesPos:Int = indexPos;
		var prevNumberOfVertices:Int = numVertices;
		
		var point = FlxPoint.get();
		point.transform(matrix);
		
		vertices[prevVerticesPos] = point.x;
		vertices[prevVerticesPos + 1] = point.y;
		
		point.set(rect.width, 0);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 2] = point.x;
		vertices[prevVerticesPos + 3] = point.y;
		
		point.set(rect.width, rect.height);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 4] = point.x;
		vertices[prevVerticesPos + 5] = point.y;
		
		point.set(0, rect.height);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 6] = point.x;
		vertices[prevVerticesPos + 7] = point.y;
		
		point.put();
		
		indices[prevIndicesPos] = prevNumberOfVertices;
		indices[prevIndicesPos + 1] = prevNumberOfVertices + 1;
		indices[prevIndicesPos + 2] = prevNumberOfVertices + 2;
		indices[prevIndicesPos + 3] = prevNumberOfVertices + 2;
		indices[prevIndicesPos + 4] = prevNumberOfVertices + 3;
		indices[prevIndicesPos + 5] = prevNumberOfVertices;
		
		this.color = color;
		this.alpha = alpha;
		
		vertexPos += 8;
		indexPos += 6;
	}
}
