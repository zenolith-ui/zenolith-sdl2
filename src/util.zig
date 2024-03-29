const zenolith = @import("zenolith");

const c = @import("ffi.zig").c;

pub fn toSdlRect(rect: zenolith.layout.Rectangle) c.SDL_Rect {
    return .{
        .x = @intCast(rect.pos.x),
        .y = @intCast(rect.pos.y),
        .w = @intCast(rect.size.width),
        .h = @intCast(rect.size.height),
    };
}

pub fn convertKey(sdl: c.SDL_Keycode) ?zenolith.key.Keycode {
    return switch (sdl) {
        c.SDLK_RETURN => .enter,
        c.SDLK_ESCAPE => .escape,
        c.SDLK_BACKSPACE => .backspace,
        c.SDLK_TAB => .tab,
        c.SDLK_SPACE => .space,
        c.SDLK_EXCLAIM => .exclaim,
        c.SDLK_QUOTEDBL => .double_quote,
        c.SDLK_HASH => .hash,
        c.SDLK_PERCENT => .percent,
        c.SDLK_DOLLAR => .dollar,
        c.SDLK_AMPERSAND => .ampersand,
        c.SDLK_QUOTE => .quote,
        c.SDLK_LEFTPAREN => .paren_left,
        c.SDLK_RIGHTPAREN => .paren_right,
        c.SDLK_ASTERISK => .asterisk,
        c.SDLK_PLUS => .plus,
        c.SDLK_COMMA => .comma,
        c.SDLK_MINUS => .minus,
        c.SDLK_PERIOD => .period,
        c.SDLK_SLASH => .slash,
        c.SDLK_0 => .@"0",
        c.SDLK_1 => .@"1",
        c.SDLK_2 => .@"2",
        c.SDLK_3 => .@"3",
        c.SDLK_4 => .@"4",
        c.SDLK_5 => .@"5",
        c.SDLK_6 => .@"6",
        c.SDLK_7 => .@"7",
        c.SDLK_8 => .@"8",
        c.SDLK_9 => .@"9",
        c.SDLK_COLON => .colon,
        c.SDLK_SEMICOLON => .semicolon,
        c.SDLK_LESS => .less,
        c.SDLK_EQUALS => .equal,
        c.SDLK_GREATER => .greater,
        c.SDLK_QUESTION => .question,
        c.SDLK_AT => .at,

        c.SDLK_LEFTBRACKET => .bracket_left,
        c.SDLK_BACKSLASH => .backslash,
        c.SDLK_RIGHTBRACKET => .bracket_right,
        c.SDLK_CARET => .caret,
        c.SDLK_UNDERSCORE => .underscore,
        c.SDLK_BACKQUOTE => .backquote,
        c.SDLK_a => .a,
        c.SDLK_b => .b,
        c.SDLK_c => .c,
        c.SDLK_d => .d,
        c.SDLK_e => .e,
        c.SDLK_f => .f,
        c.SDLK_g => .g,
        c.SDLK_h => .h,
        c.SDLK_i => .i,
        c.SDLK_j => .j,
        c.SDLK_k => .k,
        c.SDLK_l => .l,
        c.SDLK_m => .m,
        c.SDLK_n => .n,
        c.SDLK_o => .o,
        c.SDLK_p => .p,
        c.SDLK_q => .q,
        c.SDLK_r => .r,
        c.SDLK_s => .s,
        c.SDLK_t => .t,
        c.SDLK_u => .u,
        c.SDLK_v => .v,
        c.SDLK_w => .w,
        c.SDLK_x => .x,
        c.SDLK_y => .y,
        c.SDLK_z => .z,

        c.SDLK_CAPSLOCK => .caps_lock,

        c.SDLK_F1 => .f1,
        c.SDLK_F2 => .f2,
        c.SDLK_F3 => .f3,
        c.SDLK_F4 => .f4,
        c.SDLK_F5 => .f5,
        c.SDLK_F6 => .f6,
        c.SDLK_F7 => .f7,
        c.SDLK_F8 => .f8,
        c.SDLK_F9 => .f9,
        c.SDLK_F10 => .f10,
        c.SDLK_F11 => .f11,
        c.SDLK_F12 => .f12,
        c.SDLK_F13 => .f13,
        c.SDLK_F14 => .f14,
        c.SDLK_F15 => .f15,
        c.SDLK_F16 => .f16,
        c.SDLK_F17 => .f17,
        c.SDLK_F18 => .f18,
        c.SDLK_F19 => .f19,
        c.SDLK_F20 => .f20,
        c.SDLK_F21 => .f21,
        c.SDLK_F22 => .f22,
        c.SDLK_F23 => .f23,
        c.SDLK_F24 => .f24,

        c.SDLK_PRINTSCREEN, c.SDLK_SYSREQ => .sysrq,
        c.SDLK_SCROLLLOCK => .scroll_lock,
        c.SDLK_PAUSE => .pause,
        c.SDLK_INSERT => .insert,
        c.SDLK_HOME => .home,
        c.SDLK_PAGEUP => .page_up,
        c.SDLK_DELETE => .delete,
        c.SDLK_END => .end,
        c.SDLK_PAGEDOWN => .page_down,
        c.SDLK_RIGHT => .arrow_right,
        c.SDLK_LEFT => .arrow_left,
        c.SDLK_DOWN => .arrow_down,
        c.SDLK_UP => .arrow_up,

        c.SDLK_NUMLOCKCLEAR => .num_lock,
        c.SDLK_KP_DIVIDE => .numpad_divide,
        c.SDLK_KP_MULTIPLY => .numpad_multiply,
        c.SDLK_KP_MINUS => .numpad_subtract,
        c.SDLK_KP_PLUS => .numpad_add,
        c.SDLK_KP_ENTER => .numpad_enter,
        c.SDLK_KP_1 => .numpad_1,
        c.SDLK_KP_2 => .numpad_2,
        c.SDLK_KP_3 => .numpad_3,
        c.SDLK_KP_4 => .numpad_4,
        c.SDLK_KP_5 => .numpad_5,
        c.SDLK_KP_6 => .numpad_6,
        c.SDLK_KP_7 => .numpad_7,
        c.SDLK_KP_8 => .numpad_8,
        c.SDLK_KP_9 => .numpad_9,
        c.SDLK_KP_0 => .numpad_0,
        c.SDLK_KP_PERIOD => .numpad_decimal,

        c.SDLK_APPLICATION => .compose,
        c.SDLK_POWER => .power,
        c.SDLK_KP_EQUALS => .numpad_equal,
        c.SDLK_EXECUTE => .open,
        c.SDLK_HELP => .help,
        c.SDLK_SELECT => .select,
        c.SDLK_STOP => .stop,
        c.SDLK_AGAIN => .again,
        c.SDLK_UNDO => .undo,
        c.SDLK_CUT => .cut,
        c.SDLK_COPY => .copy,
        c.SDLK_PASTE => .paste,
        c.SDLK_FIND => .find,
        c.SDLK_MUTE => .mic_mute_toggle,
        c.SDLK_VOLUMEUP => .volume_up,
        c.SDLK_VOLUMEDOWN => .volume_down,
        c.SDLK_KP_COMMA => .numpad_comma,

        c.SDLK_CANCEL => .abort,
        c.SDLK_CLEAR => .delete,
        c.SDLK_RETURN2 => .enter,

        c.SDLK_KP_LEFTPAREN => .numpad_paren_left,
        c.SDLK_KP_RIGHTPAREN => .numpad_paren_right,

        c.SDLK_LCTRL => .ctrl_left,
        c.SDLK_LSHIFT => .shift_left,
        c.SDLK_LALT => .alt_left,
        c.SDLK_LGUI => .meta_left,
        c.SDLK_RCTRL => .ctrl_right,
        c.SDLK_RSHIFT => .shift_right,
        c.SDLK_RALT => .alt_right,
        c.SDLK_RGUI => .meta_right,
        c.SDLK_MODE => .mode,

        c.SDLK_AUDIONEXT => .media_track_next,
        c.SDLK_AUDIOPREV => .media_track_prev,
        c.SDLK_AUDIOSTOP => .media_stop,
        c.SDLK_AUDIOPLAY => .media_play,
        c.SDLK_AUDIOMUTE => .volume_mute,
        c.SDLK_AUDIOREWIND => .media_rewind,
        c.SDLK_AUDIOFASTFORWARD => .media_fast_forward,
        c.SDLK_MEDIASELECT => .media_select,
        c.SDLK_WWW => .launch_browser,
        c.SDLK_MAIL => .launch_mail,
        c.SDLK_CALCULATOR, c.SDLK_APP2 => .launch_calculator,
        c.SDLK_COMPUTER, c.SDLK_APP1 => .launch_explorer,
        c.SDLK_AC_SEARCH => .browser_search,
        c.SDLK_AC_HOME => .browser_home,
        c.SDLK_AC_BACK => .browser_back,
        c.SDLK_AC_FORWARD => .browser_forward,
        c.SDLK_AC_STOP => .browser_stop,
        c.SDLK_AC_REFRESH => .browser_refresh,
        c.SDLK_AC_BOOKMARKS => .browser_bookmarks,

        c.SDLK_BRIGHTNESSDOWN => .brightness_down,
        c.SDLK_BRIGHTNESSUP => .brightness_up,
        c.SDLK_DISPLAYSWITCH => .display_toggle_int_ext,
        c.SDLK_KBDILLUMTOGGLE => .kbd_backlight_toggle,
        c.SDLK_KBDILLUMDOWN => .kbd_backlight_down,
        c.SDLK_KBDILLUMUP => .kbd_backlight_up,
        c.SDLK_EJECT => .eject,
        c.SDLK_SLEEP => .sleep,

        else => null,
    };
}

