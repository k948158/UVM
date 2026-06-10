`timescale 1ns / 1ps


module RAM (
    input  logic       clk,
    input  logic       we,
    input  logic [7:0] addr,
    input  logic [7:0] wdata,
    output logic [7:0] rdata
);

    logic [7:0] ram[0:255];

    always_ff @(posedge clk) begin
        if (we) begin
            ram[addr] <= wdata;
        end else begin
            rdata <= ram[addr];
        end
    end

endmodule
