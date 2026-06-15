class spi_coverage extends uvm_subscriber #(spi_seq_item);

    `uvm_component_utils(spi_coverage)

    spi_seq_item tr;

    covergroup spi_cg;
        option.per_instance = 1;

        cp_cpol: coverpoint tr.cpol {
            bins mode0_cpol = {0};
            illegal_bins unsupported_cpol = {1};
        }

        cp_cpha: coverpoint tr.cpha {
            bins mode0_cpha = {0};
            illegal_bins unsupported_cpha = {1};
        }

        cp_mode: coverpoint {tr.cpol, tr.cpha} {
            bins mode0 = {2'b00};
            illegal_bins unsupported_modes = {2'b01, 2'b10, 2'b11};
        }

        cp_clk_div: coverpoint tr.clk_div {
            bins fast   = {[8'd2:8'd4]};
            bins mid = {[8'd5:8'd7]};
            bins slow   = {[8'd8:8'd10]};
        }

        cp_tx_data: coverpoint tr.tx_data_master {
            bins data_zero = {8'h00};
            bins data_low  = {[8'h01:8'h54]};
            bins data_mid  = {[8'h55:8'hAA]};
            bins data_high = {[8'hAB:8'hFE]};
            bins data_max  = {8'hFF};
        }

        cp_rx_slave: coverpoint tr.rx_data_slave {
            bins data_zero = {8'h00};
            bins data_etc  = {[8'h01:8'hFE]};
            bins data_max  = {8'hFF};
        }

        cp_done: coverpoint {tr.done_master, tr.done_slave} {
            bins both_done = {2'b11};
            illegal_bins incomplete = default;
        }

        cx_mode_clk_div: cross cp_mode, cp_clk_div;
        cx_mode_tx_data: cross cp_mode, cp_tx_data;
    endgroup

    function new(string name = "spi_coverage", uvm_component parent = null);
        super.new(name, parent);
        spi_cg = new();
    endfunction

    function void write(spi_seq_item t);
        tr = t;
        spi_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("COV", "==============================", UVM_LOW)
        `uvm_info("COV", "= Functional Coverage Result =", UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " total           : %6.2f%%",
                  spi_cg.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " SPI mode        : %6.2f%% (supported mode 0)",
                  spi_cg.cp_mode.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " clock divider   : %6.2f%% (fast/mid/slow)",
                  spi_cg.cp_clk_div.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " TX data         : %6.2f%% (0/low/mid/high/FF)",
                  spi_cg.cp_tx_data.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " slave RX data   : %6.2f%% (0/etc/FF)",
                  spi_cg.cp_rx_slave.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " mode x divider  : %6.2f%%",
                  spi_cg.cx_mode_clk_div.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " mode x TX data  : %6.2f%%",
                  spi_cg.cx_mode_tx_data.get_inst_coverage()), UVM_LOW)

        if (spi_cg.get_inst_coverage() < 100.0) begin
            `uvm_warning("COV",
                         "coverage is less than 100%! Try more test options.")
        end
    endfunction

endclass
