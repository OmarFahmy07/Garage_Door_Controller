module Door_Controller(
  input wire activate,
  input wire Up_max,
  input wire Dn_max,
  input wire clock,
  input wire reset,
  output reg Up_motor,
  output reg Dn_motor
  );
  
  localparam  IDLE    = 3'b001,
              Move_Up = 3'b010,
              Move_Dn = 3'b100;
  
  reg [2:0] current_state, next_state;
  
  // Sequential always for state transition
  always @(posedge clock or negedge reset)
    begin
      if(!reset)
        begin
          current_state <= IDLE;
        end
      else
        begin
          current_state <= next_state;
        end
    end
    
    // Combinational always for the next state logic
    always @(*)
      begin
        // Initial value
        next_state = IDLE;
        case(current_state)
        IDLE: 
          begin
            if(activate && Up_max && !Dn_max) // If the door is completely opened
              begin
                next_state = Move_Dn;
              end
            else if(activate && !Up_max && Dn_max) // If the door is completely closed
              begin
                next_state = Move_Up;
              end
            else
              begin
                next_state = IDLE;
              end
          end
          
        Move_Up:
          begin
            if(Up_max && !Dn_max) // If the door is completely opened
              begin
                next_state = IDLE;
              end
            else // This means that both sensors read zero, which means the door is still opening
              begin
                next_state = Move_Up;
              end
          end
        
        Move_Dn:
          begin
            if(!Up_max && Dn_max) // If the door is completely closed
              begin
                next_state = IDLE;
              end
            else // This means that both sensors read zero, which means the door is still closing
              begin
                next_state = Move_Dn;
              end
          end
        
        endcase
      end
      
      // Combinational always for the output logic
      always @(*)
      begin
        // Initial values
        Up_motor = 1'b0;
        Dn_motor = 1'b0;
        case(current_state)
        IDLE:
          begin
            Up_motor = 1'b0;
            Dn_motor = 1'b0;
          end
          
        Move_Up:
          begin
            Up_motor = 1'b1;
            Dn_motor = 1'b0;
          end
          
        Move_Dn:
          begin
            Up_motor = 1'b0;
            Dn_motor = 1'b1;
          end
          
        default:
          begin
            Up_motor = 1'b0;
            Dn_motor = 1'b0;
          end
        endcase
      end
  
endmodule
