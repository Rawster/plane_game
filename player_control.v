module player_control(
    input wire clk,
    input wire reset,
    input wire start_game,
    input wire left,
    input wire right,
    output reg [11:0] player_pos
);

// Player movement acceleration parameters
localparam BASE_PLAYER_SPEED = 20'd400_000; // Slow start for precision
localparam MAX_PLAYER_SPEED  = 20'd80_000;  // Very fast top speed
localparam ACCELERATION_STEP = 20'd4_000;   // Speed increase per tick

// Player speed registers
reg [19:0] player_speed_counter = 0; 
reg [19:0] current_player_speed = BASE_PLAYER_SPEED;

// Sequential logic for player movement
always @(posedge clk or posedge reset) begin
    if (reset) begin
        player_pos <= 12'd400;
        player_speed_counter <= 20'd0;
        current_player_speed <= BASE_PLAYER_SPEED;
    end
    else begin
        if (start_game) begin
            // Reset speed to slow when no buttons are pressed
            if (!left && !right) begin
                current_player_speed <= BASE_PLAYER_SPEED;
            end

            if (player_speed_counter >= current_player_speed) begin
                player_speed_counter <= 20'd0;
                
                if (left) begin
                    if (player_pos > 12'd0) 
                        player_pos <= player_pos - 12'd1;
                        
                    // Accelerate by decreasing the counter limit
                    if (current_player_speed > MAX_PLAYER_SPEED) begin
                        current_player_speed <= current_player_speed - ACCELERATION_STEP;
                    end
                end
                else if (right) begin
                    // Max position is 799 - 30 (player width) = 769
                    if (player_pos < 12'd769) 
                        player_pos <= player_pos + 12'd1;
                        
                    // Accelerate by decreasing the counter limit
                    if (current_player_speed > MAX_PLAYER_SPEED) begin
                        current_player_speed <= current_player_speed - ACCELERATION_STEP;
                    end
                end
            end 
            else begin
                player_speed_counter <= player_speed_counter + 1'b1;
            end
        end
    end
end

endmodule