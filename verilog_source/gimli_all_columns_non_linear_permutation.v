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

module gimli_all_columns_non_linear_permutation
(
    input wire [383:0] state,
    output wire [383:0] new_state
);

generate
    genvar gen_i;
    for (gen_i = 0; gen_i < 4; gen_i = gen_i + 1) begin: all_columns

    gimli_non_linear_permutation
    gimli_i(
        .x(state[(((gen_i + 1)*32) - 1):((gen_i + 0)*32)]),
        .y(state[(((gen_i + 5)*32) - 1):((gen_i + 4)*32)]),
        .z(state[(((gen_i + 9)*32) - 1):((gen_i + 8)*32)]),
        .new_x(new_state[(((gen_i + 1)*32) - 1):((gen_i + 0)*32)]),
        .new_y(new_state[(((gen_i + 5)*32) - 1):((gen_i + 4)*32)]),
        .new_z(new_state[(((gen_i + 9)*32) - 1):((gen_i + 8)*32)])
    );
    end
endgenerate

endmodule

/* verilator lint_on UNOPTFLAT */