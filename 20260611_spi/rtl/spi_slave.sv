`timescale 1ns / 1ps

module spi_slave (
    input  logic       clk,
    input  logic       rst,
    input  logic       ss_n,
    //internal signals
    input  logic [7:0] tx_data,
    output logic       busy,
    output logic [7:0] rx_data,
    output logic       done,
    //external signals
    input  logic       sclk,
    input  logic       mosi,
    output logic       miso
);

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START,
        DATA,
        STOP
    } state_t;
    state_t state;

    logic [7:0] div_cnt;
    logic [7:0] tx_shift_reg;
    logic [7:0] rx_shift_reg;
    logic [3:0] bit_cnt;
    logic step;
    logic sclk_reg;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
            miso <= 1'b1;
            busy <= 1'b0;
            done <= 1'b0;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            bit_cnt <= 0;
            rx_data <= 0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    miso <= 1'b1;
                    tx_shift_reg <= tx_data;  //Latching
                    bit_cnt <= 0;
                    if (!ss_n) begin
                        busy  <= 1'b1;
                        step  <= 1'b0;
                        state <= START;
                    end
                end
                START: begin
                    miso <= tx_shift_reg[7];
                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                    state <= DATA;
                end
                DATA: begin
                    if (sclk) begin
                        if (step == 0) begin
                            rx_shift_reg <= {rx_shift_reg[6:0], mosi};
                            step <= 1;
                        end
                    end else if (step == 1) begin
                        if (bit_cnt < 7) begin
                            miso <= tx_shift_reg[7];
                            tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                            step <= 0;
                            bit_cnt <= bit_cnt + 1;
                        end else begin
                            state   <= STOP;
                            rx_data <= rx_shift_reg;
                        end
                    end
                end
                STOP: begin
                    done  <= 1'b1;
                    busy  <= 1'b0;
                    miso  <= 1'b1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule

