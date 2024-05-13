// Copyright (c) 2023 Beijing Institute of Open Source Chip
// vga is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "register.sv"
`include "vga_define.sv"

module vga_timgen (
    input  logic                     clk_i,
    input  logic                     rst_n_i,
    input  logic                     en_i,
    input  logic [`VGA_TB_WIDTH-1:0] hbpsize_i,
    input  logic [`VGA_TB_WIDTH-1:0] hsnsize_i,
    input  logic [`VGA_TB_WIDTH-1:0] hfpsize_i,
    input  logic [`VGA_VB_WIDTH-1:0] hvlen_i,
    input  logic [`VGA_TB_WIDTH-1:0] vbpsize_i,
    input  logic [`VGA_TB_WIDTH-1:0] vsnsize_i,
    input  logic [`VGA_TB_WIDTH-1:0] vfpsize_i,
    input  logic [`VGA_VB_WIDTH-1:0] vvlen_i,
    output logic                     hsync_o,
    output logic                     hend_o,
    output logic                     vsync_o,
    output logic                     vend_o,
    output logic                     de_o
);

  logic s_hvis, s_vvis;
  assign de_o = s_hvis && s_vvis;

  vga_cnt u_hori_vga_cnt (
      .clk_i   (clk_i),
      .rst_n_i (rst_n_i),
      .en_i    (en_i),
      .bpsize_i(hbpsize_i),
      .snsize_i(hsnsize_i),
      .fpsize_i(hfpsize_i),
      .vlen_i  (hvlen_i),
      .vis_o   (s_hvis),
      .sync_o  (hsync_o),
      .end_o   (hend_o)
  );

  vga_cnt u_vert_vga_cnt (
      .clk_i   (clk_i),
      .rst_n_i (rst_n_i),
      .en_i    (en_i && hend_o),
      .bpsize_i(vbpsize_i),
      .snsize_i(vsnsize_i),
      .fpsize_i(vfpsize_i),
      .vlen_i  (vvlen_i),
      .vis_o   (s_vvis),
      .sync_o  (vsync_o),
      .end_o   (vend_o)
  );

endmodule
