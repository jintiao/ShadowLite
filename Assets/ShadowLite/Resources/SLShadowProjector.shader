Shader "Hidden/ShadowLite/SLShadowProjector"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                // V2F_SHADOW_CASTER;
                float4 pos : SV_POSITION;
                float2 screenPos : TEXCOORD0;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                // TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                o.pos = UnityObjectToClipPos(v.vertex);
                o.screenPos = o.pos.zw;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
            	half4 col = i.screenPos.x / i.screenPos.y;
    			return col;
            }
            ENDCG
        }
    }
}
