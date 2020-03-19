Shader "Custom/Basic_fragment_Surface_Shader"
{
    Properties
    {
        //Red
        _Color ("Color", Color) = (1,0,0,1)
        _MainTex ("Base texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
                //Define functions
                #pragma vertex vert
                #pragma fragment frag

                half4 _Color;
                sampler2D _MainTex;

                struct vertInput 
                {
                    //POSTION -> contains the position of current vertex 
                    //similar to vertex field of appdata_full structure in a SurfaceShader
                    //>>> POSITION is represented in Modelcoords -> needed to convert in View coords <<<
                    //vetex function responsible for projection Coords to the Screen. Different to SurfaceShader
                    //so multiply POSITION by UNITY_MATRIX_MVP [Model-View-Projection-Matrix] -> essantiel to find vertex position on screen
                    float4 pos : POSITION;
                    //get UV Data
                    float2 texcoord : TEXCOORD0;
                };
                struct vertOutput 
                {
                    float4 pos : SV_POSITION;
                    float2 texcoord : TEXCOORD0;
                };

                //functions
    	        //Model pass to vertex function
                vertOutput vert(vertInput input)
                {
                    vertOutput o;
                    o.pos = UnityObjectToClipPos(input.pos);
                    o.texcoord = input.texcoord;
                    return o;
                }
                //Result is than inputed to a fragment function
                half4 frag(vertOutput output) : COLOR
                {
                    half4 mainColour = tex2D(_MainTex, output.texcoord);
                    return mainColour * _Color;
                }

            ENDCG
        }
    }
}
