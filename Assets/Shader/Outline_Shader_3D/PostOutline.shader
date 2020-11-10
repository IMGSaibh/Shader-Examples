// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostOutline"
{
    Properties
    {
        //Graphics.Blit() sets the "_MainTex" property to the texture passed in
        _MainTex ("Main Texture", 2D) = "black" {}
        _SceneTex("Scene Texture", 2D) = "black" {}
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
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
                fixed4 _OutlineColor;

                //[TextureName]_TexelSize is a float4.
                /*
                information about dimension and how much screen space is used by on texel
                x = 1.0/width
                y = 1.0/width
                z = width
                w = height
                */
                float4 _MainTex_TexelSize;

                v2f vert (appdata v)
                {
                    v2f o;
                    //transform from Object to homogenous space        
                    o.pos = UnityObjectToClipPos(v.vertex);

                    //correct uvs to match screenspace coordinates
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    return o;
                }

                half4 frag (v2f i) : COLOR
                {
                    //if something already exists underneath the fragment, discard the fragment.
                    if (tex2D(_MainTex,i.uv.xy).r > 0)
                        return tex2D(_SceneTex,i.uv.xy);

                    //number of iterations for now
                    int iterations = 19;

                    //Dimensions of smaple2D _MainText
                    //split texel size into smaller words
                    float texel_x = _MainTex_TexelSize.x;
                    float texel_y = _MainTex_TexelSize.y;

                    
                    //and a final intensity that increments based on surrounding intensities.
                    float outline = 0;

                    //for every iteration we need to do horizontally
                    for (int k = 0; k < iterations; k += 1)
                    {
                        //for every iteration we need to do vertically
                        for (int j = 0; j < iterations; j += 1)
                        {
                            //construct outline from pixels within of object
                            outline += tex2D
                            (
                                _MainTex,                           //sampler to look up
                                i.uv.xy + float2                    //coordiantes to perform look 
                                (
                                    (k- iterations / 2) * texel_x,
                                    (j- iterations / 2) * texel_y
                                )
                            ).r; //red channel cause objects in mask are red
                        }
                    }
                    //some bias
                    outline *= 0.005;
                    

                    half4 color = tex2D(_SceneTex, i.uv.xy) + outline; //half4(0, 1, 0, 1);
                    
                    //color.r = max(tex2D(_SceneTex, i.uv.xy).r - outline, 0);
                    color.r = tex2D(_SceneTex, i.uv.xy).r;
                    return color;
                }
            ENDCG
        }//end pass
    }//end subshader
}//end shader
