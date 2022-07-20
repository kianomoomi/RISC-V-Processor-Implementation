module Control_Unit(
    input[31:0] inst,
    // input [31:0] inst_addr,
    output reg [4:0] rs1_num4,
    output reg [4:0] rs2_num4,
    output reg [4:0] rd_num4,
    output reg [31:0] immSmall,
    output reg [3:0] alu_control,
    input clk,
    input rst_b
);
    reg[6:0] opcode;
    reg[2:0] funct3;    
    reg[6:0] funct7;
    reg bool = 1'b0;

    reg [4:0] rd_num;
    reg [4:0] rd_num1;
    reg [4:0] rd_num2;
    reg [4:0] rd_num3;

    dff #(5) rd_num1_dff (
        .d(rd_num),
        .q(rd_num1),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(5) rd_num2_dff (
        .d(rd_num1),
        .q(rd_num2),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(5) rd_num3_dff (
        .d(rd_num2),
        .q(rd_num3),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(5) rd_num4_dff (
        .d(rd_num3),
        .q(rd_num4),
        .clk(clk),
        .rst_b(rst_b)
    );

    reg [4:0] rs1_num;
    reg [4:0] rs1_num1;
    reg [4:0] rs1_num2;
    reg [4:0] rs1_num3;

    dff #(5) rs1_num1_dff (
        .d(rs1_num),
        .q(rs1_num1),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(5) rs1_num2_dff (
        .d(rs1_num1),
        .q(rs1_num2),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(5) rs1_num3_dff (
        .d(rs1_num2),
        .q(rs1_num3),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(5) rs1_num4_dff (
        .d(rs1_num3),
        .q(rs1_num4),
        .clk(clk),
        .rst_b(rst_b)
    );

    reg [4:0] rs2_num;
    reg [4:0] rs2_num1;
    reg [4:0] rs2_num2;
    reg [4:0] rs2_num3;

    dff #(5) rs2_num1_dff (
        .d(rs2_num),
        .q(rs2_num1),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(5) rs2_num2_dff (
        .d(rs2_num1),
        .q(rs2_num2),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(5) rs2_num3_dff (
        .d(rs2_num2),
        .q(rs2_num3),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(5) rs2_num4_dff (
        .d(rs2_num3),
        .q(rs2_num4),
        .clk(clk),
        .rst_b(rst_b)
    );

    always @(posedge clk) begin
        // $display("%h", inst);
        opcode = inst[6:0];
        
        case(opcode)
        'h33: begin
            rs1_num <= inst[19:15];
            rs2_num <= inst[24:20];
            rd_num <= inst[11:7];
            funct3 = inst[14:12];
            funct7 = inst[31:25];

            // add
            if (funct3 == 0 && funct7 == 0) begin
                alu_control <= 4'b0010;
            end
            // sub
            if (funct3 == 0 && funct7 == 32) begin
                alu_control <= 4'b0100;
            end
            // sll
            if (funct3 == 1 && funct7 == 0) begin
                alu_control <= 4'b0001;
            end
            // slt
            if (funct3 == 2 && funct7 == 0) begin
                alu_control <= 4'b0101;
            end
            // sltu
            if (funct3 == 3 && funct7 == 0) begin
                alu_control <= 4'b0111;
            end
            // xor
            if (funct3 == 4 && funct7 == 0) begin
                alu_control <= 4'b0110;
            end
       
        end
        
        'h13: begin
            rs1_num <= inst[19:15];
            rs2_num <= {5{1'b0}};
            rd_num <= inst[11:7];
            funct3 = inst[14:12];
            immSmall <= {{20{inst[31]}}, inst[31:20]};

            // addi
            if (funct3 == 0) begin
                alu_control <= 4'b0010;
            end
            // slli
            if (funct3 == 1) begin
                alu_control <= 4'b0001;
                immSmall <= {{27{1'b0}}, immSmall[4:0]};
            end
            // slti
            if (funct3 == 2) begin
                alu_control <= 4'b0101;
            end
            // sltiu
            if (funct3 == 3) begin
                alu_control <= 4'b0111;
            end
            //xori
            if (funct3 == 4) begin
                alu_control <= 4'b0110;
            end
            //srli
            if (funct3 == 5) begin
                if (immSmall[10] == 0) begin
                    alu_control <= 4'b1000;
                    immSmall <= {{27{1'b0}}, immSmall[4:0]};
                end
            end
            //srai
            if (funct3 == 5) begin
                if (immSmall[10] == 1) begin
                    alu_control <= 4'b1001;
                    immSmall <=  {{27{1'b0}}, immSmall[4:0]};
                end
            end
            //ori
            if (funct3 == 6) begin
                alu_control <= 4'b0011;
            end
            //andi
            if (funct3 == 7) begin
                alu_control <= 4'b0000;
            end


        end

        // load
        'h03: begin
            rs1_num <= inst[19:15];
            rs2_num <= {5{1'b0}};
            rd_num <= inst[11:7];
            funct3 = inst[14:12];
            immSmall <= {{20{inst[31]}}, inst[31:20]};
            alu_control <= 4'b1101;

        end

        // store
        'h23: begin
            rs1_num <= inst[19:15];
            rs2_num <= inst[24:20];
            funct3 = inst[14:12];
            immSmall <= {{20{inst[31]}}, inst[31:25], inst[11:7]};
            alu_control <= 4'b1100;

        end
        
        // branch
        'h63: begin
            rs1_num <= inst[19:15];
            rs2_num <= inst[24:20];
            funct3 = inst[14:12];
            immSmall <= {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], {1{1'b0}}};
            // we assign 1111 to alu_control because registers should'nt change
            alu_control <= 4'b1111;
        end

        // jal
        'h6F: begin
            rd_num <= inst[11:7];
            immSmall <= {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], {1{1'b0}}};
            alu_control <= 4'b1011;
        end

        // load upper immidiate
        'h37: begin
            immSmall <= {inst[31:12], {12{1'b0}}};
            rd_num <= inst[11:7];
            rs1_num <= {5{1'b0}};
            rs2_num <= {5{1'b0}};
            alu_control <= 4'b0010;
        end
        
        // jump and link register
        'h67: begin
            rs1_num <= inst[19:15];
            rs2_num <= {5{1'b0}};
            rd_num <= inst[11:7];
            funct3 = inst[14:12];
            immSmall <= {{20{inst[31]}}, inst[31:20]};
            alu_control <= 4'b1010;
        end

        // add upper immidiate to PC
        'h17: begin
            immSmall <= {inst[31:12], {12{1'b0}}};
            rd_num <= inst[11:7];
            rs1_num <= {5{1'b0}};
            rs2_num <= {5{1'b0}};
            alu_control <= 4'b1110;
        end

        default: begin
            rs1_num <= 0;
            rs2_num <= 0;
            rd_num <= 0;
            immSmall <= 0;
            alu_control <= 4'b1111;

        end
        endcase
    end

endmodule