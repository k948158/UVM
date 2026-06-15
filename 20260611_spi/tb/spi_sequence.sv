class spi_sequence extends uvm_sequence #(spi_seq_item);

    `uvm_object_utils(spi_sequence)

    function new(string name = "spi_sequence");
        super.new(name);
    endfunction

    task send_targeted(bit [7:0] data, bit [7:0] divider);
        spi_seq_item req;

        req = spi_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            tx_data_master == data;
            clk_div        == divider;
            cpol           == 1'b0;
            cpha           == 1'b0;
        });
        finish_item(req);
    endtask

    task body();
        spi_seq_item req;

        // Hit every TX-data bin at each clock-divider bin.
        send_targeted(8'h00, 8'd2);
        send_targeted(8'h20, 8'd2);
        send_targeted(8'h80, 8'd2);
        send_targeted(8'hD0, 8'd2);
        send_targeted(8'hFF, 8'd2);

        send_targeted(8'h00, 8'd6);
        send_targeted(8'h20, 8'd6);
        send_targeted(8'h80, 8'd6);
        send_targeted(8'hD0, 8'd6);
        send_targeted(8'hFF, 8'd6);

        send_targeted(8'h00, 8'd9);
        send_targeted(8'h20, 8'd9);
        send_targeted(8'h80, 8'd9);
        send_targeted(8'hD0, 8'd9);
        send_targeted(8'hFF, 8'd9);

        // Keep the total at 50 transfers with additional random traffic.
        repeat (35) begin
            req = spi_seq_item::type_id::create("req");
            start_item(req);
            assert(req.randomize());
            finish_item(req);
        end
    endtask

endclass
