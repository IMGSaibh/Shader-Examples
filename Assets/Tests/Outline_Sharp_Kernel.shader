Shader "Custom/Outline_Sharp_Kernel"
{
	Properties
	{
		//Graphics.Blit() sets the "_MainTex" property to the texture passed in
		_MainTex("Main Texture", 2D) = "black" {}
		_SceneTex("Scene Texture", 2D) = "black" {}
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_Thickness("_Distance width", Range(0.1, 1.0)) = 1.0
		_Opacity("_Bias Sobel", Range(0.001,1.0)) = 0.25
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

					float x = 0;
					float y = 0;
					if (tex2D(_MainTex, i.uv.xy).r > 0)
					{
						return tex2D(_SceneTex, i.uv.xy);
					}

					x += tex2D(_MainTex, i.uv + _Thickness * float2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y))	* -1.0;
					x += tex2D(_MainTex, i.uv + _Thickness * float2(-_MainTex_TexelSize.x, 0))						* -2.0;
					x += tex2D(_MainTex, i.uv + _Thickness * float2(-_MainTex_TexelSize.x, _MainTex_TexelSize.y))	* -1.0;

					x += tex2D(_MainTex, i.uv + _Thickness * float2(_MainTex_TexelSize.x, -_MainTex_TexelSize.y))	*  1.0;
					x += tex2D(_MainTex, i.uv + _Thickness * float2(_MainTex_TexelSize.x, 0))						*  2.0;
					x += tex2D(_MainTex, i.uv + _Thickness * float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y))	*  1.0;

					y += tex2D(_MainTex, i.uv + _Thickness * float2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y))	* -1.0;
					y += tex2D(_MainTex, i.uv + _Thickness * float2(0, -_MainTex_TexelSize.y))						* -2.0;
					y += tex2D(_MainTex, i.uv + _Thickness * float2(_MainTex_TexelSize.x, -_MainTex_TexelSize.y))	* -1.0;

					y += tex2D(_MainTex, i.uv + _Thickness * float2(-_MainTex_TexelSize.x, _MainTex_TexelSize.y))	*  1.0;
					y += tex2D(_MainTex, i.uv + _Thickness * float2(0, _MainTex_TexelSize.y))						*  2.0;
					y += tex2D(_MainTex, i.uv + _Thickness * float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y))	*  1.0;



					float w = sqrt(x * x + y * y) * _Opacity;
					half4 source = tex2D(_SceneTex, i.uv);
					return half4(lerp(source.rgb, _OutlineColor.rgb, w), 1);

				}
			ENDCG
		}//end pass
	}//end subshader
}
