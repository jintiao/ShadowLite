Shader "Unlit/SingleColor"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc" // for UnityObjectToWorldNormal
            #include "UnityLightingCommon.cginc" // for _LightColor0
            #include "Assets/ShadowLite/CGIncludes/SLShadow.cginc"

			struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 diff : COLOR0;
                fixed3 ambient : COLOR1;
            	SL_SHADOW_COORDS(3);
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                o.diff = nl * _LightColor0.rgb;
                o.ambient = ShadeSH9(half4(worldNormal,1));
                SL_TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 _Color;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _Color;

                fixed shadow = SL_SHADOW_ATTENUATION(i);
                fixed3 lighting = saturate(i.diff * shadow + i.ambient + 0.3);
                col.rgb *= lighting;

                return col;
            }
            ENDCG
        }
    }
}
