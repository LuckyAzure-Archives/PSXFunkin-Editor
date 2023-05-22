#include "hypno.h"

#include "../../psx/mem.h"
#include "../../psx/archive.h"
#include "../../scenes/stage/stage.h"
#include "../../main.h"

//Hypno character structure
enum
{
	Hypno_ArcMain_idle0,
	Hypno_ArcMain_left0,

	Hypno_Arc_Max,
};

typedef struct
{
	//Character base structure
	Character character;
	
	//Render data and state
	IO_Data arc_main;
	IO_Data arc_ptr[Hypno_Arc_Max];
	
	Gfx_Tex tex;
	u8 frame, tex_id;
} Char_Hypno;

//Hypno character definitions
static const u16 char_hypno_icons[2][4] = {
	[84,0,27,25],
	[112,0,27,25]
};

static const CharFrame char_hypno_frame[] = {
	{Hypno_ArcMain_idle0,{0,0,216,164},{111,160}}, //0 Idle0
	{Hypno_ArcMain_idle0,{0,0,216,164},{116,160}}, //1 Idle0
	{Hypno_ArcMain_idle0,{0,0,216,164},{108,160}}, //2 Idle0
	{Hypno_ArcMain_idle0,{0,0,216,164},{114,160}}, //3 Idle0
	{Hypno_ArcMain_idle0,{0,0,216,164},{118,160}}, //4 Idle0
	{Hypno_ArcMain_idle0,{0,0,216,164},{121,160}}, //5 Idle0
	{Hypno_ArcMain_idle0,{0,0,216,164},{118,160}}, //6 Idle0
	{Hypno_ArcMain_idle0,{0,0,216,164},{117,160}}, //7 Idle0
	{Hypno_ArcMain_idle0,{0,0,216,164},{116,160}}, //8 Idle0
	{Hypno_ArcMain_idle0,{0,0,216,164},{115,160}}, //9 Idle0
	{Hypno_ArcMain_idle0,{0,0,216,164},{114,160}}, //10 Idle0
	{Hypno_ArcMain_idle0,{0,0,216,164},{113,160}}, //11 Idle0
	{Hypno_ArcMain_idle0,{0,0,216,164},{112,160}}, //12 Idle0
	{Hypno_ArcMain_idle0,{0,0,216,164},{111,160}}, //13 Idle0
	
	{Hypno_ArcMain_left0,{0,0,238,176},{151,170}}, //14 Left
	

};

static const Animation char_hypno_anim[CharAnim_Max] = {
	{0, (const u8[]){ASCR_CHGANI, CharAnim_Idle}},		//CharAnim_Idle
	{24, (const u8[]){ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, ASCR_BACK, 1}},		//CharAnim_Left
	{24, (const u8[]){ 14, ASCR_BACK, 1}},		//CharAnim_Left
	{0, (const u8[]){ASCR_CHGANI, CharAnim_Idle}},		//CharAnim_LeftAlt
	{0, (const u8[]){ASCR_CHGANI, CharAnim_Idle}},		//CharAnim_Down
	{0, (const u8[]){ASCR_CHGANI, CharAnim_Idle}},		//CharAnim_DownAlt
	{0, (const u8[]){ASCR_CHGANI, CharAnim_Idle}},		//CharAnim_Up
	{0, (const u8[]){ASCR_CHGANI, CharAnim_Idle}},		//CharAnim_UpAlt
	{0, (const u8[]){ASCR_CHGANI, CharAnim_Idle}},		//CharAnim_Right
	{0, (const u8[]){ASCR_CHGANI, CharAnim_Idle}},		//CharAnim_RightAlt

};

//Hypno character functions
void Char_Hypno_SetFrame(void *user, u8 frame)
{
	Char_Hypno *this = (Char_Hypno*)user;
	
	//Check if this is a new frame
	if (frame != this->frame)
	{
		//Check if new art shall be loaded
		const CharFrame *cframe = &char_hypno_frame[this->frame = frame];
		if (cframe->tex != this->tex_id)
			Gfx_LoadTex(&this->tex, this->arc_ptr[this->tex_id = cframe->tex], 0);
	}
}

void Char_Hypno_Tick(Character *character)
{
	Char_Hypno *this = (Char_Hypno*)character;
	
	//Perform idle dance
	if ((character->pad_held & (stage.prefs.control_keys[0] | stage.prefs.control_keys[1] | stage.prefs.control_keys[2] | stage.prefs.control_keys[3])) == 0)
		Character_PerformIdle(character);
	
	//Animate and draw
	Animatable_Animate(&character->animatable, (void*)this, Char_Hypno_SetFrame);
	Character_Draw(character, &this->tex, &char_hypno_frame[this->frame]);
}

void Char_Hypno_SetAnim(Character *character, u8 anim)
{
	//Set animation
	Animatable_SetAnim(&character->animatable, anim);
	Character_CheckStartSing(character);
}

void Char_Hypno_Free(Character *character)
{
	Char_Hypno *this = (Char_Hypno*)character;
	
	//Free art
	Mem_Free(this->arc_main);
}

Character *Char_Hypno_New(fixed_t x, fixed_t y)
{
	//Allocate hypno object
	Char_Hypno *this = Mem_Alloc(sizeof(Char_Hypno));
	if (this == NULL)
	{
		sprintf(error_msg, "[Char_Hypno_New] Failed to allocate hypno object");
		ErrorLock();
		return NULL;
	}
	
	//Initialize character
	this->character.tick = Char_Hypno_Tick;
	this->character.set_anim = Char_Hypno_SetAnim;
	this->character.free = Char_Hypno_Free;
	
	Animatable_Init(&this->character.animatable, char_hypno_anim);
	Character_Init((Character*)this, x, y);
	
	//Set character information
	this->character.spec = 0;
	
	memcpy(this->character.health_i, char_hypno_icons, sizeof(char_hypno_icons));
	
	//health bar color
	this->character.health_bar = 0xFF808080;
	
	this->character.focus_x = FIXED_DEC(-30,1);
	this->character.focus_y = FIXED_DEC(-90,1);
	this->character.focus_zoom = FIXED_DEC(100,1);
	
	this->character.size = FIXED_DEC(100,100);
	
	//Load art
	this->arc_main = IO_Read("\\CHAR\\HYPNO.ARC;1");
	
	const char **pathp = (const char *[]){
		"idle0.tim",
		"left0.tim",

		NULL
	};
	IO_Data *arc_ptr = this->arc_ptr;
	for (; *pathp != NULL; pathp++)
		*arc_ptr++ = Archive_Find(this->arc_main, *pathp);
	
	//Initialize render state
	this->tex_id = this->frame = 0xFF;
	
	return (Character*)this;
}
