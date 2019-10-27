#ifndef HUD_H
#define HUD_H

#include <Godot.hpp>
#include <CanvasLayer.hpp>

namespace godot {

enum class State : int64_t
{
    START_GAME,
    MENU,
    GAME_OVER,
    NONE
};

class HUD: public CanvasLayer {
    GODOT_CLASS(HUD, CanvasLayer)

private:
    State state = State::NONE;

public:
    static void _register_methods();

    HUD();
    ~HUD();

    void _init();

    void _on_StartButton_pressed();
    void _on_MessageTimer_timeout();
    void show_message(String text);
    void show_game_over();
    void update_score(int score);
    void show_menu();
};

}

#endif