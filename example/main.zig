const std = @import("std");
const zenolith = @import("zenolith");
const zsdl2 = @import("zenolith-sdl2");

pub const zenolith_options = struct {
    pub const platform_impls = [_]type{zsdl2.Sdl2Platform};
    pub const painter_impls = [_]type{zsdl2.Sdl2Painter};
};

pub fn main() !void {
    const alloc = std.heap.c_allocator;

    var platform = try zsdl2.Sdl2Platform.init(.{
        .alloc = alloc,
    });
    defer platform.deinit();

    var font = zenolith.font.Font.create(try platform.createFont(.{
        .source = .{ .path = "/usr/share/fonts/noto/NotoSans-Regular.ttf" },
    }), {});
    defer font.deinit();
    var zplatform = zenolith.platform.Platform.create(platform, {});

    const root = try zenolith.widget.Box.init(alloc, .vertical);
    defer root.deinit();

    {
        var attrs = zenolith.attreebute.AttreebuteMap.init();
        errdefer attrs.deinit(alloc);

        (try attrs.mod(alloc, zenolith.attreebute.CurrentFont)).* = .{ .font = &font };
        (try attrs.mod(alloc, zenolith.attreebute.ButtonStyle)).* = .{
            .background = .{
                .stroked = .{
                    .stroke = zenolith.Color.fromInt(0xeba0acff),
                    .fill = zenolith.Color.fromInt(0x1e1e2eff),
                    .width = 4,
                },
            },
            .background_hovered = .{
                .stroked = .{
                    .stroke = zenolith.Color.fromInt(0xeba0acff),
                    .fill = zenolith.Color.fromInt(0x313244ff),
                    .width = 3,
                },
            },
            .padding = 10,
            .font_size = 32,
            .text_color = zenolith.Color.fromInt(0xcdd6f4ff),
        };

        root.data.attreebutes = attrs;
    }

    root.downcast(zenolith.widget.Box).?.orth_expand = true;
    try root.downcast(zenolith.widget.Box).?.addChildPositioned(root, null, try zenolith.widget.Label.init(.{
        .alloc = alloc,
        .font = &font,
        .text = "Hello, Zenolith!",
        .size = 64,
    }), .center);

    try root.addChild(null, try zenolith.widget.Label.init(.{
        .alloc = alloc,
        .font = &font,
        .text = "Labels!",
        .size = 32,
    }));

    try root.addChild(null, try zenolith.widget.Button.init(alloc, "Click Me!"));

    try root.treevent(zenolith.treevent.Link{
        .parent = null,
        .platform = &zplatform,
    });

    while (try platform.run(root)) |ev| {
        if (ev.downcast(zenolith.backevent.ButtonActivated)) |btn| {
            std.debug.print("Button @ {*} clicked!\n", .{btn.btn_widget});
        }
    }
}
