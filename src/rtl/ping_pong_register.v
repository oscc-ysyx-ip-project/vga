module ping_pong_register
#(
    parameter ADDR_WIDTH=64,
    parameter DATA_WIDTH=64
)
(
    // signals with VC(VGA Control)
    input  wire                  clk_v,      // clock with vga block
    input  wire                  resetn_v,
    input  wire                  data_reg_i, // data request from VC
    output reg  [11:0]           data_o,
    // signals with CU(config unit)
    input  wire [ADDR_WIDTH-1:0] base_addr_i,      // SDRAM read base addr
    input  wire [ADDR_WIDTH-1:0] top_addr_i, // memory length
    // signals with AXI bus
    input  wire                  clk_a,      // clock with AXI bus
    input  wire                  resetn_a,      // clock with AXI bus
    input  wire                  arready_i,
    input  wire                  rvalid_i,
    input  wire [1:0]            rresp_i,
    input  wire [DATA_WIDTH-1:0] rdata_i,

    output reg  [ADDR_WIDTH-1:0] araddr_o,
    output reg  [1:0]            arburst_o,
    output reg  [7:0]            arlen_o,
    output reg  [2:0]            arsize_o,
    output reg                   arvalid_o,
    output reg                   rready_o
); 

// =========================================================================
// ============================ variables =============================
// =========================================================================
reg [63:0] ping [31:0];
reg [63:0] pong [31:0];
reg        read_ping; // currently read from ping register
reg [ 4:0] reg_count; // which register in ping or pong is read
reg [ 1:0] byte_count;// which 16bits in a register is read, 64 bits register has 4 16-bits part
reg [63:0] next_addr;
reg [ 4:0] write_cnt;


// =========================================================================
// ============================ implementation =============================
// =========================================================================


    // ==================== read logics ====================
    // read pointer 
    always @(posedge clk_v ) begin 
        if(~resetn_v) begin
            byte_count <= 2'b0;    
        end
        else if(data_reg_i) begin
            byte_count <= byte_count + 1;    
        end
        else begin
            byte_count <= byte_count;    
        end
    end

    always @(posedge clk_v ) begin 
        if(~resetn_v) begin
            reg_count <= 5'h0;    
        end
        else if(data_reg_i && byte_count == 2'b11) begin
            reg_count <= reg_count + 1;    
        end
        else begin
            reg_count <= reg_count;    
        end
    end
    
    always @(posedge clk_v) begin 
        if(~resetn_v) begin
            read_ping <= 1'b0;    
        end
        else if(reg_count == 5'h1f && byte_count == 2'b11) begin
            // finish read whole register group
            read_ping <= ~read_ping;
        end
    end
    
    // get VGA read data
    always @(posedge clk_v) begin 
        if(~resetn_v) begin
            data_o <= 12'h0;    
        end
        else if(data_reg_i) begin
            if(read_ping) begin
                    
            end
        end
        else begin
            data_o <= data_o;    
        end
    end

    // ==================== write logics ====================
    // calculate AXI read address
    always @(posedge clk_a) begin 
        if(~resetn_a) begin
            araddr_o <= base_addr_i;
            next_addr<= base_addr_i;
            arburst_o<= 2'h0;
            arlen_o  <= 8'h0;
            arsize_o <= 3'h0;
            arvalid_o<= 1'h0;
            rready_o <= 1'h0;
        end
        else if(arready_i) begin
            araddr_o <=  next_addr;   
            if(next_addr+64'h100 < top_addr_i) begin
                next_addr<=  next_addr+64'h100;
            end
            else begin
                next_addr<=base_addr_i;    
            end
            arburst_o<= 2'h1; // addr increment
            arlen_o  <= 8'h1f;// 31+1=32 transfers 
            arsize_o <= 3'h3; // 8 byte for 1 transaction
            arvalid_o<= 1'h1; // read addrss valid
            rready_o <= 1'h1; // ready for read data
        end
    end
    // write AXI data into memory
    always @(posedge clk_a ) begin 
        if(~resetn_a) begin
            write_cnt <= 5'h0;    
        end
        else if(rvalid_i && (rresp_i==2'h0)) begin
            if(read_ping) begin
                pong[write_cnt] <= rdata_i;
            end    
            else begin
                ping[write_cnt] <= rdata_i;    
            end
        end
    end
endmodule
