#ifndef MAIN_H
#define MAIN_H

#include <Godot.hpp>
#include <Node.hpp>
#include <PackedScene.hpp>
#include <Ref.hpp>

namespace godot {

#ifndef RAND_RANGE
#define RAND_RANGE(LO, HI) LO + static_cast <float> (rand()) /( static_cast <float> (RAND_MAX/(HI-LO)));
#endif

class Main: public Node {
    GODOT_CLASS(Main, Node)

public:
    int score = 0;
    Ref<PackedScene> mob;
public:
    static void _register_methods();
    Array _get_property_list();
    Variant _get(String p_name);
	bool _set(String p_name, Variant p_value);

    Main();
    ~Main();

    void _init();

    void _ready();
    void _on_MobTimer_timeout();
    void _on_ScoreTimer_timeout();
    void _on_StartTimer_timeout();

    void game_over();
    void new_game();
};

}

#endif