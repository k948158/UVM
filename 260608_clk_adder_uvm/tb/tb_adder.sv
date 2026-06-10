`include "uvm_macros.svh"
import uvm_pkg::*;

interface adder_if (
    input logic clk,
    input logic rst_n
);
    logic [7:0] a;
    logic [7:0] b;
    logic [8:0] y;
endinterface  //

class adder_seq_item extends uvm_sequence_item;
    rand logic [7:0] a;
    rand logic [7:0] b;
    logic [8:0] y;
    function new(string name = "adder_seq_item");
        super.new(name);
    endfunction  //new()
    `uvm_object_utils_begin(adder_seq_item);
        `uvm_field_int(a, UVM_DEFAULT)
        `uvm_field_int(b, UVM_DEFAULT)
        `uvm_field_int(y, UVM_DEFAULT)
    `uvm_object_utils_end

    function string convert2string();
        return $sformatf("a=%0d, b=%0d, y=%0d", a, b, y);

    endfunction
endclass

class adder_sequence extends uvm_sequence;
    `uvm_object_utils(adder_sequence)
    int loop_count;

    function new(string name = "adder_sequence");
        super.new(name);
    endfunction  //new()

    virtual task body();
        adder_seq_item item;
        for (int i = 0; i < loop_count; i++) begin
            item = adder_seq_item::type_id::create($sformatf("item_%0d", i));
            start_item(item);
            if (!item.randomize())
                `uvm_fatal(get_type_name(), "Randomization failed!");
            finish_item(item);
        end
    endtask  //
endclass

class adder_driver extends uvm_driver #(adder_seq_item);
    `uvm_component_utils(adder_driver)
    virtual adder_if a_if;
    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual adder_if)::get(this, "", "a_if", a_if))
            `uvm_fatal(get_type_name(), "a_if not found!")
        `uvm_info(get_type_name(), "build_phase complete", UVM_HIGH);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction

    virtual task drive_item(adder_seq_item item);
        a_if.a <= item.a;
        a_if.b <= item.b;
        @(posedge a_if.clk);
        @(posedge a_if.clk);
        `uvm_info(get_type_name(), item.convert2string(), UVM_HIGH);
    endtask

    virtual task run_phase(uvm_phase phase);
        adder_seq_item item;
        @(posedge a_if.rst_n);
        forever begin
            seq_item_port.get_next_item(item);
            drive_item(item);
            seq_item_port.item_done();
        end
    endtask

    virtual function void report_phase(uvm_phase phase);


    endfunction
endclass

class adder_monitor extends uvm_monitor;
    `uvm_component_utils(adder_monitor)
    uvm_analysis_port #(adder_seq_item) ap;
    virtual adder_if a_if;
    function new(string name, uvm_component c);
        super.new(name, c);
        ap = new("ap", this);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual adder_if)::get(this, "", "a_if", a_if))
            `uvm_fatal(get_type_name(), "a_if not found!")
        `uvm_info(get_type_name(), "build_phase complete", UVM_HIGH);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction

    virtual task run_phase(uvm_phase phase);
        @(posedge a_if.rst_n);
        forever begin
            adder_seq_item item = adder_seq_item::type_id::create("item");
            @(posedge a_if.clk);
            item.a = a_if.a;
            item.b = a_if.b;
            @(posedge a_if.clk);
            item.y = a_if.y;
            ap.write(item);
            `uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM)

        end
    endtask


endclass

class adder_component1 extends uvm_component;
    `uvm_component_utils(adder_component1)
    uvm_analysis_imp #(adder_seq_item, adder_component1) ap_imp_comp1;
    function new(string name, uvm_component c);
        super.new(name, c);
        ap_imp_comp1 = new("ap_imp_comp2", this);

    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction

    virtual task run_phase(uvm_phase phase);

    endtask
    virtual function void write(adder_seq_item item);
        `uvm_info(get_type_name(), $sformatf(
                  "received: %s", item.convert2string()), UVM_MEDIUM)

    endfunction
endclass  //adder_component extends uvm_component 

class adder_component2 extends uvm_component;
    `uvm_component_utils(adder_component2)
    uvm_analysis_imp #(adder_seq_item, adder_component2) ap_imp_comp2;
    function new(string name, uvm_component c);
        super.new(name, c);
        ap_imp_comp2 = new("ap_imp_comp2", this);

    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction

    virtual task run_phase(uvm_phase phase);

    endtask
    virtual function void write(adder_seq_item item);
        `uvm_info(get_type_name(), $sformatf(
                  "received: %s", item.convert2string()), UVM_MEDIUM)

    endfunction
