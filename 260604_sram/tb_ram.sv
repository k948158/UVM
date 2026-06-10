`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/01 13:30:11
// Design Name: 
// Module Name: tb_RAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
interface ram_interface;
    logic       clk;
    logic       we;
    logic [7:0] addr;
    logic [7:0] wdata;
    logic [7:0] rdata;
endinterface  //ram_if

class transaction;
    rand logic       we;
    rand logic [7:0] addr;
    rand logic [7:0] wdata;
    logic      [7:0] rdata;
endclass  //transaction

class generator;
    transaction            tr;
    mailbox #(transaction) gen2drv_mbox;
    event                  event_gen_next;
    function new(mailbox#(transaction) gen2drv_mbox, event event_gen_next);
        this.gen2drv_mbox   = gen2drv_mbox;
        this.event_gen_next = event_gen_next;
    endfunction  //new()

    task run(int num);
        repeat (num) begin
            tr = new();
            tr.randomize();
            gen2drv_mbox.put(tr);
            @(event_gen_next);
        end
    endtask  //
endclass  //generator

class driver;

    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    virtual ram_interface ram_vif;
    byte queue[$];
    function new(mailbox#(transaction) gen2drv_mbox,
                 virtual ram_interface ram_vif);
        this.gen2drv_mbox = gen2drv_mbox;
        this.ram_vif = ram_vif;
    endfunction  //new()

    task preset();
        ram_vif.addr  = 0;
        ram_vif.wdata = 0;
        ram_vif.we    = 1;
        @(posedge ram_vif.clk);
    endtask  //
    task write();
        forever begin
            @(posedge ram_vif.clk);
            gen2drv_mbox.get(tr);
            #2;
            ram_vif.we    = 1'b1;
            ram_vif.addr  = tr.addr;
            ram_vif.wdata = tr.wdata;
            queue.push_back(tr.addr);
        end

    endtask  //
    task read();
        forever begin
            @(posedge ram_vif.clk);
            gen2drv_mbox.get(tr);
            #2;
            ram_vif.we   = 1'b0;
            ram_vif.addr = queue.pop_front();
        end

    endtask  //

endclass  //driver

class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    virtual ram_interface ram_vif;
    function new(mailbox#(transaction) mon2scb_mbox,
                 virtual ram_interface ram_vif);
        this.mon2scb_mbox = mon2scb_mbox;
        this.ram_vif = ram_vif;
    endfunction  //new()
    task run();
        forever begin
            @(posedge ram_vif.clk);
            #1;
            tr = new();
            tr.addr = ram_vif.addr;
            tr.wdata = ram_vif.wdata;
            tr.we = ram_vif.we;
            tr.rdata = ram_vif.rdata;
            mon2scb_mbox.put(tr);

        end
    endtask  //
endclass  //monitor

class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    event event_gen_next;
    int total_cnt = 0, pass_cnt = 0, fail_cnt = 0;
    logic [7:0] mem[256];
    function new(mailbox#(transaction) mon2scb_mbox, event event_gen_next);
        this.mon2scb_mbox   = mon2scb_mbox;
        this.event_gen_next = event_gen_next;
    endfunction  //new()

    task run();
        forever begin
            mon2scb_mbox.get(tr);
            if (tr.we) begin
                mem[tr.addr] = tr.wdata;
            end else begin  // read scenario
                total_cnt++;
                if (tr.rdata == mem[tr.addr]) begin
                    $display("%t : PASS", $time);
                    pass_cnt++;
                end else begin
                    $display(
                        "%t : FAIL addr = %d, wdata %d, rdata = %d, compare data = %d",
                        $time, tr.addr, tr.wdata, tr.rdata, mem[tr.addr]);
                    fail_cnt++;
                end
            end
            ->event_gen_next;
        end
    endtask  //

endclass  //scoreboard

class environment;
    transaction tr;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    mailbox #(transaction) mon2scb_mbox;
    mailbox #(transaction) gen2drv_mbox;

    event event_gen_next;

    function new(virtual ram_interface ram_vif);
        gen2drv_mbox = new;
        mon2scb_mbox = new;
        gen = new(gen2drv_mbox, event_gen_next);
        drv = new(gen2drv_mbox, ram_vif);
        mon = new(mon2scb_mbox, ram_vif);
        scb = new(mon2scb_mbox, event_gen_next);
    endfunction

    task write();
        //ram interface initial
        drv.preset();
        fork
            gen.run(10);
            drv.write();
            mon.run();
            scb.run();
        join_any
        disable fork;

    endtask
    task read();
        fork
            gen.run(10);
            drv.read();
            mon.run();
            scb.run();
        join_any

        #10;
        $display("env run task end");

        $display("________________________");
        $display("** SRAM IP Verificaiton **");
        $display("** total test num = %2d ***", scb.total_cnt);
        $display("** Pass test num = %2d ***", scb.pass_cnt);
        $display("** Fail test num = %2d ***", scb.fail_cnt);
        $display("*************************");
        $stop;

    endtask


endclass

module tb_RAM ();

    ram_interface ram_if ();
    environment env;
    RAM dut (
        .clk(ram_if.clk),
        .we(ram_if.we),
        .addr(ram_if.addr),
        .wdata(ram_if.wdata),
        .rdata(ram_if.rdata)
    );

    always #5 ram_if.clk = ~ram_if.clk;

    initial begin
	    $fsdbDumpfile("wave_ram.fsdb");
	    $fsdbDumpvars(0);
	    $fsdbDumpMDA();
        ram_if.clk = 0;
        env = new(ram_if);
        env.write();
        env.read();
        #10;
        $stop;
    end

endmodule
