// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostOutline"
{
    Properties
    {
        //Graphics.Blit() sets the "_MainTex" property to the texture passed in
        _MainTex ("Main Texture", 2D) = "black" {}
        _SceneTex("Main Texture", 2D) = "black" {}

    }
    SubShader
    {
        //Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"

                struct appdata
                {

                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD0;
                };

                //CG Programm variables
                sampler2D _MainTex;
                sampler2D _SceneTex;
                //_TexelSize is a float2 that says how much screen space a texel occupies.
                float2 _MainTex_TexelSize;

                v2f vert (appdata_base v)
                {
                    v2f o;
                    /*Despite the fact that we are only drawing a quad to the screen, 
                    Unity requires us to multiply vertices by our MVP matrix, 
                    presumably to keep things working when inexperienced 
                    people try copying code from other shaders.
                    */                
                    o.pos = UnityObjectToClipPos(v.vertex);

                    /*Also, we need to fix the UVs to match our screen space coordinates. 
                    There is a Unity define for this that should normally be used.
                    */
                    o.uv = o.pos.xy / 2 + 0.5;

                    return o;
                }

                half4 frag (v2f i) : COLOR
                {
                    if (tex2D(_MainTex,i.uv.xy).r > 0)
                        return tex2D(_SceneTex,i.uv.xy);

                    //arbitrary number of iterations for now
                    int numberOfIterations = 19;

                    //split texel size into smaller words
                    float TX_x = _MainTex_TexelSize.x;
                    float TX_y = _MainTex_TexelSize.y;
                    
                    //and a final intensity that increments based on surrounding intensities.
                    float colorIntensityInRadius = 0;

                    //if something already exists underneath the fragment, discard the fragment.
                    if (tex2D(_MainTex, i.uv.xy).r > 0)
                    {
                        discard;
                    }
                    //for every iteration we need to do horizontally
                    for (int k = 0; k < numberOfIterations; k += 1)
                    {
                        //for every iteration we need to do vertically
                        for (int j = 0; j < numberOfIterations; j += 1)
                        {
                            //increase our output color by the pixels in the area
                            colorIntensityInRadius += tex2D(
                                _MainTex,
                                i.uv.xy + float2
                                (
                                    (k - numberOfIterations / 2) * TX_x,
                                    (j - numberOfIterations / 2) * TX_y
                                    )
                            ).r;
                        }
                    }

                    //return the texture we just looked up
                    //return tex2D(_MainTex,i.uv.xy);

                    //output some intensity of teal
                    //return colorIntensityInRadius * half4(0, 1, 1, 1)*0.005;
                    colorIntensityInRadius *= 0.005;
                    half4 color = tex2D(_SceneTex, i.uv.xy) + colorIntensityInRadius * half4(0, 1, 1, 1);
                    color.r = max(tex2D(_SceneTex, i.uv.xy).r - colorIntensityInRadius, 0);

                    return color;
                }
            ENDCG
        }//end pass
    }//end subshader
}//end shader
