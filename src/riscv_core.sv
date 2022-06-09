module riscv_core(
    inst_addr,
    inst,
    mem_addr,
    mem_data_out,
    mem_data_in,
    mem_write_en,
    halted,
    clk,
    rst_b
);
    output  reg [31:0] inst_addr;
    input   [31:0] inst;
    output  reg [31:0] mem_addr;
    input   [7:0]  mem_data_out[0:3];
    output  [7:0]  mem_data_in[0:3];
    output         mem_write_en;
    output  reg    halted;
    input          clk;
    input          rst_b;
    

    reg [31:0] input1;
    reg [31:0] input2;
    reg [31:0] inpin;
    reg [31:0] alu_result;

    reg [31:0] instAddr;
    reg bool = 1'b0;
    
    reg [3:0] alu_control;
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;
    reg [4:0] rs1_num;
    reg [31:0] rs1_data;
    reg [4:0] rs2_num;
    reg [31:0] rs2_data;
    reg [4:0] rd_num;
    reg [31:0] rd_data;
    reg [31:0] immSmall;
    reg rd_we;

    reg cache_hit;
    reg [7:0] cache_data_out[0:3];
    reg [7:0] cache_data_in[0:3];
    reg [31:0] cache_addr;
    reg cache_we;
    reg interupt_start;
    reg interupt_second;
    reg interupt_stop = 0;

    regfile r(
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rs1_num(rs1_num),
        .rs2_num(rs2_num),
        .rd_num(rd_num),
        .rd_data(rd_data),
        .rd_we(1'b1),
        .clk(clk),
        .rst_b(rst_b),
        .halted(halted)
    );

    Control_Unit control_module(
        inst,
        inst_addr,
        rs1_num,
        rs2_num,
        rd_num,
        immSmall,
        alu_control
    );

    Cache cache (
        .cache_addr(cache_addr),
        .cache_hit(cache_hit),
        .cache_data_out(cache_data_out),
        .cache_data_in(cache_data_in),
        .clk(clk),
        .cache_we(cache_we),
        .reset(rst_b),
        .mem_data_in(mem_data_in),
        .mem_data_out(mem_data_out),
        .mem_addr(mem_addr),
        .mem_we(mem_write_en),
        .interupt_start(interupt_start),
        .interupt_second(interupt_second),
        .interupt_stop(interupt_stop)
    );
    
    // ALU alu_module(
    //     input1,
    //     input2,
    //     alu_control,
    //     rd_data,
    //     funct3,
    //     mem_addr,
    //     mem_write_en,
    //     mem_data_out,
    //     mem_data_in,
    //     inpin,
    //     inst_addr
    // );

    ALU alu_module(
        input1,
        input2,
        alu_control,
        rd_data,
        funct3,
        cache_addr,
        cache_we,
        cache_data_out,
        cache_data_in,
        inpin,
        inst_addr
    );


    reg [31:0] forward = 4;
    reg [2:0] counter = 0;
    always_ff @(posedge clk) begin
        if (interupt_start) begin
            counter <= counter + 1;
            interupt_stop <= 0;
            if (counter == 4) begin
                interupt_stop <= 1;
                counter <= 0;
            end
        end
        else if (interupt_second) begin
            counter <= counter + 1;
            interupt_stop <= 0;
            if (counter == 4) begin
                interupt_stop <= 1;
                counter <= 0;
            end
        end
        else begin
        if (bool != 1'b0) begin
            inst_addr <= inst_addr + forward;
        end
        bool = 1'b1;
        if (opcode == 'h73) begin
            halted <= 1;
        end
        end
    end

    always_comb begin
        opcode = inst[6:0];
        funct3 = inst[14:12];
        forward = 4;
        case(opcode)

        'h33: begin           
            input1 = rs1_data;
            input2 = rs2_data;
        end
        
        'h13: begin
            input1 = rs1_data;
            input2 = immSmall;  

        end
        
        'h37: begin
            input1 = rs1_data;
            input2 = immSmall;
        end
        
        'h17: begin
            input1 = immSmall;
        end
        
        // load
        'h03: begin
            input1 = rs1_data;
            input2 = immSmall;
        end
        
        // store
        'h23: begin
            input1 = rs1_data;
            input2 = immSmall;
            inpin = rs2_data;
            rd_num = 0;
        end

        'h63: begin
            rd_num = 0;
            case(funct3)
                0: begin
                    if (rs1_data == rs2_data)
                        forward = immSmall;
                    else
                        forward = 4;
                end
                1: begin
                    if (rs1_data != rs2_data)
                        forward = immSmall;
                    else
                        forward = 4;
                end
                4: begin
                    if ($signed(rs1_data) < $signed(rs2_data))
                        forward = immSmall;
                    else
                        forward = 4;
                end
                5: begin
                    if ($signed(rs1_data) >= $signed(rs2_data))
                        forward = immSmall;
                    else
                        forward = 4;
                end
                6: begin
                    if ($unsigned(rs1_data) < $unsigned(rs2_data))
                        forward = immSmall;
                    else
                        forward = 4;
                end
                7: begin
                    if ($unsigned(rs1_data) >= $unsigned(rs2_data))
                        forward = immSmall;
                    else
                        forward = 4;
                end
            endcase
        end
        
        'h67: begin
            input1 = rs1_data;
            input2 = immSmall;
            forward = ((rs1_data+immSmall) & (-2)) - inst_addr;
        end
        
        'h6F: begin
            forward = immSmall;
        end
        
        // 'h73: begin
        //     halted = 1;
        // end
        
        default: begin
            input1 = 0;
            input2 = 0;
        end
        endcase
    end

endmodule
