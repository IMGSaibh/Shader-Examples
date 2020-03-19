// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
Shader "Custom/GrabPass_Shader"
{
    SubShader
    {
        //1 pass
        GrabPass
        {
        }
        //2Pass
        Pass
        {
            CGPROGRAM
                //Define functions
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                //Grab Pass automatically creates a Texture that can be refered as
                //follwos:
                sampler2D _GrabTexture;

                struct vertInput 
                {
                    float4 vertex : POSITION;
                };
                struct vertOutput 
                {
                    float4 vertex : POSITION;
                    //TEXCOORD1 the i-th UV Data stored in Vertex
                    float4 uvgrab : TEXCOORD1;
                };

                //functions
                //vert calculates also the UV Data for the grabpass
               
                vertOutput vert(vertInput v)
                {
                    vertOutput o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    //returns data to sample the grab texture
                    o.uvgrab = ComputeGrabScreenPos(o.vertex);
                    return o;
                }
                half4 frag(vertOutput i) : COLOR
                {
                    //sample grab texture
                    //is standard way in which a texture is grabbed and applied to the screen
                    fixed4 col = tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(i.uvgrab));
                    return col + half4(1.0,0,0,0);
                }

            ENDCG
        }
    }
}
