using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FPSCounter : MonoBehaviour
{
    [SerializeField] Color textColor = Color.white;

    private float timer = 0f;
    private float msec;
    private float fps;
    private float hudRefreshRate = 1f;

    // Update is called once per frame
    void Update()
    {
        if (Time.unscaledTime > timer)
        {
            fps = (1f / Time.unscaledDeltaTime);
            msec = 1e3f * Time.unscaledDeltaTime;
            timer = Time.unscaledTime + hudRefreshRate;
        }
    }

    void OnGUI()
    {
        int w = Screen.width, h = Screen.height;
        Rect rect = new Rect(0, 0, w * 0.3f, h * 0.1f);

        GUIStyle style = new GUIStyle();
        style.alignment = TextAnchor.UpperLeft;
        style.fontSize = h * 2 / 50;
        style.normal.textColor = textColor;        

        string text = string.Format("{0:0.0} FPS ({1:0.0} ms)", fps, msec);

        GUI.Label(rect, text, style);
    }
}
