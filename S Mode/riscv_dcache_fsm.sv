module riscv_dcache_fsm  (
  input   logic       clk           ,   //  positive edge clock signal
  input   logic       rst           ,   //  positive edge reset signal
  input   logic       cpu_wren      ,   //  CPU write enable signal
  input   logic       cpu_rden      ,   //  CPU read enable signal
  input   logic       cpu_amoen     ,   //  CPU amo enable signal // NEW
  input   logic       hit           ,   //  Tag hit flag
  input   logic       dirty         ,   //  Dirty flag
  input   logic       mem_ready     ,   //  RAM ready flag
  input   logic       glob_stall    ,   //  Global Stall flag
  output  logic       cache_rden    ,   //  Cache read enable signal
  output  logic       cache_wren    ,   //  Cache write enable signal
  output  logic [1:0] cache_insel   ,   //  Cache input selection between DRAM or CPU or AMO UNIT //NEW
  output  logic       mem_wren      ,   //  DRAM write enable
  output  logic       mem_rden      ,   //  DRAM read enable
  output  logic       set_dirty     ,   //  Replace dirty bit signal
  output  logic       set_valid     ,   //  Replace valid bit signal
  output  logic       replace_tag   ,   //  Replace tag enable signal
  output  logic       dcache_stall  ,   //  Stall signal when miss
  output  logic       tag_sel       ,   //  Decide the DRAM input tag
  output  logic       amo_unit_en   ,
  output  logic       amo_buffer_en     //  Enable the amo buffer to fetch the data from cache.// NEW
);

  // FSM states
 /*typedef enum {IDLE, COMPARE_TAG, WRITE_BACK, ALLOCATE, CACHE_ACCESS , AMO_MODIFY , AMO_STORE} states;//new
   states current_state, next_state;*/

   typedef enum logic [2:0] { IDLE, COMPARE_TAG, WRITE_BACK, ALLOCATE, CACHE_ACCESS, AMO_MODIFY, AMO_STORE } states;  // Use logic for hardware compatibility

   // State encoding using a constant array
   localparam logic [2:0] state_encoding_gray[] =  // Array for clarity
     { 3'b000, 3'b001, 3'b011, 3'b010, 3'b110, 3'b100, 3'b101 };
   
   states current_state, next_state;
   

  // Registering CPU read and write enable
  logic       cpu_rden_reg,cpu_wren_reg,cpu_amoen_reg;//new

  //
   always_ff @(posedge clk or posedge rst) begin
   if(rst)begin
     cpu_rden_reg  <= 1'b0;
     cpu_wren_reg  <= 1'b0;
     cpu_amoen_reg <= 1'b0;//new
   end
   else if (!glob_stall) begin 
     cpu_rden_reg  <= cpu_rden;
     cpu_wren_reg  <= cpu_wren;
     cpu_amoen_reg <= cpu_amoen;//new
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
        if(cpu_rden || cpu_wren || cpu_amoen) begin//new
          next_state    = COMPARE_TAG;
          cache_rden    = 1'b0;
          cache_wren    = 1'b0;
          cache_insel   = 2'b00;
          mem_rden      = 1'b0;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b0;   
          set_valid     = 1'b0;    
          replace_tag   = 1'b0;
          dcache_stall  = 1'b0;
          tag_sel       = 1'b0;
          amo_buffer_en = 1'b0;
          amo_unit_en   = 1'b0;
        end
        else begin
          next_state    = IDLE;
          cache_rden    = 1'b0;
          cache_wren    = 1'b0;
          cache_insel   = 2'b00;
          mem_rden      = 1'b0;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b0;   
          set_valid     = 1'b0;    
          replace_tag   = 1'b0;
          dcache_stall  = 1'b0;
          tag_sel       = 1'b0;
          amo_buffer_en = 1'b0;
          amo_unit_en   = 1'b0;          
        end
      end
      /****************/
      COMPARE_TAG: begin
        if(hit && (!cpu_amoen_reg)) begin// new !cpu_amoen
          cache_rden    = cpu_rden_reg;
          cache_wren    = cpu_wren_reg;
          cache_insel   = 2'b00;
          mem_rden      = 1'b0;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b1;   
          set_valid     = 1'b1;    
          replace_tag   = cpu_wren_reg;
          dcache_stall  = 1'b0;
          tag_sel       = 1'b0;
          amo_buffer_en = 1'b0;
          amo_unit_en   = 1'b0;
          if(glob_stall)
            next_state    = COMPARE_TAG;
          else if(cpu_rden || cpu_wren || cpu_amoen ) //new
            next_state    = COMPARE_TAG ;
          else 
            next_state    = IDLE;
        end
         else if(hit && cpu_amoen_reg) begin // new condition
          cache_rden    = 1'b1;
          cache_wren    = 1'b0;
          cache_insel   = 2'b00; // don't care now it will be 10 while store from amo unit
          mem_rden      = 1'b0;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b1;// always will store    
          set_valid     = 1'b1;    
          replace_tag   = cpu_amoen_reg;
          dcache_stall  = 1'b1;// new   stall for amo however hit =1
          tag_sel       = 1'b0;
          amo_buffer_en = 1'b1;// new  
          amo_unit_en   = 1'b0;
          next_state    = AMO_MODIFY; //new
        end
        else if(dirty) begin
          next_state    = WRITE_BACK;
          cache_rden    = 1'b1;
          cache_wren    = 1'b0;
          cache_insel   = 2'b00;
          mem_rden      = 1'b0;
          mem_wren      = 1'b1;
          set_dirty     = cpu_wren_reg;
          set_valid     = 1'b1;    
          replace_tag   = 1'b0;
          dcache_stall  = 1'b1;
          tag_sel       = 1'b1;
          amo_buffer_en = 1'b0;
          amo_unit_en   = 1'b0;
        end
        else begin
          next_state    = ALLOCATE;
          cache_rden    = 1'b0;
          cache_wren    = 1'b0;
          cache_insel   = 2'b00;
          mem_rden      = 1'b1;
          mem_wren      = 1'b0;  
          set_dirty     = cpu_wren_reg;
          set_valid     = 1'b1;    
          replace_tag   = 1'b0;
          dcache_stall  = 1'b1;
          tag_sel       = 1'b0;
          amo_buffer_en = 1'b0;
          amo_unit_en   = 1'b0;          
        end
      end
      /***************/
      WRITE_BACK: begin
        if(mem_ready) begin
          next_state    = ALLOCATE;
          cache_rden    = 1'b0;
          cache_wren    = 1'b0;
          cache_insel   = 2'b01;
          mem_rden      = 1'b1;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b0;   
          set_valid     = 1'b0;    
          replace_tag   = 1'b0;
          dcache_stall  = 1'b1;
          tag_sel       = 1'b0;
          amo_buffer_en = 1'b0;
          amo_unit_en   = 1'b0;          
        end
        else begin
          next_state    = WRITE_BACK;
          cache_rden    = 1'b1;
          cache_wren    = 1'b0;
          cache_insel   = 2'b00;
          mem_rden      = 1'b0;
          mem_wren      = 1'b1;  
          set_dirty     = cpu_wren_reg;   
          set_valid     = 1'b1;    
          replace_tag   = 1'b0;
          dcache_stall  = 1'b1;
          tag_sel       = 1'b1;
          amo_buffer_en = 1'b0;
          amo_unit_en   = 1'b0;          
        end
      end
      /*************/
      ALLOCATE: begin
        if(mem_ready) begin
          next_state    = CACHE_ACCESS;
          cache_rden    = 1'b0;
          cache_wren    = 1'b1;
          cache_insel   = 2'b01;
          mem_rden      = 1'b0;
          mem_wren      = 1'b0;  
          set_dirty     = cpu_wren_reg || cpu_amoen_reg; //new  
          set_valid     = 1'b1;    
          replace_tag   = 1'b1;
          dcache_stall  = 1'b1;
          tag_sel       = 1'b0;
          amo_buffer_en = 1'b0;
          amo_unit_en   = 1'b0;          
        end
        else begin
          next_state    = ALLOCATE;
          cache_rden    = 1'b0;
          cache_wren    = 1'b0;
          cache_insel   = 2'b00;
          mem_rden      = 1'b1;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b0;   
          set_valid     = 1'b0;    
          replace_tag   = 1'b0;
          dcache_stall  = 1'b1;
          tag_sel       = 1'b0;
          amo_buffer_en = 1'b0;
          amo_unit_en   = 1'b0;          
        end
      end
      /****************/
      CACHE_ACCESS:begin
        if(!cpu_amoen_reg)begin
          cache_rden    = cpu_rden_reg;
          cache_wren    = cpu_wren_reg;
          cache_insel   = 2'b00;
          mem_rden      = 1'b0;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b0;   
          set_valid     = 1'b0;    
          replace_tag   = 1'b0;
          dcache_stall  = 1'b0;
          tag_sel       = 1'b0;
          amo_buffer_en = 1'b0;
          amo_unit_en   = 1'b0;
          if(glob_stall)
           next_state    = CACHE_ACCESS;
          else if(cpu_rden || cpu_wren || cpu_amoen)
            next_state    = COMPARE_TAG ;
          else 
            next_state    = IDLE;
        end
        else begin //new load part of the amo instruction after cache miss READ
         cache_rden    = cpu_amoen_reg;
         cache_wren    = 1'b0;
         cache_insel   = 2'b00;
         mem_rden      = 1'b0;
         mem_wren      = 1'b0;  
         set_dirty     = 1'b0;   
         set_valid     = 1'b0;    
         replace_tag   = 1'b0;
         dcache_stall  = 1'b1;
         tag_sel       = 1'b0;
         amo_buffer_en = 1'b1;
         amo_unit_en   = 1'b0;
         next_state    = AMO_MODIFY;
        end

      end
       AMO_MODIFY:begin
         cache_rden    = 1'b0;
         cache_wren    = 1'b0;
         cache_insel   = 2'b10;
         mem_rden      = 1'b0;
         mem_wren      = 1'b0;  
         set_dirty     = 1'b0;   
         set_valid     = 1'b0;    
         replace_tag   = 1'b0;
         dcache_stall  = 1'b1;
         tag_sel       = 1'b0;
         amo_buffer_en = 1'b1;
         amo_unit_en   = 1'b1; //new
         next_state    = AMO_STORE;
      end
       AMO_STORE:begin
        cache_rden    = 1'b0;
        cache_wren    = 1'b1;
        cache_insel   = 2'b10;
        mem_rden      = 1'b0;
        mem_wren      = 1'b0;  
        set_dirty     = 1'b0;   
        set_valid     = 1'b0;    
        replace_tag   = 1'b0;
        dcache_stall  = 1'b0;// vip
        tag_sel       = 1'b0;
        amo_buffer_en = 1'b0;
        amo_unit_en   = 1'b1;
        if(glob_stall)
          next_state    = AMO_STORE;
        else if(cpu_rden || cpu_wren || cpu_amoen ) 
          next_state    = COMPARE_TAG ;
        else 
          next_state    = IDLE;
      end
      default:begin
        next_state    = IDLE;
        cache_rden    = 1'b0;
        cache_wren    = 1'b0;
        cache_insel   = 2'b00;
        mem_rden      = 1'b0;
        mem_wren      = 1'b0;  
        set_dirty     = 1'b0;   
        set_valid     = 1'b0;    
        replace_tag   = 1'b0;
        dcache_stall  = 1'b1;
        tag_sel       = 1'b0;
        amo_buffer_en = 1'b0;
        amo_unit_en   = 1'b0;
      end
      
    endcase
  end
endmodule