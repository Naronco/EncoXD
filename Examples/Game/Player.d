module Player;

import EncoDesktop;
import EncoShared;

class Player : GameObject
{
	private int m_x, m_y;
	private int m_topX, m_topY;
	private int m_respawnX, m_respawnY;
	private int m_targetX, m_targetY;
	private bool m_enabled;
	private MeshObject m_bottom, m_top;
	private int m_topState = 0;
	private f32 m_camRotation = 0;

	private bool m_double;

	public @property bool isDouble() { return m_double; }
	
	public ref @property int x() { return m_x; }
	public ref @property int y() { return m_y; }
	
	public ref @property int topX() { return m_topX; }
	public ref @property int topY() { return m_topY; }

	public ref @property f32 camRotation() { return m_camRotation; }

	public @property vec3 topPosition() { return m_top.transform.position; }

	public ref @property bool isEnabled() { return m_enabled; }
	
	public @property i32vec2 respawnPosition() { return i32vec2(m_respawnX, m_respawnY); }
	public @property void respawnPosition(i32vec2 pos) { m_respawnX = pos.x; m_respawnY = pos.y; }
	
	public @property i32vec2 finishPosition() { return i32vec2(m_targetX, m_targetY); }
	public @property void finishPosition(i32vec2 pos) { m_targetX = pos.x; m_targetY = pos.y; }

	public this(Mesh mesh, Material material)
	{
		m_double = true;
		m_x = 0;
		m_y = 0;
		m_respawnX = 0;
		m_respawnY = 0;
		m_enabled = true;
		
		addChild(m_bottom = new MeshObject(mesh, material));
		addChild(m_top = new MeshObject(mesh, material));

		EncoContext.instance.onKeyDown += (sender, key)
		{
			if(key == Key.D)
			{
				if(m_topState == 0)
				{
					m_topState = 1;
					m_x++;
				}
				else if(m_topState == 1)
				{
					m_x += 2;
					m_topState = 0;
				}
				else if(m_topState == 2)
				{
					m_x += 1;
					m_topState = 0;
				}
				else
				{
					m_x++;
				}
			}

			if(key == Key.S)
			{
				if(m_topState == 0)
				{
					m_topState = 3;
					m_y++;
				}
				else if(m_topState == 3)
				{
					m_y += 2;
					m_topState = 0;
				}
				else if(m_topState == 4)
				{
					m_y += 1;
					m_topState = 0;
				}
				else
				{
					m_y++;
				}
			}

			if(key == Key.A)
			{
				if(m_topState == 0)
				{
					m_topState = 2;
					m_x--;
				}
				else if(m_topState == 1)
				{
					m_x -= 1;
					m_topState = 0;
				}
				else if(m_topState == 2)
				{
					m_x -= 2;
					m_topState = 0;
				}
				else
				{
					m_x--;
				}
			}

			if(key == Key.W)
			{
				if(m_topState == 0)
				{
					m_topState = 4;
					m_y--;
				}
				else if(m_topState == 4)
				{
					m_y -= 2;
					m_topState = 0;
				}
				else if(m_topState == 3)
				{
					m_y -= 1;
					m_topState = 0;
				}
				else
				{
					m_y--;
				}
			}
		};
	}
	
	override protected void update(f64 deltaTime)
	{
		transform.position.x = m_x + 0.5f;
		transform.position.y = 0.5f;
		transform.position.z = m_y + 0.5f;
		m_bottom.transform.position = transform.position;
		if(m_topState == 0) // Upright
		{
			m_top.transform.position = transform.position;
			m_top.transform.position.y = 1.5f;
		}
		if(m_topState == 1) // Towards +X
		{
			m_top.transform.position = transform.position;
			m_top.transform.position.x += 1.0f;
		}
		if(m_topState == 2) // Towards -X
		{
			m_top.transform.position = transform.position;
			m_top.transform.position.x -= 1.0f;
		}
		if(m_topState == 3) // Towards +Z
		{
			m_top.transform.position = transform.position;
			m_top.transform.position.z += 1.0f;
		}
		if(m_topState == 4) // Towards -Z
		{
			m_top.transform.position = transform.position;
			m_top.transform.position.z -= 1.0f;
		}
		if(m_topState == 5) // Splitted
		{
			m_top.transform.position = transform.position;
			m_top.transform.position.x = m_topX;
			m_top.transform.position.z = m_topX;
		}
	}
}

class PlayerLock : IComponent
{
	AnimatedFunctionValue!vec3 camMovement;
	AnimatedProperty!f64 zoom;
	f64 zoomVal = 5;
	Camera camera;
	vec3 pos;

	public this(Player player, Camera camera)
	{
		this.player = player;
		camMovement = new AnimatedFunctionValue!vec3(vec3(0, 0, 0));
		camMovement.interpolationFunction = (vec3 delta, vec3 offset, f64 time)
		{
			return delta * (-pow(2, -10 * time) + 1) + offset;
		};
		camMovement.length = 300;

		zoom = new AnimatedProperty!f64(10);
		zoom.length = 30;
		zoom.easingType = "quadratic";

		EncoContext.instance.onScroll += (s, v) {
			Logger.writeln("SCROLL ", v.x, " ", v.y);
			zoomVal += v.y * -0.5f;
			if(zoomVal < 2) zoomVal = 2;
			if(zoomVal > 20) zoomVal = 20;
			zoom.value = zoomVal;
		};

		this.camera = camera;
	}

	public override void add(GameObject object)
	{
		this.object = object;
	}
	
	public override void draw(RenderContext context, IRenderer renderer) {
	}
	
	public override void preDraw(RenderContext context, IRenderer renderer) {
	}
	
	public override void preUpdate(f64 deltaTime) {
	}
	
	public override void update(f64 deltaTime)
	{
		pos = (player.transform.position + player.topPosition) * 0.5f;
		pos.y = 0.5f;
		camMovement.value = pos;
		camMovement.update(deltaTime);
		zoom.update(deltaTime);
		object.transform.position = camMovement.value;
		camera.zoom = zoom.value;
	}
	
	private Player player;
	public GameObject object;
}