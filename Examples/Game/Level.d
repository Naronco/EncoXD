module Level;

import EncoShared;

import Player;

class Block : GameObject
{
	protected int m_x, m_y;
	
	public @property int x() { return m_x; }
	public @property int y() { return m_y; }
	
	public @property bool willFall() { return false; }

	public this(int x, int y, Mesh regularPlane, Material material)
	{
		m_x = x;
		m_y = y;


		MeshObject mesh = new MeshObject(regularPlane, material);
		mesh.transform.position = vec3(m_x, 0, m_y);
		addChild(mesh);
	}
	
	public void onPlayerStateChange(Player player) {}
	public void onPlayerRespawn(Player player) {}
}

class Level : GameObject
{
	private i32vec2 m_finish, m_start;

	public this()
	{
	}

	public bool fromBitmap(string path, Material material, IRenderer renderer)
	{
		Bitmap bmp = Bitmap.load(path);
		scope(exit) bmp.destroy();
		Mesh boxes = MeshUtils.createCube(0.5f, 0.2f, 0.5f, -0.5f, -0.2f, -0.5f);
		boxes = renderer.createMesh(boxes);
		for(int x = 0; x < bmp.width; x++)
		{
			for(int y = 0; y < bmp.height; y++)
			{
				Color pixel = bmp.getPixel(x, y);
				if(pixel.R == 0) // Block
				{
					if(pixel.G == 0) // Regular Block
					{
						addChild(new Block(x, y, boxes, material));
					}
					else if(pixel.G == 32) // Donut Block
					{
						addChild(new Block(x, y, boxes, material));
					}
					else
					{
						Logger.errln("Invalid Color at ", x, "-", y, " (", pixel.R, ", ", pixel.G, ", ", pixel.B, ")");
						return false;
					}
				}
				else if(pixel.R == 32) // Switch / Path
				{

				}
				else if(pixel.R == 64) // Splitter
				{

				}
				else if(pixel.R == 96) // Trigger
				{
					if(pixel.B == 0)
					{
						m_start = i32vec2(x, y);
						addChild(new Block(x, y, boxes, material));
					}
					else if(pixel.B == 127)
					{

					}
					else if(pixel.B == 255)
					{
						m_finish = i32vec2(x, y);
						addChild(new Block(x, y, boxes, material));
					}
					else
					{
						Logger.errln("Invalid Color at ", x, "-", y, " (", pixel.R, ", ", pixel.G, ", ", pixel.B, ")");
						return false;
					}
				}
				else if(pixel.R == 255) {} // Air
				else
				{
					Logger.errln("Invalid Color at ", x, "-", y, " (", pixel.R, ", ", pixel.G, ", ", pixel.B, ")");
					return false;
				}
			}
		}
		return true;
	}

	public Level setPlayer(Player player)
	{
		player.x = m_start.x;
		player.y = m_start.y;
		player.finishPosition = m_finish;

		addChild(player);

		return this;
	}
}