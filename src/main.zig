const std = @import("std");

test {
    _ = Sdl2Font;
    _ = Sdl2Painter;
    _ = Sdl2Platform;
    _ = Sdl2Texture;
}

/// This module as well as `c` are public to serve as an escape hatch in case FT or SDL2 APIs
/// aren't wrapped by Zenolith-SDL2.
pub const ffi = @import("ffi.zig");
pub const c = ffi.c;

pub const FreeTypeError = ffi.FreeTypeError;

pub const Sdl2Font = @import("Sdl2Font.zig");
pub const Sdl2Painter = @import("Sdl2Painter.zig");
pub const Sdl2Platform = @import("Sdl2Platform.zig");
pub const Sdl2Texture = @import("Sdl2Texture.zig");
