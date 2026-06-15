class i2c_monitor extends uvm_monitor;

    `uvm_component_utils(i2c_monitor)

    virtual i2c_if vif;
    uvm_analysis_port #(i2c_seq_item) mon_ap;

    function new(string name = "i2c_monitor", uvm_component parent = null);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "i2c_if was not found in uvm_config_db")
        end
    endfunction

    task run_phase(uvm_phase phase);
        i2c_seq_item item;

        wait (vif.reset == 1'b0);

        forever begin
            @(posedge vif.done_master);
            item = i2c_seq_item::type_id::create("item");
            item.tx_data        = vif.expected_data;
            item.rx_data_master = vif.rx_data_master;
            item.rx_data_slave  = vif.rx_data_slave;
            item.loopback_data  = vif.loopback_data;
            item.ack_error      = vif.ack_error;
            mon_ap.write(item);
        end
    endtask

endclass
