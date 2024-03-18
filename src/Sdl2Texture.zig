//! A wrapper around SDL2's SDL_Texture which acts as the platform's texture type.
const std = @import("std");
const zenolith = @import("zenolith");

const c = @import("ffi.zig").c;
const util = @import("util.zig");

const log = std.log.scoped(.zenolith_sdl2);

tex: *c.SDL_Texture,

const Sdl2Texture = @This();

/// 32-bit integer formats have been removed, as they're assigned their `8888` equivalents
/// depending on system endianness. Directly use those instead.
pub const PixelFormat = enum(u32) {
    INDEX1LSB = c.SDL_PIXELFORMAT_INDEX1LSB,
    INDEX1MSB = c.SDL_PIXELFORMAT_INDEX1MSB,
    INDEX4LSB = c.SDL_PIXELFORMAT_INDEX4LSB,
    INDEX4MSB = c.SDL_PIXELFORMAT_INDEX4MSB,
    INDEX8 = c.SDL_PIXELFORMAT_INDEX8,
    RGB332 = c.SDL_PIXELFORMAT_RGB332,
    RGB444 = c.SDL_PIXELFORMAT_RGB444,
    RGB555 = c.SDL_PIXELFORMAT_RGB555,
    BGR555 = c.SDL_PIXELFORMAT_BGR555,
    ARGB4444 = c.SDL_PIXELFORMAT_ARGB4444,
    RGBA4444 = c.SDL_PIXELFORMAT_RGBA4444,
    ABGR4444 = c.SDL_PIXELFORMAT_ABGR4444,
    BGRA4444 = c.SDL_PIXELFORMAT_BGRA4444,
    ARGB1555 = c.SDL_PIXELFORMAT_ARGB1555,
    RGBA5551 = c.SDL_PIXELFORMAT_RGBA5551,
    ABGR1555 = c.SDL_PIXELFORMAT_ABGR1555,
    BGRA5551 = c.SDL_PIXELFORMAT_BGRA5551,
    RGB565 = c.SDL_PIXELFORMAT_RGB565,
    BGR565 = c.SDL_PIXELFORMAT_BGR565,
    RGB24 = c.SDL_PIXELFORMAT_RGB24,
    BGR24 = c.SDL_PIXELFORMAT_BGR24,
    RGB888 = c.SDL_PIXELFORMAT_RGB888,
    RGBX8888 = c.SDL_PIXELFORMAT_RGBX8888,
    BGR888 = c.SDL_PIXELFORMAT_BGR888,
    BGRX8888 = c.SDL_PIXELFORMAT_BGRX8888,
    ARGB8888 = c.SDL_PIXELFORMAT_ARGB8888,
    RGBA8888 = c.SDL_PIXELFORMAT_RGBA8888,
    ABGR8888 = c.SDL_PIXELFORMAT_ABGR8888,
    BGRA8888 = c.SDL_PIXELFORMAT_BGRA8888,
    ARGB2101010 = c.SDL_PIXELFORMAT_ARGB2101010,
    YV12 = c.SDL_PIXELFORMAT_YV12,
    IYUV = c.SDL_PIXELFORMAT_IYUV,
    YUY2 = c.SDL_PIXELFORMAT_YUY2,
    UYVY = c.SDL_PIXELFORMAT_UYVY,
    YVYU = c.SDL_PIXELFORMAT_YVYU,
    NV12 = c.SDL_PIXELFORMAT_NV12,
    NV21 = c.SDL_PIXELFORMAT_NV21,
};

pub const PixelAccess = enum(c_int) {
    static = c.SDL_TEXTUREACCESS_STATIC,
    streaming = c.SDL_TEXTUREACCESS_STREAMING,
    target = c.SDL_TEXTUREACCESS_TARGET,
};

pub const TextureBlendMode = enum(c_uint) {
    none = c.SDL_BLENDMODE_NONE,
    blend = c.SDL_BLENDMODE_BLEND,
    add = c.SDL_BLENDMODE_ADD,
    mod = c.SDL_BLENDMODE_MOD,
    mul = c.SDL_BLENDMODE_MUL,
};

pub fn getSize(self: Sdl2Texture) zenolith.layout.Size {
    var w: c_int = 0;
    var h: c_int = 0;

    if (c.SDL_QueryTexture(self.tex, null, null, &w, &h) != 0) {
        // probably not the best error handling, but this is probably not a likely failure state
        log.err("getting SDL2 texture size: {s}", .{c.SDL_GetError()});
    }

    return .{ .width = @intCast(w), .height = @intCast(h) };
}

pub fn setPixels(self: Sdl2Texture, pixels: []const u8, pitch: u31, rect: ?zenolith.layout.Rectangle) !void {
    std.debug.assert(pixels.len % pitch == 0);

    const rec = if (rect) |r| &util.toSdlRect(r) else null;
    if (c.SDL_UpdateTexture(self.tex, rec, pixels.ptr, pitch) != 0) return error.UpdateTexture;
}

pub fn setBlendMode(self: Sdl2Texture, blend_mode: TextureBlendMode) !void {
    if (c.SDL_SetTextureBlendMode(self.tex, @intFromEnum(blend_mode)) != 0) return error.SetBlendMode;
}

pub fn deinit(self: Sdl2Texture) void {
    c.SDL_DestroyTexture(self.tex);
}
