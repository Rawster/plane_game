module game_loop(
    input wire clk,
    input wire reset,
    input wire start_btn,
    input wire [11:0] player_pos, // Position coming from top module
    input wire [11:0] pixel_x,
    input wire [11:0] pixel_y,
    input wire [3:0] random_num,

    output reg [7:0] color_r,
    output reg [7:0] color_g,
    output reg [7:0] color_b,
    output reg start_game         // Exporting game state to top module
);

localparam GAP_SIZE = 12'd72;
localparam EXTRA_SPACE = 12'd450;
localparam SCREEN_HEIGHT = 12'd600;

// Falling lines speed
localparam SPEED1 = 20'd833_333;   
localparam SPEED2 = 20'd600_000;   
localparam SPEED3 = 20'd400_000;   

reg game_over = 0;
reg [11:0] horizontal_lines [0:3];
reg [11:0] horizontal_gaps [0:3];
reg [19:0] speed_counter;
reg [19:0] speed = SPEED1;
integer i;

// 1. STATE REGISTERS (Clocked)
always @(posedge clk or posedge reset) begin
    if(reset) begin
        horizontal_lines[0] <= 12'd450;
        horizontal_lines[1] <= 12'd300;
        horizontal_lines[2] <= 12'd150;
        horizontal_lines[3] <= 12'd000;
        
        horizontal_gaps[0] <= 12'd72;
        horizontal_gaps[1] <= 12'd72 + 12'd72 + 12'd72;
        horizontal_gaps[2] <= 12'd72 + 12'd144 + 12'd144;
        horizontal_gaps[3] <= 12'd72 + 12'd288 + 12'd288;
        
        start_game <= 0;
        game_over <= 0;
        speed_counter <= 20'd0;
    end
    else begin
        if(start_btn && !game_over) begin
            start_game <= 1; 
        end
        
        if(start_game) begin
            
            // --- COLLISION DETECTION ---
            for (i = 0; i < 4; i = i + 1) begin
                if ((horizontal_lines[i] >= 12'd500 + EXTRA_SPACE) && 
                    (horizontal_lines[i] <= 12'd550 + EXTRA_SPACE)) begin
                    
                    if ((player_pos < horizontal_gaps[i]) || 
                        (player_pos + 12'd30 > horizontal_gaps[i] + GAP_SIZE)) begin
                        game_over <= 1;
                        start_game <= 0; // Stop the game immediately
                    end
                end
            end

            // --- MOVEMENT OF HORIZONTAL LINES ---
            if(speed_counter == speed) begin
                speed_counter <= 0;
                
                if (horizontal_lines[0] == SCREEN_HEIGHT + EXTRA_SPACE) 
                     horizontal_lines[0] <= EXTRA_SPACE;
                else 
                     horizontal_lines[0] <= horizontal_lines[0] + 12'd1;
                
                if (horizontal_lines[1] == SCREEN_HEIGHT + EXTRA_SPACE) 
                     horizontal_lines[1] <= EXTRA_SPACE;
                else 
                     horizontal_lines[1] <= horizontal_lines[1] + 12'd1;
                
                if (horizontal_lines[2] == SCREEN_HEIGHT + EXTRA_SPACE) 
                     horizontal_lines[2] <= EXTRA_SPACE;
                else 
                     horizontal_lines[2] <= horizontal_lines[2] + 12'd1;
                
                if (horizontal_lines[3] == SCREEN_HEIGHT + EXTRA_SPACE) 
                     horizontal_lines[3] <= EXTRA_SPACE;
                else 
                     horizontal_lines[3] <= horizontal_lines[3] + 12'd1;
                    
            end
            else begin
                speed_counter <= speed_counter+1;
            end
              
            // --- RANDOM GAP GENERATION ---
            if (horizontal_lines[0] == EXTRA_SPACE+SCREEN_HEIGHT) 
                horizontal_gaps[0] <= random_num * 2 * GAP_SIZE + GAP_SIZE;
            if (horizontal_lines[1] == EXTRA_SPACE+SCREEN_HEIGHT) 
                horizontal_gaps[1] <= random_num * 2 * GAP_SIZE + GAP_SIZE;
            if (horizontal_lines[2] == EXTRA_SPACE+SCREEN_HEIGHT) 
                horizontal_gaps[2] <= random_num * 2 * GAP_SIZE + GAP_SIZE;
            if (horizontal_lines[3] == EXTRA_SPACE+SCREEN_HEIGHT) 
                horizontal_gaps[3] <= random_num * 2 * GAP_SIZE + GAP_SIZE;  
              
        end
    end
end

// 2. DRAWING LOGIC (Combinational)
always @(*) begin
    // Default background color
    color_r = 8'h00;
    color_g = 8'h00;
    color_b = 8'h00;
        
    // Highest priority: Game Over screen
    if (game_over) begin
        color_r = 8'hFF;
        color_g = 8'h00;
        color_b = 8'h00;
    end
    else begin
        if (start_game) begin
            // Draw plane
            if (pixel_y > 12'd500 && pixel_y <= 12'd513) begin
                if (pixel_x > player_pos && pixel_x <= player_pos+12'd30) begin
                    color_r = 8'hFF;
                    color_g = 8'h00;
                    color_b = 8'h00;
                end
            end
            else if (pixel_y > 12'd513 && pixel_y <= 12'd543) begin
                if (pixel_x > player_pos+12'd12 && pixel_x <= player_pos+12'd18) begin
                    color_r = 8'hFF;
                    color_g = 8'h00;
                    color_b = 8'h00;
                end
            end
            else if (pixel_y > 12'd543 && pixel_y <= 12'd550) begin
                if (pixel_x > player_pos+12'd8 && pixel_x <= player_pos+12'd22) begin
                    color_r = 8'hFF;
                    color_g = 8'h00;
                    color_b = 8'h00;
                end
            end
        end
        
        // Draw lines and gaps
        for (i = 0; i < 4; i = i + 1) begin
            if (pixel_y + EXTRA_SPACE == horizontal_lines[i] && start_game) begin
                if (pixel_x < horizontal_gaps[i] || pixel_x > horizontal_gaps[i] + GAP_SIZE) begin
                    color_r = 8'hFF;
                    color_g = 8'hFF;
                    color_b = 8'hFF;
                end
            end
        end
    end
end

endmodule