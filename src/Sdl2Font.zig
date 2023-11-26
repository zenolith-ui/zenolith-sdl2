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
glyphs: std.AutoArrayHashMap(GlyphProperties, Glyph),

/// A buffer for creating glyph pixel data in for SDL2 textures.
pixel_buf: std.ArrayList(u8),

const Sdl2Font = @This();

pub const Chunk = struct {
    font: *Sdl2Font,
    glyphs: std.ArrayList(PositionedGlyph),
    // Saving the size here to improve performance by not recalculating this.
    // This is an immutable data structure.
    size: zenolith.layout.Size,

    pub fn deinit(self: Chunk) void {
        self.glyphs.deinit();
    }

    pub fn getSize(self: Chunk) zenolith.layout.Size {
        return self.size;
    }
};

const PositionedGlyph = struct {
    glyph: Glyph,
    pos: zenolith.layout.Position,
};

pub const Glyph = struct {
    /// Rectangle in atlas-local coordinates of this glyph.
    sprite: zenolith.layout.Rectangle,

    /// Offset the glyph is rendered at.
    bearing: [2]i32,
    advance: usize,
};

pub const GlyphProperties = struct {
    codepoint: u21,
    size: u32,
};

pub fn deinit(self_: Sdl2Font) void {
    var self = self_;
    c.SDL_DestroyTexture(self.atlas);
    _ = c.FT_Done_Face(self.face);
    self.glyphs.deinit();
    self.pixel_buf.deinit();
}

pub fn getGlyph(self: *Sdl2Font, props: GlyphProperties) !Glyph {
    if (self.glyphs.get(props)) |g| return g;

    try ffi.handleFTError(c.FT_Set_Pixel_Sizes(self.face, 0, props.size));
    try ffi.handleFTError(c.FT_Load_Char(self.face, props.codepoint, c.FT_LOAD_RENDER));

    const bmp = self.face.*.glyph.*.bitmap;

    const rect: zenolith.layout.Rectangle = if (bmp.rows * bmp.width == 0) .{
        .pos = .{ .x = 0, .y = 0 },
        .size = .{ .width = 0, .height = 0 },
    } else try self.addAtlastSprite(bmp.buffer[0 .. bmp.rows * bmp.width], bmp.width);

    const glyph = Glyph{
        .sprite = rect,
        .bearing = .{
            self.face.*.glyph.*.bitmap_left,
            self.face.*.glyph.*.bitmap_top,
        },
        // I see no point in supporting negative glyph advance.
        .advance = @intCast(@max(0, self.face.*.glyph.*.advance.x) >> 6),
    };

    try self.glyphs.put(props, glyph);
    return glyph;
}

fn getSize(self: *Sdl2Font) zenolith.layout.Size {
    var w: c_int = 0;
    var h: c_int = 0;

    // This will only error if I messed up somewhere.
    if (c.SDL_QueryTexture(self.atlas, null, null, &w, &h) != 0) unreachable;

    return .{ .width = @intCast(w), .height = @intCast(h) };
}

