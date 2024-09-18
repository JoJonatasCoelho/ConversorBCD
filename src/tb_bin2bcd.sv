module tb_bin2bcd;

    localparam W = 8;  // Tamanho da palavra binária
    localparam int VECTOR_SIZE = 8;  // Definição do parâmetro local

    // Sinais
    logic clk, reset, start;
    logic [W-1:0] bin;
    logic [15:0] bcd;
    logic done_tick, ready;


    logic [W-1:0] test_vectors_in [0:VECTOR_SIZE-1];  
    logic [15:0] test_vectors_out [0:VECTOR_SIZE-1];
    int errors;

    // Instanciando o módulo bin2bcd
    bin2bcd #(
        .W(W)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .bin(bin),
        .bcd(bcd),
        .done_tick(done_tick),
        .ready(ready)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Clock de 10 unidades de tempo (período de 10)
    end

    initial begin

        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_bin2bcd);

        reset = 1;
        start = 0;
        bin = 0;
        errors = 0;
        #5 reset = 0;
        start = 1;

        $readmemb("input_vectors_bcd_sa.txt", test_vectors_in);
        $readmemb("output_vectors_bcd_sa.txt", test_vectors_out);

        for (int i = 0; i < VECTOR_SIZE; i++) begin
            
            bin = test_vectors_in[i];
            #10 clk = 1;

            wait(done_tick);
            if((done_tick == 1) & (bcd != test_vectors_out[i])) begin
                $display("Erro: Input = %b, Output = %b, Esperado = %b", {bin}, {bcd}, test_vectors_out[i]);
                errors++;
            end
            else begin
                $display("Sucess: Input = %b, Output = %b, Esperado = %b", {bin}, {bcd}, test_vectors_out[i]);
            end
            #10 clk = 0;
        end

        if (errors == 0) begin
            $display("Teste concluído sem erros.");
        end else begin
            $display("Teste concluído com %0d erro(s).", errors);
        end
        #50 $finish;
    end
endmodule