module GameScene;

import EncoShared;
import EncoDesktop;
import EncoGL3;

class Game3DLayer : RenderLayer
{
	public override void init(Scene scene)
	{
		auto meshes = Mesh.loadFromObj("meshes/yard.obj", 0);
		
		addGameObject(new MeshObject(meshes[0], GLMaterial.load(scene.renderer, "materials/grass.json")));
		addGameObject(new MeshObject(meshes[1], GLMaterial.load(scene.renderer, "materials/brick.json")));
		addGameObject(new MeshObject(meshes[2], GLMaterial.load(scene.renderer, "materials/yard_decoration.json")));
		addGameObject(new MeshObject(meshes[3], GLMaterial.load(scene.renderer, "materials/tree.json")));
		
		auto car = Mesh.loadFromObj("meshes/car.obj", 0);
		addGameObject(new MeshObject(car[0], GLMaterial.load(scene.renderer, "materials/glass.json")));
		addGameObject(new MeshObject(car[1], GLMaterial.load(scene.renderer, "materials/car.json")));
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