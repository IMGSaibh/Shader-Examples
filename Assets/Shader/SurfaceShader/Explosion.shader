Shader "Custom/Explosion"
{
    Properties
    {
        _RampTex("Color Ramp", 2D) = "white" {}
        //sample Gradient Texture to see more gray or fire 
        _RampOffset("Ramp offset", Range(-0.5,0.5)) = 0
        _NoiseTex("Noise tex", 2D) = "gray" {}
        _Period("Period", Range(0,1)) = 0.5
        _Amount("_Amount", Range(0, 1.0)) = 0.1
        _ClipRange("ClipRange", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
            // Physically based Standard lighting model, and enable shadows on all light types
            #pragma surface surf Lambert vertex:vert nolightmap

            // Use shader model 3.0 target, to get nicer looking lighting
            #pragma target 3.0

            sampler2D _RampTex;
            sampler2D _NoiseTex;
            half      _RampOffset;
            float     _Period;
            half      _Amount;
            half      _ClipRange;

            struct Input
            {
                float2 uv_NoiseTex;
            };


            void surf (Input IN, inout SurfaceOutput o)
            {
                float3 noise = tex2D(_NoiseTex, IN.uv_NoiseTex);
                float n = saturate(noise.r + _RampOffset);
                //clip removes pixel from rendering pipeline -> when negative value = pixel is not drawn
                clip(_ClipRange - n);
                //float2(param1 param2) -> Constant value
                half4 c = tex2D(_RampTex, float2(n, 0.9));
                o.Albedo = c.rgb;
                o.Emission = c.rgb * c.a;

            }

            void vert(inout appdata_full v)
            {
                float3 disp = tex2Dlod(_NoiseTex, float4(v.texcoord.xy,0,0));
                //random calculaiton noise
                //_Time[3] -> gets current Time
                //disp.r -> red chanel of Noise texture makes sure each vertex moves indepently
                //sin function makes verts go up and down
                float time = sin(_Time[3] *_Period + disp.r * 10);
                //normal extrustion takes place
                v.vertex.xyz += v.normal * disp.r * _Amount * time;
            }

        ENDCG
    }
    FallBack "Diffuse"
}
