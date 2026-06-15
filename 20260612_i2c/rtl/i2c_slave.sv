`timescale 1ns / 1ps

module i2c_slave_top #(
    parameter logic [6:0] SLAVE_ADDR = 7'h40
) (
    input  logic       clk,
    input  logic       reset,
    input  logic       scl,
    input  logic [7:0] tx_data,
    input  logic       ack_in,
    output logic [7:0] rx_data,
    output logic       rx_valid,
    output logic       ack_out,
    output logic       busy,
    output logic       done,
    inout  wire        sda
);
    logic sda_o;
    logic sda_i;

    assign sda_i = sda;
    assign sda   = sda_o ? 1'bz : 1'b0;

    i2c_slave #(
        .SLAVE_ADDR(SLAVE_ADDR)
    ) U_I2C_SLAVE (
        .clk(clk),
        .reset(reset),
        .scl(scl),
        .tx_data(tx_data),
        .ack_in(ack_in),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .ack_out(ack_out),
        .busy(busy),
        .done(done),
        .sda_o(sda_o),
        .sda_i(sda_i)
    );
endmodule

module i2c_slave #(
    parameter logic [6:0] SLAVE_ADDR = 7'h40
) (
    input  logic       clk,
    input  logic       reset,
    input  logic       scl,
    input  logic [7:0] tx_data,
    input  logic       ack_in,
    output logic [7:0] rx_data,
    output logic       rx_valid,
    output logic       ack_out,
    output logic       busy,
    output logic       done,
    output logic       sda_o,
    input  logic       sda_i
);

    typedef enum logic [3:0] {
        IDLE,
        ADDRESS,
        ADDRESS_ACK,
        RX_DATA,
        TX_DATA,
        DATA_ACK,
        STOP
    } state_t;

    state_t state;

    logic [1:0] scl_sync;
    logic [1:0] sda_sync;
    logic       scl_prev;
    logic       sda_prev;

    logic [7:0] tx_shift_reg;
    logic [7:0] rx_shift_reg;
    logic [2:0] bit_cnt;
    logic       master_read;
    logic       ack_clock_seen;

    wire scl_rise =  scl_sync[1] & ~scl_prev;
    wire scl_fall = ~scl_sync[1] &  scl_prev;
    wire start_cond =  sda_prev & ~sda_sync[1] & scl_sync[1];
    wire stop_cond  = ~sda_prev &  sda_sync[1] & scl_sync[1];

    // sda_o = 0 drives SDA low, sda_o = 1 releases the open-drain bus.
    assign busy = (state != IDLE);

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            scl_sync <= 2'b11;
            sda_sync <= 2'b11;
            scl_prev <= 1'b1;
            sda_prev <= 1'b1;
        end else begin
            scl_sync <= {scl_sync[0], scl};
            sda_sync <= {sda_sync[0], sda_i};
            scl_prev <= scl_sync[1];
            sda_prev <= sda_sync[1];
        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state          <= IDLE;
            sda_o          <= 1'b1;
            tx_shift_reg   <= 8'h00;
            rx_shift_reg   <= 8'h00;
            rx_data        <= 8'h00;
            rx_valid       <= 1'b0;
            bit_cnt        <= 3'd0;
            master_read    <= 1'b0;
            ack_clock_seen <= 1'b0;
            ack_out        <= 1'b1;
            done           <= 1'b0;
        end else begin
            done <= 1'b0;
            rx_valid <= 1'b0;

            // A repeated START restarts address reception from any state.
            if (start_cond) begin
                state          <= ADDRESS;
                sda_o          <= 1'b1;
                rx_shift_reg   <= 8'h00;
                bit_cnt        <= 3'd0;
                ack_clock_seen <= 1'b0;
            end else if (stop_cond) begin
                state <= IDLE;
                sda_o <= 1'b1;
                done  <= 1'b1;
            end else begin
                case (state)
                    IDLE: begin
                        sda_o <= 1'b1;
                    end

                    ADDRESS: begin
                        if (scl_rise) begin
                            rx_shift_reg <= {rx_shift_reg[6:0], sda_sync[1]};
                            if (bit_cnt == 3'd7) begin
                                bit_cnt <= 3'd0;
                                master_read <= sda_sync[1];

                                if ({rx_shift_reg[6:0]} == SLAVE_ADDR) begin
                                    state <= ADDRESS_ACK;
                                    ack_clock_seen <= 1'b0;
                                end else begin
                                    state <= STOP;
                                end
                            end else begin
                                bit_cnt <= bit_cnt + 1'b1;
                            end
                        end
                    end

                    ADDRESS_ACK: begin
                        if (scl_fall && !ack_clock_seen) begin
                            sda_o <= 1'b0;
                        end else if (scl_rise) begin
                            ack_clock_seen <= 1'b1;
                        end else if (scl_fall && ack_clock_seen) begin
                            ack_clock_seen <= 1'b0;
                            bit_cnt <= 3'd0;

                            if (master_read) begin
                                sda_o <= tx_data[7];
                                tx_shift_reg <= {tx_data[6:0], 1'b0};
                                state <= TX_DATA;
                            end else begin
                                sda_o <= 1'b1;
                                rx_shift_reg <= 8'h00;
                                state <= RX_DATA;
                            end
                        end
                    end

                    RX_DATA: begin
                        if (scl_rise) begin
                            rx_shift_reg <= {rx_shift_reg[6:0], sda_sync[1]};
                            if (bit_cnt == 3'd7) begin
                                rx_data <= {rx_shift_reg[6:0], sda_sync[1]};
                                rx_valid <= 1'b1;
                                bit_cnt <= 3'd0;
                                ack_clock_seen <= 1'b0;
                                state <= DATA_ACK;
                            end else begin
                                bit_cnt <= bit_cnt + 1'b1;
                            end
                        end
                    end

                    TX_DATA: begin
                        // Prepare the next bit while SCL is low.
                        if (scl_fall) begin
                            sda_o <= tx_shift_reg[7];
                            tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                        end

                        // The master samples the prepared bit on SCL rising.
                        if (scl_rise) begin
                            if (bit_cnt == 3'd7) begin
                                bit_cnt <= 3'd0;
                                ack_clock_seen <= 1'b0;
                                state <= DATA_ACK;
                            end else begin
                                bit_cnt <= bit_cnt + 1'b1;
                            end
                        end
                    end

                    DATA_ACK: begin
                        if (!master_read) begin
                            // ACK/NACK the byte received from the master.
                            if (scl_fall && !ack_clock_seen) begin
                                sda_o <= ack_in;
                            end else if (scl_rise) begin
                                ack_clock_seen <= 1'b1;
                            end else if (scl_fall && ack_clock_seen) begin
                                sda_o <= 1'b1;
                                ack_clock_seen <= 1'b0;
                                rx_shift_reg <= 8'h00;
                                state <= RX_DATA;
                            end
                        end else begin
                            // Release SDA, then sample the master's ACK/NACK.
                            if (scl_fall && !ack_clock_seen) begin
                                sda_o <= 1'b1;
                            end else if (scl_rise) begin
                                ack_out <= sda_sync[1];
                                ack_clock_seen <= 1'b1;
                            end else if (scl_fall && ack_clock_seen) begin
                                ack_clock_seen <= 1'b0;
                                if (!ack_out) begin
                                    sda_o <= tx_data[7];
                                    tx_shift_reg <= {tx_data[6:0], 1'b0};
                                    state <= TX_DATA;
                                end else begin
                                    state <= STOP;
                                end
                            end
                        end
                    end

                    STOP: begin
                        sda_o <= 1'b1;
                    end

                    default: begin
                        state <= IDLE;
                        sda_o <= 1'b1;
                    end
                endcase
            end
        end
    end

endmodule
