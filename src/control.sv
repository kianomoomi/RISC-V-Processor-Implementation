module control(
    input[31:0] inst,
    output reg [4:0] rs1_num,
    output reg [4:0] rs2_num,
    output reg [4:0] rd_num,
    output reg [31:0] immSmall,
    output reg [3:0] alu_control
);
    reg[6:0] opcode;
    reg[2:0] funct3;
    reg[6:0] funct7;


    always @(inst) begin
        // $display("%h", inst);
        opcode = inst[6:0];
        case(opcode)
        'h33: begin
            rs1_num = inst[19:15];
            rs2_num = inst[24:20];
            rd_num = inst[11:7];
            funct3 = inst[14:12];
            funct7 = inst[31:25];
            if (funct3 == 0 && funct7 == 0) begin
                alu_control = 4'b0010;
            end
            if (funct3 == 0 && funct7 == 32) begin
                alu_control = 4'b0100;
            end
        end
        'h13: begin
            rs1_num = inst[19:15];
            rs2_num = inst[24:20];
            rd_num = inst[11:7];
            funct3 = inst[14:12];
            funct7 = inst[31:25];
            immSmall = {{20{inst[31]}}, inst[31:20]};
            if (funct3 == 0) begin
                alu_control = 4'b0010;
            end
        end
        default: begin
            rs1_num = 0;
            rs2_num = 0;
            rd_num = 0;
            immSmall = 0;
            alu_control = 4'b1111;

        end
    endcase
    end


endmodule