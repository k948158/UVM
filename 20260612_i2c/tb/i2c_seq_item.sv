class i2c_seq_item extends uvm_sequence_item;

    rand bit [7:0] tx_data;

         logic [7:0] rx_data_master;
         logic [7:0] rx_data_slave;
         logic [7:0] loopback_data;
         bit         ack_error;

    `uvm_object_utils_begin(i2c_seq_item)
        `uvm_field_int(tx_data,        UVM_ALL_ON)
        `uvm_field_int(rx_data_master, UVM_ALL_ON)
        `uvm_field_int(rx_data_slave,  UVM_ALL_ON)
        `uvm_field_int(loopback_data,  UVM_ALL_ON)
        `uvm_field_int(ack_error,      UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "i2c_seq_item");
        super.new(name);
    endfunction

endclass
