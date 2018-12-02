Shader "Hidden/ShadowLite/SLShadowCaster"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
	
            #include "../CGIncludes/SLShadow.cginc"

            struct v2f
            {
            	SL_V2F_SHADOW_CASTER;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                SL_TRANSFER_SHADOW_CASTER(o);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
    			return SL_SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }
    }
}
