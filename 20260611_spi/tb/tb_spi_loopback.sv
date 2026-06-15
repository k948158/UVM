`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import spi_pkg::*;

module tb_spi_loopback;

    spi_if spi_vif();
    wire [7:0] w_loopback;

    initial begin
        $fsdbDumpfile("spi_loopback.fsdb");
        $fsdbDumpvars(0, tb_spi_loopback, "+all");
    end

    assign w_loopback = spi_vif.rx_data_slave;

    spi_master_slave dut (
        .clk            (spi_vif.clk),
        .rst            (spi_vif.rst),
        .start          (spi_vif.start),
        .cpol           (spi_vif.cpol),
        .cpha           (spi_vif.cpha),
        .clk_div        (spi_vif.clk_div),
        .tx_data_master (spi_vif.tx_data_master),
        .tx_data_slave  (w_loopback),
        .busy_master    (spi_vif.busy_master),
        .busy_slave     (spi_vif.busy_slave),
        .rx_data_master (spi_vif.rx_data_master),
        .rx_data_slave  (spi_vif.rx_data_slave),
        .done_master    (spi_vif.done_master),
        .done_slave     (spi_vif.done_slave)
    );

    initial begin
        spi_vif.clk = 1'b0;
        forever #5 spi_vif.clk = ~spi_vif.clk;
    end

    initial begin
        spi_vif.rst = 1'b1;
        repeat (5) @(posedge spi_vif.clk);
        spi_vif.rst = 1'b0;
    end

    initial begin
        uvm_config_db#(virtual spi_if)::set(null, "*", "vif", spi_vif);
        run_test("spi_test");
    end

endmodule
