Shader "Unlit/Hologram"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TintColor("Tint Color", Color) = (1,1,1,1)
        _Transparency("Transparency", Range(0.0,0.5)) = 0.25
        _CutOutThresh("Cutout Threshhold", Range(0.0,1.0)) = 0.2

        //for sin function
        _Distance("Distance", Float) = 1
        _Amplitude("Amplitude", Float) = 1
        _Speed("Speed",Float) = 1
        _Amount("Amount", Range(0.0, 1.0)) = 1
    }
    //more subshader possible (like one for PC and one for PS4)
    SubShader
    {
        //Setup for renderer (Rendering Order)
        //
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        //how the shader behaviour according to level of detail
        LOD 100
        //Pixel from this Object are written in depth buffer [on] -> for transparent object switch to off. For solid color to on 
        ZWrite off

        Blend SrcAlpha OneMinusSrcAlpha

        //single instruction for GPU is Pass
        Pass
        {
            // Programm that runs on GPU
            CGPROGRAM
                //define vertex and fragment function
                #pragma vertex vert
                #pragma fragment frag

                //include at compiletime helper functions
                #include "UnityCG.cginc"
                
                //Dataobject passed to the functions below. Those are objects 
                struct appdata
                {
                    //inforamtion of vertices (x,y,z,w) its a packed array
                    // vertex position
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    // SV_Position = Screenspace Position
                    float4 vertex : SV_POSITION;
                };

                //CG Programm variables
                sampler2D   _MainTex;
                float4      _MainTex_ST;
                float4      _TintColor;
                float       _Transparency;
                float       _CutOutThresh;

                float       _Distance;
                float       _Amplitude;
                float       _Speed;
                float       _Amount;

                // functions
                v2f vert (appdata v)
                {
                    //v2f -> vertex to fragment
                    v2f o;
                    //still in object space
                    // _Time.y is the time in seconds
                    v.vertex.x += sin(_Time.y * _Speed + v.vertex.y * _Amplitude) * _Distance * _Amount;
                    //v.vertex -> are the vertex in the models local space
                    //UnityObjectToClipPos = transform from Local Space->Worldspace->Viewspace->Clipspace->Screenspace
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    //TRANSFORM_TEX = takes uv data from model
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    return o;
                }



                //SV-Target = Rendertarget (e.g. Framebuffer of the Screen)
                fixed4 frag (v2f i) : SV_Target
                {
                    //sample the texture
                    //col = Color (r,g,b,a)
                    fixed4 col = tex2D(_MainTex, i.uv) + _TintColor;
                    col.a = _Transparency;
                    //clip any pixel that have less amount of red and dont draw them
                    clip(col.r - _CutOutThresh);   // same as if(col.r < _CutOutThresh) discard;
                    return col;
                }
            ENDCG
        }
    }
}
