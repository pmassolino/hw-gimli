/*--------------------------------------------------------------------------------*/
/* Implementation by Pedro Maat C. Massolino,                                     */
/* hereby denoted as "the implementer".                                           */
/*                                                                                */
/* To the extent possible under law, the implementer has waived all copyright     */
/* and related or neighboring rights to the source code in this file.             */
/* http://creativecommons.org/publicdomain/zero/1.0/                              */
/*--------------------------------------------------------------------------------*/
`default_nettype    none

module gimli_rounds_simple
#(parameter ASYNC_RSTN = 0,// 0 - Synchronous reset in high, 1 - Asynchrouns reset in low.
parameter COMBINATIONAL_ROUNDS = 12 // The number of unrolled rounds in the Gimli permutation (Values allowed : 1,2,3,4,6,8,12)
)
(
    input wire clk,
    input wire arstn,
    input wire [2:0] oper,
    input wire [127:0] din,
    input wire [4:0] din_size,
    input wire din_valid,
    output wire din_ready,
    output wire [127:0] dout,
    output wire dout_valid,
    input wire dout_ready,
    output wire [4:0] dout_size
);

reg int_din_ready;
wire int_dout_valid;

reg [127:0] din_padding;
reg [127:0] din_mask;
wire [127:0] din_masked;
wire [127:0] din_padding_xor_state;
wire [127:0] din_xor_state_masked;
wire [127:0] din_absorb_enc;
wire [127:0] din_absorb_dec;

reg [127:0] reg_dout, next_dout;
reg [4:0] reg_dout_size, next_dout_size;

reg [383:0] reg_state, next_state;

reg [383:0] gimli_state;
reg [4:0] gimli_round;
wire [383:0] gimli_new_state;
wire [4:0] gimli_new_round;
wire gimli_last_round;

reg [4:0] reg_gimli_round, next_gimli_round;

wire din_valid_and_ready;
wire dout_valid_and_ready;
reg reg_computing_permutation, next_computing_permutation;
reg reg_has_data_out, next_has_data_out;

assign din_valid_and_ready = din_valid & int_din_ready;
assign dout_valid_and_ready = int_dout_valid & dout_ready;

generate
    if (ASYNC_RSTN != 0) begin : use_asynchrnous_reset_zero_enable
        always @(posedge clk or negedge arstn) begin
            if (arstn == 1'b0) begin
                reg_computing_permutation <= 1'b0;
                reg_has_data_out <= 1'b0;
            end else begin
                reg_computing_permutation <= next_computing_permutation;
                reg_has_data_out <= next_has_data_out;
            end
        end
    end else begin
        always @(posedge clk) begin
            if (arstn == 1'b1) begin
                reg_computing_permutation <= 1'b0;
                reg_has_data_out <= 1'b0;
            end else begin
                reg_computing_permutation <= next_computing_permutation;
                reg_has_data_out <= next_has_data_out;
            end
        end
    end
endgenerate

always @(posedge clk) begin
    reg_state <= next_state;
    reg_gimli_round <= next_gimli_round;
    reg_dout <= next_dout;
    reg_dout_size <= next_dout_size;
end

always @(*) begin
    if(din_valid_and_ready == 1'b1) begin
        case (oper)
            // Absorb directly, Absorb encryption, Absorb decryption, Squeeze and permute
            3'b000, 3'b001, 3'b010, 3'b011  : begin
                next_state = gimli_new_state;
            end
            // Init first column
            3'b100 : begin
                next_state[127:0]   = din;
                next_state[255:128] = reg_state[255:128];
                next_state[383:256] = reg_state[383:256];
            end
            // Init second column
            3'b101 : begin
                next_state[127:0]   = reg_state[127:0];
                next_state[255:128] = din;
                next_state[383:256] = reg_state[383:256];
            end
            // Init third column
            3'b110 : begin
                next_state[127:0]   = reg_state[127:0];
                next_state[255:128] = reg_state[255:128];
                next_state[383:256] = din;
            end
            // Init zero
            3'b111 : begin
                next_state[127:0]   = {128{1'b0}};
                next_state[255:128] = {128{1'b0}};
                next_state[383:256] = {128{1'b0}};
            end
            default : begin
                next_state = reg_state;
            end
        endcase
    end else if(reg_computing_permutation == 1'b1) begin
        next_state = gimli_new_state;
    end else begin
        next_state = reg_state;
    end
end

always @(*) begin
    case(din_size)
        5'b00000 : begin
            din_padding[7:0]     = 8'b00000001;
            din_padding[127:8]   = {120{1'b0}};
            din_mask[127:0]      = {16{8'h00}};
        end                     
        5'b00001 : begin        
            din_padding[7:0]     = {8{1'b0}};
            din_padding[15:8]    = 8'b00000001;
            din_padding[127:16]  = {112{1'b0}};
            din_mask[7:0]        = {1{8'hFF}};
            din_mask[127:8]      = {15{8'h00}};
        end                     
        5'b00010 : begin        
            din_padding[15:0]    = {16{1'b0}};
            din_padding[23:16]   = 8'b00000001;
            din_padding[127:24]  = {104{1'b0}};
            din_mask[15:0]       = {2{8'hFF}};
            din_mask[127:16]     = {14{8'h00}};
        end                     
        5'b00011 : begin        
            din_padding[23:0]    = {24{1'b0}};
            din_padding[31:24]   = 8'b00000001;
            din_padding[127:32]  = {96{1'b0}};
            din_mask[23:0]       = {3{8'hFF}};
            din_mask[127:24]     = {13{8'h00}};
        end                     
        5'b00100 : begin        
            din_padding[31:0]    = {32{1'b0}};
            din_padding[39:32]   = 8'b00000001;
            din_padding[127:40]  = {88{1'b0}};
            din_mask[31:0]       = {4{8'hFF}};
            din_mask[127:32]     = {12{8'h00}};
        end                     
        5'b00101 : begin        
            din_padding[39:0]    = {40{1'b0}};
            din_padding[47:40]   = 8'b00000001;
            din_padding[127:48]  = {80{1'b0}};
            din_mask[39:0]       = {5{8'hFF}};
            din_mask[127:40]     = {11{8'h00}};
        end                     
        5'b00110 : begin        
            din_padding[47:0]    = {48{1'b0}};
            din_padding[55:48]   = 8'b00000001;
            din_padding[127:56]  = {72{1'b0}};
            din_mask[47:0]       = {6{8'hFF}};
            din_mask[127:48]     = {10{8'h00}};
        end                     
        5'b00111 : begin        
            din_padding[55:0]    = {56{1'b0}};
            din_padding[63:56]   = 8'b00000001;
            din_padding[127:64]  = {64{1'b0}};
            din_mask[55:0]       = {7{8'hFF}};
            din_mask[127:56]     = {9{8'h00}};
        end                     
        5'b01000 : begin        
            din_padding[63:0]    = {64{1'b0}};
            din_padding[71:64]   = 8'b00000001;
            din_padding[127:72]  = {56{1'b0}};
            din_mask[63:0]       = {8{8'hFF}};
            din_mask[127:64]     = {8{8'h00}};
        end                     
        5'b01001 : begin        
            din_padding[71:0]    = {72{1'b0}};
            din_padding[79:72]   = 8'b00000001;
            din_padding[127:80]  = {48{1'b0}};
            din_mask[71:0]       = {9{8'hFF}};
            din_mask[127:72]     = {7{8'h00}};
        end                     
        5'b01010 : begin        
            din_padding[79:0]    = {80{1'b0}};
            din_padding[87:80]   = 8'b00000001;
            din_padding[127:88]  = {40{1'b0}};
            din_mask[79:0]       = {10{8'hFF}};
            din_mask[127:80]     = {6{8'h00}};
        end                     
        5'b01011 : begin        
            din_padding[87:0]    = {88{1'b0}};
            din_padding[95:88]   = 8'b00000001;
            din_padding[127:96]  = {32{1'b0}};
            din_mask[87:0]       = {11{8'hFF}};
            din_mask[127:88]     = {5{8'h00}};
        end
        5'b01100 : begin
            din_padding[95:0]    = {96{1'b0}};
            din_padding[103:96]  = 8'b00000001;
            din_padding[127:104] = {24{1'b0}};
            din_mask[95:0]       = {12{8'hFF}};
            din_mask[127:96]     = {4{8'h00}};
        end
        5'b01101 : begin
            din_padding[103:0]    = {104{1'b0}};
            din_padding[111:104]  = 8'b00000001;
            din_padding[127:112]  = {16{1'b0}};
            din_mask[103:0]       = {13{8'hFF}};
            din_mask[127:104]     = {3{8'h00}};
        end
        5'b01110 : begin
            din_padding[111:0]    = {112{1'b0}};
            din_padding[119:112]  = 8'b00000001;
            din_padding[127:120]  = {8{1'b0}};
            din_mask[111:0]       = {14{8'hFF}};
            din_mask[127:112]     = {2{8'h00}};
        end
        5'b01111 : begin
            din_padding[119:0]    = {120{1'b0}};
            din_padding[127:120]  = 8'b00000001;
            din_mask[119:0]       = {15{8'hFF}};
            din_mask[127:120]     = {1{8'h00}};
        end
        5'b10000 : begin
            din_padding[127:0]    = {128{1'b0}};
            din_mask[127:0]       = {16{8'hFF}};
        end
        default : begin
            din_mask[127:0]       = {16{8'h00}};
            din_padding[127:0]    = {128{1'b0}};
        end
    endcase
end

assign din_masked = din & din_mask;
assign din_padding_xor_state = din_padding ^ reg_state[127:0];
assign din_xor_state_masked = (din ^ reg_state[127:0]) & din_mask;
assign din_absorb_enc = din_masked ^ din_padding_xor_state;
assign din_absorb_dec = din_xor_state_masked ^ din_padding_xor_state;

always @(*) begin
    if(din_valid_and_ready == 1'b1) begin
        case (oper)
            // Absorb directly, Absorb encryption, Absorb decryption
            3'b000, 3'b001, 3'b010  : begin
                if(oper == 3'b010) begin
                    gimli_state[127:0]   = din_absorb_dec;
                end else begin
                    gimli_state[127:0]   = din_absorb_enc;
                end
                gimli_state[255:128] = reg_state[255:128];
                gimli_state[375:256] = reg_state[375:256];
                if(din_size == 5'b10000) begin
                    // Full Absorb
                    gimli_state[383:376] = reg_state[383:376];
                end else begin
                    // Padded Absorb
                    gimli_state[383:376] = reg_state[383:376] ^ 8'b00000001;
                end
            end
            // Squeeze and permute
            3'b011 : begin
                gimli_state = reg_state;
            end
            default : begin
                gimli_state = reg_state;
            end
        endcase
    end else begin
        gimli_state = reg_state;
    end
end

always @(*) begin
    if(din_valid_and_ready == 1'b1) begin
        case (oper)
            // Absorb directly, Absorb encryption, Absorb decryption, Squeeze and permute
            3'b000, 3'b001, 3'b010, 3'b011 : begin
                next_gimli_round = gimli_new_round;
            end
            default : begin
                next_gimli_round = reg_gimli_round;
            end
        endcase
    end else if(reg_computing_permutation == 1'b1) begin
        next_gimli_round = gimli_new_round;
    end else begin
        next_gimli_round = reg_gimli_round;
    end
end

always @(*) begin
    if(din_valid_and_ready == 1'b1) begin
        case (oper)
            // Absorb directly, Absorb encryption, Absorb decryption, Squeeze and permute
            3'b000, 3'b001, 3'b010, 3'b011 : begin
                gimli_round = 5'd24;
            end
            default : begin
                gimli_round = reg_gimli_round;
            end
        endcase
    end else begin
        gimli_round = reg_gimli_round;
    end
end

gimli_permutation_rounds_combinational
#(.COMBINATIONAL_ROUNDS(COMBINATIONAL_ROUNDS))
gimli (
    .state(gimli_state),
    .round(gimli_round),
    .new_state(gimli_new_state),
    .new_round(gimli_new_round),
    .last_round(gimli_last_round)
);

always @(*) begin
    if(din_valid_and_ready == 1'b1) begin
        case (oper)
            // Absorb directly, Absorb encryption, Absorb decryption, Squeeze and permute
            3'b000, 3'b001, 3'b010, 3'b011 : begin
                next_computing_permutation = 1'b1;
            end
            default : begin
                next_computing_permutation = 1'b0;
            end
        endcase
    end else if(reg_computing_permutation == 1'b1) begin
        if(gimli_last_round == 1'b1) begin
            next_computing_permutation = 1'b0;
        end else begin
            next_computing_permutation = reg_computing_permutation;
        end
    end else begin
        next_computing_permutation = reg_computing_permutation;
    end
end

always @(*) begin
    if(reg_computing_permutation == 1'b1) begin
        int_din_ready = 1'b0;
    end else if(reg_has_data_out == 1'b1) begin
        int_din_ready = dout_ready;
    end else begin
        int_din_ready = 1'b1;
    end
end

always @(*) begin
    if((din_valid_and_ready == 1'b1) && (dout_valid_and_ready == 1'b1)) begin
        case (oper)
            // Absorb encryption, Absorb decryption, Squeeze and permute
            3'b001, 3'b010, 3'b011 : begin
                next_has_data_out = 1'b1;
            end
            default : begin
                next_has_data_out = 1'b0;
            end
        endcase
    end else if(din_valid_and_ready == 1'b1) begin
        case (oper)
            // Absorb encryption, Absorb decryption, Squeeze and permute
            3'b001, 3'b010, 3'b011 : begin
                next_has_data_out = 1'b1;
            end
            default : begin
                next_has_data_out = reg_has_data_out;
            end
        endcase
    end else if(dout_valid_and_ready == 1'b1) begin
        next_has_data_out = 1'b0;
    end else begin
        next_has_data_out = reg_has_data_out;
    end
end

always @(*) begin
    if(din_valid_and_ready == 1'b1) begin
        case (oper)
            // Absorb encryption, Absorb decryption
            3'b001, 3'b010 : begin
                next_dout = din_xor_state_masked;
            end
            // Squeeze and permute
            3'b011 : begin
                next_dout = reg_state[127:0];
            end
            default : begin
                next_dout = reg_dout;
            end
        endcase
    end else begin
        next_dout = reg_dout;
    end
end

always @(*) begin
    if(din_valid_and_ready == 1'b1) begin
        case (oper)
            // Absorb encryption, Absorb decryption
            3'b001, 3'b010 : begin
                next_dout_size = din_size;
            end
            // Squeeze and permute
            3'b011 : begin
                next_dout_size = 5'b10000;
            end
            default : begin
                next_dout_size = 5'b00000;
            end
        endcase
    end else begin
        next_dout_size = reg_dout_size;
    end
end

assign int_dout_valid = reg_has_data_out;

assign din_ready = int_din_ready;
assign dout_valid = int_dout_valid;
assign dout = reg_dout;
assign dout_size = reg_dout_size;

endmodule