#ifndef CG_INCLUDE_LIGHT
#define CG_INCLUDE_LIGHT


fixed4 _LightColor;
inline fixed4 LightingHalfLambert(SurfaceOutput s, fixed3 lightDirection, fixed LightAttenuation)
{
    fixed diff = max(0, dot(s.Normal, lightDirection));
    diff = (diff + 0.5)*0.5;

    fixed4 c;
    c.rgb = s.Albedo * _LightColor0.rgb * ((diff * _LightColor.rgb) * LightAttenuation);
    c.a = s.Alpha;
    return c;
}

#endif