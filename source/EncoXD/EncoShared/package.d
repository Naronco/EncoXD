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

	import EncoShared.Math.Frustum;
	import EncoShared.Math.Random;
	import EncoShared.Math.Transform;

	import EncoShared.Core.IView;
	import EncoShared.Core.EncoContext;
	import EncoShared.Core.Camera;
	import EncoShared.Core.GameObject;
	import EncoShared.Core.IComponent;
	import EncoShared.Core.TemplateParser;
	import EncoShared.Core.Logger;
	import EncoShared.Core.Event;
	import EncoShared.Core.Window;
	import EncoShared.Core.TimeHelper;
	import EncoShared.Core.ContentManager;
	import EncoShared.Core.IDevice;

	import EncoShared.Render.IRenderer;
	import EncoShared.Render.ITexture;
	import EncoShared.Render.Bitmap;
	import EncoShared.Render.Material;
	import EncoShared.Render.RenderContext;
	import EncoShared.Render.IRenderTarget;
	import EncoShared.Render.MeshObject;
	import EncoShared.Render.Mesh;
	import EncoShared.Render.Shader;
	import EncoShared.Render.Color;
	import EncoShared.Render.GUIRenderer;
	import EncoShared.Render.Font;

	import EncoShared.Scripting.LuaExt;

	import EncoShared.GUI.Control;
	import EncoShared.GUI.PictureControl;
	import EncoShared.GUI.DynamicColorControl;
	import EncoShared.GUI.TextControl;
	import EncoShared.GUI.PanelControl;
	import EncoShared.GUI.SpriteControl;

	import EncoShared.Ext.Array;
	import EncoShared.Ext.String;
	import EncoShared.Ext.Vector;

	import EncoShared.Network.Network;
	import EncoShared.Network.StringPacket;
	import EncoShared.Network.ArrayPackets;

	import EncoShared.Animation.Animation;
	import EncoShared.Animation.BasicEaseFunctions;
	import EncoShared.Animation.AnimatedProperty;

	import EncoShared.Input.Keyboard;
	import EncoShared.Input.Mouse;
	import EncoShared.Input.Controller;

	import EncoShared.Components.FPSRotation;
	import EncoShared.Components.FreeMove;

	import EncoShared.Level.LevelLoader;

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

	/// 2*pi
	enum PI2 = 6.28318530718;

	/// Converts degrees to radians
	static float degToRad(float f)
	{
		return f * 0.0174532925f;
	}

	/// Converts radians to degrees
	static float radToDeg(float f)
	{
		return f * 57.2957795f;
	}
}
