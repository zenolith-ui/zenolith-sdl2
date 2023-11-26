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
