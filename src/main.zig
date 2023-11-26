const std = @import("std");

test {
    _ = Sdl2Font;
    _ = Sdl2Painter;
    _ = Sdl2Platform;
    _ = Sdl2Texture;
}

pub const FreeTypeError = @import("ffi.zig").FreeTypeError;

pub const Sdl2Font = @import("Sdl2Font.zig");
pub const Sdl2Painter = @import("Sdl2Painter.zig");
pub const Sdl2Platform = @import("Sdl2Platform.zig");
pub const Sdl2Texture = @import("Sdl2Texture.zig");
