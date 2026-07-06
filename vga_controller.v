
module vga_controller (
    input wire          clk,
    input wire          reset,
    input wire [11:0]   resolution_height,
    input wire [11:0]   resolution_width,
    input wire  [7:0]   red_in,
    input wire  [7:0]   green_in,
    input wire  [7:0]   blue_in,
	 
    output reg          vga_hs,
    output reg          vga_vs,
	 output reg          vga_hs_driver,
    output reg          vga_vs_driver,
    output reg  [7:0]   vga_r,
    output reg  [7:0]   vga_g,
    output reg  [7:0]   vga_b,
	 output reg [11:0]  pixel_x,
    output reg [11:0]  pixel_y
	 
);

    //========================================================================
    // VESA Timing Parameters (Front Porch, Sync Pulse, Back Porch)
    //========================================================================
    localparam H_DISPLAY_800=800,V_DISPLAY_600=600,H_FRONT_PORCH_800=40,V_FRONT_PORCH_600=1,H_SYNC_PULSE_800=128,V_SYNC_PULSE_600=4,H_BACK_PORCH_800=88,V_BACK_PORCH_600=23,H_TOTAL_800=1056,V_TOTAL_600=628;
    localparam H_DISPLAY_1280_720=1280,V_DISPLAY_1280_720=720,H_FRONT_PORCH_1280=110,V_FRONT_PORCH_720=5,H_SYNC_PULSE_1280=40,V_SYNC_PULSE_720=5,H_BACK_PORCH_1280=220,V_BACK_PORCH_720=20,H_TOTAL_1280_720=1650,V_TOTAL_1280_720=750;
    localparam H_DISPLAY_1368=1368,V_DISPLAY_768=768,H_FRONT_PORCH_1368=72,V_FRONT_PORCH_768=17,H_SYNC_PULSE_1368=136,V_SYNC_PULSE_768=10,H_BACK_PORCH_1368=208,V_BACK_PORCH_768=17,H_TOTAL_1368=1776,V_TOTAL_768=798;
    localparam H_DISPLAY_1920=1920,V_DISPLAY_1080=1080,H_FRONT_PORCH_1920=88,V_FRONT_PORCH_1080=4,H_SYNC_PULSE_1920=44,V_SYNC_PULSE_1080=5,H_BACK_PORCH_1920=148,V_BACK_PORCH_1080=36,H_TOTAL_1920=2200,V_TOTAL_1080=1125;
    localparam H_DISPLAY_1280_960=1280,V_DISPLAY_1280_960=960,H_FRONT_PORCH_1280_960=48,V_FRONT_PORCH_960=1,H_SYNC_PULSE_1280_960=112,V_SYNC_PULSE_960=3,H_BACK_PORCH_1280_960=312,V_BACK_PORCH_960=36,H_TOTAL_1280_960=1752,V_TOTAL_1280_960=1000;

    reg [11:0] H_DISPLAY, H_FRONT_PORCH, H_SYNC_PULSE, H_BACK_PORCH, H_TOTAL;
    reg [11:0] V_DISPLAY, V_FRONT_PORCH, V_SYNC_PULSE, V_BACK_PORCH, V_TOTAL;
    always @(*) begin
				//Timing Parameter Selection based on Resolution
            if(resolution_width == 800 &&  resolution_height == 600) begin H_DISPLAY=H_DISPLAY_800+2; H_FRONT_PORCH=H_FRONT_PORCH_800; H_SYNC_PULSE=H_SYNC_PULSE_800; H_BACK_PORCH=H_BACK_PORCH_800; H_TOTAL=H_TOTAL_800+2; V_DISPLAY=V_DISPLAY_600; V_FRONT_PORCH=V_FRONT_PORCH_600; V_SYNC_PULSE=V_SYNC_PULSE_600; V_BACK_PORCH=V_BACK_PORCH_600; V_TOTAL=V_TOTAL_600; end
            else if(resolution_width == 1280 && resolution_height == 720) begin H_DISPLAY=H_DISPLAY_1280_720+2; H_FRONT_PORCH=H_FRONT_PORCH_1280; H_SYNC_PULSE=H_SYNC_PULSE_1280; H_BACK_PORCH=H_BACK_PORCH_1280; H_TOTAL=H_TOTAL_1280_720+2; V_DISPLAY=V_DISPLAY_1280_720; V_FRONT_PORCH=V_FRONT_PORCH_720;  V_SYNC_PULSE=V_SYNC_PULSE_720;  V_BACK_PORCH=V_BACK_PORCH_720;  V_TOTAL=V_TOTAL_1280_720; end
            else if(resolution_width == 1368 && resolution_height == 768) begin H_DISPLAY=H_DISPLAY_1368+2; H_FRONT_PORCH=H_FRONT_PORCH_1368; H_SYNC_PULSE=H_SYNC_PULSE_1368; H_BACK_PORCH=H_BACK_PORCH_1368; H_TOTAL=H_TOTAL_1368+2; V_DISPLAY=V_DISPLAY_768;  V_FRONT_PORCH=V_FRONT_PORCH_768;  V_SYNC_PULSE=V_SYNC_PULSE_768;  V_BACK_PORCH=V_BACK_PORCH_768;  V_TOTAL=V_TOTAL_768; end
            else if(resolution_width == 1920 && resolution_height == 1080) begin H_DISPLAY=H_DISPLAY_1920+2; H_FRONT_PORCH=H_FRONT_PORCH_1920; H_SYNC_PULSE=H_SYNC_PULSE_1920; H_BACK_PORCH=H_BACK_PORCH_1920; H_TOTAL=H_TOTAL_1920+2; V_DISPLAY=V_DISPLAY_1080; V_FRONT_PORCH=V_FRONT_PORCH_1080; V_SYNC_PULSE=V_SYNC_PULSE_1080; V_BACK_PORCH=V_BACK_PORCH_1080; V_TOTAL=V_TOTAL_1080; end
            else if(resolution_width == 1280 && resolution_height == 960) begin H_DISPLAY=H_DISPLAY_1280_960+2; H_FRONT_PORCH=H_FRONT_PORCH_1280_960; H_SYNC_PULSE=H_SYNC_PULSE_1280_960; H_BACK_PORCH=H_BACK_PORCH_1280_960; H_TOTAL=H_TOTAL_1280_960+2;V_DISPLAY=V_DISPLAY_1280_960; V_FRONT_PORCH=V_FRONT_PORCH_960;  V_SYNC_PULSE=V_SYNC_PULSE_960;  V_BACK_PORCH=V_BACK_PORCH_960;  V_TOTAL=V_TOTAL_1280_960;end
				else begin H_DISPLAY=H_DISPLAY_1280_720+2; H_FRONT_PORCH=H_FRONT_PORCH_1280; H_SYNC_PULSE=H_SYNC_PULSE_1280; H_BACK_PORCH=H_BACK_PORCH_1280; H_TOTAL=H_TOTAL_1280_720+2; V_DISPLAY=V_DISPLAY_1280_720; V_FRONT_PORCH=V_FRONT_PORCH_720;  V_SYNC_PULSE=V_SYNC_PULSE_720;  V_BACK_PORCH=V_BACK_PORCH_720;  V_TOTAL=V_TOTAL_1280_720; end
            
        
    end
	 //Horizontal Counter
    reg [11:0] h_count; 
	 //Vertical Counter
	 reg [11:0] v_count;
	 

	 
	 
    wire display_on;
	 //Active Display Area
    assign display_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY) && (h_count > 1);
    always @(posedge clk or posedge reset) begin
        if (reset) begin h_count <= 0; v_count <= 0; vga_hs <= 1; vga_vs <= 1; vga_r <= 0; vga_g <= 0; vga_b <= 0;
        end else begin
				//Counters Logic
            if (h_count < H_TOTAL - 1) begin h_count <= h_count + 1;
            end else begin h_count <= 0; if (v_count < V_TOTAL - 1) begin v_count <= v_count + 1;
                end else begin v_count <= 0; end
            end
				//Sync Pulse Generation
            if ((h_count >= H_DISPLAY + H_FRONT_PORCH) && (h_count < H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE)) begin vga_hs <= 0;
            end else begin vga_hs <= 1; end
            if ((v_count >= V_DISPLAY + V_FRONT_PORCH) && (v_count < V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE)) begin vga_vs <= 0;
            end else begin vga_vs <= 1; end
				
				if ((h_count >= H_DISPLAY + H_FRONT_PORCH-2) && (h_count < H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE-2)) begin vga_hs_driver <= 0;
            end else begin vga_hs_driver <= 1; end
            if ((v_count >= V_DISPLAY + V_FRONT_PORCH-2) && (v_count < V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE-2)) begin vga_vs_driver <= 0;
            end else begin vga_vs_driver <= 1; end
				
				//RGB Data Output
            if (display_on) begin vga_r <= red_in; vga_g <= green_in; vga_b <= blue_in;
            end else begin vga_r <= 0; vga_g <= 0; vga_b <= 0; end // Black during blanking
				
			pixel_x <= h_count;
			pixel_y <= v_count;
				
        end
		  

		  
    end
	 
	 
	 
	 
	 
endmodule