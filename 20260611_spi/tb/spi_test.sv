class spi_test extends uvm_test;

    `uvm_component_utils(spi_test)

    spi_env        env;
    virtual spi_if vif;

    function new(string name = "spi_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "spi_if was not found in uvm_config_db")
        end

        env = spi_env::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        `uvm_info("TOPOLOGY", "UVM testbench topology", UVM_LOW)
        uvm_top.print_topology();
    endfunction

    task run_phase(uvm_phase phase);
        spi_sequence seq;

        phase.raise_objection(this);

        seq = spi_sequence::type_id::create("seq");

        fork
            begin
                seq.start(env.agent.sequencer);
            end
            begin
                #1ms;
                `uvm_error("TIMEOUT", "SPI sequence did not finish within 1 ms")
            end
        join_any
        disable fork;

        repeat (20) @(posedge vif.clk);

        phase.drop_objection(this);
    endtask

endclass
