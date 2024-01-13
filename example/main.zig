const std = @import("std");
const zenolith = @import("zenolith");
const zsdl2 = @import("zenolith-sdl2");

pub const zenolith_options = struct {
    pub const platform_impls = [_]type{zsdl2.Sdl2Platform};
    pub const painter_impls = [_]type{zsdl2.Sdl2Painter};
    pub const debug_render = true;
};

pub fn main() !void {
    const alloc = std.heap.c_allocator;

    var platform = try zsdl2.Sdl2Platform.init(.{
        .alloc = alloc,
    });
    defer platform.deinit();

    var font = zenolith.text.Font.create(try platform.createFont(.{
        .source = .{ .path = "/usr/share/fonts/liberation/LiberationSans-Regular.ttf" },
    }), {});
    defer font.deinit();
    var zplatform = zenolith.platform.Platform.create(platform, .{});

    const root = try zenolith.widget.Box.init(alloc, .vertical);
    defer root.deinit();

    {
        var attrs = zenolith.attreebute.AttreebuteMap.init();
        errdefer attrs.deinit(alloc);

        (try attrs.mod(alloc, zenolith.attreebute.CurrentFont)).* = .{ .font = &font };
        try zenolith.Theme.catppuccin_mocha.apply(alloc, &attrs);

        root.data.attreebutes = attrs;
    }

    root.downcast(zenolith.widget.Box).?.orth_expand = true;
    try root.downcast(zenolith.widget.Box).?.addChildPositioned(
        root,
        null,
        try zenolith.widget.Label.init(alloc, "Hello, Zenolith!"),
        .center,
    );

    try root.addChild(null, try zenolith.widget.Label.init(alloc, "Labels!"));

    try root.addChild(null, try zenolith.widget.Button.init(alloc, "Button 1"));
    try root.addChild(null, try zenolith.widget.Button.init(alloc, "Button 2"));
    try root.addChild(null, try zenolith.widget.Button.init(alloc, "Button 3"));

    try root.addChild(null, try zenolith.widget.Spacer.init(alloc, .{.flex = 1}));

    {
        var chunk = zenolith.text.Chunk.init(alloc);
        errdefer chunk.deinit();

        try chunk.spans.append(.{ .span = try zenolith.text.Span.init(alloc, .{
            .font = &font,
            .text = "Span 1",
            .style = .{ .size = 32 },
        }) });
        try chunk.spans.append(.{ .span = try zenolith.text.Span.init(alloc, .{
            .font = &font,
            .text = "Span 2",
            .style = .{ .color = zenolith.Color.fromInt(0xff0000ff) },
        }) });
        try chunk.spans.append(.{ .span = try zenolith.text.Span.init(alloc, .{
            .font = &font,
            .text = "Span 3",
        }), .wrap_mode = .always });

        try chunk.spans.append(.{ .span = try zenolith.text.Span.init(alloc, .{
            .font = &font,
            .text = "abcdefghijklmnopqrstuvwxyz",
            .style = .{ .size = 48 },
        }), .wrap_mode = .always });

        for ("abcdefghijklmnopqrstuvwxyz") |ch| {
            try chunk.spans.append(.{ .span = try zenolith.text.Span.init(alloc, .{
                .font = &font,
                .text = &.{ch},
                .style = .{ .size = 48 },
            }) });
        }

        try root.addChild(null, try zenolith.widget.ChunkView.init(alloc, chunk));
    }

    try root.link(null, &zplatform);

    try platform.run(root);
}
