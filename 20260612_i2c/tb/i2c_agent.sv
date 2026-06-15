class i2c_agent extends uvm_agent;

    `uvm_component_utils(i2c_agent)

    uvm_sequencer #(i2c_seq_item) sequencer;
    i2c_driver                  driver;
    i2c_monitor                 monitor;

    function new(string name = "i2c_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sequencer = uvm_sequencer#(i2c_seq_item)::type_id::create("sequencer", this);
        driver    = i2c_driver::type_id::create("driver", this);
        monitor   = i2c_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass
