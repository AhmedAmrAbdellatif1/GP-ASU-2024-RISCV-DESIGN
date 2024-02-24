module cache_fsm  (
  input   logic clk           ,
  input   logic rst           ,
  input   logic cpu_wren      ,
  input   logic cpu_rden      ,
  input   logic hit           ,
  input   logic dirty         ,
  input   logic mem_ready     ,
  output  logic cache_rden    ,
  output  logic cache_wren    ,
  output  logic cache_insel   ,
  output  logic mem_rden      ,
  output  logic mem_wren      ,
  output  logic set_dirty     ,
  output  logic set_valid     ,
  output  logic replace_tag   ,
  output  logic stall
);

  // 
  enum {IDLE, COMPARE_TAG, WRITE_BACK, ALLOCATE} states;
  
  logic [1:0] current_state, next_state;

  // 
  always_ff @(posedge clk or posedge rst) begin
    if(rst)
      current_state <= IDLE;
    else
      current_state <= next_state;
  end

  // 
  always_comb begin
    case (states)
      IDLE: begin
        if(cpu_rden || cpu_wren) begin
          next_state    = COMPARE_TAG;
          cache_rden    = 1'b0;
          cache_wren    = 1'b0;
          cache_insel   = 1'b0;
          mem_rden      = 1'b0;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b0;   
          set_valid     = 1'b0;    
          replace_tag   = 1'b0;
          stall         = 1'b0;
        end
        else begin
          next_state    = IDLE;
          cache_rden    = 1'b0;
          cache_wren    = 1'b0;
          cache_insel   = 1'b0;
          mem_rden      = 1'b0;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b0;   
          set_valid     = 1'b0;    
          replace_tag   = 1'b0;
          stall         = 1'b0;
        end
      end
      COMPARE_TAG: begin
        if(hit) begin
          next_state    = IDLE;
          cache_rden    = cpu_rden;
          cache_wren    = cpu_wren;
          cache_insel   = 1'b0;
          mem_rden      = 1'b0;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b1;   
          set_valid     = 1'b1;    
          replace_tag   = cpu_wren;
          stall         = 1'b0;
        end
        else if(dirty) begin
          next_state    = WRITE_BACK;
          cache_rden    = 1'b1;
          cache_wren    = 1'b0;
          cache_insel   = 1'b0;
          mem_rden      = 1'b0;
          mem_wren      = 1'b1;  
          set_dirty     = cpu_wren;
          set_valid     = 1'b1;    
          replace_tag   = 1'b1;
          stall         = 1'b1;
        end
        else if(!dirty) begin
          next_state    = ALLOCATE;
          cache_rden    = 1'b0;
          cache_wren    = 1'b1;
          cache_insel   = 1'b1;
          mem_rden      = 1'b1;
          mem_wren      = 1'b0;  
          set_dirty     = cpu_wren;
          set_valid     = 1'b1;    
          replace_tag   = 1'b1;
          stall         = 1'b1;
        end
        else begin
          next_state    = COMPARE_TAG;
          cache_rden    = 1'b0;
          cache_wren    = 1'b0;
          cache_insel   = 1'b0;
          mem_rden      = 1'b0;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b0;   
          set_valid     = 1'b0;    
          replace_tag   = 1'b0;
          stall         = 1'b0;
        end
      end
      WRITE_BACK: begin
        if(mem_ready) begin
          next_state    = ALLOCATE;
          cache_rden    = 1'b0;
          cache_wren    = 1'b1;
          cache_insel   = 1'b1;
          mem_rden      = 1'b1;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b0;   
          set_valid     = 1'b0;    
          replace_tag   = 1'b0;
          stall         = 1'b1;
        end
        else begin
          next_state    = WRITE_BACK;
          cache_rden    = 1'b1;
          cache_wren    = 1'b0;
          cache_insel   = 1'b0;
          mem_rden      = 1'b0;
          mem_wren      = 1'b1;  
          set_dirty     = cpu_wren;   
          set_valid     = 1'b1;    
          replace_tag   = 1'b1;
          stall         = 1'b1;
        end
      end
      ALLOCATE: begin
        if(mem_ready) begin
          next_state    = IDLE;
          cache_rden    = cpu_rden;
          cache_wren    = cpu_wren;
          cache_insel   = 1'b0;
          mem_rden      = 1'b0;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b0;   
          set_valid     = 1'b0;    
          replace_tag   = 1'b0;
          stall         = 1'b0;
        end
        else begin
          next_state    = ALLOCATE;
          cache_rden    = 1'b0;
          cache_wren    = 1'b1;
          cache_insel   = 1'b0;
          mem_rden      = 1'b1;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b0;   
          set_valid     = 1'b0;    
          replace_tag   = 1'b0;
          stall         = 1'b1;
        end
      end
    endcase
  end
endmodule