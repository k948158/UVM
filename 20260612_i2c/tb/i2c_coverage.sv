class i2c_coverage extends uvm_subscriber #(i2c_seq_item);

    `uvm_component_utils(i2c_coverage)

    i2c_seq_item tr;

    covergroup i2c_cg;
        option.per_instance = 1;

        cp_tx_data: coverpoint tr.tx_data {
            bins data_zero = {8'h00};
            bins data_low  = {[8'h01:8'h54]};
            bins data_mid  = {[8'h55:8'hAA]};
            bins data_high = {[8'hAB:8'hFE]};
            bins data_max  = {8'hFF};
        }

        cp_master_rx: coverpoint tr.rx_data_master {
            bins data_zero = {8'h00};
            bins data_etc  = {[8'h01:8'hFE]};
            bins data_max  = {8'hFF};
        }

        cp_slave_rx: coverpoint tr.rx_data_slave {
            bins data_zero = {8'h00};
            bins data_etc  = {[8'h01:8'hFE]};
            bins data_max  = {8'hFF};
        }

        cp_ack: coverpoint tr.ack_error {
            bins ack_ok = {0};
            illegal_bins ack_error = {1};
        }
    endgroup

    function new(string name = "i2c_coverage", uvm_component parent = null);
        super.new(name, parent);
        i2c_cg = new();
    endfunction

    function void write(i2c_seq_item t);
        tr = t;
        i2c_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("COV", "==============================", UVM_LOW)
        `uvm_info("COV", "= Functional Coverage Result =", UVM_LOW)
        `uvm_info("COV", $sformatf(" total       : %6.2f%%",
                  i2c_cg.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf(" TX data     : %6.2f%%",
                  i2c_cg.cp_tx_data.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf(" master RX   : %6.2f%%",
                  i2c_cg.cp_master_rx.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf(" slave RX    : %6.2f%%",
                  i2c_cg.cp_slave_rx.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf(" ACK         : %6.2f%%",
                  i2c_cg.cp_ack.get_inst_coverage()), UVM_LOW)
    endfunction

endclass
