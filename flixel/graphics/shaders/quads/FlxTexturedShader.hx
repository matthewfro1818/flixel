package flixel.graphics.shaders.quads;

import flixel.graphics.shaders.FlxBaseShader;

/**
 * Default shader used by batcher for rendering textured quads without premultiplied alpha.
 */
class FlxTexturedShader extends FlxBaseShader
{
	public static inline var DEFAULT_VERTEX_SOURCE:String = 
			"
			attribute vec4 aPosition;
			attribute vec2 aTexCoord;
			attribute vec4 aColor;
			attribute vec4 aColorOffset;
			
			uniform mat4 uMatrix;
			uniform vec2 uTextureSize;
			
			varying vec2 vTexCoord;
			varying vec4 vColor;
			varying vec4 vColorOffset;
			
			void main(void)
			{
				vTexCoord = aTexCoord;
				// OpenFl uses textures in bgra format, so we should convert colors...
				vColor = aColor.bgra;
				vColorOffset = aColorOffset.bgra;
				gl_Position = uMatrix * aPosition;
			}";		
	
	public static inline var DEFAULT_FRAGMENT_SOURCE:String = 
			"
			varying vec2 vTexCoord;
			varying vec4 vColor;
			varying vec4 vColorOffset;
			
			uniform sampler2D uImage0;
			
			void main(void)
			{
				vec4 color = texture2D(uImage0, vTexCoord);
				
				if (color.a == 0.0)
				{
					gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
				}
				else
				{
					color = vec4(color.rgb / color.a, color.a);
					color = vColorOffset + (color * vColor);
					
					gl_FragColor = vec4(color.rgb * color.a, color.a);
				}
			}";
	
	public function new(?vertexSource:String, ?fragmentSource:String) 
	{
		vertexSource = (vertexSource == null) ? DEFAULT_VERTEX_SOURCE : vertexSource;
		fragmentSource = (fragmentSource == null) ? DEFAULT_FRAGMENT_SOURCE : fragmentSource;
		
		super(vertexSource, fragmentSource);
	}
}