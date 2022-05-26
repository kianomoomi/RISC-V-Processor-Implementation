module control(
    input[31:0] inst,
    input [31:0] inst_addr,
    output reg [4:0] rs1_num,
    output reg [4:0] rs2_num,
    output reg [4:0] rd_num,
    output reg [31:0] immSmall,
    output reg [3:0] alu_control,
    // input clk,
    output reg is_unsigned
    // input [31:0] rs1_data,
    // input [31:0] rs2_data
);
    reg[6:0] opcode;
    reg[2:0] funct3;
    reg[6:0] funct7;
    reg bool = 1'b0;

    // always @(posedge clk) begin
    always @(inst) begin
        // $display("%h", inst);
        //  if(bool == 1'b0)
        //  begin
            // $display("in control: ", inst);
        opcode = inst[6:0];
        case(opcode)
        'h33: begin
            rs1_num = inst[19:15];
            rs2_num = inst[24:20];
            $display("rs1_num control", rs1_num);
            $display("rs2_num control", rs2_num); 
            // $display("rs1_data control", rs1_data); 
            // $display("rs2_data control", rs2_data); 
            rd_num = inst[11:7];
            funct3 = inst[14:12];
            funct7 = inst[31:25];

            // add
            if (funct3 == 0 && funct7 == 0) begin
                alu_control = 4'b0010;
            end
            // sub
            if (funct3 == 0 && funct7 == 32) begin
                alu_control = 4'b0100;
            end
            // sll
            if (funct3 == 1 && funct7 == 0) begin
                alu_control = 4'b0001;
            end
            // slt
            if (funct3 == 2 && funct7 == 0) begin
                alu_control = 4'b0101;
            end
            // sltu
            if (funct3 == 3 && funct7 == 0) begin
                alu_control = 4'b0101;
                is_unsigned = 1'b1;
            end
            // xor
            if (funct3 == 4 && funct7 == 0) begin
                alu_control = 4'b0110;
            end
       
        end
        'h13: begin
            rs1_num = inst[19:15];
            rs2_num = {5{1'b0}};
            rd_num = inst[11:7];
            funct3 = inst[14:12];
            // funct7 = inst[31:25];
            immSmall = {{20{inst[31]}}, inst[31:20]};

            // addi
            if (funct3 == 0) begin
                alu_control = 4'b0010;
            end
            // slli
            if (funct3 == 1) begin
                alu_control = 4'b0001;
                immSmall = {{27{1'b0}}, immSmall[4:0]};
            end
            // slti
            if (funct3 == 2) begin
                alu_control = 4'b0101;
            end
            // sltiu
            if (funct3 == 3) begin
                alu_control = 4'b0101;
                is_unsigned = 1'b1;
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
        //  bool = !bool;
        
    // end


endmodule