const std = @import("std");

pub fn findAnswer1(input: []const u8) !u10 {
    var highest_id: u10 = 0;

    var bsps = std.mem.tokenize(input, "\n");
    while (bsps.next()) |bsp| {
        const bsp_id = seatBspToId(bsp);
        if ((bsp_id) > highest_id) highest_id = bsp_id;
    }

    return highest_id;
}

pub fn findAnswer2(input: []const u8) !u10 {
    // I would like to just use an u1024 and treat it like a big bitset, but
    // this is unsupported by LLVM. Related bug:
    // https://github.com/ziglang/zig/issues/1534
    var occupied_seats: [1024]bool = [1]bool{false} ** 1024;

    var bsps = std.mem.tokenize(input, "\n");
    while (bsps.next()) |bsp| {
        const bsp_id = seatBspToId(bsp);
        occupied_seats[bsp_id] = true;
    }

    // Find the first occupied seat; the first unoccupied seat after that
    // should be ours.
    const first_occupied = for (occupied_seats) |seat, i| {
        if (seat) break i;
    } else return error.SeatNotFound;
    const our_seat = for (occupied_seats[first_occupied..]) |seat, i| {
        if (!seat) break first_occupied + i;
    } else return error.SeatNotFound;

    return @intCast(u10, our_seat);
}

fn seatBspToId(bsp: []const u8) u10 {
    std.debug.assert(bsp.len == 10);

    var result: u10 = 0;
    var shift_amount: u4 = @intCast(u4, bsp.len);

    for (bsp[0..7]) |c| {
        shift_amount -= 1;
        switch (c) {
            'B' => {
                result += @shlExact(@as(u10, 1), shift_amount);
            },
            'F' => {},
            else => unreachable,
        }
    }

    for (bsp[7..]) |c| {
        shift_amount -= 1;
        switch (c) {
            'R' => {
                result += @shlExact(@as(u10, 1), shift_amount);
            },
            'L' => {},
            else => unreachable,
        }
    }

    return result;
}

test "seatBspToId" {
    std.testing.expectEqual(@as(u10, 567), seatBspToId("BFFFBBFRRR"));
    std.testing.expectEqual(@as(u10, 119), seatBspToId("FFFBBBFRRR"));
    std.testing.expectEqual(@as(u10, 820), seatBspToId("BBFFBBFRLL"));
}

test "findAnswer1" {
    std.testing.expectEqual(@as(u10, 832), try findAnswer1(@embedFile("input.txt")));
}

test "findAnswer2" {
    std.testing.expectEqual(@as(u10, 517), try findAnswer2(@embedFile("input.txt")));
}
