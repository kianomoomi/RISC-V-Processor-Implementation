module Cache (
    cache_addr,
    cache_hit,
    cache_data_out,
    cache_data_in,
    clk,
    cache_we,
    rst_b,
    mem_data_in,
    mem_data_out,
    mem_addr,
    mem_we,
    interupt_start,
    interupt_second,
    interupt_stop,
    opcode,
    funct3
);

    parameter ARRAY_SIZE = (2**11)-1;

    input [31:0] cache_addr;
    input cache_we;
    input clk;
    input rst_b;
    output reg cache_hit;
    input [7:0] cache_data_in[0:3];
    output reg [7:0] cache_data_out[0:3];
    output reg [7:0] mem_data_in[0:3];
    input [7:0] mem_data_out[0:3];
    output reg [31:0] mem_addr;
    output reg mem_we;
    output reg interupt_start;
    output reg interupt_second;
    input interupt_stop;
    input[6:0] opcode;
    input[2:0] funct3;

    reg bool;
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

    always_ff @(posedge clk, negedge rst_b) begin 
        if(rst_b == 0) begin
            integer i;
            for(i = 0; i <= ARRAY_SIZE; i = i + 1) begin
                v_array[i] <= 0;
                dirty_array[i] <= 0;
                tag_array[i] <= 0;
                data_array[i] <= 0;
            end
        end
        if (opcode == 'h23 || opcode == 'h03 || opcode == 'h73) begin
        if(bool == 0)
        begin
        // already in cache
        if (v_array[current_block] == 1) begin
            
            if (tag_array[current_block] == current_tag) begin
                // clean read
                if (!cache_we) begin
                    // $display("cache hit");
                    case(funct3)
                    // load byte
                    3'd0: begin
                        cache_data_out[0] <= data_array[current_block][7:0];
                        cache_data_out[1] <= {8{data_array[current_block][7]}};
                        cache_data_out[2] <= {8{data_array[current_block][7]}};
                        cache_data_out[3] <= {8{data_array[current_block][7]}};
                        cache_hit <= 1;
                    end
                    // load halfword
                    3'd1: begin
                        cache_data_out[0] <= data_array[current_block][7:0];
                        cache_data_out[1] <= data_array[current_block][15:8];
                        cache_data_out[2] <= {8{data_array[current_block][15]}};
                        cache_data_out[3] <= {8{data_array[current_block][15]}};
                        cache_hit <= 1;
                    end
                    // load word
                    3'd2: begin
                        cache_data_out[0] <= data_array[current_block][7:0];
                        cache_data_out[1] <= data_array[current_block][15:8];
                        cache_data_out[2] <= data_array[current_block][23:16];
                        cache_data_out[3] <= data_array[current_block][31:24];
                        cache_hit <= 1;
                    end
                    // load byte unsigned
                    3'd4: begin
                        cache_data_out[0] <= data_array[current_block][7:0];
                        cache_data_out[1] <= {8{1'b0}};
                        cache_data_out[2] <= {8{1'b0}};
                        cache_data_out[3] <= {8{1'b0}};
                        cache_hit <= 1;
                    end
                    // load halfword unsigned
                    3'd5: begin
                        cache_data_out[0] <= data_array[current_block][7:0];
                        cache_data_out[1] <= data_array[current_block][15:8];
                        cache_data_out[2] <= {8{1'b0}};
                        cache_data_out[3] <= {8{1'b0}};
                        cache_hit <= 1;
                    end
                    default: begin
                        cache_data_out[0] <= {8{1'b0}};
                        cache_data_out[1] <= {8{1'b0}};
                        cache_data_out[2] <= {8{1'b0}};
                        cache_data_out[3] <= {8{1'b0}};
                    end

                endcase
                   
                end
                // clean write
                else begin 
                    $display("write");
                    case(funct3)
                    // store byte
                    3'd0: begin
                        $display("store byte");
                        // data_array[current_block] <= {cache_data_out[3], cache_data_out[2], cache_data_out[1], cache_data_in[0]};
                        data_array[current_block] <= {data_array[current_block][31:24], data_array[current_block][23:16], data_array[current_block][15:8], cache_data_in[0]};
                        dirty_array[current_block] <= 1;
                    end
                    // store halfword
                    3'd1: begin
                        // data_array[current_block] <= {cache_data_out[3], cache_data_out[2], cache_data_in[1], cache_data_in[0]};
                        data_array[current_block] <= {data_array[current_block][31:24], data_array[current_block][23:16], cache_data_in[1], cache_data_in[0]};
                        dirty_array[current_block] <= 1;
                    end
                    // store word
                    3'd2: begin
                        data_array[current_block] <= {cache_data_in[3], cache_data_in[2], cache_data_in[1], cache_data_in[0]};
                        dirty_array[current_block] <= 1;
                    end
                    default: begin
                        data_array[current_block] <= 0;
                    end
                endcase
                    
                end

            end
            else begin
                // dirty functions
                if (dirty_array[current_block] == 1) begin
                    // first we should write to memory
                    mem_addr <= {tag_array[current_block], current_block, current_byte};
                    mem_we <= 1;
                    case(funct3)
                    // write byte to memory
                    3'd0: begin
                        $display("dirty write");
                        mem_data_in[0] <= data_array[current_block][7:0];
                        mem_data_in[1] <= mem_data_out[1];
                        mem_data_in[2] <= mem_data_out[2];
                        mem_data_in[3] <= mem_data_out[3];
                    end
                    // write halfword to memory
                    3'd1: begin
                        mem_data_in[0] <= data_array[current_block][7:0];
                        mem_data_in[1] <= data_array[current_block][15:8];
                        mem_data_in[2] <= mem_data_out[2];
                        mem_data_in[3] <= mem_data_out[3];
                    end
                    // write word to memory
                    3'd2: begin
                        mem_data_in[0] <= data_array[current_block][7:0];
                        mem_data_in[1] <= data_array[current_block][15:8];
                        mem_data_in[2] <= data_array[current_block][23:16];
                        mem_data_in[3] <= data_array[current_block][31:24];
                    end
                    default: begin
                        mem_data_in[0] <= 0;
                        mem_data_in[1] <= 0;
                        mem_data_in[2] <= 0;
                        mem_data_in[3] <= 0;
                    end
                endcase
                    interupt_start <= 1;
                    interupt_second <= 1;
                    if (interupt_stop == 1) begin
                        interupt_start <= 0;
                        data_array[current_block] <= 0;
                        tag_array[current_block] <= 0;
                        v_array[current_block] <= 0;
                        dirty_array[current_block] <= 0;
                    end
                end
                else begin
                    // clean read but sth stored in cache
                    if (!cache_we) begin
                        mem_addr <= cache_addr;
                        interupt_start <= 1;
                        if (interupt_stop == 1) begin
                            interupt_start <= 0;
                            tag_array[current_block] <= current_tag;
                            v_array[current_block] <= 1;
                            dirty_array[current_block] <= 0;
                        case(funct3)
                    // load byte
                    3'd0: begin
                        data_array[current_block] <= {data_array[current_block][31:24], data_array[current_block][23:16], data_array[current_block][15:8], mem_data_out[0]};
                        cache_data_out[0] <= mem_data_out[0];
                        cache_data_out[1] <= data_array[current_block][15:8];
                        cache_data_out[2] <= data_array[current_block][23:16];
                        cache_data_out[3] <= data_array[current_block][31:24];
                    end
                    // load halfword
                    3'd1: begin
                        data_array[current_block] <= {data_array[current_block][31:24], data_array[current_block][23:16], mem_data_out[1], mem_data_out[0]};
                        cache_data_out[0] <= mem_data_out[0];
                        cache_data_out[1] <= mem_data_out[1];
                        cache_data_out[2] <= data_array[current_block][23:16];
                        cache_data_out[3] <= data_array[current_block][31:24];
                    end
                    // load word
                    3'd2: begin
                        data_array[current_block] <= {mem_data_out[3], mem_data_out[2], mem_data_out[1], mem_data_out[0]};
                        cache_data_out[0] <= mem_data_out[0];
                        cache_data_out[1] <= mem_data_out[1];
                        cache_data_out[2] <= mem_data_out[2];
                        cache_data_out[3] <= mem_data_out[3];
                    end
                    // load byte unsigned
                    3'd4: begin
                        data_array[current_block] <= {{24{1'b0}}, mem_data_out[0]};
                        cache_data_out[0] <= mem_data_out[0];
                        cache_data_out[1] <= {8{1'b0}};
                        cache_data_out[2] <= {8{1'b0}};
                        cache_data_out[3] <= {8{1'b0}};
                    end
                    // load halfword unsigned
                    3'd5: begin
                        data_array[current_block] <= {{16{1'b0}}, mem_data_out[1], mem_data_out[0]};
                        cache_data_out[0] <= mem_data_out[0];
                        cache_data_out[1] <= mem_data_out[1];
                        cache_data_out[2] <= {8{1'b0}};
                        cache_data_out[3] <= {8{1'b0}};
                    end
                    default: begin
                        cache_data_out[0] <= {8{1'b0}};
                        cache_data_out[1] <= {8{1'b0}};
                        cache_data_out[2] <= {8{1'b0}};
                        cache_data_out[3] <= {8{1'b0}};
                    end
                        endcase
                        end
                    end
                    // clean write but sth stored in cache
                    else begin
                        mem_addr <= cache_addr;
                        mem_we <= 1;
                        case(funct3)
                        // write byte
                        3'd0: begin
                            mem_data_in[0] <= cache_data_in[0];
                            mem_data_in[1] <= mem_data_out[1];
                            mem_data_in[2] <= mem_data_out[2];
                            mem_data_in[3] <= mem_data_out[3];
                            data_array[current_block] <= {data_array[current_block][31:24], data_array[current_block][23:16], data_array[current_block][15:8], cache_data_in[0]};
                        end
                        // write halfword
                        3'd1: begin
                            mem_data_in[0] <= cache_data_in[0];
                            mem_data_in[1] <= cache_data_in[1];
                            mem_data_in[2] <= mem_data_out[2];
                            mem_data_in[3] <= mem_data_out[3];
                            data_array[current_block] <= {data_array[current_block][31:24], data_array[current_block][23:16], cache_data_in[1], cache_data_in[0]};
                        end
                        // write word
                        3'd2: begin
                            mem_data_in[0] <= cache_data_in[0];
                            mem_data_in[1] <= cache_data_in[1];
                            mem_data_in[2] <= cache_data_in[2];
                            mem_data_in[3] <= cache_data_in[3];
                            data_array[current_block] <= {cache_data_in[3], cache_data_in[2], cache_data_in[1], cache_data_in[0]};

                        end
                        default: begin
                            mem_data_in[0] <= {8{1'b0}};
                            mem_data_in[1] <= {8{1'b0}};
                            mem_data_in[2] <= {8{1'b0}};
                            mem_data_in[3] <= {8{1'b0}};
                        end
                    endcase
                        interupt_start <= 1;
                        if (interupt_stop == 1) begin
                            interupt_start <= 0;
                            tag_array[current_block] <= current_tag;
                            v_array[current_block] <= 1;
                            dirty_array[current_block] <= 0;
                            // cache_data_out <= mem_data_out;
                        end
                    end
                end
            end

        end
        // not in cache
        else begin
            // read from memory and store in cache
            if (!cache_we) begin
                mem_addr <= cache_addr;
                interupt_start <= 1;
                if (interupt_stop == 1) begin
                    interupt_start <= 0;
                    interupt_second <= 0;
                    tag_array[current_block] <= current_tag;
                    v_array[current_block] <= 1;
                    dirty_array[current_block] <= 0;
                    case(funct3)
                    // load byte
                    3'd0: begin
                        data_array[current_block] <= {data_array[current_block][31:24], data_array[current_block][23:16], data_array[current_block][15:8], mem_data_out[0]};
                        cache_data_out[0] <= mem_data_out[0];
                        cache_data_out[1] <= data_array[current_block][15:8];
                        cache_data_out[2] <= data_array[current_block][23:16];
                        cache_data_out[3] <= data_array[current_block][31:24];
                    end
                    // load halfword
                    3'd1: begin
                        data_array[current_block] <= {data_array[current_block][31:24], data_array[current_block][23:16], mem_data_out[1], mem_data_out[0]};
                        cache_data_out[0] <= mem_data_out[0];
                        cache_data_out[1] <= mem_data_out[1];
                        cache_data_out[2] <= data_array[current_block][23:16];
                        cache_data_out[3] <= data_array[current_block][31:24];
                    end
                    // load word
                    3'd2: begin
                        data_array[current_block] <= {mem_data_out[3], mem_data_out[2], mem_data_out[1], mem_data_out[0]};
                        cache_data_out[0] <= mem_data_out[0];
                        cache_data_out[1] <= mem_data_out[1];
                        cache_data_out[2] <= mem_data_out[2];
                        cache_data_out[3] <= mem_data_out[3];
                    end
                    // load byte unsigned
                    3'd4: begin
                        data_array[current_block] <= {{24{1'b0}}, mem_data_out[0]};
                        cache_data_out[0] <= mem_data_out[0];
                        cache_data_out[1] <= {8{1'b0}};
                        cache_data_out[2] <= {8{1'b0}};
                        cache_data_out[3] <= {8{1'b0}};
                    end
                    // load halfword unsigned
                    3'd5: begin
                        data_array[current_block] <= {{16{1'b0}}, mem_data_out[1], mem_data_out[0]};
                        cache_data_out[0] <= mem_data_out[0];
                        cache_data_out[1] <= mem_data_out[1];
                        cache_data_out[2] <= {8{1'b0}};
                        cache_data_out[3] <= {8{1'b0}};
                    end
                    default: begin
                        cache_data_out[0] <= {8{1'b0}};
                        cache_data_out[1] <= {8{1'b0}};
                        cache_data_out[2] <= {8{1'b0}};
                        cache_data_out[3] <= {8{1'b0}};
                    end
                endcase
                end
            end
            else begin
                // write to memory and store in cache
                // $display("write to memory");
                mem_addr <= cache_addr;
                mem_we <= 1;
                case(funct3)
                        // write byte
                        3'd0: begin
                            mem_data_in[0] <= cache_data_in[0];
                            mem_data_in[1] <= mem_data_out[1];
                            mem_data_in[2] <= mem_data_out[2];
                            mem_data_in[3] <= mem_data_out[3];
                            data_array[current_block] <= {data_array[current_block][31:24], data_array[current_block][23:16], data_array[current_block][15:8], cache_data_in[0]};
                        end
                        // write halfword
                        3'd1: begin
                            mem_data_in[0] <= cache_data_in[0];
                            mem_data_in[1] <= cache_data_in[1];
                            mem_data_in[2] <= mem_data_out[2];
                            mem_data_in[3] <= mem_data_out[3];
                            data_array[current_block] <= {data_array[current_block][31:24], data_array[current_block][23:16], cache_data_in[1], cache_data_in[0]};
                        end
                        // write word
                        3'd2: begin
                            mem_data_in[0] <= cache_data_in[0];
                            mem_data_in[1] <= cache_data_in[1];
                            mem_data_in[2] <= cache_data_in[2];
                            mem_data_in[3] <= cache_data_in[3];
                            data_array[current_block] <= {cache_data_in[3], cache_data_in[2], cache_data_in[1], cache_data_in[0]};

                        end
                        default: begin
                            mem_data_in[0] <= {8{1'b0}};
                            mem_data_in[1] <= {8{1'b0}};
                            mem_data_in[2] <= {8{1'b0}};
                            mem_data_in[3] <= {8{1'b0}};
                        end                
                endcase
                interupt_start <= 1;
                if (interupt_stop == 1) begin
                    // $display("interupt_stop == 1");
                    interupt_start <= 0;
                    interupt_second <= 0;
                    tag_array[current_block] <= current_tag;
                    v_array[current_block] <= 1;
                    dirty_array[current_block] <= 0;
                    // cache_data_out <= mem_data_out;
                    bool <= 1;
                end
            end
        end
        end
        else bool <= 0;
        end
    end


endmodule