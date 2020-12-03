Shader "Hidden/Masking_Shader_HLSL"
{
	SubShader
	{
		Pass
		{
			HLSLPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

				//variables
				//TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);

				float4 _MainTex_ST;

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
					// UnityObjectToClipPos() doesnt work, so write our own avoiding matrix multiplication overhead
					float4 worldPos = mul(unity_ObjectToWorld, float4(input.pos.xyz, 1.0));
					o.clipPos = mul(unity_MatrixVP, worldPos);
					o.uv = TRANSFORM_TEX(input.uv, _MainTex);
					return o;
				}

				float4 frag(VertexOutput i) : SV_TARGET
				{
					return 1;
				}
			ENDHLSL
		}
	}
}
