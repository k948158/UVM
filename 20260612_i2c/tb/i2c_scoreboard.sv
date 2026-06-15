class i2c_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(i2c_scoreboard)

    uvm_analysis_imp #(i2c_seq_item, i2c_scoreboard) sb_imp;

    int transfer_count;
    int pass_count;
    int fail_count;

    function new(string name = "i2c_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        sb_imp = new("sb_imp", this);
    endfunction

    function void write(i2c_seq_item item);
        bit item_pass = 1'b1;

        transfer_count++;

        if (item.ack_error) begin
            item_pass = 1'b0;
            `uvm_error("I2C_SCB", "ACK error occurred during the transaction")
        end

        if (item.rx_data_slave !== item.tx_data) begin
            item_pass = 1'b0;
            `uvm_error("I2C_SCB",
                       $sformatf("slave RX mismatch: expected=0x%02h actual=0x%02h",
                                 item.tx_data, item.rx_data_slave))
        end

        if (item.loopback_data !== item.tx_data) begin
            item_pass = 1'b0;
            `uvm_error("I2C_SCB",
                       $sformatf("loopback register mismatch: expected=0x%02h actual=0x%02h",
                                 item.tx_data, item.loopback_data))
        end

        if (item.rx_data_master !== item.tx_data) begin
            item_pass = 1'b0;
            `uvm_error("I2C_SCB",
                       $sformatf("master RX mismatch: expected=0x%02h actual=0x%02h",
                                 item.tx_data, item.rx_data_master))
        end

        if (item_pass) begin
            pass_count++;
            `uvm_info("I2C_SCB",
                      $sformatf("PASS: tx=0x%02h master_rx=0x%02h slave_rx=0x%02h",
                                item.tx_data,
                                item.rx_data_master,
                                item.rx_data_slave),
                      UVM_HIGH)
        end
        else begin
            fail_count++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("SCB", "===================================", UVM_LOW)
        `uvm_info("SCB", "========= I2C SCOREBOARD ==========", UVM_LOW)
        `uvm_info("SCB", $sformatf("transfer count: %0d", transfer_count), UVM_LOW)
        `uvm_info("SCB", $sformatf("pass count:     %0d", pass_count), UVM_LOW)
        `uvm_info("SCB", $sformatf("fail count:     %0d", fail_count), UVM_LOW)
        `uvm_info("SCB", "===================================", UVM_LOW)
    endfunction

endclass
