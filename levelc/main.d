import std.stdio;
import std.getopt;
import std.string;
static import std.file;
static import std.path;

import EncoShared;

void outputFile(string file, string content)
{
	if (!std.file.exists(std.path.dirName(file)))
		std.file.mkdirRecurse(std.path.dirName(file));
	std.file.write(file, content);
}

void main(string[] args)
{
	string output = "";

	auto help = getopt(args,
	                   config.passThrough,
	                   "of|outputFolder", "output folder for generated D files", &output);
	if (help.helpWanted)
	{
		defaultGetoptPrinter("Level to D converter for EncoXD", help.options);
		return;
	}

	if (args.length <= 1)
	{
		defaultGetoptPrinter("Level to D converter for EncoXD", help.options);
		return;
	}

	foreach (input; args[1 .. $])
	{
		try
		{
			string content = std.file.readText(input);
			string[] lines = content.splitLines();
			string moduleName = std.path.stripExtension(std.path.baseName(input)).replace(".", "_");
			string entryVoid = "void generate_" ~ std.path.stripExtension(std.path.baseName(input)).replace(".", "_") ~ "()";
			string root = "";
			string[] imports;
			foreach (line; lines)
			{
				if (line.indexOf("//#") != -1)
				{
					string pragmaExpr = line[line.indexOf("//#") + 3 .. $];
					string[] cargs = pragmaExpr.split(' ');
					if (cargs.length > 1)
					{
						cargs[1] = cargs[1 .. $].join(" ");
						switch (cargs[0].toLower())
						{
						case "module":
							moduleName = cargs[1];
							break;
						case "entry":
							entryVoid = cargs[1];
							break;
						case "import":
							imports ~= "import " ~ cargs[1] ~ ";";
							break;
						case "root":
							root = cargs[1];
							break;
						default:
							writefln("WARN: Unknown compiler statement '%s'", cargs[0]);
							break;
						}
					}
				}
			}
			outputFile(std.path.buildPath(output, std.path.stripExtension(std.path.baseName(input)) ~ ".d"), format("module %s;\n\n%-(%s\n%)\n\n%s {\n\t%-(%s\n\t%)\n}", moduleName, imports, entryVoid, new LevelCompiler(true, root).compileLevel(content).splitLines()));
		}
		catch (Exception e)
		{
			writefln("Couldn't compile file '%s'!\n", input, e);
		}
	}
}
