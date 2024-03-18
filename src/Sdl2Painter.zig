const std = @import("std");
const zenolith = @import("zenolith");

const util = @import("util.zig");
const c = @import("ffi.zig").c;

const Sdl2Font = @import("Sdl2Font.zig");
const Sdl2Texture = @import("Sdl2Texture.zig");

renderer: *c.SDL_Renderer,

const Sdl2Painter = @This();

pub fn rect(
    self: *Sdl2Painter,
    selfp: *zenolith.painter.Painter,
    rectangle: zenolith.layout.Rectangle,
    color: zenolith.Color,
) !void {
    const clip_rect = if (selfp.data.peekStencil()) |stenc|
        rectangle.intersection(stenc) orelse return
    else
        rectangle;

    if (c.SDL_SetRenderDrawColor(
        self.renderer,
        color.r,
        color.g,
        color.b,
        color.a,
    ) != 0) return error.Render;

    if (c.SDL_RenderFillRect(self.renderer, &util.toSdlRect(clip_rect)) != 0) return error.Render;
}

pub fn texturedRect(
    self: *Sdl2Painter,
    selfp: *zenolith.painter.Painter,
    src: zenolith.layout.Rectangle,
    dest: zenolith.layout.Rectangle,
    texture: *zenolith.texture.Texture,
) !void {
    const clip_dest = if (selfp.data.peekStencil()) |stenc|
        dest.intersection(stenc) orelse return
    else
        dest;

    // TODO: this is simply inacceptable... but it works
    const x_scale: f64 = @as(f64, @floatFromInt(clip_dest.size.width)) /
        @as(f64, @floatFromInt(dest.size.width));
    const y_scale: f64 = @as(f64, @floatFromInt(clip_dest.size.height)) /
        @as(f64, @floatFromInt(dest.size.height));

    const x_mv_scale: f64 = @as(f64, @floatFromInt(clip_dest.pos.x - dest.pos.x)) /
        @as(f64, @floatFromInt(dest.size.width));
    const y_mv_scale: f64 = @as(f64, @floatFromInt(clip_dest.pos.y - dest.pos.y)) /
        @as(f64, @floatFromInt(dest.size.height));

    const clip_src = zenolith.layout.Rectangle{
        .pos = .{
            .x = src.pos.x + @as(i32, @intFromFloat(@as(f64, @floatFromInt(src.size.width)) * x_mv_scale)),
            .y = src.pos.y + @as(i32, @intFromFloat(@as(f64, @floatFromInt(src.size.height)) * y_mv_scale)),
        },
        .size = .{
            .width = @intFromFloat(@as(f64, @floatFromInt(src.size.width)) * x_scale),
            .height = @intFromFloat(@as(f64, @floatFromInt(src.size.height)) * y_scale),
        },
    };

    if (c.SDL_RenderCopy(
        self.renderer,
        (texture.downcast(Sdl2Texture) orelse unreachable).tex,
        &util.toSdlRect(clip_src),
        &util.toSdlRect(clip_dest),
    ) != 0) return error.Render;
}

pub fn span(
    self: *Sdl2Painter,
    selfp: *zenolith.painter.Painter,
    pos: zenolith.layout.Position,
    zspan: zenolith.text.Span,
) !void {
    const font = zspan.font.downcast(Sdl2Font) orelse unreachable;

    if (c.SDL_SetTextureColorMod(
        font.atlas.tex,
        zspan.style.color.r,
        zspan.style.color.g,
        zspan.style.color.b,
    ) != 0) return error.Render;
    if (c.SDL_SetTextureAlphaMod(font.atlas.tex, zspan.style.color.a) != 0) return error.Render;

    for (zspan.glyphs.items) |g| {
        // This is sound as the span will have already gotten the glyph from the font,
        // causing it to add it to the map.
        const sprite_rect = font.getSprite(g.glyph.codepoint, zspan.style.size) orelse unreachable;

        const rectangle = zenolith.layout.Rectangle{
            .pos = pos.add(g.position),
            .size = g.glyph.size,
        };

        const clip_rect = if (selfp.data.peekStencil()) |stenc|
            rectangle.intersection(stenc) orelse continue
        else
            rectangle;

        std.debug.assert(std.meta.eql(sprite_rect.size, rectangle.size));

        const sprite_clip = zenolith.layout.Rectangle{
            .pos = sprite_rect.pos.add(clip_rect.pos.sub(rectangle.pos)),
            .size = clip_rect.size,
        };

        if (c.SDL_RenderCopy(
            self.renderer,
            font.atlas.tex,
            &util.toSdlRect(sprite_clip),
            &util.toSdlRect(clip_rect),
        ) != 0) return error.Render;
    }
}
