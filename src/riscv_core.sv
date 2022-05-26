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
    output  reg [7:0]  mem_data_in[0:3];
    output  reg       mem_write_en;
    output  reg    halted;
    input          clk;
    input          rst_b;




    reg [31:0] input1;
    reg [31:0] input2;
    reg [31:0] input_memory1;
    reg [31:0] input_memory2;


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

    control control_module(
        inst,
        inst_addr,
        rs1_num,
        rs2_num,
        rd_num,
        immSmall,
        alu_control
    );
    
    ALU alu_module(
        input1,
        input2,
        alu_control,
        rd_data
    );

    ALU alu_memory(
        input_memory1,
        input_memory2,
        alu_control,
        mem_addr
    );


    always_ff @ (posedge clk) begin
        if (bool != 1'b0)
        inst_addr <= inst_addr + 4;
        bool = 1'b1;
    end

    always_comb begin
        opcode = inst[6:0];
        funct3 = inst[14:12];
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
        'h03: begin
            input_memory1 = rs1_data;
            input_memory2 = immSmall;
            if (funct3 == 0) begin
                rd_data = {{24{1'b0}}, mem_data_out[0]};
            end 
            else if (funct3 == 1) begin
                rd_data = {{16{1'b0}}, mem_data_out[1], mem_data_out[0]};
            end 
            else if (funct3 == 2) begin
                rd_data = {mem_data_out[3], mem_data_out[2], mem_data_out[1], mem_data_out[0]};
            end
            else begin
                rd_data = 0;
            end
        end
        'h23: begin
            
        end
        'h73: begin
            halted = 1;
        end
        default: begin
            input1 = 0;
            input2 = 0;
            input_memory1 = 0;
            input_memory2 = 0;
        end
        endcase
    end

endmodule
