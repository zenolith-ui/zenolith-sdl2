//! A font backed by a texture atlas (SDL2 Texture) using a custom lazy bin-packing algorithm
//! and freetype. Create this using Sdl2Platform.createFont.
const std = @import("std");
const zenolith = @import("zenolith");

const util = @import("util.zig");
const ffi = @import("ffi.zig");
const c = ffi.c;

face: c.FT_Face,
atlas: *c.SDL_Texture,
renderer: *c.SDL_Renderer,

/// This is an ArrayHashMap to speed up iteration which is requried for collision checking.
glyphs: std.AutoArrayHashMap(GlyphProperties, AtlasGlyph),

/// A buffer for creating glyph pixel data in for SDL2 textures.
pixel_buf: std.ArrayList(u8),

const Sdl2Font = @This();

pub const AtlasGlyph = struct {
    glyph: zenolith.text.Glyph,
    sprite: zenolith.layout.Rectangle,
};

pub const GlyphProperties = struct {
    codepoint: u21,
    size: u31,
};

pub fn deinit(self: *Sdl2Font) void {
    c.SDL_DestroyTexture(self.atlas);
    _ = c.FT_Done_Face(self.face);
    self.glyphs.deinit();
    self.pixel_buf.deinit();
}

pub fn getGlyph(self: *Sdl2Font, codepoint: u21, style: zenolith.text.Style) !zenolith.text.Glyph {
    const props = GlyphProperties{ .codepoint = codepoint, .size = style.size };
    if (self.glyphs.get(props)) |g| return g.glyph;

    try ffi.handleFTError(c.FT_Set_Pixel_Sizes(self.face, 0, @intCast(style.size)));
    try ffi.handleFTError(c.FT_Load_Char(self.face, codepoint, c.FT_LOAD_RENDER));

    const bmp = self.face.*.glyph.*.bitmap;

    const rect: zenolith.layout.Rectangle = if (bmp.rows * bmp.width == 0) .{
        .pos = .{ .x = 0, .y = 0 },
        .size = .{ .width = 0, .height = 0 },
    } else try self.addAtlastSprite(bmp.buffer[0 .. bmp.rows * bmp.width], @intCast(bmp.width));

    const glyph = zenolith.text.Glyph{
        .codepoint = codepoint,
        .size = rect.size,
        .bearing = .{
            .x = self.face.*.glyph.*.bitmap_left,
            .y = -self.face.*.glyph.*.bitmap_top,
        },
        // I see no point in supporting negative glyph advance.
        .advance = @intCast(@max(0, self.face.*.glyph.*.advance.x) >> 6),
    };

    try self.glyphs.put(props, .{ .glyph = glyph, .sprite = rect });
    return glyph;
}

pub fn yOffset(self: *Sdl2Font, size: u31) u31 {
    if (c.FT_Set_Pixel_Sizes(self.face, 0, @intCast(size)) != 0)
        // TODO: wonk
        @panic("Unable to FT_Set_Pixel_Sizes for determining y offset");

    return @intCast(self.face.*.size.*.metrics.height >> 6);
}

fn getSize(self: *Sdl2Font) zenolith.layout.Size {
    var w: c_int = 0;
    var h: c_int = 0;

    // This will only error if I messed up somewhere.
    if (c.SDL_QueryTexture(self.atlas, null, null, &w, &h) != 0) unreachable;

    return .{ .width = @intCast(w), .height = @intCast(h) };
}

pub fn addAtlastSprite(self: *Sdl2Font, data: []const u8, width: u31) !zenolith.layout.Rectangle {
    std.debug.assert(data.len % width == 0);

    // Amount of pixels to leave empty between glyphs to avoid scaling artifacts.
    const padding = 2;

    const size = self.getSize();

    var collision = zenolith.layout.Rectangle{
        // start in bottom right
        .pos = .{
            .x = @intCast(size.width - width),
            .y = @intCast(size.height),
        },

        // size of glyph + padding
        .size = .{
            .width = width + padding,
            .height = @intCast(@divExact(data.len, width) + padding),
        },
    };

    // This is the state of the state machine. We continually keep moving up/left
    // until we hit a wall that prevents us from moving.
    //
    // This is probably not the fastest bin packing algorithm, but it doesn't require knowing
    // all glyphs before adding them.
    var state: enum { up, left } = .up;
    while (true) switch (state) {
        .up => {
            if (self.isTouchingAnyOnTop(collision)) {
                state = .left;
            } else {
                collision.pos.y -= 1;
            }
        },
        .left => {
            if (!self.isTouchingAnyOnTop(collision)) {
                state = .up;
            } else if (!self.isTouchingAnyOnLeft(collision)) {
                collision.pos.x -= 1;
            } else {
                break;
            }
        },
    };

    if (@as(u31, @intCast(collision.pos.y)) + collision.size.height - padding > size.height)
        return error.AtlastTooSmall;

    try self.pixel_buf.resize(data.len * 4);

    for (data, 0..) |pix, i| {
        @memset(self.pixel_buf.items[i * 4 .. i * 4 + 4], pix);
    }

    const rect = zenolith.layout.Rectangle{
        .pos = collision.pos,
        .size = .{
            .width = width,
            .height = @intCast(@divExact(data.len, width)),
        },
    };

    const rec = util.toSdlRect(rect);
    if (c.SDL_UpdateTexture(
        self.atlas,
        &rec,
        self.pixel_buf.items.ptr,
        @intCast(width * 4),
    ) != 0) return error.UpdateTexture;

    return rect;
}

pub fn getSprite(self: *Sdl2Font, codepoint: u21, size: u31) ?zenolith.layout.Rectangle {
    return (self.glyphs.get(.{ .codepoint = codepoint, .size = size }) orelse return null).sprite;
}

fn isTouchingAnyOnTop(self: *Sdl2Font, rect: zenolith.layout.Rectangle) bool {
    if (rect.pos.y == 0) return true;
    for (self.glyphs.unmanaged.entries.items(.value)) |other| {
        if (other.sprite.pos.y + @as(isize, @intCast(other.sprite.size.height)) == rect.pos.y and
            other.sprite.pos.x < rect.pos.x + @as(isize, @intCast(rect.size.width)) and
            other.sprite.pos.x + @as(isize, @intCast(other.sprite.size.width)) > rect.pos.x) return true;
    }
    return false;
}

fn isTouchingAnyOnLeft(self: *Sdl2Font, rect: zenolith.layout.Rectangle) bool {
    if (rect.pos.x == 0) return true;
    for (self.glyphs.unmanaged.entries.items(.value)) |other| {
        if (other.sprite.pos.x + @as(isize, @intCast(other.sprite.size.width)) == rect.pos.x and
            other.sprite.pos.y < rect.pos.y + @as(isize, @intCast(rect.size.height)) and
            other.sprite.pos.y + @as(isize, @intCast(other.sprite.size.height)) > rect.pos.y) return true;
    }
    return false;
}
