interface i2c_if;

    logic       clk;
    logic       reset;

    logic       cmd_start;
    logic       cmd_write;
    logic       cmd_read;
    logic       cmd_stop;
    logic [7:0] tx_data_master;
    logic       master_ack_in;

    logic [7:0] rx_data_master;
    logic       master_ack_out;
    logic       busy_master;
    logic       cmd_done_master;
    logic       done_master;

    logic [7:0] rx_data_slave;
    logic       rx_valid_slave;
    logic       slave_ack_out;
    logic       busy_slave;
    logic       done_slave;
    logic [7:0] loopback_data;

    logic       scl;
    tri1        sda;

    // Testbench-only observation signals.
    logic [7:0] expected_data;
    logic       ack_error;

endinterface
