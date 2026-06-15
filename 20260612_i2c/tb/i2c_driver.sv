class i2c_driver extends uvm_driver #(i2c_seq_item);

    `uvm_component_utils(i2c_driver)

    localparam bit [6:0] SLAVE_ADDR = 7'h40;

    virtual i2c_if vif;

    function new(string name = "i2c_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "i2c_if was not found in uvm_config_db")
        end
    endfunction

    task wait_cmd_done(string command_name);
        bit timeout;
        timeout = 1'b0;

        fork : command_timeout
            begin
                wait (vif.cmd_done_master === 1'b1);
            end
            begin
                repeat (30000) @(posedge vif.clk);
                timeout = 1'b1;
            end
        join_any
        disable command_timeout;

        if (timeout) begin
            `uvm_fatal("I2C_TIMEOUT",
                       $sformatf("%s command did not complete", command_name))
        end

        @(posedge vif.clk);
    endtask

    task send_start();
        vif.cmd_start <= 1'b1;
        @(posedge vif.clk);
        vif.cmd_start <= 1'b0;
        wait_cmd_done("START");
    endtask

    task send_write(bit [7:0] data, string command_name);
        vif.tx_data_master <= data;
        vif.cmd_write      <= 1'b1;
        @(posedge vif.clk);
        vif.cmd_write <= 1'b0;
        wait_cmd_done(command_name);

        if (vif.master_ack_out !== 1'b0) begin
            vif.ack_error <= 1'b1;
            `uvm_error("I2C_ACK",
                       $sformatf("NACK received after %s, data=0x%02h",
                                 command_name, data))
        end
    endtask

    task send_read();
        // NACK the single received byte to terminate the slave transfer.
        vif.master_ack_in <= 1'b1;
        vif.cmd_read      <= 1'b1;
        @(posedge vif.clk);
        vif.cmd_read <= 1'b0;
        wait_cmd_done("READ DATA");
    endtask

    task send_stop();
        vif.cmd_stop <= 1'b1;
        @(posedge vif.clk);
        vif.cmd_stop <= 1'b0;
        wait_cmd_done("STOP");
    endtask

    task run_phase(uvm_phase phase);
        i2c_seq_item req;

        vif.cmd_start      <= 1'b0;
        vif.cmd_write      <= 1'b0;
        vif.cmd_read       <= 1'b0;
        vif.cmd_stop       <= 1'b0;
        vif.tx_data_master <= 8'h00;
        vif.master_ack_in  <= 1'b1;
        vif.expected_data  <= 8'h00;
        vif.ack_error      <= 1'b0;

        wait (vif.reset == 1'b0);
        @(posedge vif.clk);

        forever begin
            seq_item_port.get_next_item(req);

            vif.expected_data <= req.tx_data;
            vif.ack_error     <= 1'b0;

            `uvm_info("I2C_DRV",
                      $sformatf("loopback transaction start: data=0x%02h",
                                req.tx_data),
                      UVM_MEDIUM)

            send_start();
            send_write({SLAVE_ADDR, 1'b0}, "WRITE ADDRESS");
            send_write(req.tx_data, "WRITE DATA");
            send_start();
            send_write({SLAVE_ADDR, 1'b1}, "READ ADDRESS");
            send_read();
            send_stop();

            `uvm_info("I2C_DRV",
                      $sformatf("loopback transaction done: tx=0x%02h rx=0x%02h",
                                req.tx_data, vif.rx_data_master),
                      UVM_MEDIUM)

            seq_item_port.item_done();
        end
    endtask

endclass
