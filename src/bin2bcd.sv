module bin2bcd #(parameter W = 8) (
    input logic clk,                  // Sinal de relógio
    input reset,                // Sinal de reset assíncrono
    input start,                // Sinal de start para iniciar a conversão
    input [W-1:0] bin,          // Entrada binária
    output reg [15:0] bcd,  // Saída BCD
    output reg done_tick,       // Sinal de done quando o processo termina
    output reg ready            // Sinal de pronto (idle)
);

    // Definição dos estados
    typedef enum {idle, init, shift, done} states;
    states state_reg, state_next;
  
    integer i, j;

    // Lógica de transição de estados
    always @(*) begin
        state_next = state_reg;  // Valor padrão para evitar latches
        case (state_reg)
            idle: begin
                if (start) begin
                    state_next = init;  // Vai para o estado init quando start é acionado
                end
            end
            init: begin
                state_next = shift;     // Inicia o estado de deslocamento
            end
            shift: begin
                state_next = done;  // Transição para o estado done após completar os deslocamentos
                end
            done: begin
                state_next = idle;      // Após finalizar, volta para o estado idle
            end
        endcase
    end

    // Lógica sequencial para estados e operações de deslocamento
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset assíncrono: coloca o sistema em idle
            state_reg <= idle;
            bcd <= 0;
            done_tick <= 0;
            ready <= 1;
        end else begin
            // Transição de estado
            state_reg <= state_next;
            case (state_reg)
                idle: begin
                    ready <= 1;            // Indica que o circuito está pronto
                    done_tick <= 0;        // Reset do done_tick
                end
              
                init: begin
                    ready <= 0;	            // Indica que o circuito não está mais idle
                    for (i = 0; i <= W+(W-4)/3; i++) begin
                      bcd[i] = 0;  // Initialize with zeros
                    end
                  	bcd[W-1:0] <= bin;     // Carrega o valor binário de entrada
                end
              
                shift: begin
                  ready <= 0;
                  for (i = 0; i <= W-4; i++) begin  // Iterate on structure depth
                    for (j = 0; j <= i/3; j++) begin  // Iterate on structure width
                      if (bcd[W-i+4*j -: 4] > 4) begin  // If > 4
                        bcd[W-i+4*j -: 4] = bcd[W-i+4*j -: 4] + 4'd3;
                      end
                    end
                  end
                end
              
                done: begin
                    done_tick <= 1;         // Sinaliza que o processo terminou
                end
            endcase
        end
    end

endmodule