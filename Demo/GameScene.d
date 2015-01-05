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

class GameScene : Scene
{
	public Game3DLayer game3DLayer;

	public override void init()
	{
		addLayer(game3DLayer = new Game3DLayer());
	}
}