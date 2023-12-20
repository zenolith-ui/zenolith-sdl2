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
    rectangle: zenolith.layout.Rectangle,
    color: zenolith.Color,
) !void {
    if (c.SDL_SetRenderDrawColor(
        self.renderer,
        color.r,
        color.g,
        color.b,
        color.a,
    ) != 0) return error.Render;

    if (c.SDL_RenderFillRect(self.renderer, &util.toSdlRect(rectangle)) != 0) return error.Render;
}

pub fn texturedRect(
    self: *Sdl2Painter,
    src: zenolith.layout.Rectangle,
    dest: zenolith.layout.Rectangle,
    texture: *zenolith.texture.Texture,
) !void {
    if (c.SDL_RenderCopy(
        self.renderer,
        (texture.downcast(Sdl2Texture) orelse unreachable).tex,
        &util.toSdlRect(src),
        &util.toSdlRect(dest),
    ) != 0) return error.Render;
}

pub fn span(
    self: *Sdl2Painter,
    pos: zenolith.layout.Position,
    zspan: zenolith.text.Span,
) !void {
    const font = zspan.font.downcast(Sdl2Font) orelse unreachable;

    if (c.SDL_SetTextureColorMod(
        font.atlas,
        zspan.style.color.r,
        zspan.style.color.g,
        zspan.style.color.b,
    ) != 0) return error.Render;
    if (c.SDL_SetTextureAlphaMod(font.atlas, zspan.style.color.a) != 0) return error.Render;

    for (zspan.glyphs.items) |g| {
        if (c.SDL_RenderCopy(
            self.renderer,
            font.atlas,
            &util.toSdlRect(
                // This is sound as the span will have already gotten the glyph from the font,
                // causing it to add it to the map.
                font.getSprite(g.glyph.codepoint, zspan.style.size) orelse unreachable,
            ),
            &util.toSdlRect(.{
                .pos = pos.add(g.position),
                .size = g.glyph.size,
            }),
        ) != 0) return error.Render;
    }
}
