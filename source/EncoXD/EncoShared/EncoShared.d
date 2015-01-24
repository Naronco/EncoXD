module EncoShared;

public
{
	import derelict.sdl2.sdl;
	import derelict.sdl2.image;
	import derelict.assimp3.assimp;

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
	import Enco.Shared.Core.Scene;
	import Enco.Shared.Core.TemplateParser;
	import Enco.Shared.Core.Logger;
	
	import Enco.Shared.Render.GUIRenderer;
	import Enco.Shared.Render.IRenderer;
	import Enco.Shared.Render.ITexture;
	import Enco.Shared.Render.Material;
	import Enco.Shared.Render.RenderContext;
	import Enco.Shared.Render.IRenderTarget;
	import Enco.Shared.Render.MeshObject;
	import Enco.Shared.Render.Mesh;
	import Enco.Shared.Render.Shader;

	import Enco.Shared.Scripting.LuaExt;
	
	import Enco.Shared.Ext.String;
	
	import Enco.Shared.Network.Network;
	import Enco.Shared.Network.Tcp;
	
	import Enco.Shared.Animation.Animation;
	import Enco.Shared.Animation.BasicEaseFunctions;
	import Enco.Shared.Animation.AnimatedProperty;
	
	import std.algorithm;
	import std.string;
	import std.conv;

	alias char int8, i8;
	alias short int16, i16;
	alias int int32, i32;
	alias long int64, i64;

	alias ubyte uchar, uint8, u8;
	alias ushort uint16, u16;
	alias uint uint32, u32;
	alias ulong uint64, u64;

	alias float f32, float32;
	alias double f64, float64;

	alias Vector!(u32, 2) u32vec2;
}