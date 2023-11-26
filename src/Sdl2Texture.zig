//! A wrapper around SDL2's SDL_Texture which acts as the platform's texture type.
const std = @import("std");
const zenolith = @import("zenolith");

const c = @import("ffi.zig").c;

const log = std.log.scoped(.zenolith_sdl2);

tex: *c.SDL_Texture,

const Sdl2Texture = @This();

pub fn getSize(self: Sdl2Texture) zenolith.layout.Size {
    var w: c_int = 0;
    var h: c_int = 0;

    if (c.SDL_QueryTexture(self.tex, null, null, &w, &h) != 0) {
        // probably not the best error handling, but this is probably not a likely failure state
        log.err("getting SDL2 texture size: {s}", .{c.SDL_GetError()});
    }

    return .{ .width = @intCast(w), .height = @intCast(h) };
}
