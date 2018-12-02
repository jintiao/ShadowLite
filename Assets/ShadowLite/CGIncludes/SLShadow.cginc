#ifndef SL_SHADOW_INCLUDED
#define SL_SHADOW_INCLUDED

#include "UnityCG.cginc"

//UNITY_DECLARE_SHADOWMAP(_ShadowMapTexture);
uniform sampler2D _SLShadowTex;
uniform float4x4 _SLWorldToShadow;
uniform float4 _SLShadowBias;

float SLComputeForwardShadows(float4 clipPos)
{
	float atten = 1;

	if (clipPos.x > clipPos.w || clipPos.x < -clipPos.w)
		return atten;
	if (clipPos.y > clipPos.w || clipPos.y < -clipPos.w)
		return atten;
	if (clipPos.w < 0)
		return atten;

	float3 screenPos = clipPos.xyz / clipPos.w;
	screenPos.xy = (screenPos.xy + 1) * 0.5;

	float shadowDepth = tex2D(_SLShadowTex, screenPos.xy);
	if (screenPos.z < shadowDepth)
		atten = 0.1;

	return atten;
}

#define SL_SHADOW_COORDS(idx1) float4 _SLShadowCoord : TEXCOORD##idx1
#define SL_TRANSFER_SHADOW(a) a._SLShadowCoord = mul(_SLWorldToShadow, mul(unity_ObjectToWorld, v.vertex))
#define SL_SHADOW_ATTENUATION(a) SLComputeForwardShadows(a._SLShadowCoord)


float4 SLClipSpaceShadowCasterPos(float4 vertex, float3 normal)
{
    float3 worldNormal = UnityObjectToWorldNormal(normal);
	float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
	float shadowCos = dot(worldNormal, worldLight);
	float shadowSine = sqrt(1 - shadowCos * shadowCos);
	float normalBias = _SLShadowBias.z * shadowSine;

    float4 worldPos = mul(unity_ObjectToWorld, vertex);
    worldPos.xyz -= worldNormal * normalBias;

    return mul(UNITY_MATRIX_VP, worldPos);
}

float4 SLApplyLinearShadowBias(float4 clipPos)
{
#if defined(UNITY_REVERSED_Z)
    clipPos.z -= _SLShadowBias.x / clipPos.w;
#else
    clipPos.z += _SLShadowBias.x / clipPos.w;
#endif
    return clipPos;
}

#define SL_V2F_SHADOW_CASTER UNITY_POSITION(pos)
#define SL_TRANSFER_SHADOW_CASTER(o) \
        o.pos = SLClipSpaceShadowCasterPos(v.vertex, v.normal); \
        o.pos = SLApplyLinearShadowBias(o.pos)
#define SL_SHADOW_CASTER_FRAGMENT(i) i.pos.z

#endif // #ifndef SL_SHADOW_INCLUDED
