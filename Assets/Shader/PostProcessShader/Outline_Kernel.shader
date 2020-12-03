Shader "Custom/Outline_Kernel"
{
	Properties
	{
		//Graphics.Blit() sets the "_MainTex" property to the texture passed in
		_MainTex("Main Texture", 2D) = "black" {}
		_SceneTex("Scene Texture", 2D) = "black" {}
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_Thickness("_Thickness", Range(0.1, 4.0)) = 1.0
		_Opacity("_Opacity", Range(0.001,1.0)) = 0.25
	}


	SubShader
	{
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};
				struct v2f
				{
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
				};

				//CG Programm variables
				sampler2D _MainTex;
				sampler2D _SceneTex;
				float4 _MainTex_ST;
				fixed4 _OutlineColor;
				float _Thickness;
				float _Opacity;
				//[TextureName]_TexelSize is a float4.
				float4 _MainTex_TexelSize;

				v2f vert(appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return o;
				}

				half4 frag(v2f i) : COLOR
				{

					if (tex2D(_MainTex, i.uv.xy).r > 0)
						return tex2D(_SceneTex, i.uv.xy);

					float v = 0;
					_Thickness *= _MainTex_TexelSize.xy;
					
					//simple 3x3 Kernel default value 1 in each row, add multiplikation at the and for a different kernel
					//first row of kernel									
					half a1 = tex2D(_MainTex, i.uv + _Thickness * float2(-1,  1));
					half a2 = tex2D(_MainTex, i.uv + _Thickness * float2(0,   1));
					half a3 = tex2D(_MainTex, i.uv + _Thickness * float2(1,   1));
																		   	
					//second row of kernel								   	
					half a4 = tex2D(_MainTex, i.uv + _Thickness * float2(-1,  0));
					half a5 = tex2D(_MainTex, i.uv + _Thickness * float2(0,   0));
					half a6 = tex2D(_MainTex, i.uv + _Thickness * float2(1,   0));
																		   	
					//third row of kernel								   	
					half a7 = tex2D(_MainTex, i.uv + _Thickness * float2(-1, -1));
					half a8 = tex2D(_MainTex, i.uv + _Thickness * float2(0,  -1));
					half a9 = tex2D(_MainTex, i.uv + _Thickness * float2(1,  -1));
			
					float gx = -a1 - a2 * 2 - a3 + a7 + a8 * 2 + a9 + a5;
					float gy = -a1 - a4 * 2 - a7 + a3 + a6 * 2 + a9 + a5;

					float w = sqrt(gx * gx + gy * gy) * 0.25;

					half4 source = tex2D(_SceneTex, i.uv);

					return half4(lerp(source.rgb, _OutlineColor.rgb, w * _Opacity), 1);
	
				}
			ENDCG
		}//end pass
	}//end subshader
}
