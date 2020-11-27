Shader "Unlit/OutlinePasses"
{
	Properties
	{

		//Graphics.Blit() sets the "_MainTex" property to the texture passed in
		_MainTex("Main Texture", 2D) = "black" {}
		_SceneTex("Scene Texture", 2D) = "black" {}
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_Distance("Distance", Float) = 1
		_Strength("_Bias Sobel", Range(0.001, 1.0)) = 0.25
	}
	CGINCLUDE

	#include "UnityCG.cginc"

	sampler2D _MainTex;
	sampler2D _SceneTex;
	float4 _MainTex_ST;
	fixed4 _OutlineColor;
	float4 _MainTex_TexelSize;
	float _Distance;
	float _Strength;
	float intensity = 0;

	float _GaussSamples[32];

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

	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = ComputeScreenPos(o.pos);
		return o;
	}

	/*float calculateBlur(float2 uv, float texel)
	{
		float intensity = 0;
		[unroll(20)]
		for (int k = -20; k <= 20; ++k)
		{
			intensity += tex2D(_MainTex, uv + float2(k * 0.5) * texel).r * _GaussSamples[abs(k)];

		}
		return intensity;


	}*/

	float calculateBlur2(float2 uv)
	{
		float x = 0;
		float y = 0;


		x += tex2D(_MainTex, uv + _Distance * float2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y))	* -1.0;
		x += tex2D(_MainTex, uv + _Distance * float2(-_MainTex_TexelSize.x, 0))						* -2.0;
		x += tex2D(_MainTex, uv + _Distance * float2(-_MainTex_TexelSize.x, _MainTex_TexelSize.y))	* -1.0;

		x += tex2D(_MainTex, uv + _Distance * float2(_MainTex_TexelSize.x, -_MainTex_TexelSize.y))	*  1.0;
		x += tex2D(_MainTex, uv + _Distance * float2(_MainTex_TexelSize.x, 0))						*  2.0;
		x += tex2D(_MainTex, uv + _Distance * float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y))	*  1.0;




		y += tex2D(_MainTex, uv + _Distance * float2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y))	* -1.0;
		y += tex2D(_MainTex, uv + _Distance * float2(0, -_MainTex_TexelSize.y))						* -2.0;
		y += tex2D(_MainTex, uv + _Distance * float2(_MainTex_TexelSize.x, -_MainTex_TexelSize.y))	* -1.0;

		y += tex2D(_MainTex, uv + _Distance * float2(-_MainTex_TexelSize.x, _MainTex_TexelSize.y))	* 1.0;
		y += tex2D(_MainTex, uv + _Distance * float2(0, _MainTex_TexelSize.y))						* 2.0;
		y += tex2D(_MainTex, uv + _Distance * float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y))	* 1.0;




		float w = sqrt(x * x + y * y) * _Strength;
		return w;

	}

	float calculateBlur3(float2 uv)
	{
		float x = 0;
		float y = 0;

		/*
		x += tex2D(_MainTex, uv + _Distance * float2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y))	* -1.0;
		x += tex2D(_MainTex, uv + _Distance * float2(-_MainTex_TexelSize.x, 0))						* -2.0;
		x += tex2D(_MainTex, uv + _Distance * float2(-_MainTex_TexelSize.x, _MainTex_TexelSize.y))	* -1.0;

		x += tex2D(_MainTex, uv + _Distance * float2(_MainTex_TexelSize.x, -_MainTex_TexelSize.y))	*  1.0;
		x += tex2D(_MainTex, uv + _Distance * float2(_MainTex_TexelSize.x, 0))						*  2.0;
		x += tex2D(_MainTex, uv + _Distance * float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y))	*  1.0;

		*/

		y += tex2D(_MainTex, uv + _Distance * float2(0, _MainTex_TexelSize.y))	* -1.0;
		y += tex2D(_MainTex, uv + _Distance * float2(0, _MainTex_TexelSize.y))	* -2.0;
		y += tex2D(_MainTex, uv + _Distance * float2(0, _MainTex_TexelSize.y))	* -1.0;

		y += tex2D(_MainTex, uv + _Distance * float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y))	* 1.0;
		y += tex2D(_MainTex, uv + _Distance * float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y))	* 2.0;
		y += tex2D(_MainTex, uv + _Distance * float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y))	* 1.0;

		float w = sqrt(x * x + y * y) * _Strength;
		return w;

	}


	// Separable Gaussian filters
	half4 frag_blur_h(v2f_img i) : SV_Target
	{
		for (int k = -20; k < 20; k += 1)
		{
			intensity += tex2D(_MainTex, i.uv.xy + float2(k * 0.5 * _MainTex_TexelSize.x, 0)).r * _Strength;
		}

		return half4(intensity, intensity, intensity, 1);

	}

	half4 frag_blur_v(v2f_img i) : SV_Target
	{
		if (tex2D(_MainTex,i.uv.xy).r > 0)
			return tex2D(_SceneTex,i.uv.xy);

		for (int k = -20; k < 20; k +=1)
		{
			intensity += tex2D(_MainTex, i.uv.xy + float2(0, k * 0.5 * _MainTex_TexelSize.y)).r * _Strength;

		}

		return tex2D(_SceneTex, i.uv.xy) + intensity * _OutlineColor;
	}

	ENDCG
	Subshader
	{
		Pass
		{
			ZTest Always Cull Off ZWrite Off

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_blur_h
			ENDCG
		}
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_blur_v
			ENDCG
		}
	}
}
