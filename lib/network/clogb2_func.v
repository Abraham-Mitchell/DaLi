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
  Date  : Wed, Dec 07, 05:02 PM CST 2022

  Description:
  This function calculates the address width based on specified RAM depth.
  It can also be used to compute the selection width for a mux.

================================================================================*/


/*
Usage:
    depth : RAM Depth (mux input width)
    out   : Address width (select width)

out = ceil(log2(depth))
*/


// `ifndef FUNC_clogb2
// `define FUNC_clogb2


// function automatic integer clogb2;
// 	input integer depth;
// 	for (clogb2=0; depth>0; clogb2=clogb2+1)
// 		depth = depth >> 1;
// endfunction


// `endif // FUNC_clogb2


//function above as written gives error "Port depth of type input is being assigned"
//modification of function should hopefully remove this while keeping functionality the same. Hopefully

`ifndef FUNC_clogb2
`define FUNC_clogb2

function automatic integer clogb2;
    input integer depth;
    integer temp;  // Temporary variable
    begin
        temp = depth;              // Copy the input to a temporary variable
        clogb2 = 0;                // Initialize the output
        while (temp > 0) begin
            temp = temp >> 1;       // Shift the temporary variable
            clogb2 = clogb2 + 1;    // Increment the counter
        end
    end
endfunction

`endif // FUNC_clogb2