pub fn addAtlastSprite(self: *Sdl2Font, data: []const u8, width: usize) !zenolith.layout.Rectangle {
    std.debug.assert(data.len % width == 0);

    // Amount of pixels to leave empty between glyphs to avoid scaling artifacts.
    const padding = 2;

    const size = self.getSize();

    var collision = zenolith.layout.Rectangle{
        // start in bottom right
        .pos = .{
            .x = size.width - width,
            .y = size.height,
        },

        // size of glyph + padding
        .size = .{
            .width = width + padding,
            .height = @divExact(data.len, width) + padding,
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

    if (collision.pos.y + collision.size.height - padding > size.height)
        return error.AtlastTooSmall;

    try self.pixel_buf.resize(data.len * 4);

    for (data, 0..) |pix, i| {
        @memset(self.pixel_buf.items[i * 4 .. i * 4 + 4], pix);
    }

    const rect = .{
        .pos = collision.pos,
        .size = .{
            .width = width,
            .height = @divExact(data.len, width),
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

pub fn layout(
    self: *Sdl2Font,
    text: []const u8,
    size: usize,
    wrap: zenolith.font.TextWrap,
) !zenolith.font.Chunk {
    _ = wrap;
    var glyphs = std.ArrayList(PositionedGlyph).init(self.pixel_buf.allocator);
    errdefer glyphs.deinit();

    var cur_pos = zenolith.layout.Position{
        // We start in the middle of the possible range to leave as much space in all directions
        // as possible. This is all aligned to 0/0 in the last layout step.
        .x = std.math.maxInt(usize) / 2,
        .y = std.math.maxInt(usize) / 2,
    };

    // This is the position of the top-left-most glyph. This is later subtracted from all positions.
    var min_pos = zenolith.layout.Position{
        .x = std.math.maxInt(usize),
        .y = std.math.maxInt(usize),
    };

    // The height of the current line of text.
    var cur_line_height: usize = 0;

    var iter = std.unicode.Utf8Iterator{ .i = 0, .bytes = text };
    while (iter.nextCodepoint()) |codepoint| {
        // TODO: correctly calculate size of next line first
        if (codepoint == '\n') {
            cur_pos.x = std.math.maxInt(usize) / 2;
            cur_pos.y += @intCast(self.face.*.size.*.metrics.height >> 6);

            cur_line_height = 0;

            continue;
        }

        const glyph = try self.getGlyph(.{
            .size = @intCast(size),
            .codepoint = codepoint,
        });
        const gpos = zenolith.layout.Position{
            // hacky addition with negative numbers
            .x = cur_pos.x +% @as(usize, @bitCast(@as(isize, glyph.bearing[0]))),
            .y = cur_pos.y -% @as(usize, @bitCast(@as(isize, glyph.bearing[1]))),
        };

        try glyphs.append(.{
            .glyph = glyph,
            .pos = gpos,
        });

        cur_pos.x += glyph.advance;

        if (glyph.sprite.size.height > cur_line_height) cur_line_height = glyph.sprite.size.height;

        if (gpos.x < min_pos.x) min_pos.x = gpos.x;
        if (gpos.y < min_pos.y) min_pos.y = gpos.y;
    }

    var csize = zenolith.layout.Size.zero;

    // Position glyphs at top left and calculate chunk size.
    for (glyphs.items) |*g| {
        const new_pos = g.pos.sub(min_pos);
        g.pos = new_pos;

        const xmax = g.pos.x + g.glyph.sprite.size.width;
        const ymax = g.pos.y + g.glyph.sprite.size.height;
        if (xmax > csize.width) csize.width = xmax;
        if (ymax > csize.height) csize.height = ymax;
    }

    return zenolith.font.Chunk.create(Chunk{
        .font = self,
        .glyphs = glyphs,
        .size = csize,
    }, {});
}

fn isTouchingAnyOnTop(self: *Sdl2Font, rect: zenolith.layout.Rectangle) bool {
    if (rect.pos.y == 0) return true;
    for (self.glyphs.unmanaged.entries.items(.value)) |other| {
        if (other.sprite.pos.y + other.sprite.size.height == rect.pos.y and
            other.sprite.pos.x < rect.pos.x + rect.size.width and
            other.sprite.pos.x + other.sprite.size.width > rect.pos.x) return true;
    }
    return false;
}

fn isTouchingAnyOnLeft(self: *Sdl2Font, rect: zenolith.layout.Rectangle) bool {
    if (rect.pos.x == 0) return true;
    for (self.glyphs.unmanaged.entries.items(.value)) |other| {
        if (other.sprite.pos.x + other.sprite.size.width == rect.pos.x and
            other.sprite.pos.y < rect.pos.y + rect.size.height and
            other.sprite.pos.y + other.sprite.size.height > rect.pos.y) return true;
    }
    return false;
}
