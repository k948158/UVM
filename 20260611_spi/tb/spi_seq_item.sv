class spi_seq_item extends uvm_sequence_item;

    rand bit [7:0] tx_data_master;
    rand bit       cpol;
    rand bit       cpha;
    rand bit [7:0] clk_div;

         logic [7:0] rx_data_master;
         logic [7:0] rx_data_slave;
         bit         busy_master;
         bit         busy_slave;
         bit         done_master;
         bit         done_slave;

    constraint clk_div_c {
        clk_div inside {[2:10]};
    }

    constraint mode_c {
        cpol == 1'b0;
        cpha == 1'b0;
    }

    `uvm_object_utils_begin(spi_seq_item)
        `uvm_field_int(tx_data_master, UVM_ALL_ON)
        `uvm_field_int(cpol,           UVM_ALL_ON)
        `uvm_field_int(cpha,           UVM_ALL_ON)
        `uvm_field_int(clk_div,        UVM_ALL_ON)
        `uvm_field_int(rx_data_master, UVM_ALL_ON)
        `uvm_field_int(rx_data_slave,  UVM_ALL_ON)
        `uvm_field_int(busy_master,    UVM_ALL_ON)
        `uvm_field_int(busy_slave,     UVM_ALL_ON)
        `uvm_field_int(done_master,    UVM_ALL_ON)
        `uvm_field_int(done_slave,     UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "spi_seq_item");
        super.new(name);
    endfunction

endclass
