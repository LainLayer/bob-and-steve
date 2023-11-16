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

#load "types.jai";

entities: [..]Entity;

main :: () {
    last_time = get_time();
    window = create_window(window_name="bweh", width=window_width, height=window_height);

    simp.set_render_target(window);

    the_font = simp.get_font_at_size(".", "PxPlus_IBM_VGA8.ttf",  text_height);

    a: Entity;
    make_entity(*a, "Bob");

    array_add(*entities, a);

    // array_add(*entities, Entity.{"Bob"  , Vector4.{1,0,0,1}, 2, 1, 70, .Average, .Average, .Average});
    // array_add(*entities, Entity.{"Steve", Vector4.{0,1,0,1}, 4, 5, 50, .Average, .Average, .Average});

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
                    if it.key_pressed {
                        if it.key_code == {
                            case .ESCAPE;      quit = true;
                            case .ARROW_RIGHT; entities[0].x += 1;
                            case .ARROW_LEFT;  entities[0].x -= 1;
                            case .ARROW_UP;    entities[0].y += 1;
                            case .ARROW_DOWN;  entities[0].y -= 1;
                        }
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

mouse_x: float;
mouse_y: float;

simulate :: () {
    window_mouse_x, window_mouse_y := get_mouse_pointer_position(window, true);

    w_ratio := cast(float)(game_width ) / cast(float)(window_width );
    h_ratio := cast(float)(game_height) / cast(float)(window_height);

    mouse_x = window_mouse_x * w_ratio;
    mouse_y = window_mouse_y * h_ratio;

    #if false {
        print("mouse_x: %, mouse_y: %             \r", mouse_x, mouse_y);
    }
}

draw_entity :: inline (using entity: Entity) {
    using simp;

    entity_hitbox := Vector4.{
        cast(float)(x * unit),
        cast(float)(y * unit),
        cast(float)(x * unit + unit),
        cast(float)(y * unit + unit)
    };

    /* Entity square */
    set_shader_for_color();
    immediate_quad(
        entity_hitbox.x,
        entity_hitbox.y,
        entity_hitbox.z,
        entity_hitbox.w,
        color
    );

    /* Entity name above them */
    set_shader_for_text();
    name_width := prepare_text(the_font, name);
    draw_prepared_text(
        the_font,
        x * unit + (unit / 2) - (name_width / 2),
        (y + 1) * unit + (unit / 8),
        Vector4.{0,0.5,0.5,1}
    );

    set_shader_for_color();

    /* Red part of the health bar */
    immediate_quad(
        cast(float)( x    * unit                             ),
        cast(float)((y+1) * unit + text_height + (unit / 8)  ),
        cast(float)((x+1) * unit                             ),
        cast(float)((y+1) * unit + text_height + (unit / 8)*2),
        Vector4.{1,0,0,1}
    );


    // TODO: Probably no need for a fake health bar, just display the injuries.
    {  /* Green part of the health bar */
        total_roll: s8 = xx (3 + strength + reflex + intellect);

        total_injury: float = 0;
        for injury : injuries
            total_injury += injury;

        bar_ratio: float;

        if total_injury >= cast(float)(total_roll)
            bar_ratio = 0;
        else
            bar_ratio = 1 - (total_injury / total_roll);

        immediate_quad(
            cast(float)( x    * unit                             ),
            cast(float)((y+1) * unit + text_height + (unit / 8)  ),
            unit * (x + bar_ratio)            ,
            cast(float)((y+1) * unit + text_height + (unit / 8)*2),
            Vector4.{0,1,0,1}
        );
    }

    if mouse_x >= entity_hitbox.x &&
       mouse_x <= entity_hitbox.z &&
       mouse_y >= entity_hitbox.y &&
       mouse_y <= entity_hitbox.w
    {
        set_shader_for_color();
        immediate_quad(
            entity_hitbox.x,
            entity_hitbox.y,
            entity_hitbox.z,
            entity_hitbox.w,
            Vector4.{1,1,0,1}
        );
    }

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