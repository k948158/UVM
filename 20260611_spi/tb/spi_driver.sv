class spi_driver extends uvm_driver #(spi_seq_item);

    `uvm_component_utils(spi_driver)

    virtual spi_if vif;

    function new(string name = "spi_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "spi_if was not found in uvm_config_db")
        end
    endfunction

    task run_phase(uvm_phase phase);
        spi_seq_item req;

        vif.start          <= 1'b0;
        vif.cpol           <= 1'b0;
        vif.cpha           <= 1'b0;
        vif.clk_div        <= 8'd4;
        vif.tx_data_master <= '0;

        wait (vif.rst == 1'b0);
        @(posedge vif.clk);

        forever begin
            seq_item_port.get_next_item(req);

            wait (!vif.busy_master && !vif.busy_slave);
            vif.cpol           <= req.cpol;
            vif.cpha           <= req.cpha;
            vif.clk_div        <= req.clk_div;
            vif.tx_data_master <= req.tx_data_master;
            vif.start          <= 1'b1;

            `uvm_info("SPI_DRV",
                      $sformatf("start tx=0x%02h clk_div=%0d cpol=%0b cpha=%0b",
                                req.tx_data_master, req.clk_div,
                                req.cpol, req.cpha),
                      UVM_MEDIUM)

            @(posedge vif.clk);
            vif.start <= 1'b0;

            fork
                wait (vif.done_master == 1'b1);
                wait (vif.done_slave  == 1'b1);
            join

            `uvm_info("SPI_DRV", "master/slave transfer completed", UVM_MEDIUM)

            @(posedge vif.clk);
            seq_item_port.item_done();
        end
    endtask

endclass
