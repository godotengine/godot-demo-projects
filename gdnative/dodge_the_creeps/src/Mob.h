#ifndef MOB_H
#define MOB_H

#include <Godot.hpp>
#include <RigidBody2D.hpp>

namespace godot {

class Mob: public RigidBody2D {
    GODOT_CLASS(Mob, RigidBody2D)

private:
    Array mob_types;
public:
    int min_speed = 150;
    int max_speed = 250;
public:
    static void _register_methods();

    Mob();
    ~Mob();

    void _init();

    void _ready();
    void _on_VisibilityNotifier2D_screen_exited();
};

}

#endif