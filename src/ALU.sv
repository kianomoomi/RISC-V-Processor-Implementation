/*
ALU Control lines | Function
-----------------------------
            0001    shift left (logical)
            0010	Add (A+B)
            0100	Subtract (A-B)
            0101	Set on less than
            0110    XOR
*/

module ALU (
    input [31:0] inp1, 
    input [31:0] inp2, 
    input [3:0] alu_control,
    output reg [31:0] alu_result
);

always_comb begin
    $display("in ALU: ", inp1, " + ", inp2);

    case(alu_control)
    4'b0001: alu_result = inp1 << inp2;
    4'b0010: alu_result = inp1 + inp2;
    4'b0100: alu_result = inp1 - inp2;
    4'b0101: alu_result = inp1 < inp2;
    4'b0110: alu_result = inp1 ^ inp2;
    default: alu_result = inp1;
endcase
end

endmodule