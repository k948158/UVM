`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import i2c_pkg::*;

module tb_i2c_loopback;

    i2c_if i2c_vif();

    i2c_loopback dut (
        .clk             (i2c_vif.clk),
        .reset           (i2c_vif.reset),
        .cmd_start       (i2c_vif.cmd_start),
        .cmd_write       (i2c_vif.cmd_write),
        .cmd_read        (i2c_vif.cmd_read),
        .cmd_stop        (i2c_vif.cmd_stop),
        .tx_data_master  (i2c_vif.tx_data_master),
        .master_ack_in   (i2c_vif.master_ack_in),
        .rx_data_master  (i2c_vif.rx_data_master),
        .master_ack_out  (i2c_vif.master_ack_out),
        .busy_master     (i2c_vif.busy_master),
        .cmd_done_master (i2c_vif.cmd_done_master),
        .done_master     (i2c_vif.done_master),
        .rx_data_slave   (i2c_vif.rx_data_slave),
        .rx_valid_slave  (i2c_vif.rx_valid_slave),
        .slave_ack_out   (i2c_vif.slave_ack_out),
        .busy_slave      (i2c_vif.busy_slave),
        .done_slave      (i2c_vif.done_slave),
        .loopback_data   (i2c_vif.loopback_data),
        .scl             (i2c_vif.scl),
        .sda             (i2c_vif.sda)
    );

    initial begin
        i2c_vif.clk = 1'b0;
        forever #5 i2c_vif.clk = ~i2c_vif.clk;
    end

    initial begin
        i2c_vif.reset = 1'b1;
        repeat (10) @(posedge i2c_vif.clk);
        i2c_vif.reset = 1'b0;
    end

    initial begin
        $fsdbDumpfile("i2c_loopback.fsdb");
        $fsdbDumpvars(0, tb_i2c_loopback, "+all");
    end

    initial begin
        uvm_config_db#(virtual i2c_if)::set(null, "*", "vif", i2c_vif);
        run_test("i2c_test");
    end

endmodule
