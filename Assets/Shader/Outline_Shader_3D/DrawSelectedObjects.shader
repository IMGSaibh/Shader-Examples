// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DrawSelectedObjects"
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
            };

            struct v2f
            {
                float4 vertex:SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            //pixel shader
            half4 frag (v2f i) : SV_Target
            {
                return half4(1,1,1,1);
            }

            ENDCG
        }
    }
}
