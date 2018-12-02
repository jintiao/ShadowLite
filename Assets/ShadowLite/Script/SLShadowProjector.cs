using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ShadowLite
{
	[ExecuteInEditMode]
	public class SLShadowProjector : MonoBehaviour
	{
		public Light shadowLight;
		public LightShadows shadowType = LightShadows.Soft;
//		[Range(0, 90)]
//		public float shadowAngle = 0;
		[Range(0, 1)]
		public float shadowStrength = 1;
		[Range(0, 2)]
		public float shadowBias = 0.05f;
		[Range(0, 3)]
		public float shadowNormalBias = 0.4f;
		[Range(0.1f, 10)]
		public float shadowNearPlane = 0.2f;

		private Camera shadowCamera;
		private RenderTexture shadowTexture;
		private Shader shadowShader;

		private int shadowTexPid;
		private int shadowMatrixPid;
		private int shadowBiasPid;

		private void OnEnable()
		{
			if(shadowLight == null || shadowLight.type != LightType.Directional)
				return;

			if (shadowLight.shadows != LightShadows.None)
			{
//				shadowAngle = shadowLight.shadowAngle;
				shadowStrength = shadowLight.shadowStrength;
				shadowBias = shadowLight.shadowBias;
				shadowNormalBias = shadowLight.shadowNormalBias;
				shadowNearPlane = shadowLight.shadowNearPlane;
				shadowType = shadowLight.shadows;
				shadowLight.shadows = LightShadows.None;
			}

			shadowShader = Shader.Find("Hidden/ShadowLite/SLShadowCaster");
			shadowTexture = new RenderTexture(512, 512, 16, RenderTextureFormat.RHalf);

			if (shadowCamera == null)
			{
				var goName = "SLShadowCamera";
				var t = shadowLight.transform.Find(goName);
				if (t == null)
				{
					t = new GameObject(goName).transform;
					t.parent = shadowLight.transform;
					t.localPosition = Vector3.zero;
					t.localRotation = Quaternion.identity;
				}

				shadowCamera = t.GetComponent<Camera>();
				if (shadowCamera == null)
					shadowCamera = t.gameObject.AddComponent<Camera>();
			}

			shadowCamera.orthographic = true;
			shadowCamera.allowHDR = false;
			shadowCamera.allowMSAA = false;
			shadowCamera.useOcclusionCulling = false;
			shadowCamera.clearFlags = CameraClearFlags.SolidColor;
			shadowCamera.backgroundColor = Color.white;
			shadowCamera.targetTexture = shadowTexture;
			shadowCamera.enabled = false;

			shadowTexPid = Shader.PropertyToID("_SLShadowTex");
			shadowMatrixPid = Shader.PropertyToID("_SLWorldToShadow");
			shadowBiasPid = Shader.PropertyToID("_SLShadowBias");

		}

		private void OnPreRender()
		{
			if(shadowLight == null)
				return;

			shadowCamera.RenderWithShader(shadowShader, "RenderType");

			var world2shadow = GL.GetGPUProjectionMatrix(shadowCamera.projectionMatrix, false) * shadowCamera.worldToCameraMatrix;
			Shader.SetGlobalMatrix(shadowMatrixPid, world2shadow);
			Shader.SetGlobalTexture(shadowTexPid, shadowTexture);
			Shader.SetGlobalVector(shadowBiasPid, new Vector4(shadowBias, 1, shadowNormalBias, 0));
		}
	}
}