/*********************************************************************************
* Copyright (c) 2022, Computer Systems Design Lab, University of Arkansas        *
*                                                                                *
* All rights reserved.                                                           *
*                                                                                *
* Permission is hereby granted, free of charge, to any person obtaining a copy   *
* of this software and associated documentation files (the "Software"), to deal  *
* in the Software without restriction, including without limitation the rights   *
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      *
* copies of the Software, and to permit persons to whom the Software is          *
* furnished to do so, subject to the following conditions:                       *
*                                                                                *
* The above copyright notice and this permission notice shall be included in all *
* copies or substantial portions of the Software.                                *
*                                                                                *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  *
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  *
* SOFTWARE.                                                                      *
**********************************************************************************

==================================================================================

  Author: MD Arafat Kabir
  Email : arafat.sun@gmail.com
  Date  : Mon, Dec 12, 04:33 PM CST 2022

  Description:
  This module sets the operands for the alu-array based on the given 
  configuration. The operands are selected from the different streams like
  Register-File, the data-network, etc. within the compute block.

================================================================================*/


/*
Usage:
    This version is implemented using purely behavioral description.
    
    rf_portA     : Connect port-A of the register-file
    rf_portB     : Connect port-B of the register-file
    net_stream   : Connect data stream coming from the network module
    confSig      : Connect operand-selection configuration signals from FSM
    confLoad     : Connect clock-enable coming from FSM
    opnX         : Connect operand-X of ALU
    opnY         : Connect operand-Y of the ALU

    It does not have a reset because it is not essential.
*/


module opmux_behav #(
// Parameters
    parameter RF_STREAM_WIDTH = 16,
    parameter NET_STREAM_WIDTH = 1
) (
    clk,            // clock
    rf_portA,       // Port-A of the register-file
    rf_portB,       // Port-B of the register-file
    net_stream,     // data stream coming from the network module
    confSig,        // operand-selection configuration signals
    confLoad,       // clock-enable for configuration register

    opnX,            // Operand-X output
    opnY             // Operand-Y output
);


`include "opmux_confs_param.v"

localparam OPN_WIDTH = RF_STREAM_WIDTH;      // operand width
localparam [OPN_WIDTH-1:0] ZEROS = 0;		 // a combination of all-zeros


// IO Ports
input                           clk;
input   [RF_STREAM_WIDTH-1:0]   rf_portA;
input   [RF_STREAM_WIDTH-1:0]   rf_portB;
input   [NET_STREAM_WIDTH-1:0]  net_stream;    // for bit-serial, this will probably always be 1-bit
input   [OPMUX_CONF_WIDTH-1:0]  confSig;       // OPMUX_CONF_WIDTH defined in the include file
input                           confLoad;
output  [OPN_WIDTH-1:0]         opnX;
output  [OPN_WIDTH-1:0]         opnY;


// Internal signals
(* extract_enable = "yes" *)
reg  [OPMUX_CONF_WIDTH-1:0]  conf_reg = 0;     // default reset value; no explicit reset
	
// Load configuration to the conf_reg register when requested
always @(posedge clk) begin
    if(confLoad)                // update value only if confLoad set
        conf_reg <= confSig;    // load the requested configruation 
    else
        conf_reg <= conf_reg;   // if confLoad not set, hold the current value
end


// Operand-X Muxing function
function automatic [OPN_WIDTH-1:0] mux_X;
    input [OPN_WIDTH-1:0]         A;
    input [OPMUX_CONF_WIDTH-1:0]  select;
	// Muxing logic
    if(select==OPMUX_0_OP_B)  mux_X = ZEROS;
    else mux_X = A;
endfunction

assign opnX = mux_X(rf_portA, conf_reg);


// Operand-Y Muxing function
function automatic [OPN_WIDTH-1:0] mux_Y;
    input [OPN_WIDTH-1:0]         A;
    input [OPN_WIDTH-1:0]         B;
    input [NET_STREAM_WIDTH-1:0]  net;
    input [OPMUX_CONF_WIDTH-1:0]  select;

	// Internal signals
	reg [OPN_WIDTH-1:0] foldA_1;
	reg [OPN_WIDTH-1:0] foldA_2;
	reg [OPN_WIDTH-1:0] foldA_3;
	reg [OPN_WIDTH-1:0] foldA_4;
	reg [OPN_WIDTH-1:0] net_comb;
	
	// Different sub-sizes of the operand width
	localparam HALF    = OPN_WIDTH/2,
			   QUART   = OPN_WIDTH/4,
			   HQUART  = OPN_WIDTH/8,     // Half-Quarter
			   HHQUART = OPN_WIDTH/16;    // Half-Quarter/2

	begin
		// Muxing combinations
		foldA_1  = {ZEROS[HALF +: HALF],         A[HALF +: HALF]};        // Y[lower-half] = A[upper-half],     Y[remain] = 0
		foldA_2  = {ZEROS[QUART +: QUART*3],     A[QUART +: QUART]};      // Y[lower-quarter] = A[2nd-quarter], Y[remain] = 0
		foldA_3  = {ZEROS[HQUART +: HQUART*7],   A[HQUART +: HQUART]};    // Y[lq/2] = A[lq/2u],                Y[remain] = 0
		foldA_4  = {ZEROS[HHQUART +: HHQUART*15], A[HHQUART +: HHQUART]};  // Y[lq/4] = A[lq/4u],                Y[remain] = 0
		net_comb = {ZEROS[OPN_WIDTH-1:NET_STREAM_WIDTH], net};            // Y[lower-bits] = net,               Y[upper-bits] = 0

		// Muxing logic
		(* full_case, parallel_case *)
		case (select)
			OPMUX_A_OP_B   : mux_Y = B; 
			OPMUX_A_FOLD_1 : mux_Y = foldA_1; 
			OPMUX_A_FOLD_2 : mux_Y = foldA_2; 
			OPMUX_A_FOLD_3 : mux_Y = foldA_3; 
			OPMUX_A_FOLD_4 : mux_Y = foldA_4; 
			OPMUX_A_OP_NET : mux_Y = net_comb; 
			OPMUX_0_OP_B   : mux_Y = B; 
			default		   : mux_Y = B; 
		endcase
	end
endfunction

assign opnY = mux_Y(rf_portA, rf_portB, net_stream, conf_reg);


endmodule
