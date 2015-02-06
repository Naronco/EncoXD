module GameScene;

import EncoShared;
import EncoDesktop;
import EncoGL3;

class Game3DLayer : RenderLayer
{
	AnimatedProperty!float carY;
	GameObject carObj, carGlassObj;

	public override void init(Scene scene)
	{
		auto meshes = Mesh.loadFromObj("meshes/yard.obj", 0);
		
		addGameObject(new MeshObject(meshes[0], GLMaterial.load(scene.renderer, "materials/grass.json")));
		addGameObject(new MeshObject(meshes[1], GLMaterial.load(scene.renderer, "materials/brick.json")));
		addGameObject(new MeshObject(meshes[2], GLMaterial.load(scene.renderer, "materials/yard_decoration.json")));
		addGameObject(new MeshObject(meshes[3], GLMaterial.load(scene.renderer, "materials/tree.json")));
		
		
		carY = new AnimatedProperty!float(0.0f);
		carY.easingType = "quadratic";
		carY.value = 5.0f;
		carY.length = 3000;

		auto car = Mesh.loadFromObj("meshes/car.obj", 0);
		carGlassObj = addGameObject(new MeshObject(car[0], GLMaterial.load(scene.renderer, "materials/glass.json")));
		carObj = addGameObject(new MeshObject(car[1], GLMaterial.load(scene.renderer, "materials/car.json")));
	}

	override protected void update(f64 deltaTime)
	{
		carY.update(deltaTime);
	}
	
	override protected void preDraw(RenderContext context, IRenderer renderer)
	{
		carObj.transform.position.y = cast(float)carY;
		carGlassObj.transform.position.y = cast(float)carY;
	}
}

const enum BORDER_SIZE = 100;

class UILayer : RenderLayer
{
	float t = 0;
	Color c = Color(0, 0, 0);
	DynamicColorControl left, right, top, bottom;

	public override void init(Scene scene)
	{
		addSolid(8, scene.view.height - 110, 69, 102, Color.fromHex(0x37474F));
		for(int i = 0; i < 5; i++)
			addSolid(10, scene.view.height - 108 + i * 20, 65, 18, Color.fromHex(0x80CBC4));

		c.fromHSL(0.0, 1.0, 0.5);


		left = DynamicColorControl.create!GLTexture(c);
		left.width = BORDER_SIZE;
		left.height = scene.view.height;

		right = DynamicColorControl.create!GLTexture(c);
		right.width = BORDER_SIZE;
		right.height = scene.view.height;
		right.x = scene.view.width - BORDER_SIZE;

		top = DynamicColorControl.create!GLTexture(c);
		top.width = scene.view.width;
		top.height = BORDER_SIZE;

		bottom = DynamicColorControl.create!GLTexture(c);
		bottom.width = scene.view.width;
		bottom.height = BORDER_SIZE;
		bottom.y = scene.view.height - BORDER_SIZE;
		
		addGameObject(left);
		addGameObject(right);
		addGameObject(top);
		addGameObject(bottom);
	}

	private void addSolid(float x, float y, float width, float height, Color color)
	{
		PictureControl pic = PictureControl.fromColor!GLTexture(color);
		pic.x = x;
		pic.y = y;
		pic.width = width;
		pic.height = height;
		addGameObject(pic);
	}

	private void addImage(float x, float y, float width, float height, ITexture tex)
	{
		PictureControl pic = new PictureControl(tex);
		pic.x = x;
		pic.y = y;
		pic.width = width;
		pic.height = height;
		addGameObject(pic);
	}

	override protected void update(f64 deltaTime)
	{
		t += deltaTime;
		c.fromHSL(t % 1, 1.0, 0.5);
		left.color = c;
		right.color = c;
		top.color = c;
		bottom.color = c;
	}
}

class GameScene : Scene
{
	public Game3DLayer game3DLayer;

	public override void init()
	{
		addLayer(game3DLayer = new Game3DLayer());
		addLayer(new UILayer());
	}
}