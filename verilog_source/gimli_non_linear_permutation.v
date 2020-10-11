/*--------------------------------------------------------------------------------*/
/* Implementation by Pedro Maat C. Massolino,                                     */
/* hereby denoted as "the implementer".                                           */
/*                                                                                */
/* To the extent possible under law, the implementer has waived all copyright     */
/* and related or neighboring rights to the source code in this file.             */
/* http://creativecommons.org/publicdomain/zero/1.0/                              */
/*--------------------------------------------------------------------------------*/
`default_nettype    none

module gimli_non_linear_permutation
(
    input wire [31:0] x,
    input wire [31:0] y,
    input wire [31:0] z,
    output wire [31:0] new_x,
    output wire [31:0] new_y,
    output wire [31:0] new_z
);

wire [31:0] temp_x1;
wire [31:0] temp_y1;
wire [31:0] temp_z1;

wire [31:0] temp_x2;
wire [31:0] temp_y2;
wire [31:0] temp_z2;

assign temp_x1 = {x[7:0], x[31:8]};
assign temp_y1 = {y[22:0], y[31:23]};
assign temp_z1 = z[31:0];

assign temp_x2 = {temp_y1[29:0] & temp_z1[29:0], 2'b00};

assign new_z = temp_x1 ^ {temp_z1[30:0], 1'b0} ^ temp_x2;

assign temp_y2 = {temp_x1[30:0] | temp_z1[30:0], 1'b0};

assign new_y = temp_y1 ^ temp_x1 ^ temp_y2;

assign temp_z2 = {temp_x1[28:0] & temp_y1[28:0], 3'b000};

assign new_x = temp_z1 ^ temp_y1 ^ temp_z2;

endmodule