#include "Mob.h"

#include <AnimatedSprite.hpp>

using namespace godot;

void Mob::_register_methods()
{
    register_property<Mob, int>("min_speed", &Mob::min_speed, 150);
    register_property<Mob, int>("max_speed", &Mob::max_speed, 250);
    register_method("_ready", &Mob::_ready);
    register_method("_on_VisibilityNotifier2D_screen_exited", &Mob::_on_VisibilityNotifier2D_screen_exited);
}

Mob::Mob()
{
}

Mob::~Mob()
{
}

void Mob::_init()
{
    mob_types.append("walk");
    mob_types.append("swim");
    mob_types.append("fly");
}

void Mob::_ready()
{
    String animation = mob_types[rand() % mob_types.size()];
    static_cast<AnimatedSprite *>(get_node("AnimatedSprite"))->set_animation(animation);
}

void Mob::_on_VisibilityNotifier2D_screen_exited()
{
    queue_free();
}