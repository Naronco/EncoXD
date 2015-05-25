module Player;

import EncoDesktop;
import EncoShared;

enum AnimationType : u8
{
	Still,
	X,
	NX,
	Z,
	NZ,
}

class Player : GameObject
{
	private int m_x, m_y;
	private int m_topX, m_topY;
	private int m_respawnX, m_respawnY;
	private int m_targetX, m_targetY;
	private f32 m_animationProgress = 0;
	private AnimationType m_animationType = AnimationType.Still;
	private MeshObject m_bottom, m_top;
	private int m_topState = 0;
	private f32 m_camRotation = 0;
	private Transform m_origin;

	private bool m_double;
	
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

	public @property Transform bottomTransform() { return m_bottom.transform; }
	public @property Transform topTransform() { return m_top.transform; }

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
		m_topX = 0;
		m_topY = 0;

		addChild(m_bottom = new MeshObject(mesh, material));
		m_bottom.transform.parent = null;
		addChild(m_top = new MeshObject(mesh, material));
		m_bottom.transform.position.y = 0.5f;
		m_bottom.transform.parent = &m_origin;

		EncoContext.instance.onKeyDown += (sender, key)
		{
			if(m_animationType == AnimationType.Still)
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
		float rota = radToDeg(((m_camRotation % PI2) + PI2) % PI2);
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
			if(dir == 0) { m_animationType = AnimationType.X; m_topState = 1; }
			if(dir == 1) { m_animationType = AnimationType.NZ; m_topState = 4; }
			if(dir == 2) { m_animationType = AnimationType.NX; m_topState = 2; }
			if(dir == 3) { m_animationType = AnimationType.Z; m_topState = 3; }
		}
		else if(m_topState == 1)
		{
			if(dir == 0)
			{
				m_animationType = AnimationType.X; 
				m_topState = 0;
				steps = 2;
			}
			if(dir == 2)
			{
				m_animationType = AnimationType.NX; 
				m_topState = 0;
			}
		}
		else if(m_topState == 2)
		{
			if(dir == 0)
			{
				m_animationType = AnimationType.X; 
				m_topState = 0;
			}
			if(dir == 2)
			{
				m_animationType = AnimationType.NX; 
				m_topState = 0;
				steps = 2;
			}
		}
		else if(m_topState == 3)
		{
			if(dir == 1)
			{
				m_animationType = AnimationType.NZ;
				m_topState = 0;
			}
			if(dir == 3)
			{
				m_animationType = AnimationType.Z;
				m_topState = 0;
				steps = 2;
			}
		}
		else if(m_topState == 4)
		{
			if(dir == 1)
			{
				m_animationType = AnimationType.NZ;
				m_topState = 0;
				steps = 2;
			}
			if(dir == 3)
			{
				m_topState = 0;
				m_animationType = AnimationType.Z;
			}
		}

