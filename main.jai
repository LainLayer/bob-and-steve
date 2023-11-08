#import "Basic";
#import "Window_Creation";
#import "Input";
#import "Math";

simp :: #import "Simp";

window_width:  s32 = 800;
window_height: s32 = 800;

quit := false;

current_dt: float = 0.016667;
last_time:  float64;
DT_MAX:     float : 0.15;
FPS :: 1.0 / 60;

window: Window_Type;

game_width  : s32 : 800;
game_height : s32 : 800;

unit :: game_width / 16;

game_texture: *simp.Texture;

the_font: *simp.Dynamic_Font;

text_height :: unit / 2;

Entity :: struct {
    name:  string;
    color: Vector4;

    /* From the bottom left like in simp */
    x: int;
    y: int;

    hp: u32;
}

entities: [..]Entity;

main :: () {
    last_time = get_time();
    window = create_window(window_name="bweh", width=window_width, height=window_height);

    simp.set_render_target(window);

    the_font = simp.get_font_at_size(".", "PxPlus_IBM_VGA8.ttf",  text_height);

    array_add(*entities, Entity.{"Bob"  , Vector4.{1,0,0,1}, 1, 1, 70});
    array_add(*entities, Entity.{"Steve", Vector4.{0,1,0,1}, 4, 5, 50});

    game_texture = simp.texture_create_render_target(game_width, game_height, .RGBA8);

    while !quit {
        reset_temporary_storage();
        simp.update_window(window);

        update_window_events();
        for get_window_resizes() {
            simp.update_window(it.window);

            if it.window == window {
                window_width  = it.width;
                window_height = it.height;
            }
        }

        for events_this_frame {
            if it.type == {
                case .QUIT;
                    quit = true;
                case .KEYBOARD;
                    if it.key_pressed && it.key_code == .ESCAPE {
                        quit = true;
                    }
            }
        }

        now := get_time();
        delta : float64 = now - last_time;
        current_dt = cast(float) delta;
        if current_dt > DT_MAX current_dt = DT_MAX;
        last_time = now;

        simulate();

        draw_frame();

        sleep_milliseconds(cast(s32) ((FPS - current_dt) * 1000));
    }
}

simulate :: () {

}

draw_entity :: inline (using entity: Entity) {
    using simp;

    set_shader_for_color();
    immediate_quad(
        cast(float)(x * unit),
        cast(float)(y * unit),
        cast(float)(x * unit + unit),
        cast(float)(y * unit + unit),
        color
    );

    set_shader_for_text();
    name_width := prepare_text(the_font, name);
    draw_prepared_text(
        the_font,
        x * unit + (unit / 2) - (name_width / 2),
        (y + 1) * unit + (unit / 8),
        Vector4.{0,0.5,0.5,1}
    );

    set_shader_for_color();
    immediate_quad(
        cast(float)(x * unit),
        cast(float)((y+1) * unit + text_height + (unit / 8)),
        cast(float)((x+1) * unit),
        cast(float)((y+1) * unit + text_height + (unit / 8)*2),
        Vector4.{1,0,0,1}
    );

    immediate_quad(
        cast(float)(x * unit),
        cast(float)((y+1) * unit + text_height + (unit / 8)),
        (x + 1*(hp/100.0)) * unit,
        cast(float)((y+1) * unit + text_height + (unit / 8)*2),
        Vector4.{0,1,0,1}
    );
}

draw_frame :: inline () {
    using simp;

    set_render_target(game_texture);
    clear_render_target(.15, .08, .08, 1);

    for entities
        draw_entity(it);


    set_render_target(window);
    set_shader_for_images(game_texture);
    immediate_quad(0, 0, 0.0 + window_width, 0.0 + window_height, Vector4.{1,1,1,1});

    swap_buffers(window);
}