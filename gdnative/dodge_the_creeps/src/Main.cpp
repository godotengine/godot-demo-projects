#include "Main.h"

#include <iostream>
#include <GlobalConstants.hpp>
#include <Timer.hpp>
#include <AudioStreamPlayer.hpp>
#include <Position2D.hpp>
#include <PathFollow2D.hpp>
// #include <RigidBody2D.hpp>

#include "Mob.h"

using namespace godot;

void Main::_register_methods()
{
    register_method("_get_property_list", &Main::_get_property_list);
    register_method("_get", &Main::_get);
	register_method("_set", &Main::_set);

    register_method("_ready", &Main::_ready);
    register_method("_on_MobTimer_timeout", &Main::_on_MobTimer_timeout);
    register_method("_on_ScoreTimer_timeout", &Main::_on_ScoreTimer_timeout);
    register_method("_on_StartTimer_timeout", &Main::_on_StartTimer_timeout);
    register_method("game_over", &Main::game_over);
    register_method("new_game", &Main::new_game);
}

Array Main::_get_property_list() {

	Array arr;

	Dictionary prop;
	prop["name"] = String("Mob");
	prop["type"] = GlobalConstants::TYPE_OBJECT;
	prop["hint"] = GlobalConstants::PROPERTY_HINT_RESOURCE_TYPE;
	prop["hint_string"] = "PackedScene";
	prop["usage"] = GlobalConstants::PROPERTY_USAGE_DEFAULT;
	arr.push_back(prop);

	return arr;
}

Variant Main::_get(String p_name) {

	if (p_name == "Mob") {
		return mob;
	} else {
		return Variant();
	}
}

bool Main::_set(String p_name, Variant p_value) {

	if (p_name == "Mob") {
		mob = p_value;
		return true;
	} else {
		return false;
	}
}

Main::Main()
{
}

Main::~Main()
{
}

void Main::_init()
{
}

void Main::_ready()
{
}

void Main::_on_MobTimer_timeout()
{
    PathFollow2D* path = static_cast<PathFollow2D*>(get_node("MobPath/MobSpawnLocation"));
    path->set_offset(rand());
	Mob* _mob = static_cast<Mob*>(mob->instance());
	add_child(_mob);
	float direction = path->get_rotation() + M_PI/2.0;
	_mob->set_position(path->get_position());
	direction += RAND_RANGE(-M_PI_4, M_PI_4);
	_mob->set_rotation(direction);
    int64_t min_speed = _mob->get("min_speed");
    int64_t max_speed = _mob->get("max_speed");
    Vector2 dir = Vector2(rand() % max_speed + min_speed, 0);
    
    Vector2 v;
	v.set_rotation(dir.angle() + direction);
	v *= dir.length();
	
    _mob->set_linear_velocity(v);
}

void Main::_on_ScoreTimer_timeout()
{
    score += 1;
	get_node("HUD")->call("update_score", score);
}

void Main::_on_StartTimer_timeout()
{
    static_cast<Timer*>(get_node("MobTimer"))->start();
	static_cast<Timer*>(get_node("ScoreTimer"))->start();
}

void Main::game_over()
{
    static_cast<Timer*>(get_node("ScoreTimer"))->stop();
	static_cast<Timer*>(get_node("MobTimer"))->stop();
	get_node("HUD")->call("show_game_over");
	static_cast<AudioStreamPlayer*>(get_node("Music"))->stop();
	static_cast<AudioStreamPlayer*>(get_node("DeathSound"))->play();
}

void Main::new_game()
{
    score = 0;
	get_node("Player")->call("start", static_cast<Position2D*>(get_node("StartPosition"))->get_position());
	static_cast<Timer*>(get_node("StartTimer"))->start();
	get_node("HUD")->call("update_score", score);
	get_node("HUD")->call("show_message", "Get Ready");
	static_cast<AudioStreamPlayer*>(get_node("Music"))->play();
}
