package flixel.graphics.shaders.triangles;

import flixel.graphics.shaders.FlxBaseShader;

/**
 * Default shader used for rendering textured triangles with specified color multipliers for each of the vertices, 
 * plus applied color transform of the FlxStrip.
 */
class FlxTexturedShader extends FlxBaseShader
{
	public static inline var DEFAULT_VERTEX_SOURCE:String = 
			"
			attribute vec4 aPosition;
			attribute vec2 aTexCoord;
			attribute vec4 aColor;
			
			uniform mat4 uMatrix;
			uniform mat4 uModel;
			uniform vec2 uTextureSize;
			
			varying vec2 vTexCoord;
			varying vec4 vColor;
			
			void main(void) 
			{
				vTexCoord = aTexCoord;
				// OpenFl uses textures in bgra format, so we should convert color...
				vColor = aColor.bgra;
				gl_Position = uMatrix * uModel * aPosition;
			}";
	
	public static inline var DEFAULT_FRAGMENT_SOURCE:String = 
			"
			varying vec2 vTexCoord;
			varying vec4 vColor;
			
			uniform sampler2D uImage0;
			uniform vec4 uColor;
			uniform vec4 uColorOffset;
			
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
					color = color * vColor * uColor + uColorOffset;
					
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