using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
public static class BharatBuild {
 [MenuItem("BHARAT/Build Windows EXE")]
 public static void BuildWindows(){
 Directory.CreateDirectory("Assets/Scenes");
 var scene=EditorSceneManager.NewScene(NewSceneSetup.EmptyScene,NewSceneMode.Single);
 new GameObject("BharatBootstrap").AddComponent<BharatBootstrap>();
 EditorSceneManager.SaveScene(scene,"Assets/Scenes/Main.unity");
 EditorBuildSettings.scenes=new[]{new EditorBuildSettingsScene("Assets/Scenes/Main.unity",true)};
 Directory.CreateDirectory("Build");
 var report=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{"Assets/Scenes/Main.unity"},locationPathName="Build/BHARAT-CITY-OF-THREE.exe",target=BuildTarget.StandaloneWindows64,options=BuildOptions.None});
 if(report.summary.result!=UnityEditor.Build.Reporting.BuildResult.Succeeded)throw new System.Exception("Windows build failed: "+report.summary.result);
 }
}