class i2c_test extends uvm_test;

    `uvm_component_utils(i2c_test)

    i2c_env        env;
    virtual i2c_if vif;

    function new(string name = "i2c_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "i2c_if was not found in uvm_config_db")
        end
        env = i2c_env::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

    task run_phase(uvm_phase phase);
        i2c_sequence seq;

        phase.raise_objection(this);
        seq = i2c_sequence::type_id::create("seq");

        fork
            seq.start(env.agent.sequencer);
            begin
                #100ms;
                `uvm_fatal("TIMEOUT", "I2C sequence did not finish within 100 ms")
            end
        join_any
        disable fork;

        repeat (10) @(posedge vif.clk);
        phase.drop_objection(this);
    endtask

endclass
