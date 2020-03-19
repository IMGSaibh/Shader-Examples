// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Grab_Pass_Water_Shader"
{

    Properties
    {
        _NoiseTex("Noise text", 2D) = "white" {}
        _MainColour("MainColour", Color) = (0,0,0,0)
        _Colour ("Colour", Color) = (1,1,1,1)
        _Period ("Period", Range(0,50)) = 1
        _Magnitude ("Magnitude", Range(0,0.5)) = 0.05
        _Scale ("Scale", Range(0,10)) = 1

    }
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
                sampler2D   _NoiseTex;
                fixed4      _Colour;
                fixed4      _MainColour;
                float       _Period;
                float       _Magnitude;
                float       _Scale;


                struct vertInput 
                {
                    float4 vertex : POSITION;
                };
                struct vertOutput
                {
                    float4 vertex : POSITION;
                    fixed4 color : COLOR;
                    float2 texcoord : TEXCOORD0;
                    float4 worldPos : TEXCOORD1;
                    float4 uvgrab : TEXCOORD2;

                };

                //functions
                //vert calculates also the UV Data for the grabpass
               
                vertOutput vert(vertInput v)
                {
                    vertOutput o;
                    //we need to care to initialize manually sometimes
                    UNITY_INITIALIZE_OUTPUT(vertOutput, o);
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uvgrab = ComputeGrabScreenPos(o.vertex);
                    //We need exact position of the space of each fragment
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                    return o;
                }
                fixed4 frag(vertOutput i) : COLOR
                {
                    float sinT = sin(_Time.w / _Period);
                    float2 distortion = float2
                    (
                        //oscillate
                        tex2D(_NoiseTex, i.worldPos.xy / _Scale + float2(sinT, 0) ).g - 0.5,
                        tex2D(_NoiseTex, i.worldPos.xy / _Scale + float2(0, sinT) ).g - 0.5
                    );
                    //sinus wave as an offset to uvgrab
                    i.uvgrab.xy += distortion * _Magnitude;
                    fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
                    return col * _MainColour * _Colour;
                }

            ENDCG
        }
    }
}
