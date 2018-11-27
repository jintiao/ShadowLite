using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ShadowLite
{
	[ExecuteInEditMode]
	public class SLShadowSystem : MonoBehaviour
	{
		public bool debugMode = false;

		public Camera targetCam;
		public Light shadowLight;
		public Camera depthCam;
		private RenderTexture shadowTex;

		private int shadowTexPid = -1;
		private int shadowMatrixPid = -1;

	    void Start()
	    {
			Setup(true);
	    }

	    // Update is called once per frame
	    void Update()
	    {
			Setup();

			if (depthCam != null)
			{
				Shader.SetGlobalTexture(shadowTexPid, shadowTex);

				var world2shadow = depthCam.projectionMatrix * depthCam.worldToCameraMatrix;
				Shader.SetGlobalMatrix(shadowMatrixPid, world2shadow);
			}
	    }

		private void Setup(bool force = false)
		{
			if (shadowTexPid < 0)
			{
				shadowTexPid = Shader.PropertyToID("_SLShadowTex");
			}

			if(shadowMatrixPid < 0)
			{
				shadowMatrixPid = Shader.PropertyToID("_SLWorldToShadow");
			}

			if (targetCam == null)
			{
				targetCam = Camera.main;
			}

			if (depthCam == null)
			{
				var go = new GameObject("ShadowCamera");
				go.transform.parent = transform;
				var cam = go.AddComponent<Camera>();
				depthCam = cam;

				depthCam.depth = targetCam.depth - 1;
				depthCam.SetReplacementShader(Shader.Find("Hidden/ShadowLite/SLShadowCast"), "RenderType");
			}

			if (shadowTex == null)
			{
				shadowTex = new RenderTexture(512, 512, 32, RenderTextureFormat.RFloat);
				depthCam.targetTexture = shadowTex;

				if (debugMode)
				{
					var ddd = targetCam.gameObject.GetComponent<SLDebugDrawDepth>();
					if (ddd == null)
						ddd = targetCam.gameObject.AddComponent<SLDebugDrawDepth>();
					ddd.depthTex = shadowTex;
				}
			}

			if(force)
			{
				depthCam.targetTexture = shadowTex;
				depthCam.depth = targetCam.depth - 1;
				depthCam.SetReplacementShader(Shader.Find("Hidden/ShadowLite/SLShadowCast"), "RenderType");

				if(debugMode)
				{
					var ddd = targetCam.gameObject.GetComponent<SLDebugDrawDepth>();
					ddd.depthTex = shadowTex;
				}
			}
		}
	}

}
