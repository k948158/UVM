`include "uvm_macros.svh"
import uvm_pkg::*;

interface ram_interface(input logic clk);
    logic       we;
    logic [7:0] addr;
    logic [7:0] wdata;
    logic [7:0] rdata;
endinterface


class ram_seq_item extends uvm_sequence_item;
    rand logic       we;
    rand logic [7:0] addr;
    rand logic [7:0] wdata;
         logic [7:0] rdata;

    function new(string name = "ram_seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(ram_seq_item)
        `uvm_field_int(we,    UVM_DEFAULT)
        `uvm_field_int(addr,  UVM_DEFAULT)
        `uvm_field_int(wdata, UVM_DEFAULT)
        `uvm_field_int(rdata, UVM_DEFAULT)
    `uvm_object_utils_end
endclass


class ram_seq extends uvm_sequence #(ram_seq_item);
    `uvm_object_utils(ram_seq)

    ram_seq_item item;

    function new(string name = "ram_seq");
        super.new(name);
    endfunction

    virtual task body();
        repeat (100) begin
            item = ram_seq_item::type_id::create("item");
            start_item(item);

            if (!item.randomize()) begin
                `uvm_error("SEQ", "Randomization failed")
            end

            finish_item(item);
        end
    endtask
endclass


class ram_drv extends uvm_driver #(ram_seq_item);
    `uvm_component_utils(ram_drv)

    virtual ram_interface ram_if;
    ram_seq_item item;

    function new(string name = "ram_drv", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual ram_interface)::get(
            this, "", "ram_if", ram_if
        )) begin
            `uvm_fatal("DRV", "Unable to access ram interface")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(item);

            @(posedge ram_if.clk);
            ram_if.we    <= item.we;
            ram_if.addr  <= item.addr;
            ram_if.wdata <= item.wdata;

            seq_item_port.item_done();
        end
    endtask
endclass


class ram_mon extends uvm_monitor;
    `uvm_component_utils(ram_mon)

    virtual ram_interface ram_if;
    uvm_analysis_port #(ram_seq_item) send;

    function new(string name = "ram_mon", uvm_component parent);
        super.new(name, parent);
        send = new("send", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual ram_interface)::get(
            this, "", "ram_if", ram_if
        )) begin
            `uvm_fatal("MON", "Unable to access ram interface")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        ram_seq_item item;

        forever begin
            @(posedge ram_if.clk);
            #1;

            item = ram_seq_item::type_id::create("item");

            item.we    = ram_if.we;
            item.addr  = ram_if.addr;
            item.wdata = ram_if.wdata;
            item.rdata = ram_if.rdata;

            send.write(item);
        end
    endtask
endclass


class ram_scb extends uvm_scoreboard;
    `uvm_component_utils(ram_scb)

    uvm_analysis_imp #(ram_seq_item, ram_scb) recv;
    logic [7:0] ref_mem [0:255];

    function new(string name = "ram_scb", uvm_component parent);
        super.new(name, parent);
        recv = new("recv", this);
    endfunction

    virtual function void write(ram_seq_item data);
        if (data.we) begin
            ref_mem[data.addr] = data.wdata;

            `uvm_info("SCB", $sformatf(
                "WRITE addr=%0d, wdata=%0d",
                data.addr, data.wdata
            ), UVM_LOW)
        end
        else if(data.rdata != 8'hxx)begin
            if (data.rdata == ref_mem[data.addr]) begin
                `uvm_info("SCB", $sformatf(
                    "READ PASS addr=%0d, expected=%0d, rdata=%0d",
                    data.addr, ref_mem[data.addr], data.rdata
                ), UVM_LOW)
            end
            else begin
                `uvm_error("SCB", $sformatf(
                    "READ FAIL addr=%0d, expected=%0d, rdata=%0d",
                    data.addr, ref_mem[data.addr], data.rdata
                ))
            end
        end
    endfunction
endclass


class ram_agent extends uvm_agent;
    `uvm_component_utils(ram_agent)

    ram_drv drv;
    ram_mon mon;
    uvm_sequencer #(ram_seq_item) sqr;

    function new(string name = "ram_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        drv = ram_drv::type_id::create("DRV", this);
        mon = ram_mon::type_id::create("MON", this);
        sqr = uvm_sequencer#(ram_seq_item)::type_id::create("SQR", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass


class ram_env extends uvm_env;
    `uvm_component_utils(ram_env)

    ram_agent agent;
    ram_scb   scb;

    function new(string name = "ram_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent = ram_agent::type_id::create("AGENT", this);
        scb   = ram_scb::type_id::create("SCB", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.mon.send.connect(scb.recv);
    endfunction
endclass


class ram_test extends uvm_test;
    `uvm_component_utils(ram_test)

    ram_env env;
    ram_seq seq;

    function new(string name = "ram_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = ram_env::type_id::create("ENV", this);
        seq = ram_seq::type_id::create("SEQ", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        seq.start(env.agent.sqr);

        #100;

        phase.drop_objection(this);
    endtask
endclass


module tb_RAM;

    logic clk;

    always #5 clk = ~clk;

    ram_interface ram_if(clk);

    RAM dut (
        .clk   (clk),
        .we    (ram_if.we),
        .addr  (ram_if.addr),
        .wdata (ram_if.wdata),
        .rdata (ram_if.rdata)
    );

    initial begin
        clk = 0;
        ram_if.we    = 0;
        ram_if.addr  = 0;
        ram_if.wdata = 0;
    end

    initial begin
        $fsdbDumpfile("wave_ram.fsdb");
        $fsdbDumpvars(0);
    end

    initial begin
        uvm_config_db#(virtual ram_interface)::set(
            null,
            "*",
            "ram_if",
            ram_if
        );

        run_test("ram_test");
    end

endmodule