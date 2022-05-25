module ALU (
    input [31:0] inp1, 
    input [31:0] inp2, 
    input [3:0] alu_control,
    output reg [31:0] alu_result
);

always_comb begin
    case(alu_control)
    4'b0010: alu_result = inp1 + inp2;
    4'b0100: alu_result = inp1 - inp2;
    default: alu_result = inp1;
endcase
end

endmodule