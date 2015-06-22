module Client;

import EncoShared;

import std.bitmanip;
import std.socket;
import std.stdio;

import core.thread;

class Client
{
public:
	this(string ip, ushort port)
	{
		this.ip = ip;
		this.port = port;
	}

	void handleReceive()
	{
		ubyte[] packet = new ubyte[1024];

		while(true)
		{
			ptrdiff_t length = socket.receive(packet);

			if(length == 0)
			{
				std.stdio.writeln("Disconnect from Server");
				socket.shutdown(SocketShutdown.BOTH);
				socket.close();
				return;
			}
			else if(length > 0)
			{
				ubyte[] data = packet[];
				while(length == 1024)
				{
					length = socket.receive(packet);
					if(length > 0)
						data ~= packet[];
				}
				data = data.stripRight(0);
				ushort packetID = data.read!ushort();
				if(packetID != 65500)
				{
					std.stdio.writeln("Invalid packet received!");
					socket.shutdown(SocketShutdown.BOTH);
					socket.close();
					return;
				}
				StringPacket strPacket = new StringPacket();
				strPacket.deserialize(data);
				std.stdio.writeln(" << ", strPacket.text);
			}
		}
	}

	void connect()
	{
		socket = new TcpSocket();
		socket.connect(new InternetAddress(ip, port));
		socket.blocking = false;

		new Thread(&handleReceive).start();

		while(true)
		{
			write(" >> ");
			socket.send(nativeToBigEndian(StringPacket.PACKET_ID) ~ new StringPacket(readln()[0 .. $ - 1]).serialize());
			Thread.sleep(50.msecs);
		}
	}

	void disconnect()
	{
		socket.shutdown(SocketShutdown.BOTH);
		socket.close();
	}

	string ip;
	ushort port;
	TcpSocket socket;
}