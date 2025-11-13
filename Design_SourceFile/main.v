`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Kirthana P Rao
// 
// Create Date: 23.06.2025 13:02:54
// Design Name: 
// Module Name: main
// Project Name:  AXI4-Lite Slave Peripheral Packet Validator cum Sorter
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
    module main(input wire clk,rst,input [31:0]AWADDR, input [31:0]WDATA,
                input val_wr_en,ival_wr_en,
                output reg WVALID, WREADY,AWREADY, BVALID, BREADY, AWVALID, 
                output reg val_full, val_empty, ival_full, ival_empty,
                output reg [1:0]BRESP, output reg [7:0]val_fifo_ctr, ival_fifo_ctr);
                
        reg [31:0]mem;
        reg [7:0]valid_fifo[0:7];
        reg [7:0]invalid_fifo[0:7];
        reg [2:0]val_wr_ptr, ival_wr_ptr;
        //  reg [2:0]val_rd_ptr, ival_rd_ptr;
        //            valid_fifo[val_wr_ptr] <= 0; invalid_fifo[ival_wr_ptr] <= 0;
        /*val_rd_en,ival_rd_en,*/
        
         initial begin 
            mem = 0;
            val_fifo_ctr = 0; ival_fifo_ctr = 0;
            BREADY = 0; BVALID = 0;
         end 
        
        always @(posedge clk or negedge rst) begin 
            if(rst) begin 
                AWVALID <= 0; AWREADY <= 0; BRESP <= 2'b10; //bresp will be slave error
                WVALID <= 0; WREADY <= 0; BREADY <= 0;
                ival_wr_ptr <= 0; val_wr_ptr <= 0;
            end
                
            else begin 
                if(AWADDR)
                    AWVALID <= 1;
                else
                    AWVALID <= 0;
                if(WDATA)
                    WVALID <= 1;
                else
                    WVALID <= 0;
                    
                AWREADY <= AWVALID;                             // in our case we don't have to explicitly check the master peripheral's address and data if they are ready, 
                WREADY <= WVALID;                               //rather directly assign the validity of address and data on the slave peripheral, since master data will be valid
                
                BVALID <= (AWREADY & WREADY);
                BREADY <= (AWVALID & WVALID);                   //The master peripheral confirms its ready iff the master confirms the address and data on AWADDR and WDATA are ready
                
                if(BREADY & BVALID) begin
                    if(AWADDR == 32'h00) begin                  //signal checking if address is 32'h04
                        mem <= WDATA[31:24];                              //if not then only stored in memory
                        BVALID <= 1;
                    end
                    else if(AWADDR == 32'h04) begin                         //commit last signal
                        if(( (WDATA[31:24] == 8'hA5) | (mem[31:24] == 8'hA5)) & ~val_full) begin          //validity checking
                            if(mem)                                             // the last data is stored into fifo(packet sorting)
                                valid_fifo[val_wr_ptr] <= mem;
                            else
                                valid_fifo[val_wr_ptr] <= WDATA[31:24]; 
                            
                            val_wr_ptr <= val_wr_ptr + 1;                        //master is set to 1: ready to hear back
                            BRESP <= 2'b00;                                     // BRESP says successful transfer of valid data
                        end
                        
                        if(( (WDATA[31:24] != 8'hA5) | (mem[31:24] != 8'hA5)) & ~ival_full) begin          //to check for invalid data 
                            if(~mem)
                                invalid_fifo[ival_wr_ptr] <= WDATA[31:24];
                            else
                                invalid_fifo[ival_wr_ptr] <= mem;
                            BRESP <= 2'b01;                                     // BRESP says successful transfer of INvalid dat
                            ival_wr_ptr <= ival_wr_ptr + 1;
                        end 
                    end
                    
                    else begin
                        valid_fifo[val_wr_ptr] <= 0; invalid_fifo[ival_wr_ptr] <= 0;
                        ival_wr_ptr <= 0; val_wr_ptr <= 0; 
                    end
                end  
             end
        end
         
        always @(*) begin
            assign val_full = (val_fifo_ctr == 8);
            assign val_empty = (val_fifo_ctr == 0);
            assign ival_full = (ival_fifo_ctr == 8);
            assign ival_empty = (ival_fifo_ctr == 0);
        end
        
        //FIFO COUNTER for write and read 
        always @(posedge clk or negedge rst) begin
            if(~rst) begin
                if(!val_full & val_wr_en & BVALID)
                    val_fifo_ctr <= val_fifo_ctr + 1;
                else
                    val_fifo_ctr <= val_fifo_ctr;  
                     
                if(!ival_full & ival_wr_en & BVALID)  
                    ival_fifo_ctr <= ival_fifo_ctr + 1;
                else
                    ival_fifo_ctr <= ival_fifo_ctr;
            end
            else
                val_fifo_ctr <= 0; ival_fifo_ctr <= 0;
        end
 //        always @(posedge clk or negedge rst) begin 
//            if(~rst) begin   
//                if(WDATA)
//                    WVALID <= 1;        
//                else
//                    WVALID <= 0;
                
//                    BREADY <= (AWVALID & WVALID); //The master peripheral confirms its ready iff the master confirms the address and data on AWADDR and WDATA are ready
//                end
//                WREADY <= WVALID;
//            end
//        end       
        /*fifo_main #(.DEPTH (3),.WIDTH(8)) fifo_val (.clk(clk), .rst(rst), .wr_en(val_wr_en),
        .rd_en(val_rd_en), .d_in(WDATA[31:24]), .full(val_full), .empty(val_empty),
        .d_out(WDATA[31:24]), .rd_ptr(val_rd_ptr), .wr_ptr(val_wr_ptr), .fifo_ctr(val_fifo_ctr));
        
        fifo_main #(.DEPTH(3),.WIDTH(8)) fifo_ival(.clk(clk), .rst(rst), .wr_en(ival_wr_en),
        .rd_en(ival_rd_en),.d_in(WDATA[31:24]), .full(ival_full),.empty(ival_empty),
        .d_out(WDATA[31:24]),.rd_ptr(ival_rd_ptr), .wr_ptr(ival_wr_ptr), .fifo_ctr(ival_fifo_ctr));*/
        
    endmodule
