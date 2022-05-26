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
            


*/

module ALU (
    input [31:0] inp1, 
    input [31:0] inp2, 
    input [3:0] alu_control,
    output reg [31:0] alu_result
);

always_comb begin

    $display("input1: ", inp1);
    $display("input2: ", inp2);

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
       $display("alu :" , inp1<inp2);

    end
    4'b1000: alu_result = inp1 >> inp2;
    4'b1001: alu_result = $signed(inp1) >>> $signed(inp2);
    default: alu_result = inp1;
endcase

end

endmodule