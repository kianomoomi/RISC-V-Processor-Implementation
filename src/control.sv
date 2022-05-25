module control(
    // input [6:0] funct7,
    // input [2:0] funct3,
    // input [6:0] opcode,
    // output reg [3:0] alu_control,
    // output reg regwrite_control,
    // output halted
    input[31:0] inst,
    output reg [4:0] rs1_num,
    output reg [4:0] rs2_num,
    output reg [4:0] rd_num,
    output reg [31:0] immSmall,
    output reg [3:0] alu_control
);
    //     always_ff @*
    //     begin
    //     if (opcode == 7'h33) begin // R-type instructions

    //         regwrite_control = 1;

    //         case (funct3)
    //             0: begin
    //                 if(funct7 == 0)
    //                 alu_control = 4'b0010; // ADD
    //                 else if(funct7 == 32)
    //                 alu_control = 4'b0100; // SUB
    //             end
    //             6: alu_control = 4'b0001; // OR
    //             7: alu_control = 4'b0000; // AND
    //             1: alu_control = 4'b0011; // SLL
    //             5: alu_control = 4'b0101; // SRL
	// 			2: alu_control = 4'b0110; // MUL
	// 			4: alu_control = 4'b0111; // XOR
    //         endcase

    //   end

    //   else if (opcode == 7'h13) begin // I type first
    //         regwrite_control = 1;
    //         case(funct3)
    //         0: begin
    //             alu_control = 4'b0010;
    //         end

    //         endcase

    //   end
    //   else if (opcode == 7'h03) begin // I type second
          
    //   end
    //   else if (opcode == 7'h67) begin // I type third
          
    //   end
    //     end
    reg[6:0] opcode;
    reg[2:0] funct3;
    reg[6:0] funct7;

    // always @ (inst) begin
    //     opcode = inst[6:0];
    //     if (opcode == 'h33) begin
    //         rs1_num = inst[19:15];
    //         rs2_num = inst[24:20];
    //         rd_num = inst[11:7];
    //         funct3 = inst[14:12];
    //         funct7 = inst[31:25];
    //         if (funct3 == 0) begin
    //             if (funct7 == 0) begin
    //                 alu_control = 4'b0010;
    //             end
    //             else if (funct7 == 32) begin
    //                 alu_control = 4'b0100;
    //             end
    //         end
            
    //     end
    //     else if (opcode == 'h13) begin
    //         rs1_num = inst[19:15];
    //         rd_num = inst[11:7];
    //         funct3 = inst[14:12];
    //         immSmall = {{20{inst[31]}}, inst[31:20]};
    //         if (funct3 == 0) begin
    //             alu_control = 4'b0010; 
    //         end
    //     end
    //     else begin
    //         rs1_num = 0;
    //         rs2_num = 0;
    //         rd_num = 0;
    //         immSmall = 0;
    //         alu_control = 4'b1111;
    //     end
    // end

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