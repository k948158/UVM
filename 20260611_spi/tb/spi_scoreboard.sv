class spi_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(spi_scoreboard)

    uvm_analysis_imp #(spi_seq_item, spi_scoreboard) sb_imp;
    logic [7:0] previous_tx;
    bit         previous_valid;
    int         transfer_count;
    int         pass_count;
    int         fail_count;

    function new(string name = "spi_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        sb_imp = new("sb_imp", this);
    endfunction

    function void write(spi_seq_item item);
        bit item_pass = 1'b1;

        transfer_count++;

        if (item.rx_data_slave !== item.tx_data_master) begin
            item_pass = 1'b0;
            `uvm_error("SPI_SCB",
                       $sformatf("slave RX mismatch: expected=0x%02h actual=0x%02h",
                                 item.tx_data_master, item.rx_data_slave))
        end

        if (previous_valid && item.rx_data_master !== previous_tx) begin
            item_pass = 1'b0;
            `uvm_error("SPI_SCB",
                       $sformatf("loopback mismatch: expected=0x%02h actual=0x%02h",
                                 previous_tx, item.rx_data_master))
        end

        if (item_pass) begin
            pass_count++;
            `uvm_info("SPI_SCB",
                      $sformatf("PASS: tx_master=0x%02h rx_slave=0x%02h rx_master=0x%02h",
                                item.tx_data_master,
                                item.rx_data_slave,
                                item.rx_data_master),
                      UVM_HIGH)
        end
        else begin
            fail_count++;
        end

        previous_tx    = item.tx_data_master;
        previous_valid = 1'b1;
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("SCB", "===================================", UVM_LOW)
        `uvm_info("SCB", "========= SPI SCOREBOARD ==========", UVM_LOW)
        `uvm_info("SCB", $sformatf("transfer count: %0d", transfer_count), UVM_LOW)
        `uvm_info("SCB", $sformatf("pass count:     %0d", pass_count), UVM_LOW)
        `uvm_info("SCB", $sformatf("fail count:     %0d", fail_count), UVM_LOW)
        `uvm_info("SCB", "===================================", UVM_LOW)
    endfunction

endclass
