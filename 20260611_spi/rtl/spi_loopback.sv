`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/13 14:06:24
// Design Name: 
// Module Name: spi_loopback
// Project Name: 
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


module spi_master_slave (
    input  logic       clk,
    input  logic       rst,
    //internal signals
    input  logic       start,
    input  logic       cpol,            //clock polarity
    input  logic       cpha,
    input  logic [7:0] clk_div,         //sclk speed change
    input  logic [7:0] tx_data_master,
    input  logic [7:0] tx_data_slave,
    output logic       busy_master,
    output logic       busy_slave,
    output logic [7:0] rx_data_master,
    output logic [7:0] rx_data_slave,
    output logic       done_master,
    output logic       done_slave
);
    logic sclk;
    logic mosi;
    logic miso;
    logic ss_n;
    logic w_sclk, w_mosi, w_miso, w_ss_n;
    spi_master U_SPI_MASTER (
        .clk(clk),
        .rst(rst),
        .start(start),
        .cpol(cpol),
        .cpha(cpha),
        .clk_div(clk_div),  //sclk speed change
        .tx_data(tx_data_master),
        .busy(busy_master),
        .rx_data(rx_data_master),
        .done(done_master),
        .sclk(w_sclk),
        .mosi(w_mosi),
        .miso(w_miso),
        .ss_n(w_ss_n)
    );
    logic [7:0] w_loopback;
    spi_slave U_SPI_SLAVE (
        .clk(clk),
        .rst(rst),
        .tx_data(tx_data_slave),
        .busy(busy_slave),
        .rx_data(rx_data_slave),
        .done(done_slave),
        .sclk(w_sclk),
        .mosi(w_mosi),
        .miso(w_miso),
        .ss_n(w_ss_n)
    );
endmodule
