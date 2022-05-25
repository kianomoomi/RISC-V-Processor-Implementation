

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
    output  [31:0] mem_addr;
    input   [7:0]  mem_data_out[0:3];
    output  [7:0]  mem_data_in[0:3];
    output         mem_write_en;
    output reg     halted;
    input          clk;
    input          rst_b;




    reg [31:0] input1;
    reg [31:0] input2;
    reg [31:0] instAddr;
    reg bool = 1'b0;
    
    reg [3:0] alu_control;
    reg [6:0] opcode;
    reg [2:0] func3;
    reg [6:0] func7;
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
        // .rs1_num(inst[19:15]),
        // .rs2_num(inst[24:20]),
        // .rd_num(inst[11:7]),
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
        alu_control,
        clk
    );
    
    ALU alu_module(
        input1,
        input2,
        alu_control,
        rd_data
    );


    always_ff @ (posedge clk) begin
        // $display(halted);
        opcode = inst[6:0];
        if (opcode == 'h73) begin
            halted <= 1;
        end
        $display("in core: ", inst_addr);
        if (bool != 1'b0)
        inst_addr <= inst_addr + 4;
        bool = !bool;
    end

    always_comb begin
    // always @(posedge clk) begin
        $display("in combinational: ", inst);
        case(opcode)
        'h33: begin
            input2 = rs2_data;
            input1 = rs1_data;
        end
        'h13: begin
            input2 = immSmall;
            input1 = rs1_data;
        end
        default: begin
            input1 = 0;
            input2 = 0;
        end
        endcase
        // $display(input1);
        // $display(input2);
    end

endmodule
