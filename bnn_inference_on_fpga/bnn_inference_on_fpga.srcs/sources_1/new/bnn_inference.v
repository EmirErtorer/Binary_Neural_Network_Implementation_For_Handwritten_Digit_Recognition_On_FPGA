`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 09:48:50 AM
// Design Name: 
// Module Name: bnn_inference
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

// Logic core performing inference with XNOR and popcount
module bnn_inference(input clk, input reset, input wire [783:0] image, output wire [3:0] digit, output wire done);

    parameter PARALLEL_NEURONS = 64; // desired level of parallelization
    parameter OUTPUT_NEURONS = 10;
    
    reg [6:0] neuron_idx1; // index of output neuron in Layer 1 (128 neurons, each row stores weights from 784 inputs)
    reg [5:0] neuron_idx2; // index of output neuron in Layer 2 (64 neurons, 128 inputs per neuron)
    reg [3:0] neuron_idx3; // index of output neuron in Output Layer (10 neurons, 64 inputs per neuron)
    
    reg [9:0] addr1; // index of input pixel (0-783) for Layer 1
    reg [6:0] addr2; // index of activation from Layer 1 (0-127) for Layer 2
    reg [5:0] addr3; // index of activation from Layer 2 (0-63) for Output Layer


    // Layer 1: 784 x 128
    // ---------------------------
    wire [783:0] dense_w0 [0:PARALLEL_NEURONS-1];
    wire signed [10:0] thresh_w0 [0:PARALLEL_NEURONS-1];
    // Dual-port ROM instantiations
    genvar k;
    generate
        for (k = 0; k < PARALLEL_NEURONS; k = k + 2) begin : layer1_parallel_block
            dense_kernel_rom_dualport dense_layer1_weights (
                .clk(clk),
                .addr_a(neuron_idx1 + k),
                .addr_b(neuron_idx1 + k + 1),
                .data_a(dense_w0[k]),
                .data_b(dense_w0[k+1])
            );
            // Two separate single port LUT ROMs
            dense_kernel_thresholds_rom_lut thresh_rom0_a (
                .addr(neuron_idx1 + k),
                .data(thresh_w0[k])
            );
            dense_kernel_thresholds_rom_lut thresh_rom0_b (
                .addr(neuron_idx1 + k + 1),
                .data(thresh_w0[k+1])
            );
        end
    endgenerate

    // Layer 2: 128 x 64
    // ---------------------------
    wire [127:0] dense_w1 [0:PARALLEL_NEURONS-1];
    wire signed [10:0] thresh_w1 [0:PARALLEL_NEURONS-1];
    
    genvar l;
    generate
        for (l = 0; l < PARALLEL_NEURONS; l = l + 2) begin : layer2_parallel_block
            dense_1_kernel_rom_dualport dense_layer2_weights (
                .clk(clk),
                .addr_a(neuron_idx2 + l),
                .addr_b(neuron_idx2 + l + 1),
                .data_a(dense_w1[l]),
                .data_b(dense_w1[l + 1])
            );
            // Two separate single port LUT ROMs
            dense_1_kernel_thresholds_rom_lut thresh_rom1_a (
                .addr(neuron_idx2 + l),
                .data(thresh_w1[l])
            );
            dense_1_kernel_thresholds_rom_lut thresh_rom1_b (
                .addr(neuron_idx2 + l + 1),
                .data(thresh_w1[l+1])
            );
        end
    endgenerate
    
    // Output Layer: 64 x 10
    // ---------------------------
    wire [63:0] dense_w2 [0:PARALLEL_NEURONS-1];
    genvar m;
    generate
        for (m = 0; m < PARALLEL_NEURONS; m = m + 2) begin : output_parallel_block
            if (m < OUTPUT_NEURONS) begin
                dense_2_kernel_rom_dualport dense_layer3_weights (
                    .clk(clk),
                    .addr_a(neuron_idx3 + m),
                    .addr_b(neuron_idx3 + m + 1),
                    .data_a(dense_w2[m]),
                    .data_b(dense_w2[m + 1])
                );
            end else begin
                // dummy data for unused entries
                assign dense_w2[m] = 64'd0;
                assign dense_w2[m + 1] = 64'd0;
            end
        end
    endgenerate

    // İnference with Finite State Machine
    // ---------------------------------------------------------
    
    //defining FSM states as parameters
    parameter COMPUTE_LAYER1 = 3'd0;
    parameter COMPUTE_LAYER2 = 3'd1;
    parameter COMPUTE_OUTPUT = 3'd2;
    parameter ARGMAX_OUTPUT = 3'd3;
    parameter DONE = 3'd4;
    
    reg [2:0] state, next_state;
    
    // reset logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= COMPUTE_LAYER1;
        else
            state <= next_state;
    end
    
    // flags for state transitions
    reg done_layer1;
    reg done_layer2;
    reg done_output;
    reg done_argmax;
    
    // the state transitions
    always @(*) begin
        case (state)
            COMPUTE_LAYER1: next_state = (done_layer1) ? COMPUTE_LAYER2 : COMPUTE_LAYER1;
            COMPUTE_LAYER2: next_state = (done_layer2) ? COMPUTE_OUTPUT : COMPUTE_LAYER2;
            COMPUTE_OUTPUT: next_state = (done_output) ? ARGMAX_OUTPUT : COMPUTE_OUTPUT;
            ARGMAX_OUTPUT:  next_state = (done_argmax) ? DONE : ARGMAX_OUTPUT;
            DONE: next_state = DONE;
            default: next_state = COMPUTE_LAYER1;
        endcase
    end

    // State actions
    // ---------------------------------------
    
    // registers to hold intermediate values
    reg [127:0] layer1_out;
    reg [63:0] layer2_out;
    reg signed [9:0] output_scores [OUTPUT_NEURONS-1:0];
    reg [3:0] predicted_digit;
    reg signed [9:0] temp_max;
    reg [3:0] temp_index; 
    
    // internal counters and buffers
    reg [3:0] compare_idx; 
    reg signed [10:0] popcount [0:PARALLEL_NEURONS-1];    
    reg signed [10:0] z [0:PARALLEL_NEURONS-1];
    reg process_neuron1, process_neuron2, process_neuron3;
    reg argmax_started;
    reg z_ready; 
    integer i, j;

    
    always @(posedge clk or posedge reset) begin
        
        if (reset) begin
            layer1_out <= 0; layer2_out <= 0;
            addr1 <= 0; addr2 <= 0; addr3 <= 0;
            neuron_idx1 <= 0; neuron_idx2 <= 0; neuron_idx3 <= 0;
            done_layer1 <= 0; done_layer2 <= 0; done_output <= 0; done_argmax <= 0;
            z_ready <= 0;

            process_neuron1 <= 0; process_neuron2 <= 0; process_neuron3 <= 0;
            
            compare_idx <= 0; temp_max <= 0; temp_index <= 0;
            argmax_started <= 0;
            predicted_digit <= 0;
            
            for (i = 0; i < OUTPUT_NEURONS; i = i + 1) begin
                output_scores[i] <= 0;
            end
            
            for (j = 0; j < PARALLEL_NEURONS; j = j + 1) begin
                popcount[j] <= 0;
                z[j] <= 0;
            end
    
        end
        
        else begin
            case (state)
                // ----------------------------------------
                COMPUTE_LAYER1: begin
                    if (!process_neuron1) begin
                        if (addr1 == 0) begin
                            for (j = 0; j < PARALLEL_NEURONS; j = j + 1) begin
                                popcount[j] <= 0;
                                z[j] <= 0;
                            end
                        end
                            
                        if (addr1 < 784) begin              
                            // Performing XNOR 
                            for (j = 0; j < PARALLEL_NEURONS; j = j + 1) begin
                                if (image[addr1] ~^ dense_w0[j][783 - addr1])
                                    popcount[j] <= popcount[j] + 1;
                            end
                                
                            addr1 <= addr1 + 1; // addr1 now points to the next neuron in the row
                            
                            if (addr1 == 783)
                                process_neuron1 <= 1; // mark this row as done
                        end
                    
                    end else if (!z_ready) begin
                        // Calculating the z scores for each neuron using popcount
                        for (j = 0; j < PARALLEL_NEURONS; j = j + 1)
                            z[j] <= (2 * popcount[j]) - 784;
                        z_ready <= 1; 
                        
                    end else begin 
                        // output neuron is set according to the corresponding threshold value 
                         for (j = 0; j < PARALLEL_NEURONS; j = j + 1) begin
                            if ((neuron_idx1 + j) < 128) begin
                                if (z[j] >= thresh_w0[j])
                                    layer1_out[neuron_idx1 + j] <= 1;
                                else
                                    layer1_out[neuron_idx1 + j] <= 0;
                            end
                        end
                
                        // Resetting for next batch of neurons
                        addr1 <= 0;
                        z_ready <= 0;
                        for (j = 0; j < PARALLEL_NEURONS; j = j + 1)
                            popcount[j] <= 0;
                        process_neuron1 <= 0;
                        
                        // signaling end of layer 1
                        if ((128 <= PARALLEL_NEURONS) || neuron_idx1 >= (128 - PARALLEL_NEURONS)) begin
                            neuron_idx1 <= 0;
                            done_layer1 <= 1;
                        end else begin
                            // getting the next batch of rows
                            neuron_idx1 <= neuron_idx1 + PARALLEL_NEURONS;
                        end
                    end 
                end
    
                // ----------------------------------------
                COMPUTE_LAYER2: begin
                    if (!process_neuron2) begin
                        if (addr2 == 0) begin
                            for (j = 0; j < PARALLEL_NEURONS; j = j + 1) begin
                                popcount[j] <= 0;
                                z[j] <= 0;
                            end
                        end
                            
                        if(addr2 < 128) begin   
                            for (j = 0; j < PARALLEL_NEURONS; j = j + 1) begin
                                if (layer1_out[addr2] ~^ dense_w1[j][127 - addr2])
                                    popcount[j] <= popcount[j] + 1;
                            end 
                                
                            addr2 <= addr2 + 1; // addr2 now points to the next neuron in the row
                            
                            if (addr2 == 127)
                                process_neuron2 <= 1; // mark this row as done
                        end
                        
                    end else if (!z_ready) begin
                        // Calculating the z scores for each neuron using popcount
                        for (j = 0; j < PARALLEL_NEURONS; j = j + 1)
                            z[j] <= (2 * popcount[j]) - 128;
                        z_ready <= 1;
                        
                    end else begin 
                        // output neuron is set according to the corresponding threshold value 
                        for (j = 0; j < PARALLEL_NEURONS; j = j + 1) begin
                            if ((neuron_idx2 + j) < 64) begin
                                if (z[j] >= thresh_w1[j])
                                    layer2_out[neuron_idx2 + j] <= 1;
                                else
                                    layer2_out[neuron_idx2 + j] <= 0;
                            end
                        end
                
                        // Resetting for next neuron
                        addr2 <= 0;
                        for (j = 0; j < PARALLEL_NEURONS; j = j + 1)
                            popcount[j] <= 0;
                        z_ready <= 0;
                        process_neuron2 <= 0;
                        
                        // signaling end of layer 2
                        if ((64 <= PARALLEL_NEURONS) || neuron_idx2 >= (64 - PARALLEL_NEURONS)) begin
                            neuron_idx2 <= 0;
                            done_layer2 <= 1;
                        end else begin
                            // getting the next batch of rows
                            neuron_idx2 <= neuron_idx2 + PARALLEL_NEURONS;
                        end 
                    end
                end
    
                // ----------------------------------------
                COMPUTE_OUTPUT: begin
                    if (!process_neuron3) begin
                        if (addr3 == 0) begin
                            for (j = 0; j < PARALLEL_NEURONS; j = j + 1) begin
                                popcount[j] <= 0;
                                z[j] <= 0;
                            end
                        end
                        
                        if(addr3 < 64) begin                       
                            for (j = 0; j < PARALLEL_NEURONS; j = j + 1) begin
                                if (layer2_out[addr3] ~^ dense_w2[j][63 - addr3])
                                    popcount[j] <= popcount[j] + 1;
                            end
                                     
                            addr3 <= addr3 + 1; // addr3 now points to the next neuron in the row
                            
                            if (addr3 == 63)
                                process_neuron3 <= 1; // mark this row as done
                        end  
                        
                    end else if (!z_ready) begin
                        // Calculating the z scores for each neuron using popcount
                        for (j = 0; j < PARALLEL_NEURONS; j = j + 1)
                            z[j] <= (2 * popcount[j]) - 64;
                        z_ready <= 1;
                        
                    end else begin 
                        // final output neurons are set 
                        for (j = 0; j < PARALLEL_NEURONS; j = j + 1) begin
                            if ((neuron_idx3 + j) < 10)
                                output_scores[neuron_idx3 + j] <= z[j];
                        end
                        
                        // Resetting for next neuron
                        addr3 <= 0;
                        for (j = 0; j < PARALLEL_NEURONS; j = j + 1)
                            popcount[j] <= 0;
                        z_ready <= 0;
                        process_neuron3 <= 0;
                        
                        // signaling end of output layer 
                        if ((OUTPUT_NEURONS <= PARALLEL_NEURONS) || neuron_idx3 >= (OUTPUT_NEURONS - PARALLEL_NEURONS)) begin
                            neuron_idx3 <= 0;
                            done_output <= 1;
                        end else begin
                            // getting the next batch of rows
                            neuron_idx3 <= neuron_idx3 + PARALLEL_NEURONS;
                        end
                    end
                end
                
                // ----------------------------------------
                ARGMAX_OUTPUT: begin
                    if (!argmax_started) begin
                        temp_max <= output_scores[0];
                        temp_index <= 0;
                        compare_idx <= 1;
                        argmax_started <= 1;
                    end else begin
                        if (compare_idx < OUTPUT_NEURONS) begin
                            if (output_scores[compare_idx] > temp_max) begin
                                temp_max <= output_scores[compare_idx];
                                temp_index <= compare_idx;
                            end
                            compare_idx <= compare_idx + 1;
                        end else begin
                            predicted_digit <= temp_index;
                            argmax_started <= 0;
                            done_argmax <= 1;
                        end
                    end
                end
                
            endcase
        end
    end
    
    // assigning output digit
    assign digit = predicted_digit;
    assign done = (state == DONE);
    
endmodule