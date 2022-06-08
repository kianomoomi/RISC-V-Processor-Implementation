module Cache (
    cache_addr,
    cache_hit,
    cache_data_out,
    cache_data_in,
    clk,
    cache_we,
    reset
);

    parameter ARRAY_SIZE = (2**11)-1;

    input [31:0] cache_addr;
    input cache_we;
    input clk;
    input reset;
    output cache_hit;
    input [31:0] cache_data_in;
    output [31:0] cache_data_out;

    reg v_array [0:ARRAY_SIZE];
    reg dirty_array [0:ARRAY_SIZE];
    reg [18:0] tag_array [0:ARRAY_SIZE];
    reg [31:0] data_array [0:ARRAY_SIZE];

    wire [10:0] current_block;
    wire [19:0] current_tag;
    wire [1:0] current_byte;


    assign current_block = cache_addr[12:2];
    assign current_block = cache_addr[1:0];
    assign current_tag = cache_addr[31:13];

    always_ff @(posedge clk) begin 
        if (v[current_block] == 1) begin
            
            if (tag_array[current_block] == current_tag) begin
                
                if (!cache_we) begin
                    cache_data_out <= data_array[current_block];
                end
                else begin 
                    data_array[current_block] <= cache_data_in;
                end
            end

        end
    end


endmodule