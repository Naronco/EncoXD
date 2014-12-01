module EncoShared;

public
{
	import derelict.sdl2.sdl;
	import derelict.sdl2.image;
	
	import gl3n.aabb;
	import gl3n.frustum;
	import gl3n.interpolate;
	import gl3n.linalg;
	import gl3n.math;
	import gl3n.plane;
	import gl3n.util;

	import Enco.Shared.IRenderer;
	import Enco.Shared.IView;
	import Enco.Shared.EncoContext;

	import Enco.Shared.Enco3D.Mesh;

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