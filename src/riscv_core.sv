
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

    reg [6:0] opcode;
    reg [2:0] func3;
    reg [4:0] rs1_num;
    reg [31:0] rs1_data;
    reg [4:0] rs2_num;
    reg [31:0] rs2_data;
    reg [4:0] rd_num;
    reg [31:0] rd_data;
    reg [31:0] immSmall;

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

    always_ff @(posedge clk, negedge rst_b) begin
        if (rst_b == 0) begin
            halted <= 0;
        end
        else begin
            opcode = inst[6:0];
            $display("%h", opcode);
            $display("%h", inst);
            if (opcode == 'h73) begin
                halted <= 1;
            end
            else if (opcode == 'h13) begin
                func3 = inst[14:12];
                immSmall[11:0] = inst[31:20];
                rs1_num = inst[19:15];
                rd_num = inst[11:7];
                if (func3 == 0) begin
                    rd_data = rs1_data + immSmall;
                    halted <= 1;
                end
            end

        end

    end


endmodule
