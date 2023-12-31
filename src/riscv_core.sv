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
    reg interupt_start = 0;
    reg interupt_second = 0;
    reg interupt_stop = 0;

    reg bool2 = 1'b0;

    regfile r(
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rs1_num(rs1_num),
        .rs2_num(rs2_num),
        .rd_num(rd_num3),
        .rd_data(rd_data),
        .rd_we(1'b1),
        .clk(clk),
        .rst_b(rst_b),
        .halted(halted)
    );

    Cache cache (
        .cache_addr(cache_addr),
        .cache_hit(cache_hit),
        .cache_data_out(cache_data_out),
        .cache_data_in(cache_data_in),
        .clk(clk),
        .cache_we(cache_we),
        .rst_b(rst_b),
        .mem_data_in(mem_data_in),
        .mem_data_out(mem_data_out),
        .mem_addr(mem_addr),
        .mem_we(mem_write_en),
        .interupt_start(interupt_start),
        .interupt_second(interupt_second),
        .interupt_stop(interupt_stop),
        .opcode(opcode4),
        .funct3(funct3_buffer4)
    );

    reg [6:0] opcode1;
    reg [6:0] opcode2;
    reg [6:0] opcode3;
    reg [6:0] opcode4;

    reg [2:0] funct3_buffer2;
    reg [2:0] funct3_buffer3;
    reg [2:0] funct3_buffer4;

    dff #(7) opcode_dff1(opcode, opcode1, clk, rst_b);
    dff #(7) opcode_dff2(opcode1, opcode2, clk, rst_b);
    dff #(7) opcode_dff3(opcode2, opcode3, clk, rst_b);
    dff #(7) opcode_dff4(opcode3, opcode4, clk, rst_b);

    dff #(3) funct3_dff1(funct3_buffer, funct3_buffer2, clk, rst_b);
    dff #(3) funct3_dff2(funct3_buffer2, funct3_buffer3, clk, rst_b);
    dff #(3) funct3_dff3(funct3_buffer3, funct3_buffer4, clk, rst_b);
    
    ALU alu_module(
        input1_buffer,
        input2_buffer,
        alu_control_buffer,
        rd_data,
        funct3_buffer,
        cache_addr,
        cache_we,
        cache_data_out,
        cache_data_in,
        inpin_buffer,
        instAddr_buffer5,
        clk,
        rst_b
    );

    reg [31:0] inst_buffer;
    reg [31:0] inst_buffer2;

    dff #(32) IR_dff(
        .d(inst),
        .q(inst_buffer),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(32) IR_dff2(
        .d(inst_buffer),
        .q(inst_buffer2),
        .clk(clk),
        .rst_b(rst_b)
    );

    reg [31:0] instAddr_buffer;
    reg [31:0] instAddr_buffer2;
    reg [31:0] instAddr_buffer3;
    reg [31:0] instAddr_buffer4;
    reg [31:0] instAddr_buffer5;

    dff #(32) IA_dff(
        .d(inst_addr),
        .q(instAddr_buffer),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(32) IA_dff2(
        .d(instAddr_buffer),
        .q(instAddr_buffer2),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(32) IA_dff3(
        .d(instAddr_buffer2),
        .q(instAddr_buffer3),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(32) IA_dff4(
        .d(instAddr_buffer3),
        .q(instAddr_buffer4),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(32) IA_dff5(
        .d(instAddr_buffer4),
        .q(instAddr_buffer5),
        .clk(clk),
        .rst_b(rst_b)
    );

    reg halted1;
    reg halted2;
    reg halted3;
    reg halted4;

    dff #(1) halted1_dff(
        .d(halted1),
        .q(halted2),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(1) halted2_dff(
        .d(halted2),
        .q(halted3),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(1) halted3_dff(
        .d(halted3),
        .q(halted4),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(1) halted4_dff(
        .d(halted4),
        .q(halted),
        .clk(clk),
        .rst_b(rst_b)
    );

    reg [4:0] rd_num1;
    reg [4:0] rd_num2;
    reg [4:0] rd_num3;

    dff #(5) rd_num1_dff(
        .d(rd_num),
        .q(rd_num1),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(5) rd_num2_dff(
        .d(rd_num1),
        .q(rd_num2),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(5) rd_num3_dff(
        .d(rd_num2),
        .q(rd_num3),
        .clk(clk),
        .rst_b(rst_b)
    );

    reg [31:0] forward = 4;
    reg [2:0] counter = 0;

    reg boolSW1 = 1'b0;
    reg boolSW2 = 1'b0;
    reg boolSW3 = 1'b0;
    reg boolSW4 = 1'b0;
    reg boolSW5 = 1'b0;
    reg boolSW6 = 1'b0;

    reg boolCopy = 1'b0;
    reg [31:0] inst_copy = 0; 

    always_ff @(posedge clk) begin

        // boolSW here is for Store instruction
        if (inst[6:0] == 7'h23 && boolSW1 == 1'b0 && boolSW2 == 1'b0 && boolSW3 == 1'b0 && boolSW4 == 1'b0 && boolSW5 == 1'b0 && boolSW6 == 1'b0 ) begin
            forward = 0;
            boolSW1 = 1'b1;
        end
        else if (inst[6:0] == 7'h23 && boolSW1 == 1'b1 && boolSW2 == 1'b0 && boolSW3 == 1'b0 && boolSW4 == 1'b0 && boolSW5 == 1'b0 && boolSW6 == 1'b0 ) begin
            boolSW2 = 1'b1;
            forward = 0;
        end
        else if (inst[6:0] == 7'h23 && boolSW1 == 1'b1 && boolSW2 == 1'b1 && boolSW3 == 1'b0 && boolSW4 == 1'b0 && boolSW5 == 1'b0 && boolSW6 == 1'b0 ) begin
            boolSW3 = 1'b1;
            forward = 0;
        end
        else if (inst[6:0] == 7'h23 && boolSW1 == 1'b1 && boolSW2 == 1'b1 && boolSW3 == 1'b1 && boolSW4 == 1'b0 && boolSW5 == 1'b0 && boolSW6 == 1'b0 ) begin
            boolSW4 = 1'b1;
            forward = 0;
        end
        else if (inst[6:0] == 7'h23 && boolSW1 == 1'b1 && boolSW2 == 1'b1 && boolSW3 == 1'b1 && boolSW4 == 1'b1 && boolSW5 == 1'b0 && boolSW6 == 1'b0 ) begin
            boolSW5 = 1'b1;
            forward = 0;
        end
        else if (inst[6:0] == 7'h23 && boolSW1 == 1'b1 && boolSW2 == 1'b1 && boolSW3 == 1'b1 && boolSW4 == 1'b1 && boolSW5 == 1'b1 && boolSW6 == 1'b0 ) begin
            boolSW6 = 1'b1;
            forward = 0;
        end
        else if (inst[6:0] == 7'h23 && boolSW1 == 1'b1 && boolSW2 == 1'b1 && boolSW3 == 1'b1 && boolSW4 == 1'b1 && boolSW5 == 1'b1 && boolSW6 == 1'b1 ) begin
            boolSW1 = 1'b0;
            boolSW2 = 1'b0;
            boolSW3 = 1'b0;
            boolSW4 = 1'b0;
            boolSW5 = 1'b0;
            boolSW6 = 1'b0;
            forward = 4;
        end

        // boolSW here is for Load instruction
        if (inst[6:0] == 7'h03 && boolSW1 == 1'b0 && boolSW2 == 1'b0 && boolSW3 == 1'b0 && boolSW4 == 1'b0 ) begin
            forward = 0;
            boolSW1 = 1'b1;
        end
        else if (inst[6:0] == 7'h03 && boolSW1 == 1'b1 && boolSW2 == 1'b0 && boolSW3 == 1'b0 && boolSW4 == 1'b0 ) begin
            boolSW2 = 1'b1;
            forward = 0;
        end
        else if (inst[6:0] == 7'h03 && boolSW1 == 1'b1 && boolSW2 == 1'b1 && boolSW3 == 1'b0 && boolSW4 == 1'b0 ) begin
            boolSW3 = 1'b1;
            forward = 0;
        end
        else if (inst[6:0] == 7'h03 && boolSW1 == 1'b1 && boolSW2 == 1'b1 && boolSW3 == 1'b1 && boolSW4 == 1'b0 ) begin
            boolSW4 = 1'b1;
            forward = 0;
        end
        else if (inst[6:0] == 7'h03 && boolSW1 == 1'b1 && boolSW2 == 1'b1 && boolSW3 == 1'b1 && boolSW4 == 1'b1 ) begin
            boolSW1 = 1'b0;
            boolSW2 = 1'b0;
            boolSW3 = 1'b0;
            boolSW4 = 1'b0;
            forward = 4;
        end

        if (opcode == 'h73) begin
            halted1 <= 1;
        end

        if (boolCopy == 1'b0) begin
            inst_copy = inst;
            boolCopy = 1'b1;
        end

        if (inst_copy[6:0] == 'h33 || inst_copy[6:0] == 'h13) begin
            inst_addr += 'd256;
            $display("addr: %h", inst_addr);
            $display("inst: %h", inst);
            forward = 0;
            counter <= counter + 1;
            if (counter == 4) begin
                counter <= 0;
                inst_addr -= 'd1024;
                forward = 4;
                boolCopy = 1'b0;
            end
        end
        if (interupt_start == 1) begin
            counter <= counter + 1;
            interupt_stop <= 0;
            if (counter == 4) begin
                interupt_stop <= 1;
                counter <= 0;
            end
        end
        else if (interupt_second == 1) begin
            counter <= counter + 1;
            interupt_stop <= 0;
            if (counter == 4) begin
                interupt_stop <= 1;
                counter <= 0;
            end
        end
        else begin
        // if (bool != 1'b0) begin 
            if ((opcode == 7'h23 || opcode == 7'h03) && bool2==1'b0) begin
                inst_addr = inst_addr;
                bool2 <= 1'b1;
            end
            else begin
                inst_addr = inst_addr + forward;
                bool2 <= 1'b0;
            end
        // end
        bool = 1'b1;
       
        end
    end

    reg [31:0] input1_buffer;
    reg [31:0] input2_buffer;
    reg [31:0] inpin_buffer;
    reg [3:0] alu_control_buffer;
    reg [2:0] funct3_buffer;

    dff #(32) input1_dff(
        .d(input1),
        .q(input1_buffer),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(32) input2_dff (
        .d(input2),
        .q(input2_buffer),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(32) inpin_dff (
        .d(inpin),
        .q(inpin_buffer),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(4) alu_control_dff (
        .d(alu_control),
        .q(alu_control_buffer),
        .clk(clk),
        .rst_b(rst_b)
    );

    dff #(3) funct3_dff (
        .d(funct3),
        .q(funct3_buffer),
        .clk(clk),
        .rst_b(rst_b)
    );

    always_ff @(posedge clk) begin
        opcode = inst_buffer2[6:0];
        funct3 <= inst_buffer2[14:12];
        forward = 4;
        case(opcode)

        'h33: begin
            // rs1_num = inst_buffer[19:15];
            // rs2_num = inst_buffer[24:20];
            rd_num = inst_buffer2[11:7];
            funct3 <= inst_buffer2[14:12];
            funct7 = inst_buffer2[31:25];
                   
            input1 = rs1_data;
            input2 = rs2_data;
            // add
            if (inst_buffer2[14:12] == 0 && funct7 == 0) begin
                alu_control <= 4'b0010;
            end
            // sub
            if (inst_buffer2[14:12] == 0 && funct7 == 32) begin
                alu_control <= 4'b0100;
            end
            // sll
            if (inst_buffer2[14:12] == 1 && funct7 == 0) begin
                alu_control <= 4'b0001;
            end
            // slt
            if (inst_buffer2[14:12] == 2 && funct7 == 0) begin
                alu_control <= 4'b0101;
            end
            // sltu
            if (inst_buffer2[14:12] == 3 && funct7 == 0) begin
                alu_control <= 4'b0111;
            end
            // xor
            if (inst_buffer2[14:12] == 4 && funct7 == 0) begin
                alu_control <= 4'b0110;
            end
        end
        
        'h13: begin
            // rs1_num = inst_buffer[19:15];
            // rs2_num = {5{1'b0}};
            rd_num = inst_buffer2[11:7];
            funct3 <= inst_buffer2[14:12];
            immSmall = {{20{inst_buffer2[31]}}, inst_buffer2[31:20]};
            input1 = rs1_data;
            input2 = immSmall;

            // addi
            if (inst_buffer2[14:12] == 0) begin
                alu_control <= 4'b0010;
            end
            // slli
            if (inst_buffer2[14:12] == 1) begin
                alu_control <= 4'b0001;
                immSmall = {{27{1'b0}}, immSmall[4:0]};
                input2 = immSmall;
            end
            // slti
            if (inst_buffer2[14:12] == 2) begin
                alu_control <= 4'b0101;
            end
            // sltiu
            if (inst_buffer2[14:12] == 3) begin
                alu_control <= 4'b0111;
            end
            //xori
            if (inst_buffer2[14:12] == 4) begin
                alu_control <= 4'b0110;
            end
            //srli
            if (inst_buffer2[14:12] == 5) begin
                if (immSmall[10] == 0) begin
                    alu_control <= 4'b1000;
                    immSmall = {{27{1'b0}}, immSmall[4:0]};
                    input2 = immSmall;
                end
            end
            //srai
            if (inst_buffer2[14:12] == 5) begin
                if (immSmall[10] == 1) begin
                    alu_control <= 4'b1001;
                    immSmall = {{27{1'b0}}, immSmall[4:0]};
                    input2 = immSmall;
                end
            end
            //ori
            if (inst_buffer2[14:12] == 6) begin
                alu_control <= 4'b0011;
            end
            //andi
            if (inst_buffer2[14:12] == 7) begin
                alu_control <= 4'b0000;
            end
        end
        
        'h37: begin
            immSmall = {inst_buffer2[31:12], {12{1'b0}}};
            rd_num = inst_buffer2[11:7];
            alu_control <= 4'b0010;
            
            input1 = rs1_data;
            input2 = immSmall;
        end
        
        'h17: begin
            immSmall = {inst_buffer2[31:12], {12{1'b0}}};
            rd_num = inst_buffer2[11:7];
            alu_control <= 4'b1110;

            input1 = immSmall;
        end
        
        // load
        'h03: begin
            rd_num = inst_buffer2[11:7];
            funct3 <= inst_buffer2[14:12];
            immSmall = {{20{inst_buffer2[31]}}, inst_buffer2[31:20]};
            alu_control <= 4'b1101;

            input1 = rs1_data;
            input2 = immSmall;
        end
        
        // store
        'h23: begin
            funct3 <= inst_buffer2[14:12];
            immSmall = {{20{inst_buffer2[31]}}, inst_buffer2[31:25], inst_buffer2[11:7]};
            alu_control <= 4'b1100;

            input1 = rs1_data;
            input2 = immSmall;
            inpin = rs2_data;
            rd_num = 0;
        end

        'h63: begin
            funct3 <= inst_buffer2[14:12];
            immSmall = {{19{inst_buffer2[31]}}, inst_buffer2[31], inst_buffer2[7], inst_buffer2[30:25], inst_buffer2[11:8], {1{1'b0}}};
            // we assign 1111 to alu_control because registers should'nt change
            alu_control <= 4'b1111;
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
        default: begin
            input1 = 0;
            input2 = 0;
        end
        endcase
    end

    always_ff @(posedge clk) begin
        opcode = inst_buffer[6:0];
        funct3 <= inst_buffer[14:12];
        forward = 4;
        case(opcode)

        'h33: begin
            rs1_num = inst_buffer[19:15];
            rs2_num = inst_buffer[24:20];
        end
        
        'h13: begin
            rs1_num = inst_buffer[19:15];
            rs2_num = {5{1'b0}};
        end
        
        'h37: begin
            rs1_num = {5{1'b0}};
            rs2_num = {5{1'b0}};
        end
        
        'h17: begin
            rs1_num = {5{1'b0}};
            rs2_num = {5{1'b0}};
        end
        
        // load
        'h03: begin
            rs1_num = inst_buffer[19:15];
            rs2_num = {5{1'b0}};
        end
        
        // store
        'h23: begin
            rs1_num = inst_buffer[19:15];
            rs2_num = inst_buffer[24:20];

            // rd_num <= 0;
        end

        'h63: begin
            rs1_num = inst_buffer[19:15];
            rs2_num = inst_buffer[24:20];
        end
        
        'h67: begin
            input1 = rs1_data;
            input2 = immSmall;
            forward = ((rs1_data+immSmall) & (-2)) - inst_addr;
        end
        
        'h6F: begin
            forward = immSmall;
        end       
        default: begin
            input1 = 0;
            input2 = 0;
        end
        endcase
    end

endmodule
