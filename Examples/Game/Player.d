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

	private AnimatedProperty!f32 m_rotation;
	private int m_prevX, m_prevY;
	private int m_prevState;
	private bool m_locked = false;
	
	public Trigger onStateChange = new Trigger;
	public Trigger onRespawn = new Trigger;

	public @property bool isDouble() { return m_double; }

	public ref @property int x() { return m_x; }
	public ref @property int y() { return m_y; }

	public @property int topState() { return m_topState; }

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
		m_topX = 0;
		m_topY = 0;

		m_rotation = new AnimatedProperty!f32(0);

		addChild(m_bottom = new MeshObject(mesh, material));
		addChild(m_top = new MeshObject(mesh, material));

		EncoContext.instance.onKeyDown += (sender, key)
		{
			if(!m_locked)
			{
				if(key == Key.D || key == Key.Right)
				{
					moveRight();
				}
				if(key == Key.S || key == Key.Down)
				{
					moveBack();
				}
				if(key == Key.A || key == Key.Left)
				{
					moveLeft();
				}
				if(key == Key.W || key == Key.Up)
				{
					moveFront();
				}
			}
		};
	}

	public void respawn()
	{
		m_x = m_respawnX;
		m_y = m_respawnY;
		m_double = true;
		m_topState = 0;
		onRespawn(this);
	}

	public int getDirection()
	{
		float rota = degrees(((m_camRotation % PI2) + PI2) % PI2);
		if(rota >= 45 && rota < 135) return 1;
		if(rota >= 135 && rota < 225) return 2;
		if(rota >= 225 && rota < 315) return 3;
		return 0;
	}

	public void moveRight()
	{
		int dir = getDirection();

		int steps = 1;

		if(m_topState == 0)
		{
			if(dir == 0) m_topState = 1;
			if(dir == 1) m_topState = 4;
			if(dir == 2) m_topState = 2;
			if(dir == 3) m_topState = 3;
		}
		else if(m_topState == 1)
		{
			if(dir == 0)
			{
				m_topState = 0;
				steps = 2;
			}
			if(dir == 2) m_topState = 0;
		}
		else if(m_topState == 2)
		{
			if(dir == 0) m_topState = 0;
			if(dir == 2)
			{
				m_topState = 0;
				steps = 2;
			}
		}
		else if(m_topState == 3)
		{
			if(dir == 1) m_topState = 0;
			if(dir == 3)
			{
				m_topState = 0;
				steps = 2;
			}
		}
		else if(m_topState == 4)
		{
			if(dir == 1)
			{
				m_topState = 0;
				steps = 2;
			}
			if(dir == 3) m_topState = 0;
		}

		moveRelativeX(steps);
	}

	public void moveLeft()
	{
		int dir = getDirection();

		int steps = 1;

		if(m_topState == 0)
		{
			if(dir == 0) m_topState = 2;
			if(dir == 1) m_topState = 3;
			if(dir == 2) m_topState = 1;
			if(dir == 3) m_topState = 4;
		}
		else if(m_topState == 1)
		{
			if(dir == 0) m_topState = 0;
			if(dir == 2)
			{
				m_topState = 0;
				steps = 2;
			}
		}
		else if(m_topState == 2)
		{
			if(dir == 0)
			{
				m_topState = 0;
				steps = 2;
			}
			if(dir == 2) m_topState = 0;
		}
		else if(m_topState == 3)
		{
			if(dir == 1)
			{
				m_topState = 0;
				steps = 2;
			}
			if(dir == 3) m_topState = 0;
		}
		else if(m_topState == 4)
		{
			if(dir == 1) m_topState = 0;
			if(dir == 3)
			{
				m_topState = 0;
				steps = 2;
			}
		}

		moveRelativeX(-steps);
	}

	public void moveFront()
	{
		int dir = getDirection();

		int steps = 1;

		
		if(m_topState == 0)
		{
			if(dir == 0) m_topState = 4;
			if(dir == 1) m_topState = 2;
			if(dir == 2) m_topState = 3;
			if(dir == 3) m_topState = 1;
		}
		else if(m_topState == 2)
		{
			if(dir == 1)
			{
				m_topState = 0;
				steps = 2;
			}
			if(dir == 3) m_topState = 0;
		}
		else if(m_topState == 1)
		{
			if(dir == 1) m_topState = 0;
			if(dir == 3)
			{
				m_topState = 0;
				steps = 2;
			}
		}
		else if(m_topState == 4)
		{
			if(dir == 0)
			{
				m_topState = 0;
				steps = 2;
			}
			if(dir == 2) m_topState = 0;
		}
		else if(m_topState == 3)
		{
			if(dir == 0) m_topState = 0;
			if(dir == 2)
			{
				m_topState = 0;
				steps = 2;
			}
		}

		moveRelativeY(-steps);
	}

	public void moveBack()
	{
		int dir = getDirection();

		int steps = 1;

		if(m_topState == 0)
		{
			if(dir == 0) m_topState = 3;
			if(dir == 1) m_topState = 1;
			if(dir == 2) m_topState = 4;
			if(dir == 3) m_topState = 2;
		}
		else if(m_topState == 1)
		{
			if(dir == 1)
			{
				m_topState = 0;
				steps = 2;
			}
			if(dir == 3) m_topState = 0;
		}
		else if(m_topState == 2)
		{
			if(dir == 1) m_topState = 0;
			if(dir == 3)
			{
				m_topState = 0;
				steps = 2;
			}
		}
		else if(m_topState == 3)
		{
			if(dir == 0)
			{
				m_topState = 0;
				steps = 2;
			}
			if(dir == 2) m_topState = 0;
		}
		else if(m_topState == 4)
		{
			if(dir == 0) m_topState = 0;
			if(dir == 2)
			{
				m_topState = 0;
				steps = 2;
			}
		}

		moveRelativeY(steps);
	}

	private void moveRelativeX(int steps)
	{
		int dir = getDirection();

		if(dir == 2) steps = -steps;

		if(dir == 3)
		{
			m_y += steps;
		}
		else if(dir == 1)
		{
			m_y -= steps;
		}
		else
		{
			m_x += steps;
		}

		onStateChange(this);
	}

	private void moveRelativeY(int steps)
	{
		int dir = getDirection();
		
		if(dir == 2) steps = -steps;
		
		if(dir == 1)
		{
			m_x += steps;
		}
		else if(dir == 3)
		{
			m_x -= steps;
		}
		else
		{
			m_y += steps;
		}
		
		onStateChange(this);
	}

	override protected void update(f64 deltaTime)
	{
		if(m_rotation.isAnimating)
		{

		}
		else
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
}

class PlayerLock : IComponent
{
	AnimatedFunctionValue!vec3 camMovement;
	AnimatedProperty!f64 zoom;
	f64 zoomVal = 8;
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

		zoom = new AnimatedProperty!f64(zoomVal);
		zoom.length = 30;
		zoom.easingType = "quadratic";

		EncoContext.instance.onScroll += (s, v) {
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
		player.camRotation = camera.transform.rotation.pitch;
		camMovement.value = pos;
		camMovement.update(deltaTime);
		zoom.update(deltaTime);
		object.transform.position = camMovement.value;
		camera.zoom = zoom.value;
	}

	private Player player;
	public GameObject object;
}