pub fn convertScancode(sdl: c.SDL_Scancode) ?zenolith.key.Keycode {
    return switch (sdl) {
        c.SDL_SCANCODE_A => .a,
        c.SDL_SCANCODE_B => .b,
        c.SDL_SCANCODE_C => .c,
        c.SDL_SCANCODE_D => .d,
        c.SDL_SCANCODE_E => .e,
        c.SDL_SCANCODE_F => .f,
        c.SDL_SCANCODE_G => .g,
        c.SDL_SCANCODE_H => .h,
        c.SDL_SCANCODE_I => .i,
        c.SDL_SCANCODE_J => .j,
        c.SDL_SCANCODE_K => .k,
        c.SDL_SCANCODE_L => .l,
        c.SDL_SCANCODE_M => .m,
        c.SDL_SCANCODE_N => .n,
        c.SDL_SCANCODE_O => .o,
        c.SDL_SCANCODE_P => .p,
        c.SDL_SCANCODE_Q => .q,
        c.SDL_SCANCODE_R => .r,
        c.SDL_SCANCODE_S => .s,
        c.SDL_SCANCODE_T => .t,
        c.SDL_SCANCODE_U => .u,
        c.SDL_SCANCODE_V => .v,
        c.SDL_SCANCODE_W => .w,
        c.SDL_SCANCODE_X => .x,
        c.SDL_SCANCODE_Y => .y,
        c.SDL_SCANCODE_Z => .z,
        c.SDL_SCANCODE_1 => .@"1",
        c.SDL_SCANCODE_2 => .@"2",
        c.SDL_SCANCODE_3 => .@"3",
        c.SDL_SCANCODE_4 => .@"4",
        c.SDL_SCANCODE_5 => .@"5",
        c.SDL_SCANCODE_6 => .@"6",
        c.SDL_SCANCODE_7 => .@"7",
        c.SDL_SCANCODE_8 => .@"8",
        c.SDL_SCANCODE_9 => .@"9",
        c.SDL_SCANCODE_0 => .@"0",
        c.SDL_SCANCODE_RETURN => .enter,
        c.SDL_SCANCODE_ESCAPE => .escape,
        c.SDL_SCANCODE_BACKSPACE => .backspace,
        c.SDL_SCANCODE_TAB => .tab,
        c.SDL_SCANCODE_SPACE => .space,
        c.SDL_SCANCODE_MINUS => .minus,
        c.SDL_SCANCODE_EQUALS => .equal,
        c.SDL_SCANCODE_LEFTBRACKET => .bracket_left,
        c.SDL_SCANCODE_RIGHTBRACKET => .bracket_right,
        c.SDL_SCANCODE_BACKSLASH => .backslash,
        c.SDL_SCANCODE_NONUSHASH => .intl_hash,
        c.SDL_SCANCODE_SEMICOLON => .semicolon,
        c.SDL_SCANCODE_APOSTROPHE => .quote,
        c.SDL_SCANCODE_GRAVE => .backquote,
        c.SDL_SCANCODE_COMMA => .comma,
        c.SDL_SCANCODE_PERIOD => .period,
        c.SDL_SCANCODE_SLASH => .slash,
        c.SDL_SCANCODE_CAPSLOCK => .caps_lock,
        c.SDL_SCANCODE_F1 => .f1,
        c.SDL_SCANCODE_F2 => .f2,
        c.SDL_SCANCODE_F3 => .f3,
        c.SDL_SCANCODE_F4 => .f4,
        c.SDL_SCANCODE_F5 => .f5,
        c.SDL_SCANCODE_F6 => .f6,
        c.SDL_SCANCODE_F7 => .f7,
        c.SDL_SCANCODE_F8 => .f8,
        c.SDL_SCANCODE_F9 => .f9,
        c.SDL_SCANCODE_F10 => .f10,
        c.SDL_SCANCODE_F11 => .f11,
        c.SDL_SCANCODE_F12 => .f12,
        c.SDL_SCANCODE_PRINTSCREEN, c.SDL_SCANCODE_SYSREQ => .sysrq,
        c.SDL_SCANCODE_SCROLLLOCK => .scroll_lock,
        c.SDL_SCANCODE_PAUSE => .pause,
        c.SDL_SCANCODE_INSERT => .insert,
        c.SDL_SCANCODE_HOME => .home,
        c.SDL_SCANCODE_PAGEUP => .page_up,
        c.SDL_SCANCODE_DELETE => .delete,
        c.SDL_SCANCODE_END => .end,
        c.SDL_SCANCODE_PAGEDOWN => .page_down,
        c.SDL_SCANCODE_RIGHT => .arrow_right,
        c.SDL_SCANCODE_LEFT => .arrow_left,
        c.SDL_SCANCODE_DOWN => .arrow_down,
        c.SDL_SCANCODE_UP => .arrow_up,
        c.SDL_SCANCODE_NUMLOCKCLEAR => .num_lock,
        c.SDL_SCANCODE_KP_DIVIDE => .numpad_divide,
        c.SDL_SCANCODE_KP_MULTIPLY => .numpad_multiply,
        c.SDL_SCANCODE_KP_MINUS => .numpad_subtract,
        c.SDL_SCANCODE_KP_PLUS => .numpad_add,
        c.SDL_SCANCODE_KP_ENTER => .numpad_enter,
        c.SDL_SCANCODE_KP_1 => .numpad_1,
        c.SDL_SCANCODE_KP_2 => .numpad_2,
        c.SDL_SCANCODE_KP_3 => .numpad_3,
        c.SDL_SCANCODE_KP_4 => .numpad_4,
        c.SDL_SCANCODE_KP_5 => .numpad_5,
        c.SDL_SCANCODE_KP_6 => .numpad_6,
        c.SDL_SCANCODE_KP_7 => .numpad_7,
        c.SDL_SCANCODE_KP_8 => .numpad_8,
        c.SDL_SCANCODE_KP_9 => .numpad_9,
        c.SDL_SCANCODE_KP_0 => .numpad_0,
        c.SDL_SCANCODE_KP_PERIOD => .numpad_decimal,
        c.SDL_SCANCODE_NONUSBACKSLASH => .intl_backslash,
        c.SDL_SCANCODE_APPLICATION => .compose,
        c.SDL_SCANCODE_POWER => .power,
        c.SDL_SCANCODE_KP_EQUALS => .numpad_equal,
        c.SDL_SCANCODE_F13 => .f13,
        c.SDL_SCANCODE_F14 => .f14,
        c.SDL_SCANCODE_F15 => .f15,
        c.SDL_SCANCODE_F16 => .f16,
        c.SDL_SCANCODE_F17 => .f17,
        c.SDL_SCANCODE_F18 => .f18,
        c.SDL_SCANCODE_F19 => .f19,
        c.SDL_SCANCODE_F20 => .f20,
        c.SDL_SCANCODE_F21 => .f21,
        c.SDL_SCANCODE_F22 => .f22,
        c.SDL_SCANCODE_F23 => .f23,
        c.SDL_SCANCODE_F24 => .f24,
        c.SDL_SCANCODE_EXECUTE => .open,
        c.SDL_SCANCODE_HELP => .help,
        // Can't find any information on where this key even exists.
        // Do not confuse with the compose key (next to right alt)
        //c.SDL_SCANCODE_MENU => ?,
        c.SDL_SCANCODE_SELECT => .select,
        c.SDL_SCANCODE_STOP => .stop,
        c.SDL_SCANCODE_AGAIN => .again,
        c.SDL_SCANCODE_UNDO => .undo,
        c.SDL_SCANCODE_CUT => .cut,
        c.SDL_SCANCODE_COPY => .copy,
        c.SDL_SCANCODE_PASTE => .paste,
        c.SDL_SCANCODE_FIND => .find,
        c.SDL_SCANCODE_MUTE => .mic_mute_toggle,
        c.SDL_SCANCODE_VOLUMEUP => .volume_up,
        c.SDL_SCANCODE_VOLUMEDOWN => .volume_down,
        c.SDL_SCANCODE_KP_COMMA => .numpad_comma,
        // Equals sign on some obscure IBM hardware that has literally no reason to be a different keycode.
        c.SDL_SCANCODE_KP_EQUALSAS400 => .numpad_equal,
        c.SDL_SCANCODE_INTERNATIONAL1 => .international1,
        c.SDL_SCANCODE_INTERNATIONAL2 => .international2,
        c.SDL_SCANCODE_INTERNATIONAL3 => .international3,
        c.SDL_SCANCODE_INTERNATIONAL4 => .international4,
        c.SDL_SCANCODE_INTERNATIONAL5 => .international5,
        c.SDL_SCANCODE_INTERNATIONAL6 => .international6,
        c.SDL_SCANCODE_INTERNATIONAL7 => .international7,
        c.SDL_SCANCODE_INTERNATIONAL8 => .international8,
        c.SDL_SCANCODE_INTERNATIONAL9 => .international9,
        c.SDL_SCANCODE_LANG1 => .lang1,
        c.SDL_SCANCODE_LANG2 => .lang2,
        c.SDL_SCANCODE_LANG3 => .lang3,
        c.SDL_SCANCODE_LANG4 => .lang4,
        c.SDL_SCANCODE_LANG5 => .lang5,
        c.SDL_SCANCODE_LANG6 => .lang6,
        c.SDL_SCANCODE_LANG7 => .lang7,
        c.SDL_SCANCODE_LANG8 => .lang8,
        c.SDL_SCANCODE_LANG9 => .lang9,
        c.SDL_SCANCODE_CANCEL => .abort,
        // mapped to delete by the kernel
        c.SDL_SCANCODE_CLEAR => .delete,
        // Man, return 1 is just so last century
        c.SDL_SCANCODE_RETURN2 => .enter,
        c.SDL_SCANCODE_CRSEL => .props,
        c.SDL_SCANCODE_KP_LEFTPAREN => .numpad_paren_left,
        c.SDL_SCANCODE_KP_RIGHTPAREN => .numpad_paren_right,
        c.SDL_SCANCODE_KP_BACKSPACE => .backspace,
        c.SDL_SCANCODE_KP_COLON => .numpad_decimal,
        c.SDL_SCANCODE_LCTRL => .ctrl_left,
        c.SDL_SCANCODE_LSHIFT => .shift_left,
        c.SDL_SCANCODE_LALT => .alt_left,
        c.SDL_SCANCODE_LGUI => .meta_left,
        c.SDL_SCANCODE_RCTRL => .ctrl_right,
        c.SDL_SCANCODE_RSHIFT => .shift_right,
        c.SDL_SCANCODE_RALT => .alt_right,
        c.SDL_SCANCODE_RGUI => .meta_right,
        c.SDL_SCANCODE_MODE => .mode,
        c.SDL_SCANCODE_AUDIONEXT => .media_track_next,
        c.SDL_SCANCODE_AUDIOPREV => .media_track_prev,
        c.SDL_SCANCODE_AUDIOSTOP => .media_stop,
        c.SDL_SCANCODE_AUDIOPLAY => .media_play,
        c.SDL_SCANCODE_AUDIOMUTE => .volume_mute,
        c.SDL_SCANCODE_MEDIASELECT => .media_select,
        c.SDL_SCANCODE_WWW => .launch_browser,
        c.SDL_SCANCODE_MAIL => .launch_mail,
        c.SDL_SCANCODE_CALCULATOR, c.SDL_SCANCODE_APP2 => .launch_calculator,
        c.SDL_SCANCODE_COMPUTER, c.SDL_SCANCODE_APP1 => .launch_explorer,
        c.SDL_SCANCODE_AC_SEARCH => .browser_search,
        c.SDL_SCANCODE_AC_HOME => .browser_home,
        c.SDL_SCANCODE_AC_BACK => .browser_back,
        c.SDL_SCANCODE_AC_FORWARD => .browser_forward,
        c.SDL_SCANCODE_AC_STOP => .browser_stop,
        c.SDL_SCANCODE_AC_REFRESH => .browser_refresh,
        c.SDL_SCANCODE_AC_BOOKMARKS => .browser_bookmarks,
        c.SDL_SCANCODE_BRIGHTNESSDOWN => .brightness_down,
        c.SDL_SCANCODE_BRIGHTNESSUP => .brightness_up,
        c.SDL_SCANCODE_DISPLAYSWITCH => .display_toggle_int_ext,
        c.SDL_SCANCODE_KBDILLUMTOGGLE => .kbd_backlight_toggle,
        c.SDL_SCANCODE_KBDILLUMDOWN => .kbd_backlight_down,
        c.SDL_SCANCODE_KBDILLUMUP => .kbd_backlight_up,
        c.SDL_SCANCODE_EJECT => .eject,
        c.SDL_SCANCODE_SLEEP => .sleep,
        c.SDL_SCANCODE_AUDIOREWIND => .media_rewind,
        c.SDL_SCANCODE_AUDIOFASTFORWARD => .media_fast_forward,

        else => null,
    };
}
