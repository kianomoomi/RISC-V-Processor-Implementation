/*
ALU Control lines | Function
-----------------------------
            0000    AND
            0001    shift left (logical)
            0010	Add (A+B)
            0011    OR
            0100	Subtract (A-B)
            0101	Set less than
            0110    XOR
            0111    set less than unsigned
            1000    shift right (logical)
            1001    shift right (arithmetic)
            1010    Jump and Link Register
            1011    Jump and Link 
            1100    memory store
            1101    memory load
            1110    Add Upper Imm to PC
            
*/

module ALU (
    input [31:0] inp1, 
    input [31:0] inp2, 
    input [3:0] alu_control,
    output reg [31:0] alu_result,
    input [2:0] funct3,
    output reg [31:0] mem_addr,
    output reg mem_write_en,
    input [7:0] mem_data_out [0:3],
    output [7:0] mem_data_in [0:3],
    input [31:0] inpin,
    input [31:0] inst_addr_inp
);

reg [31:0] temp_result;

always_comb begin
    
    mem_write_en = 0;
    
    case(alu_control)
    4'b0000: alu_result = inp1 & inp2;
    4'b0001: alu_result = inp1 << inp2;
    4'b0010: alu_result = inp1 + inp2;
    4'b0011: alu_result = inp1 | inp2;
    4'b0100: alu_result = inp1 - inp2;
    4'b0101: begin
         alu_result = (inp1[31] == inp2[31]) ? {{31{1'b0}}, inp1 < inp2} :
                      (inp1[31] == 0 && inp2[31] == 1) ? {32{1'b0}} :
                      {{31{1'b0}}, 1'b1};
    end
    4'b0110: alu_result = inp1 ^ inp2;
    // 4'b0111: alu_result = 
    4'b0111:begin
       alu_result =  {{31{1'b0}}, inp1 < inp2};
    end
    4'b1000: alu_result = inp1 >> inp2;
    4'b1001: alu_result = $signed(inp1) >>> $signed(inp2);
    4'b1100: begin
        mem_write_en = 1'b1;
        mem_addr = inp1 + inp2;
        case(funct3)
            0: begin
                mem_data_in[0] = inpin[7:0];
                mem_data_in[1] = mem_data_out[1];
                mem_data_in[2] = mem_data_out[2];
                mem_data_in[3] = mem_data_out[3];
            end
            1: begin
                mem_data_in[0] = inpin[7:0];
                mem_data_in[1] = inpin[15:8];
                mem_data_in[2] = mem_data_out[2];
                mem_data_in[3] = mem_data_out[3];
            end
            2: begin
                mem_data_in[0] = inpin[7:0];
                mem_data_in[1] = inpin[15:8];
                mem_data_in[2] = inpin[23:16];
                mem_data_in[3] = inpin[31:24];
            end
        endcase
    end
    4'b1101: begin
        mem_addr = inp1 + inp2;
        case(funct3)
            0: begin
                alu_result = {{24{mem_data_out[0][7]}}, mem_data_out[0]};
            end
            1: begin
                alu_result = {{16{mem_data_out[1][7]}}, mem_data_out[1], mem_data_out[0]};
            end
            2: begin
                alu_result = {mem_data_out[3], mem_data_out[2], mem_data_out[1], mem_data_out[0]};
            end
            4: begin
                alu_result = {{24{1'b0}}, mem_data_out[0]};
            end
            5: begin
                alu_result = {{16{1'b0}}, mem_data_out[1], mem_data_out[0]};
            end
        endcase
    end
    4'b1010: begin
        alu_result = inst_addr_inp + 4;
    end
    4'b1011: begin
        alu_result = inst_addr_inp + 4;
    end
    4'b1110: begin
        alu_result = inst_addr_inp + inp1;
    end
    default: alu_result = inp1;
endcase

end

endmodule