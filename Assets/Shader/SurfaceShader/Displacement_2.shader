Shader "Custom/Displacement_2"
{
	Properties
    {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
 
		_Amount("Amount", Range(0,1)) = 0
		_DisplacementTexture("Displacement Texture", 2D) = "white"{}
	}
 
		SubShader
        {
			Tags { "RenderType" = "Opaque" }
 
			CGPROGRAM
			#pragma surface surf Standard fullforwardshadows vertex:vert
			
            sampler2D _MainTex;
            sampler2D _DisplacementTexture;
			fixed4 _Color;
			float _Amount;
 
			struct Input
            {
				float2 uv_MainTex;
                //stores how much we displace the object
				float displacementValue; 
			};


 
			void vert(inout appdata_full v, out Input o)
            {
				//How much we expand, based on our DisplacementTexture
                //https://developer.download.nvidia.com/cg/tex2Dlod.html [tex2Dlod reference]
				float value = tex2Dlod(_DisplacementTexture, v.texcoord*7).x * _Amount;
				v.vertex.xyz += v.normal.xyz * value * 0.3;
 
				UNITY_INITIALIZE_OUTPUT(Input, o);
                //Pass this info to the surface shader
				o.displacementValue = value; 
			}
 
			void surf(Input IN, inout SurfaceOutputStandard o)
            {
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				//https://developer.download.nvidia.com/cg/lerp.html [lerp reference]
				o.Albedo = lerp(c.rgb * c.a, float3(0, 0, 0), IN.displacementValue);
				o.Alpha = c.a;
			}
			ENDCG
	}
 
		FallBack "Diffuse"
}
