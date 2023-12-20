const std = @import("std");
const zenolith = @import("zenolith");

const ffi = @import("ffi.zig");
const c = ffi.c;

const Sdl2Font = @import("Sdl2Font.zig");
const Sdl2Painter = @import("Sdl2Painter.zig");
const Sdl2Texture = @import("Sdl2Texture.zig");

// These decls are public so that zenolith includes them in it's statspatch types.
pub const Font = Sdl2Font;
pub const Texture = Sdl2Texture;

alloc: std.mem.Allocator,
window: *c.SDL_Window,
renderer: *c.SDL_Renderer,
freetype: c.FT_Library,
backevent_id: u32,
mouse_pos: ?zenolith.layout.Position,
initial_run: bool,

const Sdl2Platform = @This();

pub const InitOptions = struct {
    alloc: std.mem.Allocator,
    /// The title of the window the platform will create.
    window_title: [*:0]const u8 = "Zenolith SDL2",

    /// An optional initial window position.
    window_position: ?[2]c_int = null,

    /// Initial window size
    window_size: [2]c_int = .{ 800, 600 },
};

pub const InitializeError = error{
    /// An error has occured trying to initialize the SDL2 library.
    InitializeSDL2,

    /// An error has occured trying to initialize the freetype2 library.
    InitializeFreetype,

    /// SDL2 failed to create a window.
    CreateWindow,

    /// SDL2 failed to create a renderer.
    CreateRenderer,
};

/// Create a new SDL2 Platform. Initializes the SDL2 and FreeType libraries and creates a
/// window. Do not create multiple Sdl2Platforms at once!
// TODO: Window API
pub fn init(options: InitOptions) InitializeError!Sdl2Platform {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) return error.InitializeSDL2;
    errdefer c.SDL_Quit();

    const window_pos = options.window_position orelse [1]c_int{c.SDL_WINDOWPOS_UNDEFINED} ** 2;
    const window = c.SDL_CreateWindow(
        options.window_title,
        window_pos[0],
        window_pos[1],
        options.window_size[0],
        options.window_size[1],
        c.SDL_WINDOW_SHOWN | c.SDL_WINDOW_RESIZABLE, // TODO: add API to change this
    ) orelse return error.CreateWindow;
    errdefer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(
        window,
        -1,
        c.SDL_RENDERER_ACCELERATED,
    ) orelse return error.CreateRenderer;
    errdefer c.SDL_DestroyRenderer(renderer);

    const backevent_id = c.SDL_RegisterEvents(1);
    if (backevent_id == std.math.maxInt(u32)) return error.InitializeSDL2;

    var freetype: c.FT_Library = undefined;
    if (c.FT_Init_FreeType(&freetype) != 0) return error.InitializeFreetype;
    errdefer _ = c.FT_Done_FreeType(freetype);

    return .{
        .alloc = options.alloc,
        .window = window,
        .renderer = renderer,
        .freetype = freetype,
        .backevent_id = backevent_id,
        .mouse_pos = null,
        .initial_run = true,
    };
}

/// Runs the event loop until a backevent is received. This is typically used with a while loop.
pub fn run(
    self: *Sdl2Platform,
    root: *zenolith.widget.Widget,
) anyerror!?zenolith.backevent.Backevent {
    // Initial layout pass before we get a resize event.
    if (self.initial_run) {
        var width: c_int = 0;
        var height: c_int = 0;
        c.SDL_GetWindowSize(self.window, &width, &height);

        try zenolith.treevent.fire(root, zenolith.treevent.LayoutSize{
            .final = true,
            .constraints = .{
                .min = .{ .width = 0, .height = 0 },
                .max = .{ .width = @intCast(width), .height = @intCast(height) },
            },
        });

        try zenolith.treevent.fire(root, zenolith.treevent.LayoutPosition{
            .position = .{ .x = 0, .y = 0 },
        });

        self.initial_run = false;
    }

    while (true) {
        var ev: c.SDL_Event = undefined;

        if (c.SDL_WaitEvent(&ev) != 1) return error.GetEvents;

        if (ev.type == self.backevent_id) {
            const evp: *zenolith.backevent.Backevent = @ptrCast(@alignCast(ev.user.data1));
            defer self.alloc.destroy(evp);
            return evp.*;
        }

        switch (ev.type) {
            // quit event - exit
            c.SDL_QUIT => return null,

            c.SDL_WINDOWEVENT => switch (ev.window.event) {
                // window resized - redo tree layout
                c.SDL_WINDOWEVENT_RESIZED => {
                    const size = zenolith.layout.Size{
                        .width = @intCast(ev.window.data1),
                        .height = @intCast(ev.window.data2),
                    };

                    try zenolith.treevent.fire(root, zenolith.treevent.LayoutSize{
                        .final = true,
                        .constraints = .{
                            .min = .{ .width = 0, .height = 0 },
                            .max = size,
                        },
                    });

                    try zenolith.treevent.fire(root, zenolith.treevent.LayoutPosition{
                        .position = .{ .x = 0, .y = 0 },
                    });
                },
                else => {},
            },

            c.SDL_MOUSEMOTION => {
                const mouse_pos = zenolith.layout.Position{
                    .x = @intCast(ev.motion.x),
                    .y = @intCast(ev.motion.y),
                };
                self.mouse_pos = mouse_pos;

                try zenolith.treevent.fire(root, zenolith.treevent.MouseMove{
                    .pos = mouse_pos,
                    .dx = ev.motion.xrel,
                    .dy = ev.motion.yrel,
                });
            },

            c.SDL_MOUSEBUTTONDOWN, c.SDL_MOUSEBUTTONUP => {
                const button: ?zenolith.treevent.Click.MouseButton = switch (ev.button.button) {
                    c.SDL_BUTTON_LEFT => .left,
                    c.SDL_BUTTON_MIDDLE => .middle,
                    c.SDL_BUTTON_RIGHT => .right,
                    else => null,
                };

                const actions: []const zenolith.treevent.Click.Action = switch (ev.type) {
                    c.SDL_MOUSEBUTTONDOWN => &.{ .down, .click },
                    c.SDL_MOUSEBUTTONUP => &.{.up},
                    else => unreachable,
                };

                if (button) |but| {
                    for (actions) |act| {
                        try zenolith.treevent.fire(root, zenolith.treevent.Click{
                            .pos = .{
                                .x = @intCast(ev.button.x),
                                .y = @intCast(ev.button.y),
                            },
                            .button = but,
                            .action = act,
                        });
                    }
                }
            },

            c.SDL_MOUSEWHEEL => if (self.mouse_pos) |mp| {
                const btn: zenolith.treevent.Click.MouseButton = if (ev.wheel.y > 0)
                    .scroll_up
                else if (ev.wheel.y < 0)
                    .scroll_down
                else if (ev.wheel.x > 0)
                    .scroll_right
                else if (ev.wheel.x < 0)
                    .scroll_left
                else
                    unreachable;

                try zenolith.treevent.fire(root, zenolith.treevent.Click{
                    .pos = mp,
                    .button = btn,
                    .action = .click,
                });
            },
            else => {},
        }

        // do render pass after events
        // TODO: lazify
        if (c.SDL_SetRenderDrawColor(self.renderer, 0, 0, 0, 0xff) != 0) return error.Render;
        if (c.SDL_RenderClear(self.renderer) != 0) return error.Render;

        var painter = zenolith.painter.Painter.create(Sdl2Painter{ .renderer = self.renderer }, {});
        try root.treevent(zenolith.treevent.Draw{ .painter = &painter });

        c.SDL_RenderPresent(self.renderer);
    }
}

