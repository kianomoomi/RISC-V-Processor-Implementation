/*
ALU Control lines | Function
-----------------------------
            0000    Bitwise-AND
            0001    Bitwise-OR
            0010	Add (A+B)
            0100	Subtract (A-B)
            1000	Set on less than
            0011    Shift left logical
            0101    Shift right logical
            0110    Multiply
            0111    Bitwise-XOR
*/

module ALU (
    input [31:0] rs1_data, rs2_data, 
    input [3:0] alu_control,
    output reg [31:0] alu_result,
    output reg halted
);

always @(*)
    begin
        // Operating based on control input
        $display(alu_control);
        case(alu_control)

            4'b0000: alu_result = rs1_data&rs2_data;
            4'b0001: alu_result = rs1_data|rs2_data;
            4'b0010: alu_result = rs1_data+rs2_data;
            4'b0100: alu_result = rs1_data-rs2_data;
            4'b1000: begin 
                if(rs1_data<rs2_data)
                alu_result = 1;
                else
                alu_result = 0;
            end
            4'b0011: alu_result = rs1_data<<rs2_data;
            4'b0101: alu_result = rs1_data>>rs2_data;
            4'b0110: alu_result = rs1_data*rs2_data;
            4'b0111: alu_result = rs1_data^rs2_data;
            default: alu_result = rs1_data;

        endcase

        // Setting Zero_flag if ALU_result is zero
        // if (alu_result == 0)
        //     halted = 1'b0;
        // else
        //     halted = 1'b1;
        
    end

endmodule