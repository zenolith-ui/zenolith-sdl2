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

pub fn text(
    self: *Sdl2Painter,
    pos: zenolith.layout.Position,
    zchunk: zenolith.font.Chunk,
    color: zenolith.Color,
) !void {
    const chunk = zchunk.downcast(Sdl2Font.Chunk) orelse unreachable;
    if (c.SDL_SetTextureColorMod(chunk.font.atlas, color.r, color.g, color.b) != 0) return error.Render;
    if (c.SDL_SetTextureAlphaMod(chunk.font.atlas, color.a) != 0) return error.Render;
    for (chunk.glyphs.items) |g| {
        if (c.SDL_RenderCopy(
            self.renderer,
            chunk.font.atlas,
            &util.toSdlRect(g.glyph.sprite),
            &util.toSdlRect(.{
                .pos = pos.add(g.pos),
                .size = g.glyph.sprite.size,
            }),
        ) != 0) return error.Render;
    }
}