pub fn deinit(self: Sdl2Platform) void {
    _ = c.FT_Done_FreeType(self.freetype);
    c.SDL_DestroyRenderer(self.renderer);
    c.SDL_DestroyWindow(self.window);
    c.SDL_Quit();
}

pub const CreateFontOptions = struct {
    /// Source data to open the font from.
    source: union(enum) {
        /// Read the font at a given file path.
        path: [*:0]const u8,
        /// Use the data of the slice as font. Useful with @embedFile.
        /// The data must remain alive until .deinit() is called on the returned font!
        data: []const u8,
    },

    /// This is FreeType's infamous face_index parameter. You should either consider reading the
    /// short novel of historical design mistakes that is it's documentation here:
    /// https://freetype.org/freetype2/docs/reference/ft2-face_creation.html#ft_open_face
    /// ...or leave it as 0.
    face_index: c_long = 0,

    /// Size of the font atlas texture. Increase this if you needs to render lots of glyphs.
    /// The bin packing algorithm performs best with tall rather than wide atlases.
    atlas_size: zenolith.layout.Size = .{ .width = 512, .height = 1024 },
};

pub const CreateFontError = ffi.FreeTypeError || error{CreateTexture};

pub fn createFont(self: Sdl2Platform, opts: CreateFontOptions) CreateFontError!Sdl2Font {
    var face: c.FT_Face = undefined;
    switch (opts.source) {
        .path => |p| try ffi.handleFTError(c.FT_New_Face(
            self.freetype,
            p,
            opts.face_index,
            &face,
        )),
        .data => |d| try ffi.handleFTError(c.FT_New_Memory_Face(
            self.freetype,
            d.ptr,
            @intCast(d.len),
            opts.face_index,
            &face,
        )),
    }
    errdefer _ = c.FT_Done_Face(face);

    const atlas = c.SDL_CreateTexture(
        self.renderer,
        c.SDL_PIXELFORMAT_RGBA8888,
        c.SDL_TEXTUREACCESS_STATIC,
        @intCast(opts.atlas_size.width),
        @intCast(opts.atlas_size.height),
    ) orelse return error.CreateTexture;
    errdefer c.SDL_DestroyTexture(atlas);

    if (c.SDL_SetTextureBlendMode(atlas, c.SDL_BLENDMODE_BLEND) != 0) return error.CreateTexture;

    return .{
        .face = face,
        .atlas = atlas,
        .renderer = self.renderer,
        .glyphs = std.AutoArrayHashMap(Sdl2Font.GlyphProperties, Sdl2Font.AtlasGlyph).init(self.alloc),
        .pixel_buf = std.ArrayList(u8).init(self.alloc),
    };
}

pub fn pushBackevent(self: *Sdl2Platform, ev: zenolith.backevent.Backevent) !void {
    const evp = try self.alloc.create(zenolith.backevent.Backevent);
    errdefer self.alloc.destroy(evp);
    evp.* = ev;

    var sdl_ev = c.SDL_Event{ .user = .{
        .type = self.backevent_id,
        .code = 1,
        .data1 = evp,
    } };
    if (c.SDL_PushEvent(&sdl_ev) < 0) return error.PushEvent;
}
