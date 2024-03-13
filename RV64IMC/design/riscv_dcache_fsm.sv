module riscv_dcache_fsm  (
  input   logic clk           ,   //  positive edge clock signal
  input   logic rst           ,   //  positive edge reset signal
  input   logic cpu_wren      ,   //  CPU write enable signal
  input   logic cpu_rden      ,   //  CPU read enable signal
  input   logic hit           ,   //  Tag hit flag
  input   logic dirty         ,   //  Dirty flag
  input   logic mem_ready     ,   //  RAM ready flag
  input   logic glob_stall    ,   //  Global Stall flag
  output  logic cache_rden    ,   //  Cache read enable signal
  output  logic cache_wren    ,   //  Cache write enable signal
  output  logic cache_insel   ,   //  Cache input selection between DRAM or CPU
  output  logic mem_wren      ,   //  DRAM write enable
  output  logic mem_rden      ,   //  DRAM read enable
  output  logic set_dirty     ,   //  Replace dirty bit signal
  output  logic set_valid     ,   //  Replace valid bit signal
  output  logic replace_tag   ,   //  Replace tag enable signal
  output  logic dcache_stall  ,   //  Stall signal when miss
  output  logic tag_sel           //  Decide the DRAM input tag
);

  // FSM states
 typedef enum {IDLE, COMPARE_TAG, WRITE_BACK, ALLOCATE, CACHE_ACCESS} states;
  states current_state, next_state;

  // Registering CPU read and write enable
  logic       cpu_rden_reg,cpu_wren_reg;

  //
   always_ff @(posedge clk or posedge rst) begin
   if(rst)begin
     cpu_rden_reg  <= 1'b0;
     cpu_wren_reg  <= 1'b0;
   end
   else if (!glob_stall) begin 
     cpu_rden_reg  <= cpu_rden;
     cpu_wren_reg  <= cpu_wren;
   end
 end

 /********************************************* FSM *********************************************/

   // Current state sequential block
  always_ff @(posedge clk or posedge rst) begin
    if(rst)
      current_state <= IDLE;
    else
      current_state <= next_state;    
  end

  // Next State & Output combinational block
  always_comb begin
    case (current_state)
      /*********/
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
          dcache_stall  = 1'b0;
          tag_sel       = 1'b0;
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
          dcache_stall  = 1'b0;
          tag_sel       = 1'b0;
        end
      end
      /****************/
      COMPARE_TAG: begin
        if(hit) begin
          cache_rden    = cpu_rden_reg;
          cache_wren    = cpu_wren_reg;
          cache_insel   = 1'b0;
          mem_rden      = 1'b0;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b1;   
          set_valid     = 1'b1;    
          replace_tag   = cpu_wren_reg;
          dcache_stall  = 1'b0;
          tag_sel       = 1'b0;
          if(cpu_rden || cpu_wren) 
          next_state    = COMPARE_TAG ;
          else 
          next_state    = IDLE;
        end
        else if(dirty) begin
          next_state    = WRITE_BACK;
          cache_rden    = 1'b1;
          cache_wren    = 1'b0;
          cache_insel   = 1'b0;
          mem_rden      = 1'b0;
          mem_wren      = 1'b1;
          set_dirty     = cpu_wren_reg;
          set_valid     = 1'b1;    
          replace_tag   = 1'b0;
          dcache_stall  = 1'b1;
          tag_sel       = 1'b1;
        end
        else begin
          next_state    = ALLOCATE;
          cache_rden    = 1'b0;
          cache_wren    = 1'b0;
          cache_insel   = 1'b0;
          mem_rden      = 1'b1;
          mem_wren      = 1'b0;  
          set_dirty     = cpu_wren_reg;
          set_valid     = 1'b1;    
          replace_tag   = 1'b0;
          dcache_stall  = 1'b1;
          tag_sel       = 1'b0;
        end
      end
      /***************/
      WRITE_BACK: begin
        if(mem_ready) begin
          next_state    = ALLOCATE;
          cache_rden    = 1'b0;
          cache_wren    = 1'b0;
          cache_insel   = 1'b1;
          mem_rden      = 1'b1;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b0;   
          set_valid     = 1'b0;    
          replace_tag   = 1'b0;
          dcache_stall  = 1'b1;
          tag_sel       = 1'b0;
        end
        else begin
          next_state    = WRITE_BACK;
          cache_rden    = 1'b1;
          cache_wren    = 1'b0;
          cache_insel   = 1'b0;
          mem_rden      = 1'b0;
          mem_wren      = 1'b1;  
          set_dirty     = cpu_wren_reg;   
          set_valid     = 1'b1;    
          replace_tag   = 1'b0;
          dcache_stall  = 1'b1;
          tag_sel       = 1'b1;
        end
      end
      /*************/
      ALLOCATE: begin
        if(mem_ready) begin
          next_state    = CACHE_ACCESS;
          cache_rden    = 1'b0;
          cache_wren    = 1'b1;
          cache_insel   = 1'b1;
          mem_rden      = 1'b0;
          mem_wren      = 1'b0;  
          set_dirty     = cpu_wren_reg;   
          set_valid     = 1'b1;    
          replace_tag   = 1'b1;
          dcache_stall  = 1'b1;
          tag_sel       = 1'b0;
        end
        else begin
          next_state    = ALLOCATE;
          cache_rden    = 1'b0;
          cache_wren    = 1'b0;
          cache_insel   = 1'b0;
          mem_rden      = 1'b1;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b0;   
          set_valid     = 1'b0;    
          replace_tag   = 1'b0;
          dcache_stall  = 1'b1;
          tag_sel       = 1'b0;
        end
      end
      /****************/
      CACHE_ACCESS:begin
         cache_rden    = cpu_rden_reg;
         cache_wren    = cpu_wren_reg;
         cache_insel   = 1'b0;
         mem_rden      = 1'b0;
         mem_wren      = 1'b0;  
         set_dirty     = 1'b0;   
         set_valid     = 1'b0;    
         replace_tag   = 1'b0;
         dcache_stall  = 1'b0;
         tag_sel       = 1'b0;
         if(cpu_rden || cpu_wren)
          next_state    = COMPARE_TAG ;
          else 
          next_state    = IDLE;
      end
      default:begin
        next_state    = IDLE;
        cache_rden    = 1'b0;
        cache_wren    = 1'b0;
        cache_insel   = 1'b0;
        mem_rden      = 1'b0;
        mem_wren      = 1'b0;  
        set_dirty     = 1'b0;   
        set_valid     = 1'b0;    
        replace_tag   = 1'b0;
        dcache_stall  = 1'b1;
        tag_sel       = 1'b0;
      end
      
    endcase
  end
endmodule