`timescale 1ns / 1ps

module i2c_master_top (
    input  logic       clk,
    input  logic       reset,
    input  logic       cmd_start,
    input  logic       cmd_write,
    input  logic       cmd_read,
    input  logic       cmd_stop,
    input  logic [7:0] tx_data,
    input  logic       ack_in,
    output logic [7:0] rx_data,
    output logic       ack_out,
    output logic       busy,
    output logic       cmd_done,
    output logic       done,
    output logic       scl,
    inout  wire        sda
);
    logic sda_o;
    logic sda_i;

    assign sda_i = sda;
    assign sda   = sda_o ? 1'bz : 1'b0;

    i2c_master U_I2C_MASTER (
        .clk(clk), .reset(reset),
        .cmd_start(cmd_start), .cmd_write(cmd_write),
        .cmd_read(cmd_read), .cmd_stop(cmd_stop),
        .tx_data(tx_data), .ack_in(ack_in),
        .rx_data(rx_data), .ack_out(ack_out),
        .busy(busy), .cmd_done(cmd_done), .done(done),
        .scl(scl), .sda_o(sda_o), .sda_i(sda_i)
    );
endmodule

module i2c_master (
    input  logic       clk,
    input  logic       reset,
    input  logic       cmd_start,
    input  logic       cmd_write,
    input  logic       cmd_read,
    input  logic       cmd_stop,
    input  logic [7:0] tx_data,
    input  logic       ack_in,
    output logic [7:0] rx_data,
    output logic       ack_out,
    output logic       busy,
    output logic       cmd_done,
    output logic       done,
    output logic       scl,
    output logic       sda_o,
    input  logic       sda_i
);
    typedef enum logic [2:0] {
        IDLE,
        START,
        WAIT_CMD,
        DATA,
        DATA_ACK,
        STOP
    } state_t;

    state_t state;

    logic [7:0] div_cnt;
    logic       qtr_tick;
    logic [1:0] step;
    logic [7:0] tx_shift_reg;
    logic [7:0] rx_shift_reg;
    logic [2:0] bit_cnt;
    logic       is_read;
    logic       ack_in_r;

    assign busy = (state != IDLE);

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            div_cnt  <= 8'd0;
            qtr_tick <= 1'b0;
        end else if (state == IDLE || state == WAIT_CMD) begin
            div_cnt  <= 8'd0;
            qtr_tick <= 1'b0;
        end else if (div_cnt == 8'd249) begin
            div_cnt  <= 8'd0;
            qtr_tick <= 1'b1;
        end else begin
            div_cnt  <= div_cnt + 1'b1;
            qtr_tick <= 1'b0;
        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state          <= IDLE;
            scl            <= 1'b1;
            sda_o          <= 1'b1;
            step           <= 2'd0;
            bit_cnt        <= 3'd0;
            tx_shift_reg   <= 8'h00;
            rx_shift_reg   <= 8'h00;
            rx_data        <= 8'h00;
            ack_out        <= 1'b1;
            is_read        <= 1'b0;
            ack_in_r       <= 1'b1;
            cmd_done       <= 1'b0;
            done           <= 1'b0;
        end else begin
            cmd_done <= 1'b0;
            done     <= 1'b0;

            case (state)
                IDLE: begin
                    scl   <= 1'b1;
                    sda_o <= 1'b1;
                    step  <= 2'd0;
                    if (cmd_start)
                        state <= START;
                end

                START: begin
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                scl <= 1'b1; sda_o <= 1'b1; step <= 2'd1;
                            end
                            2'd1: begin
                                scl <= 1'b1; sda_o <= 1'b0; step <= 2'd2;
                            end
                            2'd2: begin
                                scl <= 1'b0; sda_o <= 1'b0; step <= 2'd3;
                            end
                            2'd3: begin
                                step <= 2'd0;
                                cmd_done <= 1'b1;
                                state <= WAIT_CMD;
                            end
                        endcase
                    end
                end

                WAIT_CMD: begin
                    if (cmd_write) begin
                        tx_shift_reg <= tx_data;
                        bit_cnt <= 3'd0;
                        is_read <= 1'b0;
                        step <= 2'd0;
                        state <= DATA;
                    end else if (cmd_read) begin
                        rx_shift_reg <= 8'h00;
                        bit_cnt <= 3'd0;
                        is_read <= 1'b1;
                        ack_in_r <= ack_in;
                        step <= 2'd0;
                        state <= DATA;
                    end else if (cmd_stop) begin
                        step <= 2'd0;
                        state <= STOP;
                    end else if (cmd_start) begin
                        step <= 2'd0;
                        state <= START;
                    end
                end

                DATA: begin
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                scl <= 1'b0;
                                sda_o <= is_read ? 1'b1 : tx_shift_reg[7];
                                step <= 2'd1;
                            end
                            2'd1: begin
                                scl <= 1'b1;
                                step <= 2'd2;
                            end
                            2'd2: begin
                                scl <= 1'b1;
                                if (is_read)
                                    rx_shift_reg <= {rx_shift_reg[6:0], sda_i};
                                step <= 2'd3;
                            end
                            2'd3: begin
                                scl <= 1'b0;
                                sda_o <= is_read ? 1'b1 : tx_shift_reg[7];
                                if (!is_read)
                                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                step <= 2'd0;

                                if (bit_cnt == 3'd7) begin
                                    state <= DATA_ACK;
                                end else begin
                                    bit_cnt <= bit_cnt + 1'b1;
                                end
                            end
                        endcase
                    end
                end

                DATA_ACK: begin
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                scl <= 1'b0;
                                sda_o <= is_read ? ack_in_r : 1'b1;
                                step <= 2'd1;
                            end
                            2'd1: begin
                                scl <= 1'b1;
                                step <= 2'd2;
                            end
                            2'd2: begin
                                scl <= 1'b1;
                                if (is_read)
                                    rx_data <= rx_shift_reg;
                                else
                                    ack_out <= sda_i;
                                step <= 2'd3;
                            end
                            2'd3: begin
                                scl <= 1'b0;
                                sda_o <= 1'b1;
                                step <= 2'd0;
                                cmd_done <= 1'b1;
                                state <= WAIT_CMD;
                            end
                        endcase
                    end
                end

                STOP: begin
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                scl <= 1'b0; sda_o <= 1'b0; step <= 2'd1;
                            end
                            2'd1: begin
                                scl <= 1'b1; sda_o <= 1'b0; step <= 2'd2;
                            end
                            2'd2: begin
                                scl <= 1'b1; sda_o <= 1'b1; step <= 2'd3;
                            end
                            2'd3: begin
                                step <= 2'd0;
                                cmd_done <= 1'b1;
                                done <= 1'b1;
                                state <= IDLE;
                            end
                        endcase
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
