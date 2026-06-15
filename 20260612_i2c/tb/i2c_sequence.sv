class i2c_sequence extends uvm_sequence #(i2c_seq_item);

    `uvm_object_utils(i2c_sequence)

    function new(string name = "i2c_sequence");
        super.new(name);
    endfunction

    task send_data(bit [7:0] data);
        i2c_seq_item req;

        req = i2c_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize() with { tx_data == data; });
        finish_item(req);
    endtask

    task body();
        i2c_seq_item req;

        // Target the edge-value coverage bins first.
        send_data(8'h00);
        send_data(8'h01);
        send_data(8'h55);
        send_data(8'hAA);
        send_data(8'hFE);
        send_data(8'hFF);

        repeat (44) begin
            req = i2c_seq_item::type_id::create("req");
            start_item(req);
            assert(req.randomize());
            finish_item(req);
        end
    endtask

endclass
