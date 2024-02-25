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
  output  logic stall         ,
  output  logic tag_sel //new
);

  // 
 typedef enum {IDLE, COMPARE_TAG, WRITE_BACK, ALLOCATE, CACHE_ACCESS} states;
  
  logic [2:0] current_state, next_state;
  logic       cpu_rden_reg,cpu_wren_reg;//new

  // 
  always_ff @(posedge clk or posedge rst) begin
    if(rst)
      current_state <= IDLE;
    else
      current_state <= next_state;
      cpu_rden_reg  <= cpu_rden;//new
      cpu_wren_reg  <= cpu_wren;//new
  end

  // 
  always_comb begin
    case (current_state)
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
          tag_sel       = 1'b0; /// tag used is the input tag physical address 
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
          tag_sel       = 1'b0;//new
        end
      end
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
          stall         = 1'b0;
          tag_sel       = 1'b0;//new
          // 2 load/store instruction 
          if(cpu_rden || cpu_wren)//both of those signals are from the following instructions 
          next_state    = COMPARE_TAG ;
          else 
          next_state    = IDLE;
        end
        else if(dirty) begin
          next_state    = WRITE_BACK;//here for axi bus we need write memory ready signal to be checked first (data, address)
          cache_rden    = 1'b1;
          cache_wren    = 1'b0;
          cache_insel   = 1'b0;
          mem_rden      = 1'b0;
          mem_wren      = 1'b1;//can be considered write signal (data , address) valid  
          set_dirty     = cpu_wren_reg;
          set_valid     = 1'b1;    
          replace_tag   = 1'b1;
          stall         = 1'b1;
          tag_sel       = 1'b1;// tag used is fetched from tag array
        end
        else begin
          next_state    = ALLOCATE;
          cache_rden    = 1'b0;
          cache_wren    = 1'b0;//////cache will write when the memory ready come to indicate valid block *********new
          cache_insel   = 1'b1;
          mem_rden      = 1'b1;
          mem_wren      = 1'b0;  
          set_dirty     = cpu_wren_reg;
          set_valid     = 1'b1;    
          replace_tag   = 1'b1;
          stall         = 1'b1;
          tag_sel       = 1'b0;//new
        end
        /*else begin
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
        end*/
      end
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
          stall         = 1'b1;
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
          replace_tag   = 1'b1;// could be zero,as it is written before 
          stall         = 1'b1;
          tag_sel       = 1'b1;
        end
      end
      ALLOCATE: begin
        if(mem_ready) begin//not memory ready it means read from memory done (read valid)
          next_state    = CACHE_ACCESS;
          cache_rden    = 1'b0;
          cache_wren    = 1'b1;
          cache_insel   = 1'b1;
          mem_rden      = 1'b0;
          mem_wren      = 1'b0;  
          set_dirty     = 1'b0;   
          set_valid     = 1'b0;    
          replace_tag   = 1'b0;
          stall         = 1'b0;
          tag_sel       = 1'b0;// don't care
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
          stall         = 1'b1;
          tag_sel       = 1'b0;
        end
      end
      CACHE_ACCESS:begin
         cache_rden    = cpu_rden_reg;
         cache_wren    = cpu_wren_reg;
         cache_insel   = 1'b0;
         mem_rden      = 1'b0;
         mem_wren      = 1'b0;  
         set_dirty     = 1'b0;   
         set_valid     = 1'b0;    
         replace_tag   = 1'b0;
         stall         = 1'b0;
         tag_sel       = 1'b0;//don't care;
         if(cpu_rden || cpu_wren)//both of those signals are from the following instructions
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
        stall         = 1'b1;
        tag_sel       = 1'b0;
      
      end
      
    endcase
  end
endmodule