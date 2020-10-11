/*--------------------------------------------------------------------------------*/
/* Implementation by Pedro Maat C. Massolino,                                     */
/* hereby denoted as "the implementer".                                           */
/*                                                                                */
/* To the extent possible under law, the implementer has waived all copyright     */
/* and related or neighboring rights to the source code in this file.             */
/* http://creativecommons.org/publicdomain/zero/1.0/                              */
/*--------------------------------------------------------------------------------*/
`default_nettype    none

module gimli_stream
#(parameter ASYNC_RSTN = 1,   // 0 - Synchronous reset in high, 1 - Asynchrouns reset in low.
COMBINATIONAL_ROUNDS = 1,     // Number of unrolled combinational rounds possible (Supported sizes : 1, 2, 3, 4, 6, 8, 12)
DIN_DOUT_WIDTH = 32,          // The width of ports din and dout (Supported sizes : 8, 16, 32, 64)
DIN_DOUT_SIZE_WIDTH = 2)      // DIN_DOUT_WIDTH = 8,  DIN_DOUT_SIZE_WIDTH = 0
                              // DIN_DOUT_WIDTH = 16, DIN_DOUT_SIZE_WIDTH = 1
                              // DIN_DOUT_WIDTH = 32, DIN_DOUT_SIZE_WIDTH = 2
                              // DIN_DOUT_WIDTH = 64, DIN_DOUT_SIZE_WIDTH = 4
(
    input wire clk,
    input wire arstn,
    // Data in bus
    input wire [(DIN_DOUT_WIDTH-1):0] din,
    input wire [DIN_DOUT_SIZE_WIDTH:0] din_size,
    input wire din_last,
    input wire din_valid,
    output wire din_ready,
    // Instruction bus
    input wire [3:0] inst,
    input wire inst_valid,
    output wire inst_ready,
    // Data out bus
    output wire [(DIN_DOUT_WIDTH-1):0] dout,
    output wire [DIN_DOUT_SIZE_WIDTH:0] dout_size,
    output wire dout_last,
    output wire dout_valid,
    input wire dout_ready
);

reg [3:0] reg_inst, next_inst;
wire int_inst_ready;
wire sm_inst_ready;

wire inst_valid_and_ready;

reg int_din_ready;
wire sm_din_ready;
wire sm_p_core_din_valid;

wire sm_p_core_last;

// Buffer in

wire din_valid_and_ready;

wire buffer_in_din_oper;

wire buffer_in_rst;
reg [(DIN_DOUT_WIDTH-1):0] buffer_in_din;
reg [DIN_DOUT_SIZE_WIDTH:0] buffer_in_din_size;
reg buffer_in_din_last;
reg buffer_in_din_valid;
wire buffer_in_din_ready;
wire [127:0] buffer_in_dout;
wire [4:0] buffer_in_dout_size;
wire buffer_in_dout_valid;
reg buffer_in_dout_ready;
wire buffer_in_dout_last;
wire [4:0] buffer_in_size;
wire buffer_in_size_full;


// Permutation core (Gimli)

wire p_core_din_valid_and_ready;

wire [1:0] p_core_din_oper;

wire [2:0] p_core_oper;
reg [127:0] p_core_din;
reg [4:0] p_core_din_size;
reg p_core_din_valid;
wire p_core_din_ready;
wire [127:0] p_core_dout;
wire p_core_dout_valid;
reg p_core_dout_ready;
wire [4:0] p_core_dout_size;

wire p_core_dout_valid_and_ready;

reg reg_p_core_last, next_p_core_last;

// Buffer out

wire [1:0] buffer_out_din_oper;

wire buffer_out_rst;
reg [127:0] buffer_out_din;
reg [4:0] buffer_out_din_size;
reg buffer_out_din_last;
reg buffer_out_din_valid;
wire buffer_out_din_ready;
wire [(DIN_DOUT_WIDTH-1):0] buffer_out_dout;
wire [DIN_DOUT_SIZE_WIDTH:0] buffer_out_dout_size;
wire buffer_out_dout_valid;
reg buffer_out_dout_ready;
wire buffer_out_dout_last;
wire [4:0] buffer_out_size;

// Dout signals

wire [1:0] dout_oper;

wire dout_valid_and_ready;

reg [(DIN_DOUT_WIDTH-1):0] int_dout;
reg [DIN_DOUT_SIZE_WIDTH:0] int_dout_size;
reg int_dout_last;
reg int_dout_valid;

// Tag comparison

reg [127:0] reg_compare_tag, next_compare_tag;
wire reg_compare_tag_valid_and_ready;
wire reg_compare_tag_rst;
wire reg_compare_tag_enable;

reg is_reg_compare_tag_equal_zero;

// Instruction register

assign inst_valid_and_ready = int_inst_ready & inst_valid;

always @(posedge clk) begin
    reg_inst <= next_inst;
end

always @(*) begin
    if((inst_valid_and_ready == 1'b1)) begin
        next_inst = inst;
    end else begin
        next_inst = reg_inst;
    end
end

// Buffer in

assign din_valid_and_ready = din_valid & int_din_ready;

always @(*) begin
    buffer_in_din = din;
    buffer_in_din_size = din_size;
    buffer_in_din_last = din_last;
    if(buffer_in_din_oper == 1'b1) begin
        buffer_in_din_valid = 1'b0;
        int_din_ready = 1'b0;
    end else begin
        buffer_in_din_valid = din_valid;
        int_din_ready = buffer_in_din_ready;
    end
end

gimli_stream_buffer_in
#(.DIN_WIDTH(DIN_DOUT_WIDTH),
.DIN_SIZE_WIDTH(DIN_DOUT_SIZE_WIDTH),
.DOUT_WIDTH(128),
.DOUT_SIZE_WIDTH(4))
buffer_in
(
    .clk(clk),
    .rst(buffer_in_rst),
    .din(buffer_in_din),
    .din_size(buffer_in_din_size),
    .din_last(buffer_in_din_last),
    .din_valid(buffer_in_din_valid),
    .din_ready(buffer_in_din_ready),
    .dout(buffer_in_dout),
    .dout_size(buffer_in_dout_size),
    .dout_valid(buffer_in_dout_valid),
    .dout_ready(buffer_in_dout_ready),
    .dout_last(buffer_in_dout_last),
    .size(buffer_in_size),
    .reg_buffer_size_full(buffer_in_size_full)
);

assign p_core_din_valid_and_ready = p_core_din_valid & p_core_din_ready;

// Permutation core

always @(*) begin
    case(p_core_din_oper)
        // Disabled
        2'b01 : begin
            p_core_din = 128'b00;
            p_core_din_size = 5'b00000;
            p_core_din_valid = 1'b0;
            buffer_in_dout_ready = 1'b0;
        end
        // Insert 0
        2'b10 : begin
            p_core_din = 128'b00;
            p_core_din_size = 5'b00000;
            p_core_din_valid = 1'b1;
            buffer_in_dout_ready = 1'b0;
        end
        // Tag mode
        2'b11 : begin
            p_core_din = 128'b00;
            p_core_din_size = 5'b00000;
            p_core_din_valid = 1'b1;
            buffer_in_dout_ready = p_core_dout_valid;
        end
        default : begin
            p_core_din = buffer_in_dout;
            p_core_din_size = buffer_in_dout_size;
            p_core_din_valid = buffer_in_dout_valid;
            buffer_in_dout_ready = p_core_din_ready;
        end
    endcase
end

gimli_rounds_simple
#(.ASYNC_RSTN(ASYNC_RSTN),
.COMBINATIONAL_ROUNDS(COMBINATIONAL_ROUNDS))
p_core
(
    .clk(clk),
    .arstn(arstn),
    .oper(p_core_oper),
    .din(p_core_din),
    .din_size(p_core_din_size),
    .din_valid(p_core_din_valid),
    .din_ready(p_core_din_ready),
    .dout(p_core_dout),
    .dout_valid(p_core_dout_valid),
    .dout_ready(p_core_dout_ready),
    .dout_size(p_core_dout_size)
);

always @(posedge clk) begin
    reg_p_core_last <= next_p_core_last;
end

always @(*) begin
    if(p_core_din_valid_and_ready == 1'b1) begin
        case(p_core_din_oper)
            // Disabled
            2'b01 : begin
                next_p_core_last = 1'b0;
            end
            // Insert 0
            2'b10 : begin
                next_p_core_last = sm_p_core_last;
            end
            // Tag mode
            2'b11 : begin
                next_p_core_last = sm_p_core_last;
            end
            default : begin
                next_p_core_last = buffer_in_dout_last;
            end
        endcase
    end else begin
        next_p_core_last = reg_p_core_last;
    end
end

// Buffer out

assign p_core_dout_valid_and_ready = p_core_dout_ready & p_core_dout_valid;

always @(*) begin
    buffer_out_din = p_core_dout;
    buffer_out_din_size = p_core_dout_size;
    buffer_out_din_last = reg_p_core_last;
    case(buffer_out_din_oper)
        // Disabled
        2'b01 : begin
            buffer_out_din_valid = 1'b0;
            p_core_dout_ready = 1'b0;
        end
        // Ignore output
        2'b10 : begin
            buffer_out_din_valid = 1'b0;
            p_core_dout_ready = 1'b1;
        end
        // Tag mode
        2'b11 : begin
            buffer_out_din_valid = 1'b0;
            p_core_dout_ready = buffer_in_dout_valid;
        end
        default : begin
            buffer_out_din_valid = p_core_dout_valid;
            p_core_dout_ready = buffer_out_din_ready;
        end
    endcase
end

gimli_stream_buffer_out
#(.DIN_WIDTH(128),
.DIN_SIZE_WIDTH(4),
.DOUT_WIDTH(DIN_DOUT_WIDTH),
.DOUT_SIZE_WIDTH(DIN_DOUT_SIZE_WIDTH))
buffer_out
(
    .clk(clk),
    .rst(buffer_out_rst),
    .din(buffer_out_din),
    .din_size(buffer_out_din_size),
    .din_last(buffer_out_din_last),
    .din_valid(buffer_out_din_valid),
    .din_ready(buffer_out_din_ready),
    .dout(buffer_out_dout),
    .dout_size(buffer_out_dout_size),
    .dout_valid(buffer_out_dout_valid),
    .dout_ready(buffer_out_dout_ready),
    .dout_last(buffer_out_dout_last),
    .size(buffer_out_size)
);

// Dout connection

assign dout_valid_and_ready = int_dout_valid & dout_ready;

always @(*) begin
    case(dout_oper)
        // Disabled
        2'b01 : begin
            int_dout = {DIN_DOUT_WIDTH{1'b0}};
            int_dout_size = {(DIN_DOUT_SIZE_WIDTH+1){1'b0}};
            int_dout_last = 1'b0;
            int_dout_valid = 1'b0;
            buffer_out_dout_ready = 1'b0;
        end
        // Tag mode
        2'b11 : begin
            int_dout[(DIN_DOUT_WIDTH-1):4] = {DIN_DOUT_WIDTH-4{1'b0}};
            int_dout[3:1]  = 3'b111;
            int_dout[0]    = ~is_reg_compare_tag_equal_zero;
            int_dout_size = {{DIN_DOUT_SIZE_WIDTH{1'b0}}, 1'b1};
            int_dout_last = 1'b1;
            int_dout_valid = 1'b1;
            buffer_out_dout_ready = 1'b0;
        end
        default : begin
            int_dout = buffer_out_dout;
            int_dout_size = buffer_out_dout_size;
            int_dout_last = buffer_out_dout_last;
            int_dout_valid = buffer_out_dout_valid;
            buffer_out_dout_ready = dout_ready;
        end
    endcase
end

assign reg_compare_tag_valid_and_ready = buffer_in_dout_valid & p_core_dout_valid;

always @(posedge clk) begin
    reg_compare_tag <= next_compare_tag;
end

always @(*) begin
    if(reg_compare_tag_rst == 1'b1) begin
        next_compare_tag = 128'b00;
    end else begin
        if((reg_compare_tag_enable == 1'b1) && (reg_compare_tag_valid_and_ready == 1'b1)) begin
            next_compare_tag = reg_compare_tag | (p_core_dout ^ buffer_in_dout);
        end else begin
            next_compare_tag = reg_compare_tag;
        end
    end
end

always @(*) begin
    if(reg_compare_tag == 128'b00) begin
        is_reg_compare_tag_equal_zero = 1'b1;
    end else begin
        is_reg_compare_tag_equal_zero = 1'b0;
    end
end

gimli_stream_state_machine
#(.ASYNC_RSTN(ASYNC_RSTN))
state_machine
(
    .clk(clk),
    .arstn(arstn),
    // Buffer in
    .din_last(din_last),
    .din_valid_and_ready(din_valid_and_ready),
    .buffer_in_rst(buffer_in_rst),
    .buffer_in_din_oper(buffer_in_din_oper),
    .buffer_in_size_full(buffer_in_size_full),
    // Instruction bus
    .inst(inst),
    .inst_valid_and_ready(inst_valid_and_ready),
    .inst_ready(sm_inst_ready),
    .reg_inst(reg_inst),
    // Permutation core
    .p_core_din_valid_and_ready(p_core_din_valid_and_ready),
    .p_core_din_oper(p_core_din_oper),
    .p_core_oper(p_core_oper),
    .sm_p_core_last(sm_p_core_last),
    .p_core_dout_valid_and_ready(p_core_dout_valid_and_ready),
    // Buffer out 
    .buffer_out_dout_last(buffer_out_dout_last),
    .buffer_out_rst(buffer_out_rst),
    .buffer_out_din_oper(buffer_out_din_oper),
    // Tag compare register
    .reg_compare_tag_valid_and_ready(reg_compare_tag_valid_and_ready),
    .reg_compare_tag_rst(reg_compare_tag_rst),
    .reg_compare_tag_enable(reg_compare_tag_enable),
    // Dout
    .dout_valid_and_ready(dout_valid_and_ready),
    .dout_oper(dout_oper)
);

assign dout = int_dout;
assign dout_size = int_dout_size;
assign dout_last = int_dout_last;
assign dout_valid = int_dout_valid;

assign din_ready = int_din_ready;

assign int_inst_ready = sm_inst_ready;
assign inst_ready = int_inst_ready;

endmodule