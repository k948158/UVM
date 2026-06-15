`timescale 1ns/1ps

module i2c_loopback #(
    parameter logic [6:0] SLAVE_ADDR = 7'h40
) (
    input  logic       clk,
    input  logic       reset,

    input  logic       cmd_start,
    input  logic       cmd_write,
    input  logic       cmd_read,
    input  logic       cmd_stop,
    input  logic [7:0] tx_data_master,
    input  logic       master_ack_in,

    output logic [7:0] rx_data_master,
    output logic       master_ack_out,
    output logic       busy_master,
    output logic       cmd_done_master,
    output logic       done_master,

    output logic [7:0] rx_data_slave,
    output logic       rx_valid_slave,
    output logic       slave_ack_out,
    output logic       busy_slave,
    output logic       done_slave,

    output logic [7:0] loopback_data,
    output wire        scl,
    inout  tri1        sda
);

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            loopback_data <= 8'h00;
        end
        else if (rx_valid_slave) begin
            loopback_data <= rx_data_slave;
        end
    end

    i2c_master_top U_I2C_MASTER_TOP (
        .clk       (clk),
        .reset     (reset),
        .cmd_start (cmd_start),
        .cmd_write (cmd_write),
        .cmd_read  (cmd_read),
        .cmd_stop  (cmd_stop),
        .tx_data   (tx_data_master),
        .ack_in    (master_ack_in),
        .rx_data   (rx_data_master),
        .ack_out   (master_ack_out),
        .busy      (busy_master),
        .cmd_done  (cmd_done_master),
        .done      (done_master),
        .scl       (scl),
        .sda       (sda)
    );

    i2c_slave_top #(
        .SLAVE_ADDR(SLAVE_ADDR)
    ) U_I2C_SLAVE_TOP (
        .clk      (clk),
        .reset    (reset),
        .scl      (scl),
        .tx_data  (loopback_data),
        .ack_in   (1'b0),
        .rx_data  (rx_data_slave),
        .rx_valid (rx_valid_slave),
        .ack_out  (slave_ack_out),
        .busy     (busy_slave),
        .done     (done_slave),
        .sda      (sda)
    );

endmodule
