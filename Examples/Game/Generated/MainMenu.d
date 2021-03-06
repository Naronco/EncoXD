module Generated.MainMenu;

import Scenes.MainMenu;
import EncoGL3;
import EncoShared;

void generateMainMenu(MainMenu menu, ContentManager content) {
	TextControl!GLTexture _textcontrol1 = new TextControl!GLTexture();
	_textcontrol1.y = (-110);
	_textcontrol1.color = (Color.fromRGB(0x37474F));
	_textcontrol1.font = (new Font("res/fonts/Roboto/Roboto-Regular.ttf", 40));
	_textcontrol1.alignment = (Alignment.MiddleCenter);
	_textcontrol1.text = ("ExampleGame");
	menu.addChild(_textcontrol1);
	PanelControl _panelcontrol2 = new PanelControl();
	_panelcontrol2.size(0, 30, 200, 190);
	_panelcontrol2.alignment = (Alignment.MiddleCenter);
	menu.addChild(_panelcontrol2);
	DynamicColorControl _dynamiccolorcontrol3 = new DynamicColorControl();
	_dynamiccolorcontrol3.size(0, 0, 100.per100, 40);
	_dynamiccolorcontrol3.alignment = (Alignment.TopCenter);
	_dynamiccolorcontrol3.color = (Color.fromRGB(0x3F51B5));
	_panelcontrol2.addChild(_dynamiccolorcontrol3);
	SpriteControl _spritecontrol4 = new SpriteControl();
	_spritecontrol4.texture = (content.loadTexture("res/tex/icons.png"));
	_spritecontrol4.clip = (vec4(0, 64, 64, 64));
	_spritecontrol4.size(0, 0, 40, 40);
	_spritecontrol4.alignment = (Alignment.MiddleLeft);
	_dynamiccolorcontrol3.addChild(_spritecontrol4);
	TextControl!GLTexture _textcontrol5 = new TextControl!GLTexture();
	_textcontrol5.font = (new Font("res/fonts/Roboto/Roboto-Regular.ttf", 20));
	_textcontrol5.alignment = (Alignment.MiddleCenter);
	_textcontrol5.text = ("Play");
	_dynamiccolorcontrol3.addChild(_textcontrol5);
	DynamicColorControl _dynamiccolorcontrol6 = new DynamicColorControl();
	_dynamiccolorcontrol6.size(0, 50, 100.per100, 40);
	_dynamiccolorcontrol6.alignment = (Alignment.TopCenter);
	_dynamiccolorcontrol6.color = (Color.fromRGB(0x3F51B5));
	_panelcontrol2.addChild(_dynamiccolorcontrol6);
	SpriteControl _spritecontrol7 = new SpriteControl();
	_spritecontrol7.texture = (content.loadTexture("res/tex/icons.png"));
	_spritecontrol7.clip = (vec4(0, 0, 64, 64));
	_spritecontrol7.size(0, 0, 40, 40);
	_spritecontrol7.alignment = (Alignment.MiddleLeft);
	_dynamiccolorcontrol6.addChild(_spritecontrol7);
	TextControl!GLTexture _textcontrol8 = new TextControl!GLTexture();
	_textcontrol8.font = (new Font("res/fonts/Roboto/Roboto-Regular.ttf", 20));
	_textcontrol8.alignment = (Alignment.MiddleCenter);
	_textcontrol8.text = ("Settings");
	_dynamiccolorcontrol6.addChild(_textcontrol8);
	DynamicColorControl _dynamiccolorcontrol9 = new DynamicColorControl();
	_dynamiccolorcontrol9.size(0, 150, 100.per100, 40);
	_dynamiccolorcontrol9.alignment = (Alignment.TopCenter);
	_dynamiccolorcontrol9.color = (Color.fromRGB(0x3F51B5));
	_panelcontrol2.addChild(_dynamiccolorcontrol9);
	SpriteControl _spritecontrol10 = new SpriteControl();
	_spritecontrol10.texture = (content.loadTexture("res/tex/icons.png"));
	_spritecontrol10.clip = (vec4(64, 0, 64, 64));
	_spritecontrol10.size(0, 0, 40, 40);
	_spritecontrol10.alignment = (Alignment.MiddleLeft);
	_dynamiccolorcontrol9.addChild(_spritecontrol10);
	TextControl!GLTexture _textcontrol11 = new TextControl!GLTexture();
	_textcontrol11.font = (new Font("res/fonts/Roboto/Roboto-Regular.ttf", 20));
	_textcontrol11.alignment = (Alignment.MiddleCenter);
	_textcontrol11.text = ("Exit");
	_dynamiccolorcontrol9.addChild(_textcontrol11);
}