Shader "Custom/Hologram_2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _DotProduct("Rim Effect", Range(-1,1)) = 0.25

    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque"
            "IgnoreProjector" = "True"
            "Queue" = "Transparent" 
        }
        LOD 200

        CGPROGRAM

        //no simulate realistic model so turn off PBR Lighting. Lmabertian reflectance is used instead
        #pragma surface surf Lambert alpha:fade

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0


        sampler2D _MainTex;
        float _DotProduct;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal;
            float3 viewDir;
        };
        fixed4 _Color;



        //Parameter should be SurfaceOutput cause of #pragma Lambert
        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;

            //abs -> returns absolute value of x [Betrag]
            //dot -> dot product [skalar produkt]
            float border = 1 - (abs(dot(IN.viewDir, IN.worldNormal)));
            float alpha = (border * (1 - _DotProduct) + _DotProduct);
            o.Alpha = c.a * alpha;

            //If we look at the object from another angle, its outline will change.
            //eometrically speaking, the edges of a model are all those triangles 
            //whose normal direction is orthogonal (90 degrees) to the current view direction.

            //he Input structure declares these parameters, worldNormal and viewDir, respectively

            //The second aspect that is used in this shader is the gentle fading between the edge of 
            //the model (fully visible) and the angle determined by _DotProduct (invisible). 
            //This linear interpolation is done as follows:

            //float alpha = (border * (1 - _DotProduct) + _DotProduct);
            //Finally, the original alpha from the texture is multiplied with the newly calculated
            //coefficient to achieve the final look.




        }
        ENDCG
    }
    FallBack "Diffuse"
}