endclass

class adder_subscriber extends uvm_subscriber #(adder_seq_item);
    `uvm_component_utils(adder_subscriber)

    function new(string name, uvm_component c);
        super.new(name, c);

    endfunction  //new()

    virtual function void write(adder_seq_item item);
        `uvm_info(get_type_name(), $sformatf(
                  "adder_subscriber: %s", item.convert2string()), UVM_MEDIUM)

    endfunction
endclass  //adder_subscriber extends superClass

class adder_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(adder_scoreboard)
    uvm_analysis_imp #(adder_seq_item, adder_scoreboard) ap_imp;

    int fail_count;
    int pass_count;
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

    endtask
    virtual function void write(adder_seq_item item);
        `uvm_info(get_type_name(), $sformatf(
                  "received: %s", item.convert2string()), UVM_MEDIUM)
        //if (item.y === item.a + item.b) begin
        //    `uvm_info(get_type_name(), $sformatf(
        //                                   "Matched!: y:%0d === a:%d + b:%d",
        //                                   item.y, item.a, item.b), UVM_MEDIUM)
        //    pass_count++;
        //end else begin
        //    `uvm_error(get_type_name(), $sformatf(
        //               "Error!: y:%0d === a:%d + b:%d", item.y, item.a, item.b))
        //    fail_count++;
        //end

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

class adder_agent extends uvm_agent;
    `uvm_component_utils(adder_agent)

    uvm_sequencer #(adder_seq_item) sqr;
    adder_driver drv;
    adder_monitor mon;
    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = uvm_sequencer#(adder_seq_item)::type_id::create("sqr", this);
        drv = adder_driver::type_id::create("drv", this);
        mon = adder_monitor::type_id::create("mon", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

    virtual task run_phase(uvm_phase phase);

    endtask

    virtual function void report_phase(uvm_phase phase);


    endfunction
endclass

class adder_env extends uvm_env;
    `uvm_component_utils(adder_env)

    adder_agent agt;
    adder_scoreboard scb;
    adder_component1 cmp1;
    adder_component2 cmp2;
    adder_subscriber subs;
    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt  = adder_agent::type_id::create("agt", this);
        scb  = adder_scoreboard::type_id::create("scb", this);
        cmp1 = adder_component1::type_id::create("cmp1", this);
        cmp2 = adder_component2::type_id::create("cmp2", this);
        subs = adder_subscriber::type_id::create("subs", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.mon.ap.connect(scb.ap_imp);
        agt.mon.ap.connect(cmp1.ap_imp_comp1);
        agt.mon.ap.connect(cmp2.ap_imp_comp2);
        agt.mon.ap.connect(subs.analysis_export);
    endfunction

    virtual task run_phase(uvm_phase phase);

    endtask

    virtual function void report_phase(uvm_phase phase);


    endfunction
endclass

class adder_test extends uvm_test;
    `uvm_component_utils(adder_test)

    adder_env env;
    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = adder_env::type_id::create("env", this);
        `uvm_info(get_type_name(), "build_phase", UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "build_phase", UVM_HIGH)
    endfunction

    virtual task run_phase(uvm_phase phase);
        adder_sequence seq;
        `uvm_info(get_type_name(), "adder_sequence_phase", UVM_DEBUG)
        phase.raise_objection(this);
        `uvm_info(get_type_name(), "phase_raise_objection", UVM_DEBUG)
        seq = adder_sequence::type_id::create("seq", this);
        seq.loop_count = 10;
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "phase_drop_objection", UVM_DEBUG)
    endtask

    virtual function void report_phase(uvm_phase phase);

        uvm_top.print_topology();
    endfunction
endclass  //adder_test extends uvm_test

module tb_adder ();
    logic clk, rst_n;

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        rst_n = 0;
        #10;
        rst_n = 1;
    end

    adder_if a_if (
        clk,
        rst_n
    );
    adder dut (
        .clk(a_if.clk),
        .rst_n(a_if.rst_n),
        .a(a_if.a),
        .b(a_if.b),
        .y(a_if.y)
    );

    initial begin
        uvm_config_db#(virtual adder_if)::set(null, "*", "a_if", a_if);
        run_test("adder_test");
    end

endmodule
