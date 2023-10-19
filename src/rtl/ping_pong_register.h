#ifndef __PING_PONG_REGISTER__
#define __PING_PONG_REGISTER__
#include "config.h"
#include <cstdio>
#include <stdlib.h>
#define PING false
#define PONG true

// IO input
class ppr_in_io {
public:
  bool clk_a, clk_v;
  bool data_req_i;  // request color data
  bool self_test_i; // seft test enable
  bool resetn_v;
  // signals with AXI bus
  bool arready_i, rvalid_i;
  int rresp_i;
  long rdata_i;
  bool resetn_a;
  long base_addr_i, top_addr_i; // AXI data and address width is 64 bits
  ppr_in_io() {
    clk_a = 0;
    clk_v = 0;
    data_req_i = 0;
    self_test_i = 0;
    resetn_v = 1;
    resetn_a = 1;
    arready_i = 0;
    rvalid_i = 0;
    rresp_i = 0;
    base_addr_i = 0;
    top_addr_i = 0;
  }
  void display() {
    Log("\nInIO data:\n");
    Log("clk_v=%d, clk_a=%d\n", clk_v, clk_a);
    Log("arready_i=%d\n", arready_i);
    Log("data_req_i=%d, self_test_i=%d\n", data_req_i, self_test_i);
  }

  // get randome InIO
  void randInIO(unsigned long int sim_time) {
    if (sim_time >= 0 && sim_time < 4) {
      data_req_i = 0;
      self_test_i = 0;
      base_addr_i = 0;
      top_addr_i = 0;
      arready_i = 0;
      rvalid_i = 0;
      rresp_i = 0;
      rdata_i = 0;
      resetn_a = 0;
      resetn_v = 0;
    } else {
      resetn_a = 1;
      resetn_v = 1;
      // arready_i = rand() & 1; // sdram ready for read
      arready_i = 1; // sdram ready for read
      // self_test_i = 1;        // enable self_test
      data_req_i = 1; // vga require data
      // get data from SDRAM through AXI
      self_test_i = 0; // disable self_test
      rvalid_i = 1;
      rresp_i = 0;
      // rdata_i = 0x012356789abcdef;
      // rdata_i = sim_time;
      rdata_i = rand();
    }
    // calculate clock
    if (sim_time == 0) {
      clk_a = 0;
      clk_v = 0;
    } else {
      clk_a ^= 1;
      clk_v ^= 1;
    }
  }
};

// initial clock_a
// int InIO::clock_a = 0;

class ppr_out_io {
public:
  // VC color data
  int data_o;
  long araddr_o;
  int arburst_o, arlen_o, arsize_o;
  bool arvalid_o, rready_o;
  // compare if OutIO is equal
};
class ping_pong_register {
private:
  // ping pong registers
  long ping[32];
  long pong[32];
  int color; // self test color

  int next_addr;
  bool read_ping;
  int byte_count, read_count, write_count;
  bool ppr_write_finish, vga_read_finish;

public:
  // IO
  ppr_in_io *in;
  ppr_out_io *out;
  // functions
  void resetn(); // reset ppr c_model
  void eval();   // step one cycle
  ping_pong_register() {
    in = new ppr_in_io;
    out = new ppr_out_io;
  }
  // ping_pong_register(ppr_in_io *i, ppr_out_io *o) {
  //   in = i;
  //   out = o;
  // }
};
#endif
