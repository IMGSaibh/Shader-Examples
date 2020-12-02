Shader "Unlit/NewUnlitShader"
{
	Properties
	{
		//Graphics.Blit() sets the "_MainTex" property to the texture passed in
		_MainTex("Main Texture", 2D) = "black" {}
		_SceneTex("Scene Texture", 2D) = "black" {}
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_Thickness("_Thickness width", Range(0.1, 1.0)) = 1.0
		_Opacity("_Opacity Sobel", Range(0.001,1.0)) = 0.25
	}
	SubShader
	{

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

			//variables
			sampler2D _MainTex;
			sampler2D _SceneTex;
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float _Thickness;
			float _Opacity;
			//[TextureName]_TexelSize is a float4.
			float4 _MainTex_TexelSize;


			struct VertexInput
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;

			};

			struct VertexOutput
			{

				float4 clipPos : SV_POSITION;
				float2 uv: TEXTCOORD0;
			};

			VertexOutput vert(VertexInput input)
			{
				VertexOutput o;
				// UnityObjectToClipPos() doesnt work so write our own avoiding matrix multiplication overhead
				float4 worldPos = mul(unity_ObjectToWorld, float4(input.pos.xyz, 1.0));
				o.clipPos = mul(unity_MatrixVP, worldPos);
				o.uv = TRANSFORM_TEX(input.uv, _MainTex);
				return o;
			}



			float4 frag(VertexOutput i) : SV_TARGET
			{
				if (tex2D(_MainTex, i.uv.xy).r > 0)
					return tex2D(_SceneTex, i.uv.xy);



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
						outline += tex2D(_MainTex, i.uv.xy + float2((k - 10) * _MainTex_TexelSize.x * _Thickness, (j - 10) * _MainTex_TexelSize.y * _Thickness));
					}
				}
				//some bias
				outline *= 0.005 * _Opacity;
				half4 color = tex2D(_SceneTex, i.uv.xy) + outline * _OutlineColor;
				return color;
			}

			ENDHLSL
		}
	}
}
