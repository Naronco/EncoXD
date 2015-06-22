import std.getopt;
import std.stdio;

import Server;
import Client;

void main(string[] args)
{
	bool server, client;
	string ip = "127.0.0.1";
	ushort port = 2060;

	auto help = getopt(args, "server|s", &server, "client|c", &client, "ip|i", &ip, "port|p", &port);

	if(help.helpWanted)
	{
		defaultGetoptPrinter("Packet Demo", help.options);
		return;
	}

	if(server == client)
	{
		writeln("Select either server or client (-s or -c). Not both!");
		return;
	}

	if(server)
	{
		Server s = new Server(port);
		scope(exit) s.stop();
		s.listen();
	}
	else
	{
		Client c = new Client(ip, port);
		scope(exit) c.disconnect();
		c.connect();
	}
}
