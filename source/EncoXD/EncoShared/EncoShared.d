module EncoShared;

public
{
	import derelict.sdl2.sdl;
	import derelict.sdl2.image;
	import derelict.sdl2.ttf;
	import derelict.assimp3.assimp;
	import derelict.opengl3.gl3;

	import luad.all;

	import gl3n.aabb;
	import gl3n.frustum;
	import gl3n.interpolate;
	import gl3n.linalg;
	import gl3n.math;
	import gl3n.plane;
	import gl3n.util;

	import Enco.Shared.Math.Frustum;
	import Enco.Shared.Math.Random;
	import Enco.Shared.Math.Transform;

	import Enco.Shared.Core.IView;
	import Enco.Shared.Core.EncoContext;
	import Enco.Shared.Core.Camera;
	import Enco.Shared.Core.GameObject;
	import Enco.Shared.Core.IComponent;
	import Enco.Shared.Core.TemplateParser;
	import Enco.Shared.Core.Logger;
	import Enco.Shared.Core.Event;
	import Enco.Shared.Core.Window;
	import Enco.Shared.Core.TimeHelper;
	import Enco.Shared.Core.ContentManager;
	import Enco.Shared.Core.IDevice;

	import Enco.Shared.Render.IRenderer;
	import Enco.Shared.Render.ITexture;
	import Enco.Shared.Render.Bitmap;
	import Enco.Shared.Render.Material;
	import Enco.Shared.Render.RenderContext;
	import Enco.Shared.Render.IRenderTarget;
	import Enco.Shared.Render.MeshObject;
	import Enco.Shared.Render.Mesh;
	import Enco.Shared.Render.Shader;
	import Enco.Shared.Render.Color;
	import Enco.Shared.Render.GUIRenderer;
	import Enco.Shared.Render.Font;

	import Enco.Shared.Scripting.LuaExt;

	import Enco.Shared.GUI.Control;
	import Enco.Shared.GUI.PictureControl;
	import Enco.Shared.GUI.DynamicColorControl;
	import Enco.Shared.GUI.TextControl;
	import Enco.Shared.GUI.PanelControl;
	import Enco.Shared.GUI.SpriteControl;

	import Enco.Shared.Ext.Array;
	import Enco.Shared.Ext.String;
	import Enco.Shared.Ext.Vector;

	import Enco.Shared.Network.Network;
	import Enco.Shared.Network.StringPacket;
	import Enco.Shared.Network.ArrayPackets;

	import Enco.Shared.Animation.Animation;
	import Enco.Shared.Animation.BasicEaseFunctions;
	import Enco.Shared.Animation.AnimatedProperty;

	import Enco.Shared.Input.Keyboard;
	import Enco.Shared.Input.Mouse;
	import Enco.Shared.Input.Controller;

	import Enco.Shared.Components.FPSRotation;
	import Enco.Shared.Components.FreeMove;

	import Enco.Shared.Level.LevelLoader;

	import std.algorithm;
	import std.string;
	import std.conv;

	alias byte int8, i8;
	alias short int16, i16;
	alias int int32, i32;
	alias long int64, i64;

	alias ubyte uint8, u8;
	alias ushort uint16, u16;
	alias uint uint32, u32;
	alias ulong uint64, u64;

	alias float f32, float32;
	alias double f64, float64;

	alias Vector!(uint, 2) u32vec2;
	alias Vector!(int, 2) i32vec2;

	enum ENCO_VERSION = "1.0.0";
	enum ENCO_VERSION_ID = 1;

	enum PI2 = 6.28318530718;

	static float degToRad(float f)
	{
		return f * 0.0174532925f;
	}

	static float radToDeg(float f)
	{
		return f * 57.2957795f;
	}
}
