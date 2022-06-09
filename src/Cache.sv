module Cache (
    cache_addr,
    cache_hit,
    cache_data_out,
    cache_data_in,
    clk,
    cache_we,
    reset,
    mem_data_in,
    mem_data_out,
    mem_addr,
    mem_we,
    interupt_start,
    interupt_stop
);

    parameter ARRAY_SIZE = (2**11)-1;

    input [31:0] cache_addr;
    input cache_we;
    input clk;
    input reset;
    output reg cache_hit;
    input [7:0] cache_data_in[0:3];
    output reg [7:0] cache_data_out[0:3];
    output reg [7:0] mem_data_in[0:3];
    input [7:0] mem_data_out[0:3];
    output reg [31:0] mem_addr;
    output reg mem_we;
    output reg interupt_start;
    input reg interupt_stop;

    reg v_array [0:ARRAY_SIZE];
    reg dirty_array [0:ARRAY_SIZE];
    reg [18:0] tag_array [0:ARRAY_SIZE];
    reg [31:0] data_array [0:ARRAY_SIZE];

    wire [10:0] current_block;
    wire [18:0] current_tag;
    wire [1:0] current_byte;

    reg [2:0] counter = 0;


    assign current_block = cache_addr[12:2];
    assign current_byte = cache_addr[1:0];
    assign current_tag = cache_addr[31:13];

    always_ff @(posedge clk) begin 
        if (v_array[current_block] == 1) begin
            
            if (tag_array[current_block] == current_tag) begin
                
                if (!cache_we) begin
                    cache_data_out[0] <= data_array[current_block][7:0];
                    cache_data_out[1] <= data_array[current_block][15:8];
                    cache_data_out[2] <= data_array[current_block][23:16];
                    cache_data_out[3] <= data_array[current_block][31:24];
                    cache_hit <= 1;
                end
                else begin 
                    data_array[current_block] <= {cache_data_in[3], cache_data_in[2], cache_data_in[1], cache_data_in[0]};
                    dirty_array[current_block] <= 1;
                end

            end
            else begin
                if (dirty_array[current_block] == 1) begin
                    if (!cache_we) begin
                        
                    end
                    else begin
                        
                    end
                end
                else begin
                    if (!cache_we) begin
                        mem_addr <= cache_addr;
                        interupt_start <= 1;
                        if (interupt_stop == 1) begin
                            interupt_start <= 0;
                            data_array[current_block] <= {mem_data_out[3], mem_data_out[2], mem_data_out[1], mem_data_out[0]};
                            tag_array[current_block] <= current_tag;
                            v_array[current_block] <= 1;
                            dirty_array[current_block] <= 0;
                            cache_data_out <= mem_data_out;
                        end
                    end
                    else begin
                        mem_addr <= cache_addr;
                        mem_we <= 1;
                        mem_data_in[0] <= cache_data_in[0];
                        mem_data_in[1] <= cache_data_in[1];
                        mem_data_in[2] <= cache_data_in[2];
                        mem_data_in[3] <= cache_data_in[3];
                        interupt_start <= 1;
                        if (interupt_stop == 1) begin
                            interupt_start <= 0;
                            data_array[current_block] <= {cache_data_in[3], cache_data_in[2], cache_data_in[1], cache_data_in[0]};
                            tag_array[current_block] <= current_tag;
                            v_array[current_block] <= 1;
                            dirty_array[current_block] <= 0;
                            // cache_data_out <= mem_data_out;
                        end
                    end
                end
            end

        end
        else begin
            if (!cache_we) begin
                mem_addr <= cache_addr;
                interupt_start <= 1;
                if (interupt_stop == 1) begin
                    interupt_start <= 0;
                    data_array[current_block] <= {mem_data_out[3], mem_data_out[2], mem_data_out[1], mem_data_out[0]};
                    tag_array[current_block] <= current_tag;
                    v_array[current_block] <= 1;
                    dirty_array[current_block] <= 0;
                    cache_data_out <= mem_data_out;
                end
            end
            else begin
                mem_addr <= cache_addr;
                mem_we <= 1;
                mem_data_in[0] <= cache_data_in[0];
                mem_data_in[1] <= cache_data_in[1];
                mem_data_in[2] <= cache_data_in[2];
                mem_data_in[3] <= cache_data_in[3];
                interupt_start <= 1;
                if (interupt_stop == 1) begin
                    interupt_start <= 0;
                    data_array[current_block] <= {cache_data_in[3], cache_data_in[2], cache_data_in[1], cache_data_in[0]};
                    tag_array[current_block] <= current_tag;
                    v_array[current_block] <= 1;
                    dirty_array[current_block] <= 0;
                    // cache_data_out <= mem_data_out;
                end
            end
        end
    end


endmodule