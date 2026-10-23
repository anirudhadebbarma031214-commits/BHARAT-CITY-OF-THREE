using UnityEngine;
public class BharatBootstrap : MonoBehaviour {
 static bool built;
 Material Mat(Color c) { Shader s=Shader.Find("Universal Render Pipeline/Lit"); if(s==null)s=Shader.Find("Standard"); var m=new Material(s); m.color=c; return m; }
 GameObject Cube(string n,Vector3 p,Vector3 s,Material m){var g=GameObject.CreatePrimitive(PrimitiveType.Cube);g.name=n;g.transform.position=p;g.transform.localScale=s;g.GetComponent<Renderer>().material=m;return g;}
 void Start(){
 if(built)return;built=true;
 var road=Mat(new Color(.12f,.14f,.15f));var path=Mat(new Color(.55f,.54f,.49f));var cream=Mat(new Color(.83f,.68f,.48f));var blue=Mat(new Color(.2f,.42f,.65f));var pink=Mat(new Color(.72f,.36f,.32f));var green=Mat(new Color(.16f,.34f,.19f));var leaves=Mat(new Color(.14f,.39f,.2f));var water=Mat(new Color(.06f,.3f,.38f));var white=Mat(Color.white);var yellow=Mat(new Color(1,.69f,.12f));var black=Mat(new Color(.04f,.04f,.04f));
 Cube("Northeast Road",new Vector3(0,-.12f,0),new Vector3(16,.2f,150),road);for(int side=-1;side<=1;side+=2)Cube("Footpath",new Vector3(side*9,.02f,0),new Vector3(2,.25f,150),path);
 for(int z=-65;z<=65;z+=12)Cube("Lane marking",new Vector3(0,-.005f,z),new Vector3(.16f,.02f,5),white);
 Random.InitState(14);for(int side=-1;side<=1;side+=2)for(int z=-60;z<=60;z+=18){float h=Random.Range(5f,11f);var mat=Random.value>.5f?cream:(Random.value>.5f?blue:pink);Cube("Agartala shop",new Vector3(side*13,h/2,z),new Vector3(7,h,12),mat);}
 for(int z=-58;z<=58;z+=14)for(int side=-1;side<=1;side+=2){var trunk=GameObject.CreatePrimitive(PrimitiveType.Cylinder);trunk.name="Street tree trunk";trunk.transform.position=new Vector3(side*10,1.3f,z);trunk.transform.localScale=new Vector3(.35f,1.3f,.35f);trunk.GetComponent<Renderer>().material=cream;var crown=GameObject.CreatePrimitive(PrimitiveType.Sphere);crown.name="Tree canopy";crown.transform.position=new Vector3(side*10,3.4f,z);crown.transform.localScale=Vector3.one*2.4f;crown.GetComponent<Renderer>().material=leaves;}
 Cube("Pond",new Vector3(28,-.1f,35),new Vector3(18,.12f,22),water);
 Cube("Auto rickshaw body",new Vector3(3,.85f,5),new Vector3(2.2f,1.3f,3),yellow);Cube("Auto roof",new Vector3(3,1.7f,5),new Vector3(2.1f,.25f,2.7f),green);Cube("Auto windshield",new Vector3(3,1.2f,3.48f),new Vector3(1.4f,.65f,.06f),white);
 foreach(float x in new float[]{2.15f,3.85f})foreach(float z in new float[]{4f,6f}){var w=GameObject.CreatePrimitive(PrimitiveType.Cylinder);w.name="Auto wheel";w.transform.position=new Vector3(x,.35f,z);w.transform.rotation=Quaternion.Euler(0,0,90);w.transform.localScale=new Vector3(.28f,.18f,.28f);w.GetComponent<Renderer>().material=black;}
 Cube("Ground",new Vector3(0,-.45f,0),new Vector3(100,.5f,160),green);
 var player=GameObject.CreatePrimitive(PrimitiveType.Capsule);player.name="Player";player.transform.position=new Vector3(0,1.1f,-8);player.GetComponent<Renderer>().material=blue;Object.Destroy(player.GetComponent<CapsuleCollider>());player.AddComponent<CharacterController>();player.AddComponent<BharatPlayerController>();
 var cam=new GameObject("Main Camera").AddComponent<Camera>();cam.tag="MainCamera";cam.fieldOfView=72;cam.transform.position=player.transform.position+new Vector3(0,4,-7);cam.transform.LookAt(player.transform.position+Vector3.up*1.2f);var follow=cam.gameObject.AddComponent<BharatCameraFollow>();follow.target=player.transform;
 var light=new GameObject("Sun").AddComponent<Light>();light.type=LightType.Directional;light.intensity=1.25f;light.transform.rotation=Quaternion.Euler(48,-32,0);RenderSettings.ambientLight=new Color(.52f,.55f,.60f);
 var canvas=new GameObject("HUD").AddComponent<Canvas>();canvas.renderMode=RenderMode.ScreenSpaceOverlay;var textObj=new GameObject("Title");textObj.transform.SetParent(canvas.transform,false);var t=textObj.AddComponent<UnityEngine.UI.Text>();t.text="BHARAT: CITY OF THREE | TRIPURA PROTOTYPE\nWASD move • Mouse look • Shift sprint";t.font=Resources.GetBuiltinResource<Font>("Arial.ttf");t.fontSize=20;t.color=Color.white;t.alignment=TextAnchor.UpperLeft;var rt=t.rectTransform;rt.anchorMin=new Vector2(0,1);rt.anchorMax=new Vector2(0,1);rt.pivot=new Vector2(0,1);rt.anchoredPosition=new Vector2(22,-18);rt.sizeDelta=new Vector2(700,70);
 }
}
public class BharatPlayerController:MonoBehaviour{
 CharacterController cc;float yaw;void Start(){cc=GetComponent<CharacterController>();yaw=transform.eulerAngles.y;Cursor.lockState=CursorLockMode.Locked;}
 void Update(){if(Input.GetKeyDown(KeyCode.Escape))Cursor.lockState=CursorLockMode.None;if(Input.GetMouseButtonDown(0))Cursor.lockState=CursorLockMode.Locked;yaw+=Input.GetAxis("Mouse X")*2.2f;transform.rotation=Quaternion.Euler(0,yaw,0);Vector3 move=transform.forward*Input.GetAxis("Vertical")+transform.right*Input.GetAxis("Horizontal");if(move.sqrMagnitude>1)move.Normalize();move*=Input.GetKey(KeyCode.LeftShift)?9f:5f;move.y=-9.8f;cc.Move(move*Time.deltaTime);}
}
public class BharatCameraFollow:MonoBehaviour{public Transform target;void LateUpdate(){if(!target)return;transform.position=Vector3.Lerp(transform.position,target.position+target.forward*-6f+Vector3.up*3f,Time.deltaTime*8f);transform.LookAt(target.position+Vector3.up*1.2f);}}
