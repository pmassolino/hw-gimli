/*--------------------------------------------------------------------------------*/
/* Implementation by Pedro Maat C. Massolino,                                     */
/* hereby denoted as "the implementer".                                           */
/*                                                                                */
/* To the extent possible under law, the implementer has waived all copyright     */
/* and related or neighboring rights to the source code in this file.             */
/* http://creativecommons.org/publicdomain/zero/1.0/                              */
/*--------------------------------------------------------------------------------*/
`default_nettype    none

/* verilator lint_off UNOPTFLAT */

module gimli_permutation_rounds_combinational
#(
    parameter COMBINATIONAL_ROUNDS = 1
)
(
    input wire [383:0] state,
    input wire [4:0] round,
    output wire [383:0] new_state,
    output wire [4:0] new_round,
    output wire last_round
);

wire [383:0] temp_state[0:COMBINATIONAL_ROUNDS - 1];
wire [4:0] temp_round[0:COMBINATIONAL_ROUNDS - 1];
wire [383:0] temp_state_after_non_linear[0:COMBINATIONAL_ROUNDS - 1];
reg [383:0] temp_new_state[0:COMBINATIONAL_ROUNDS - 1];
wire [4:0] temp_new_round[0:COMBINATIONAL_ROUNDS - 1];
reg reg_last_round;

localparam round_base_constant = 32'h9E377900;

assign temp_state[0] = state;

generate
    if(COMBINATIONAL_ROUNDS % 4 == 0) begin: optimize_for_multiples_4
        assign temp_round[0] = {round[4:2], 2'b00};
    end else if(COMBINATIONAL_ROUNDS % 4 == 2) begin: optimize_for_multiples_2
        assign temp_round[0] = {round[4:1], 1'b0};
    end else begin: no_optimization
        assign temp_round[0] = round;
    end 
endgenerate

generate
    genvar gen_i;
    for (gen_i = 0; gen_i < COMBINATIONAL_ROUNDS; gen_i = gen_i + 1) begin: all_rounds
        if(gen_i > 0) begin : input_state_from_previous
            assign temp_state[gen_i] = temp_new_state[gen_i - 1];
            assign temp_round[gen_i] = temp_new_round[gen_i - 1];
        end
        
        gimli_all_columns_non_linear_permutation
        gimli_round_I (
            .state(temp_state[gen_i]),
            .new_state(temp_state_after_non_linear[gen_i])
        );
        
        always @(*) begin
            // Apply small swap
            if(temp_round[gen_i][1:0] == 2'b00) begin
                temp_new_state[gen_i][(1*32-1):0*32]  = temp_state_after_non_linear[gen_i][2*32-1:1*32] ^ ({round_base_constant[31:8], 3'b000, temp_round[gen_i]});
                temp_new_state[gen_i][(2*32-1):1*32]  = temp_state_after_non_linear[gen_i][1*32-1:0*32];
                temp_new_state[gen_i][(3*32-1):2*32]  = temp_state_after_non_linear[gen_i][4*32-1:3*32];
                temp_new_state[gen_i][(4*32-1):3*32]  = temp_state_after_non_linear[gen_i][3*32-1:2*32];
                temp_new_state[gen_i][(12*32-1):4*32] = temp_state_after_non_linear[gen_i][12*32-1:4*32];
            // Apply big swap
            end else if(temp_round[gen_i][1:0] == 2'b10) begin
                temp_new_state[gen_i][(1*32-1):0*32]  = temp_state_after_non_linear[gen_i][3*32-1:2*32];
                temp_new_state[gen_i][(2*32-1):1*32]  = temp_state_after_non_linear[gen_i][4*32-1:3*32];
                temp_new_state[gen_i][(3*32-1):2*32]  = temp_state_after_non_linear[gen_i][1*32-1:0*32];
                temp_new_state[gen_i][(4*32-1):3*32]  = temp_state_after_non_linear[gen_i][2*32-1:1*32];
                temp_new_state[gen_i][(12*32-1):4*32] = temp_state_after_non_linear[gen_i][12*32-1:4*32];
            // Only non linear part
            end else begin
                temp_new_state[gen_i] = temp_state_after_non_linear[gen_i];
            end
        end
        
        assign temp_new_round[gen_i] = temp_round[gen_i] - 1;
        
    end
endgenerate

/* verilator lint_off WIDTH */

always @(*) begin
    if(round == COMBINATIONAL_ROUNDS) begin
        reg_last_round = 1'b1;
    end else begin
        reg_last_round = 1'b0;
    end
end

/* verilator lint_on WIDTH */

assign new_state = temp_new_state[COMBINATIONAL_ROUNDS - 1];
assign new_round = temp_new_round[COMBINATIONAL_ROUNDS - 1];
assign last_round = reg_last_round;

endmodule

/* verilator lint_on UNOPTFLAT */