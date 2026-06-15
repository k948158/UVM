`timescale 1ns / 1ps

module spi_master (
    input  logic       clk,
    input  logic       rst,
    //internal signals
    input  logic       start,
    input  logic       cpol,     //clock polarity
    input  logic       cpha,
    input  logic [7:0] clk_div,  //sclk speed change
    input  logic [7:0] tx_data,
    output logic       busy,
    output logic [7:0] rx_data,
    output logic       done,
    //external signals
    output logic       sclk,
    output logic       mosi,
    input  logic       miso,
    output logic       ss_n
);

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START,
        DATA,
        STOP
    } state_t;
    state_t state;

    logic [7:0] div_cnt;
    logic half_tick;
    logic [7:0] tx_shift_reg;
    logic [7:0] rx_shift_reg;
    logic [3:0] bit_cnt;
    logic step;
    logic cpol_reg;
    logic cpha_reg;
    logic sclk_reg;
    logic [7:0] clk_div_reg;

    assign sclk = sclk_reg;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            div_cnt   <= 0;
            half_tick <= 0;
        end else begin
            if ((state == START) || (state == DATA)) begin
                if (div_cnt == clk_div_reg - 1) begin
                    div_cnt   <= 0;
                    half_tick <= 1'b1;
                end else begin
                    div_cnt   <= div_cnt + 1;
                    half_tick <= 1'b0;
                end
            end else begin
                div_cnt   <= 0;
                half_tick <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
            mosi <= 1'b1;
            ss_n <= 1'b1;
            busy <= 1'b0;
            done <= 1'b0;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            bit_cnt <= 0;
            rx_data <= 0;
            sclk_reg <= cpol;
            cpol_reg <= 1'b0;
            cpha_reg <= 1'b0;
            clk_div_reg <= 0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    mosi <= 1'b1;
                    ss_n <= 1'b1;
                    sclk_reg <= cpol;
                    cpha_reg <= cpha;
                    if (start) begin
                        tx_shift_reg <= tx_data;  //Latching
                        clk_div_reg <= clk_div;  //Latching
                        cpol_reg <= cpol;
                        bit_cnt <= 0;
                        busy <= 1'b1;
                        step <= 1'b0;
                        ss_n <= 1'b0;
                        state <= START;
                    end
                end
                START: begin
                    if (!cpha_reg) begin
                        mosi <= tx_shift_reg[7];
                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                        state <= DATA;
                    end else if (cpha_reg) begin
                        if (half_tick) begin
                            mosi <= tx_shift_reg[7];
                            tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                            state <= DATA;
                        end
                    end
                end
                DATA: begin
                    if (half_tick) begin
                        sclk_reg <= ~sclk_reg;
                        if (step == 0) begin
                            rx_shift_reg <= {rx_shift_reg[6:0], miso};
                            step <= 1;
                        end else begin
                            if (bit_cnt < 7) begin
                                mosi <= tx_shift_reg[7];
                                tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                step <= 0;
                                bit_cnt <= bit_cnt + 1;
                            end else if ((bit_cnt == 7) && cpha_reg) begin
                                mosi <= tx_shift_reg[7];
                                tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                state <= STOP;
                                rx_data <= rx_shift_reg;
                            end else begin
                                state   <= STOP;
                                rx_data <= rx_shift_reg;
                            end
                        end
                    end
                end
                STOP: begin
                    sclk_reg <= cpol_reg;
                    ss_n <= 1'b1;
                    done <= 1'b1;
                    busy <= 1'b0;
                    mosi <= 1'b1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
