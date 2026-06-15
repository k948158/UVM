interface spi_if;

    logic       clk;
    logic       rst;
    logic       start;
    logic       cpol;
    logic       cpha;
    logic [7:0] clk_div;
    logic [7:0] tx_data_master;
    logic       busy_master;
    logic       busy_slave;
    logic [7:0] rx_data_master;
    logic [7:0] rx_data_slave;
    logic       done_master;
    logic       done_slave;

endinterface
