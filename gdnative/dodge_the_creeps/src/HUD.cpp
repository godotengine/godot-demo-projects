#include "HUD.h"

#include <Timer.hpp>
#include <Button.hpp>
#include <Label.hpp>

using namespace godot;

void HUD::_register_methods()
{
    register_method("_on_StartButton_pressed", &HUD::_on_StartButton_pressed);
    register_method("_on_MessageTimer_timeout", &HUD::_on_MessageTimer_timeout);
    register_method("show_game_over", &HUD::show_game_over);
    register_method("update_score", &HUD::update_score);
    register_method("show_message", &HUD::show_message);

    register_signal<HUD>("start_game");
}

HUD::HUD()
{
}

HUD::~HUD()
{
}

void HUD::_init()
{
}

void HUD::_on_StartButton_pressed()
{
	state = State::START_GAME;
	static_cast<Control*>(get_node("StartButton"))->hide();
	emit_signal("start_game");
}

void HUD::_on_MessageTimer_timeout()
{
	switch (state)
	{
	case State::MENU:
		static_cast<Control*>(get_node("StartButton"))->show();
		break;
	case State::GAME_OVER:
		show_menu();
		break;
	case State::START_GAME:
		static_cast<Control*>(get_node("MessageLabel"))->hide();
	default:
		break;
	}
}

void HUD::show_message(String text)
{
    static_cast<Label*>(get_node("MessageLabel"))->set_text(text);
	static_cast<Control*>(get_node("MessageLabel"))->show();
	static_cast<Timer*>(get_node("MessageTimer"))->start();
}

void HUD::show_game_over()
{
    show_message("Game Over");
	state = State::GAME_OVER;
}

void HUD::show_menu()
{
	state = State::MENU;
	static_cast<Label*>(get_node("MessageLabel"))->set_text("Dodge the\nCreeps");
	static_cast<Label*>(get_node("MessageLabel"))->show();
	static_cast<Timer*>(get_node("MessageTimer"))->start();
}

void HUD::update_score(int score)
{
    static_cast<Label*>(get_node("ScoreLabel"))->set_text(String(score));
}