		moveRelativeX(steps);
	}

	public void moveLeft()
	{
		int dir = getDirection();

		int steps = 1;

		if(m_topState == 0)
		{
			if(dir == 0) { m_animationType = AnimationType.NX; m_topState = 2; }
			if(dir == 1) { m_animationType = AnimationType.Z; m_topState = 3; }
			if(dir == 2) { m_animationType = AnimationType.X; m_topState = 1; }
			if(dir == 3) { m_animationType = AnimationType.NZ; m_topState = 4; }
		}
		else if(m_topState == 1)
		{
			if(dir == 0)
			{
				m_animationType = AnimationType.NX;
				m_topState = 0;
			}
			if(dir == 2)
			{
				m_animationType = AnimationType.X;
				m_topState = 0;
				steps = 2;
			}
		}
		else if(m_topState == 2)
		{
			if(dir == 0)
			{
				m_topState = 0;
				m_animationType = AnimationType.NX;
				steps = 2;
			}
			if(dir == 2)
			{
				m_animationType = AnimationType.X;
				m_topState = 0;
			}
		}
		else if(m_topState == 3)
		{
			if(dir == 1)
			{
				m_topState = 0;
				steps = 2;
				m_animationType = AnimationType.Z;
			}
			if(dir == 3)
			{
				m_topState = 0;
				m_animationType = AnimationType.NZ;
			}
		}
		else if(m_topState == 4)
		{
			if(dir == 1)
			{
				m_topState = 0;
				m_animationType = AnimationType.Z;
			}
			if(dir == 3)
			{
				m_topState = 0;
				steps = 2;
				m_animationType = AnimationType.NZ;
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
			if(dir == 0) { m_animationType = AnimationType.NZ; m_topState = 4; }
			if(dir == 1) { m_animationType = AnimationType.NX; m_topState = 2; }
			if(dir == 2) { m_animationType = AnimationType.Z; m_topState = 3; }
			if(dir == 3) { m_animationType = AnimationType.X; m_topState = 1; }
		}
		else if(m_topState == 2)
		{
			if(dir == 1)
			{
				m_animationType = AnimationType.NX;
				m_topState = 0;
				steps = 2;
			}
			if(dir == 3)
			{
				m_animationType = AnimationType.X;
				m_topState = 0;
			}
		}
		else if(m_topState == 1)
		{
			if(dir == 1)
			{
				m_animationType = AnimationType.NX;
				m_topState = 0;
			}
			if(dir == 3)
			{
				m_animationType = AnimationType.X;
				m_topState = 0;
				steps = 2;
			}
		}
		else if(m_topState == 4)
		{
			if(dir == 0)
			{
				m_animationType = AnimationType.NZ;
				m_topState = 0;
				steps = 2;
			}
			if(dir == 2)
			{
				m_animationType = AnimationType.Z;
				m_topState = 0;
			}
		}
		else if(m_topState == 3)
		{
			if(dir == 0)
			{
				m_animationType = AnimationType.NZ;
				m_topState = 0;
			}
			if(dir == 2)
			{
				m_animationType = AnimationType.Z;
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
			if(dir == 0) { m_animationType = AnimationType.Z; m_topState = 3; }
			if(dir == 1) { m_animationType = AnimationType.X; m_topState = 1; }
			if(dir == 2) { m_animationType = AnimationType.NZ; m_topState = 4; }
			if(dir == 3) { m_animationType = AnimationType.NX; m_topState = 2; }
		}
		else if(m_topState == 1)
		{
			if(dir == 1)
			{
				m_topState = 0;
				steps = 2;
				m_animationType = AnimationType.X;
			}
			if(dir == 3)
			{
				m_topState = 0;
				m_animationType = AnimationType.NX;
			}
		}
		else if(m_topState == 2)
		{
			if(dir == 1)
			{
				m_topState = 0;
				m_animationType = AnimationType.X;
			}
			if(dir == 3)
			{
				m_topState = 0;
				steps = 2;
				m_animationType = AnimationType.NX;
			}
		}
		else if(m_topState == 3)
		{
			if(dir == 0)
			{
				m_animationType = AnimationType.Z;
				m_topState = 0;
				steps = 2;
			}
			if(dir == 2)
			{
				m_animationType = AnimationType.NZ;
				m_topState = 0;
			}
		}
		else if(m_topState == 4)
		{
			if(dir == 0)
			{
				m_topState = 0;
				m_animationType = AnimationType.Z;
			}
			if(dir == 2)
			{
				m_animationType = AnimationType.NZ;
				m_topState = 0;
				steps = 2;
			}
		}

		moveRelativeY(steps);
	}

	private void moveRelativeX(int steps)
	{
		int dir = getDirection();

		if(dir == 3)
		{
			if(steps == 1)
				m_animationType = AnimationType.Z;
			if(steps == -1)
				m_animationType = AnimationType.NZ;
			m_y += steps;
		}
		else if(dir == 1)
		{
			if(steps == 1)
				m_animationType = AnimationType.NZ;
			if(steps == -1)
				m_animationType = AnimationType.Z;
			m_y -= steps;
		}
		else if(dir == 2)
		{
			if(steps == 1)
				m_animationType = AnimationType.NX;
			if(steps == -1)
				m_animationType = AnimationType.X;
			m_x -= steps;
		}
		else
		{
			if(steps == 1)
				m_animationType = AnimationType.X;
			if(steps == -1)
				m_animationType = AnimationType.NX;
			m_x += steps;
		}
	}

	private void moveRelativeY(int steps)
	{
		int dir = getDirection();
		
		if(dir == 1)
		{
			if(steps == 1)
				m_animationType = AnimationType.X;
			if(steps == -1)
				m_animationType = AnimationType.NX;
			m_x += steps;
		}
		else if(dir == 3)
		{
			if(steps == 1)
				m_animationType = AnimationType.NX;
			if(steps == -1)
				m_animationType = AnimationType.X;
			m_x -= steps;
		}
		else if(dir == 2)
		{
			if(steps == 1)
				m_animationType = AnimationType.NZ;
			if(steps == -1)
				m_animationType = AnimationType.Z;
			m_y -= steps;
		}
		else
		{
			if(steps == 1)
				m_animationType = AnimationType.Z;
			if(steps == -1)
				m_animationType = AnimationType.NZ;
			m_y += steps;
		}
	}

	override protected void update(f64 deltaTime)
	{
		if(m_animationType != AnimationType.Still)
			m_animationProgress += deltaTime * 6.5f;

		float offX = 0.5f;
		float offY = 0.5f;

		switch(m_animationType)
		{
		case AnimationType.X:
			if(m_animationProgress >= 1.0f)
			{
				m_bottom.transform.position.x = 0;
				m_animationProgress = 0;
				m_animationType = AnimationType.Still;
				m_origin.setIdentity();
				onStateChange(this);
			}
			else
			{
				m_bottom.transform.position.x = 0.5f;
				offX = 0;
				m_origin.rotation.z = Animation.call("sinusoidalIn", 1.57079633f, 0, m_animationProgress) - 1.57079633f;
			}
			break;
		case AnimationType.NX:
			if(m_animationProgress >= 1.0f)
			{
				m_bottom.transform.position.x = 0;
				m_animationProgress = 0;
				m_animationType = AnimationType.Still;
				m_origin.setIdentity();
				onStateChange(this);
			}
			else
			{
				m_bottom.transform.position.x = -0.5f;
				offX = 1;
				m_origin.rotation.z = Animation.call("sinusoidalIn", -1.57079633f, 0, m_animationProgress) + 1.57079633f;
			}
			break;
		case AnimationType.NZ:
			if(m_animationProgress >= 1.0f)
			{
				m_bottom.transform.position.z = 0;
				m_animationProgress = 0;
				m_animationType = AnimationType.Still;
				m_origin.setIdentity();
				onStateChange(this);
			}
			else
			{
				m_bottom.transform.position.z = -0.5f;
				m_origin.position.y = 0;
				offY = 1;
				m_origin.rotation.x = Animation.call("sinusoidalIn", 1.57079633f, 0, m_animationProgress) - 1.57079633f;
			}
			break;
		case AnimationType.Z:
			if(m_animationProgress >= 1.0f)
			{
				m_bottom.transform.position.z = 0;
				m_animationProgress = 0;
				m_animationType = AnimationType.Still;
				m_origin.setIdentity();
				onStateChange(this);
			}
			else
			{
				m_bottom.transform.position.z = 0.5f;
				m_origin.position.y = 0;
				offY = 0;
				m_origin.rotation.x = Animation.call("sinusoidalIn", -1.57079633f, 0, m_animationProgress) + 1.57079633f;
			}
			break;
		default:
			break;
		}

		m_origin.position.x = m_x + offX;
		m_origin.position.z = m_y + offY;

		if(m_topState == 0) // Upright
		{
			m_top.transform.parent = &m_bottom.transform;
			m_top.transform.setIdentity();
			m_top.transform.position.y = 1.0f;
		}
		if(m_topState == 1) // Towards +X
		{
			m_top.transform.parent = &m_bottom.transform;
			m_top.transform.setIdentity();
			m_top.transform.position.x = 1.0f;
		}
		if(m_topState == 2) // Towards -X
		{
			m_top.transform.parent = &m_bottom.transform;
			m_top.transform.setIdentity();
			m_top.transform.position.x = -1.0f;
		}
		if(m_topState == 3) // Towards +Z
		{
			m_top.transform.parent = &m_bottom.transform;
			m_top.transform.setIdentity();
			m_top.transform.position.z = 1.0f;
		}
		if(m_topState == 4) // Towards -Z
		{
			m_top.transform.parent = &m_bottom.transform;
			m_top.transform.setIdentity();
			m_top.transform.position.z = -1.0f;
		}
		if(m_topState == 5) // Splitted
		{
			m_top.transform.parent = null;
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
		pos = (player.topTransform.appliedPosition + player.bottomTransform.appliedPosition) * 0.5f;
		pos.y = 0.5f;
		player.camRotation = camera.transform.rotation.y;
		camMovement.value = pos;
		camMovement.update(deltaTime);
		zoom.update(deltaTime);
		object.transform.position = camMovement.value;
		camera.zoom = zoom.value;
	}

	private Player player;
	public GameObject object;
}
