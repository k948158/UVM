class spi_monitor extends uvm_monitor;

    `uvm_component_utils(spi_monitor)

    virtual spi_if vif;
    uvm_analysis_port #(spi_seq_item) mon_ap;

    function new(string name = "spi_monitor", uvm_component parent = null);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "spi_if was not found in uvm_config_db")
        end
    endfunction

    task run_phase(uvm_phase phase);
        spi_seq_item item;

        wait (vif.rst == 1'b0);

        forever begin
            @(posedge vif.start);

            item = spi_seq_item::type_id::create("item");
            item.tx_data_master = vif.tx_data_master;
            item.cpol           = vif.cpol;
            item.cpha           = vif.cpha;
            item.clk_div        = vif.clk_div;

            fork
                begin
                    wait (vif.done_master == 1'b1);
                    item.rx_data_master = vif.rx_data_master;
                    item.done_master    = vif.done_master;
                end
                begin
                    wait (vif.done_slave == 1'b1);
                    item.rx_data_slave = vif.rx_data_slave;
                    item.done_slave    = vif.done_slave;
                end
            join

            item.busy_master = vif.busy_master;
            item.busy_slave  = vif.busy_slave;
            mon_ap.write(item);
        end
    endtask

endclass
