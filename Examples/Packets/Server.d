module Server;

import std.socket;
import std.bitmanip;
import std.algorithm;

import core.thread;

import EncoShared;

class ClientThread : Thread
{
private:

	void run()
	{
		std.stdio.writeln("Incoming connection from Socket #", id, " (", socket.remoteAddress.toAddrString(), ")");
		socket.blocking = false;
		ubyte[1024] packet = new ubyte[1024];
		while(socket.isAlive())
		{
			try
			{
				ptrdiff_t length = socket.receive(packet);

				if(length == 0)
				{
					std.stdio.writeln("Disconnect from Socket #", id);
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
						std.stdio.writeln("Invalid packet from Socket #", id);
						socket.shutdown(SocketShutdown.BOTH);
						socket.close();
						return;
					}
					std.stdio.writefln("Received packet #%s from Socket #%s", packetID, id);
					StringPacket strPacket = new StringPacket();
					strPacket.deserialize(data);
					std.stdio.writeln(strPacket.text);

					if(strPacket.text == "password")
					{
						socket.send(nativeToBigEndian(StringPacket.PACKET_ID) ~ new StringPacket("Password Accepted!").serialize());
					}
				}

				Thread.sleep(20.msecs);
			}
			catch
			{
				std.stdio.writeln("Unhandled exception from Socket #", id);
			}
		}
	}

public:
	this(Socket socket, int id)
	{
		super(&run);

		this.socket = socket;
		this.id = id;
	}

	Socket socket;
	int id;
}

class Server
{
public:
	this(ushort port)
	{
		this.port = port;
	}

	void listen()
	{
		socket = new TcpSocket();
		socket.bind(new InternetAddress(port));
		socket.listen(0);
		int id = 0;
		
		while(true)
		{
			Socket s = socket.accept();
			if(s !is null)
				new ClientThread(s, id++).start();
		}
	}

	void stop()
	{
		socket.shutdown(SocketShutdown.BOTH);
		socket.close();
	}

	ushort port;
	TcpSocket socket;
}