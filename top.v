module top(

input               clk,
input               key_reset,
input               key_start,
input               key_left,
input               key_right,
output wire         vga_hs,
output wire         vga_vs,

// 4-bit VGA Output
output wire [3:0]   vga_r,
output wire [3:0]   vga_g,
output wire [3:0]   vga_b

);

wire  [7:0]     red_s;
wire  [7:0]     green_s;
wire  [7:0]     blue_s;
wire [11:0]     resolution_height   = 600;
wire [11:0]     resolution_width    = 800;

wire reset = ~key_reset;
wire start = ~key_start;
wire left = ~key_left;
wire right = ~key_right;

wire [7:0] vga_r_8bit;
wire [7:0] vga_g_8bit;
wire [7:0] vga_b_8bit;
wire [11:0]  pixel_x_s;
wire [11:0]  pixel_y_s;
wire vga_clk;
wire [3:0] rnd_val_s;

// Wires connecting the top-level instances
wire [11:0] player_pos_s;
wire start_game_s;

player_control player_u (

.clk(vga_clk),
.reset(reset),
.start_game(start_game_s),
.left(left),
.right(right),
.player_pos(player_pos_s)

);

game_loop game_loop_u (

.color_r(red_s),
.color_g(green_s),
.color_b(blue_s),
.pixel_x(pixel_x_s),
.pixel_y(pixel_y_s),
.random_num(rnd_val_s),
.clk(vga_clk),
.reset(reset),
.start_btn(start),
.player_pos(player_pos_s),
.start_game(start_game_s)

);

vga_controller vga_u(

.clk(vga_clk),
.reset(reset),
.resolution_height(resolution_height),
.resolution_width(resolution_width),
.red_in(red_s),
.green_in(green_s),
.blue_in(blue_s),
.vga_r(vga_r_8bit),
.vga_g(vga_g_8bit),
.vga_b(vga_b_8bit),
.vga_hs(vga_hs),  
.vga_vs(vga_vs),   
.pixel_x(pixel_x_s),
.pixel_y(pixel_y_s)

);

vga_clk vga_clk_u(
.refclk(clk),   //  refclk.clk
.rst(reset),      //   reset.reset
.outclk_0(vga_clk) // outclk0.clk

);
    
random_1_to_5_lfsr random_u(

.clk(vga_clk),
.reset(reset),
.rnd_val(rnd_val_s)

);

assign vga_r = vga_r_8bit[7:4];
assign vga_g = vga_g_8bit[7:4];
assign vga_b = vga_b_8bit[7:4];

endmodule