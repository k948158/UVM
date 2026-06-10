module ram (
    input  logic       clk,
    input  logic       we,
    input  logic [7:0] addr,
    input  logic [7:0] wdata,
    output logic [7:0] rdata
);
    logic [7:0] data[0:255];
    always_ff @(posedge clk) begin
        if (we) begin
            data[addr] <= wdata;
        end else begin
            rdata <= data[addr];
        end
    end

endmodule
