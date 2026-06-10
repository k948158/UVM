`include "uvm_macros.svh"
import uvm_pkg::*;

interface ram_interface (
    input logic clk
);

    logic       we;
    logic [7:0] addr;
    logic [7:0] wdata;
    logic [7:0] rdata;
endinterface  //ram_interface

class ram_seq_item extends uvm_sequence_item;
    rand logic       we;
    rand logic [7:0] addr;
    rand logic [7:0] wdata;
    logic      [7:0] rdata;
    function new(string name = "ram_seq_item");
        super.new(name);
    endfunction  //new()
    `uvm_object_utils_begin(ram_seq_item)
        `uvm_field_int(we, UVM_DEFAULT)
        `uvm_field_int(addr, UVM_DEFAULT)
        `uvm_field_int(wdata, UVM_DEFAULT)
        `uvm_field_int(rdata, UVM_DEFAULT)
    `uvm_object_utils_end
    function string convert2string();
        return $sformatf(
            "we =%0d, addr = %0d, wdata= %0d, rdata= %0d",
            we,
            addr,
            wdata,
            rdata
        );

    endfunction
endclass  //ram_seq_item extends uvm_seq_item

class ram_sequence extends uvm_sequence;
    `uvm_object_utils(ram_sequence)
    ram_seq_item item;
    int          loop_count;
    function new(string name = "ram_sequence");
        super.new(name);
    endfunction  //new()

    virtual task body();
        for (int i = 0; i < loop_count; i++) begin
            item = ram_seq_item::type_id::create($sformatf("item: %0d", i));
            start_item(item);
            if (!item.randomize())
                `uvm_fatal(get_type_name(), "Randomized fail!")
            finish_item(item);
        end
    endtask
endclass  //ram_sequence extends uvm_sequence

class ram_driver extends uvm_driver #(ram_seq_item);
    `uvm_component_utils(ram_driver)
    virtual ram_interface ram_if;

    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ram_interface)::get(
                this, "", "ram_if", ram_if
            ))
            `uvm_fatal(get_type_name(), "Connect interface fail!")
        else `uvm_info(get_type_name(), "build_phase complete", UVM_HIGH)
    endfunction
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            ram_seq_item item;
            seq_item_port.get_next_item(item);
            @(negedge ram_if.clk);
            ram_if.we <= item.we;
            ram_if.addr <= item.addr;
            ram_if.wdata <= item.wdata;
            `uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM)
            seq_item_port.item_done();
        end
    endtask  //
    virtual function void report_phase(uvm_phase phase);


    endfunction
endclass  //ram_driver extends superClass

class ram_monitor extends uvm_monitor;
    `uvm_component_utils(ram_monitor)
    uvm_analysis_port #(ram_seq_item) ap;
    virtual ram_interface ram_if;

    function new(string name, uvm_component c);
        super.new(name, c);
        ap = new("ap", this);
    endfunction  //new()
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ram_interface)::get(
                this, "", "ram_if", ram_if
            ))
            `uvm_fatal(get_type_name(), "Connect interface fail!")
        else `uvm_info(get_type_name(), "build_phase complete", UVM_HIGH)
    endfunction
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            ram_seq_item item;
            item = ram_seq_item::type_id::create("item");
            @(posedge ram_if.clk);
            #1;
            item.we = ram_if.we;
            item.addr = ram_if.addr;
            item.wdata = ram_if.wdata;
            item.rdata = ram_if.rdata;
            `uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM)
            ap.write(item);
        end
    endtask  //
    virtual function void report_phase(uvm_phase phase);


    endfunction
endclass  //ram_driver extends superClass

class ram_agent extends uvm_agent;
    `uvm_component_utils(ram_agent)
    uvm_sequencer #(ram_seq_item) sqr;
    ram_driver drv;
    ram_monitor mon;

    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = uvm_sequencer#(ram_seq_item)::type_id::create("sqr", this);
        drv = ram_driver::type_id::create("drv", this);
        mon = ram_monitor::type_id::create("mon", this);
    endfunction
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

    virtual task run_phase(uvm_phase phase);

    endtask  //
    virtual function void report_phase(uvm_phase phase);


    endfunction
endclass  //ram_driver extends superClass

class ram_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ram_scoreboard)
    uvm_analysis_imp #(ram_seq_item, ram_scoreboard) ap_imp;
    int fail_count;
    int pass_count;
    logic [7:0] sram[0:255];
    function new(string name, uvm_component c);
        super.new(name, c);
        ap_imp = new("ap_imp", this);
        fail_count = 0;
        pass_count = 0;
    endfunction  //new()
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);

    endtask  //
    virtual function void write(ram_seq_item item);
        if (item.we) begin
            sram[item.addr] = item.wdata;
            `uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM)
        end else begin
            if (item.rdata === sram[item.addr]) begin
                `uvm_info(get_type_name(), $sformatf(("rdata= %0d, sram= %0d"),
                                                     item.rdata,
                                                     sram[item.addr]), UVM_LOW)
                pass_count++;
            end else begin
                `uvm_error(get_type_name(), item.convert2string())
                fail_count++;
            end
        end

    endfunction
    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
                  "============Scoreboard Summary=============", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(
                  "Total transactions: %0d", pass_count + fail_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(
                  "Pass transactions: %0d", pass_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(
                  "Fail transactions: %0d", fail_count), UVM_LOW)
        if (fail_count > 0) begin
            `uvm_error(get_type_name(),
                       $sformatf("TEST FAILED: %0d ,mismatches detected!",
                                 fail_count))
        end else begin
            `uvm_info(get_type_name(), $sformatf(
                      "TEST PASSED: %0d ,matches detected!", pass_count),
                      UVM_LOW)
        end

    endfunction
endclass

class ram_env extends uvm_env;
    `uvm_component_utils(ram_env)
    ram_agent agt;
    ram_scoreboard scb;

    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = ram_agent::type_id::create("agt", this);
        scb = ram_scoreboard::type_id::create("scb", this);
    endfunction
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.mon.ap.connect(scb.ap_imp);
    endfunction

    virtual task run_phase(uvm_phase phase);

    endtask  //
    virtual function void report_phase(uvm_phase phase);


    endfunction
endclass

class ram_test extends uvm_test;
    `uvm_component_utils(ram_test)

    ram_env env;

    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = ram_env::type_id::create("env", this);
        `uvm_info(get_type_name(), "build_phase", UVM_HIGH)
    endfunction
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "connect_phase", UVM_HIGH)
    endfunction

    virtual task run_phase(uvm_phase phase);
        ram_sequence seq;
        phase.raise_objection(this);
        seq = ram_sequence::type_id::create("seq", this);
        seq.loop_count = 100;
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask  //
    virtual function void report_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction
endclass  //ram_test extends uvm_test

module tb_ram ();
    logic clk;

    always #5 clk = ~clk;
    initial begin
        clk = 0;
    end
    ram_interface ram_if (clk);
    ram dut (
        .clk(ram_if.clk),
        .we(ram_if.we),
        .addr(ram_if.addr),
        .wdata(ram_if.wdata),
        .rdata(ram_if.rdata)
    );
    initial begin
        $fsdbDumpfile("ram_tb.fsdb");
        $fsdbDumpvars(0);
        $fsdbDumpMDA();
        uvm_config_db#(virtual ram_interface)::set(null, "*", "ram_if", ram_if);
        run_test("ram_test");
    end
endmodule
