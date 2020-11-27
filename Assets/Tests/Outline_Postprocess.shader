// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Outline_Postprocess"
{
	Properties
	{
		//Graphics.Blit() sets the "_MainTex" property to the texture passed in
		_MainTex("Main Texture", 2D) = "black" {}
		_SceneTex("Scene Texture", 2D) = "black" {}
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_Thickness("_Thickness width", Range(0.1, 1.0)) = 1.0
		_Opacity("_Opacity Sobel", Range(0.001,1.0 )) = 0.25
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
					/*
					information about dimension and how much screen space is used by one texel
					x = 1.0/width
					y = 1.0/width
					z = width
					w = height
					*/
					float4 _MainTex_TexelSize;

					v2f vert(appdata v)
					{
						v2f o;
						o.pos = UnityObjectToClipPos(v.vertex);
						o.uv = v.uv;
						return o;
					}

					half4 frag(v2f i) : COLOR
					{
						//if pixel is red draw _SceneTex and maskout object
						if (tex2D(_MainTex,i.uv.xy).r > 0)
							return tex2D(_SceneTex,i.uv.xy);

						float outline = 0;

						[unroll(20)]
						//horizontal
						for (int k = 0; k < 20; k += 1)
						{
							[unroll(20)]
							//vertical
							for (int j = 0; j < 20; j += 1)
							{
								//construct outline from pixels within of object
								outline += tex2D(_MainTex, i.uv.xy + float2((k - 10) * _MainTex_TexelSize.x * _Thickness,(j - 10) * _MainTex_TexelSize.y * _Thickness));
							}
						}
						//some bias
						outline *= 0.005 * _Opacity;

						half4 color = tex2D(_SceneTex, i.uv.xy) + outline * _OutlineColor;
						return color;
					}
				ENDCG


			}//end pass
	}//end subshader
}//end shader