Shader "Custom/MaskingObjects"
{
	SubShader
	{
		ZWrite Off
		ZTest Always
		Lighting Off
		Pass
		{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex:POSITION;
				float2 uv : TEXCOORD0;

			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}

			half4 frag (v2f i) : SV_Target
			{
				return half4(1, 1, 1, 1);
			}

			ENDCG
		}
	}
}
