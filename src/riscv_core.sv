`include "ALU.sv"


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
    output  [31:0] inst_addr;
    input   [31:0] inst;
    output  [31:0] mem_addr;
    input   [7:0]  mem_data_out[0:3];
    output  [7:0]  mem_data_in[0:3];
    output         mem_write_en;
    output reg     halted;
    input          clk;
    input          rst_b;

    reg [31:0] instAddr;
    reg [31:0] result;
    reg halt;

    reg [6:0] opcode;
    reg [2:0] func3;
    reg [6:0] func7;
    reg [4:0] rs1_num;
    wire [31:0] rs1_data;
    reg [4:0] rs2_num;
    wire [31:0] rs2_data;
    reg [4:0] rd_num;
    reg [31:0] rd_data;
    reg [31:0] immSmall;
    reg rd_we;

    regfile r(
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .rs1_num(inst[19:15]),
    .rs2_num(inst[24:20]),
    .rd_num(inst[11:7]),
    // .rs1_num(rs1_num),
    // .rs2_num(rs2_num),
    // .rd_num(rd_num),
    .rd_data(rd_data),
    .rd_we(1'b1),
    .clk(clk),
    .rst_b(rst_b),
    .halted(halted)
    );













    // always_ff @(posedge clk, negedge rst_b) begin
    //     if (rst_b == 0) begin
    //         halt <= 0;
    //     end
    //     else begin
    //         opcode <= inst[6:0];
            
    //         // ecall
    //         if (opcode == 'h73) begin
    //             halt <= 1;
    //         end

    //         // i-type
    //         else if (opcode == 'h13) begin
    //             func3 <= inst[14:12];
    //             immSmall[11:0] <= inst[31:20];
    //             // rs1_num <= inst[19:15];
    //             // rd_num <= inst[11:7];
    //             if (func3 == 0) begin
    //                 if (immSmall >= 2048) begin
    //                     rd_data = rs1_data - (4096 - immSmall);
    //                 end
    //                 else begin
    //                     rd_data = rs1_data + immSmall;
    //                 end
    //             end
    //             instAddr <= instAddr + 4;
    //         end

    //         // r-type
    //         else if (opcode == 'h33) begin
    //             func3 <= inst[14:12];
    //             func7 <= inst[31:25];
    //             rs1_num <= inst[19:15];
    //             rs2_num <= inst[24:20];
    //             rd_num <= inst[11:7];
    //             if (func3 == 0 && func7 == 0) begin
    //                 rd_data = rs1_data + rs2_data;
    //             end
                
    //             instAddr <= instAddr + 4;
    //         end 
        
    //     end

    // end

    // // assign rd_data = (opcode == 'h13 && func3 == 0) ? ((immSmall >= 2048) ? (rs1_data - (4096 - immSmall)) : rs1_data + immSmall) : 0;

    // assign inst_addr = instAddr;
    // assign halted = (halt == 1);
endmodule
