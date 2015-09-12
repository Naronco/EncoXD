module Server;

import std.socket;
import std.bitmanip;
import std.algorithm;

import core.thread;

import EncoShared;

class Server
{
private:
	int _id = 0;

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
		socket.blocking = false;

		ubyte[1024] buffer = new ubyte[1024];
		ubyte[] data;

		Socket[] sockets;

		while (true)
		{
			auto sock = socket.accept();
			if (sock && sock.isAlive)
			{
				sockets ~= sock;
				std.stdio.writeln("New Connection");
			}

			for (size_t i = 0; i < sockets.length; i++)
			{
				if (sockets[i].isAlive)
				{
					data.length = 0;
					int received;
					while ((received = sockets[i].receive(buffer)) > 0)
					{
						data ~= buffer[0 .. received];
					}
					if (data.length > 0)
					{
						if (data.read!ushort != StringPacket.PACKET_ID)
						{
							sockets[i].close();
						}
						else
						{
							try
							{
								for (size_t j = 0; j < sockets.length; j++)
								{
									sockets[j].send(data);
								}
							}
							catch (Exception)
							{
								sockets[i].close();
							}
						}
					}
				}
			}
			Thread.sleep(50.msecs);
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
