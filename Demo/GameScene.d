module GameScene;

import EncoShared;
import EncoDesktop;
import EncoGL3;

class Game3DLayer : RenderLayer
{
	AnimatedProperty!float carY;
	GameObject carObj, carGlassObj;
	bool up = false;
	ContentManager content;

	public this(ContentManager content)
	{
		this.content = content;
	}

	public override void init(Scene scene)
	{
		auto meshes = Mesh.loadFromObj("res/meshes/yard.obj", 0);

		addGameObject(new MeshObject(meshes[0], content.loadMaterial("res/materials/grass.json")));
		addGameObject(new MeshObject(meshes[1], content.loadMaterial("res/materials/brick.json")));
		addGameObject(new MeshObject(meshes[2], content.loadMaterial("res/materials/yard_decoration.json")));
		addGameObject(new MeshObject(meshes[3], content.loadMaterial("res/materials/tree.json")));

		auto clouds = Mesh.loadFromObj("res/meshes/cloudPlane.obj", 0)[0];
		MeshObject cloudsObj = new MeshObject(clouds, content.loadMaterial("res/materials/clouds.json"));
		cloudsObj.transform.scale = vec3(600, 400, 600);
		cloudsObj.renderRelative = true;
		addGameObject(cloudsObj);

		MeshObject cloudsObj2 = new MeshObject(clouds, content.loadMaterial("res/materials/clouds2.json"));
		cloudsObj2.transform.scale = vec3(600, 300, 600);
		cloudsObj2.renderRelative = true;
		addGameObject(cloudsObj2);


		carY = new AnimatedProperty!float (0.0f);
		carY.easingType = "quadratic";
		carY.value = 5.0f;
		carY.length = 3000;

		carY.onDone += (e) {
			up = !up;
			carY.value = up ? 0 : 5;
		};

		auto car = Mesh.loadFromObj("res/meshes/lamborghini.obj", 0);
		carGlassObj = addGameObject(new MeshObject(car[0], content.loadMaterial("res/materials/glass.json")));
		carObj = addGameObject(new MeshObject(car[1], content.loadMaterial("res/materials/lamborghini.json")));
	}

	override protected void update(double deltaTime)
	{
		carY.update(deltaTime);
	}

	override protected void draw(RenderContext context, IRenderer renderer)
	{
		carObj.transform.position.y = cast(float) carY;
		carGlassObj.transform.position.y = cast(float) carY;
	}
}

class UILayer : RenderLayer
{
	public override void init(Scene scene)
	{
	}
}

class DebugLayer : RenderLayer
{
	public override void init(Scene scene)
	{
		string os = "unknown";
		version (Windows) addVersion(os = "win");
		version (linux) addVersion(os = "lin");
		version (OSX) addVersion(os = "osx");
		version (Android) addVersion(os = "android");

		Font font = new Font("res/fonts/Roboto/Roboto-Regular.ttf", 16);
		string compiler = "Unknown Compiler";
		version (DigitalMars) compiler = "DMD";
		version (GNU) compiler = "GDC";
		version (LDC) compiler = "LDC";
		version (SDC) compiler = "SDC";
		TextControl!GLTexture txt = new TextControl!GLTexture(font);
		txt.text = "EncoXD " ~ ENCO_VERSION ~ " (" ~ to!string(ENCO_VERSION_ID) ~ ")\n" ~
		           "Compiler: " ~ compiler ~ "\n" ~
		           "Compiler-Platform: " ~ os ~ "\n";
		txt.x = 20;
		txt.y = 60;
		addGameObject(txt);
	}

	public void addVersion(string ver)
	{
		PictureControl verPic = new PictureControl(GLTexturePool.load("res/tex/" ~ ver ~ ".png"));
		verPic.x = 20;
		verPic.y = 20;
		verPic.width = 200;
		verPic.height = 100;
		addGameObject(verPic);
	}
}

class GameScene : Scene
{
	public Game3DLayer game3DLayer;
	public ContentManager content;

	this(ContentManager content)
	{
		this.content = content;
	}

	public override void init()
	{
		addLayer(game3DLayer = new Game3DLayer(content));
		addLayer(new UILayer());
		addLayer(new DebugLayer());
	}
}
