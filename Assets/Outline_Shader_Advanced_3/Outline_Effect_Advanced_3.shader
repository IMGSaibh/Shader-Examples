Shader "Custom/Outline_Effect_Advanced_3"
{
    Properties
    {
        //Graphics.Blit() sets the "_MainTex" property to the texture passed in
        _MainTex("Main Texture", 2D) = "black" {}
        _SceneTex("Scene Texture", 2D) = "black" {}
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _Distance("Distance", Float) = 1
    }
        SubShader
        {
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
                    half4 _OutlineColor;
                    float _Distance;

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
                        //transform from Object to homogenous space        
                        o.pos = UnityObjectToClipPos(v.vertex);

                        //correct uvs to match screenspace coordinates
                        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                        return o;
                    }

                    half4 frag(v2f i) : COLOR
                    {
                        // Simple sobel filter for the red channel of tempRT.

                        float d = _MainTex_TexelSize.xy * _Distance;
                                
                        half a1 = tex2D(_MainTex, i.uv + d * float2(-1, -1)).r;
                        half a2 = tex2D(_MainTex, i.uv + d * float2(0, -1)).r;
                        half a3 = tex2D(_MainTex, i.uv + d * float2(+1, -1)).r;
                        half a4 = tex2D(_MainTex, i.uv + d * float2(-1, 0)).r;
                        half a6 = tex2D(_MainTex, i.uv + d * float2(+1, 0)).r;
                        half a7 = tex2D(_MainTex, i.uv + d * float2(-1, +1)).r;
                        half a8 = tex2D(_MainTex, i.uv + d * float2(0, +1)).r;
                        half a9 = tex2D(_MainTex, i.uv + d * float2(+1, +1)).r;

                        float gx = -a1 - a2 * 2 - a3 + a7 + a8 * 2 + a9;
                        float gy = -a1 - a4 * 2 - a7 + a3 + a6 * 2 + a9;

                        float w = sqrt(gx * gx + gy * gy) / 4;

                        // Mix the contour color.
                        half4 source = tex2D(_SceneTex, i.uv);
                        return half4(lerp(source.rgb, _OutlineColor.rgb, w), 1);

                }
            ENDCG
        }//end pass
    }//end subshader
    FallBack "Diffuse"
}
