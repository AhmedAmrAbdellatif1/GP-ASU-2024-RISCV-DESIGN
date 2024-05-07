module icache_fsm  (
  input   logic       clk              ,
  input   logic       rst              ,
  input   logic       hit              ,
  input   logic       hit_missalign    ,
  input   logic       mem_ready        ,// when ready the memory operation is done (it will be read response or valid bit for AXI bus)
  input   logic [3:0] block_offset     ,// used to check for missalignment
  output  logic       cache_wren       ,//permission to write to  cache from ram at negative edge
  output  logic       mem_rden         ,// permission to read from memory
  output  logic       set_valid        ,
  output  logic       replace_tag      ,
  output  logic       stall            ,//used to stall all the pipeline register and PC
  output  logic       addr_sel         ,// select the address(index) for the fetched block from ram to cache (idexed one or the following one for missalignment)
  // also used as input to instruction array to write the block (idexed one or the following one for missalignment) in the cache after ALLOCATE_1 or ALLOCATE_2 resp.
  output  logic       set_valid_align  ,
  output  logic       replace_tag_align
);

  // 
  typedef enum {NORMAL_OP, ALLOCATE_1,ALLOCATE_2, CACHE_ACCESS} states;
  states current_state, next_state;

  // 
  always_ff @(posedge clk or posedge rst) begin
    if(rst)
      current_state <= NORMAL_OP;
    else
      current_state <= next_state;    
  end


  // 
  always_comb begin
    case (current_state)
      NORMAL_OP: begin
        if(!hit) begin//checking block offset at allocate 1 
          next_state        = ALLOCATE_1;
          cache_wren        = 1'b0;
          mem_rden          = 1'b1;    
          addr_sel          = 1'b0;
          set_valid_align   = 1'b0;    
          replace_tag_align = 1'b0;
          set_valid         = 1'b0;
          replace_tag       = 1'b0;
          stall             = 1'b1;
         end    
        
        else if((hit && (block_offset<'b1101))||(hit && (block_offset>'b1100) && hit_missalign))begin//normal hit or hit with miss alignment hit  
          next_state        = NORMAL_OP;
          cache_wren        = 1'b0;
          mem_rden          = 1'b0;
          addr_sel          = 1'b0;
          set_valid         = 1'b1;    
          replace_tag       = 1'b0;
          stall             = 1'b0;
          set_valid_align   = 1'b0;
          replace_tag_align = 1'b0;
        end
        else if(hit && (block_offset>'b1100) && !hit_missalign)begin
          next_state        = ALLOCATE_2;
          cache_wren        = 1'b0;
          mem_rden          = 1'b1;    
          addr_sel          = 1'b1;
          set_valid_align   = 1'b0;
          replace_tag_align = 1'b0;
          set_valid         = 1'b0;
          replace_tag       = 1'b0;
          stall             = 1'b1;          
        end
        else begin
          next_state        = NORMAL_OP;
          cache_wren        = 1'b0;
          mem_rden          = 1'b0;    
          addr_sel          = 1'b0;
          set_valid_align   = 1'b0;    
          replace_tag_align = 1'b0;
          set_valid         = 1'b0;
          replace_tag       = 1'b0;
          stall             = 1'b0;
        end
      end
      ALLOCATE_1: begin
        if(mem_ready) begin//not memory ready it means read from memory done (read valid)
          if((block_offset<'b1101)||((block_offset>'b1100) && hit_missalign))begin
              next_state        = CACHE_ACCESS;
              cache_wren        = 1'b1;
              mem_rden          = 1'b0;  
              set_valid         = 1'b1;  
              replace_tag       = 1'b1;
              stall             = 1'b1;
              addr_sel          = 1'b0;
              set_valid_align   = 1'b0;
              replace_tag_align = 1'b0;
          end
          else if(((block_offset>'b1100) && !hit_missalign))begin
              next_state        = ALLOCATE_2;
              cache_wren        = 1'b1;
              mem_rden          = 1'b0;  
              set_valid         = 1'b1;  
              replace_tag       = 1'b1;
              stall             = 1'b1;
              addr_sel          = 1'b0;
              set_valid_align   = 1'b0;
              replace_tag_align = 1'b0;
          end
          else begin
            next_state        = ALLOCATE_1; 
            cache_wren        = 1'b0;
            mem_rden          = 1'b1;  
            set_valid         = 1'b0;  
            replace_tag       = 1'b0;
            stall             = 1'b1;
            addr_sel          = 1'b0;
            set_valid_align   = 1'b0;
            replace_tag_align = 1'b0;
          end
        end
        else begin
          next_state        = ALLOCATE_1;
          cache_wren        = 1'b0;
          mem_rden          = 1'b1;  
          set_valid         = 1'b0;    
          replace_tag       = 1'b0;
          stall             = 1'b1;
          addr_sel          = 1'b0;
          set_valid_align   = 1'b0;
          replace_tag_align = 1'b0;
        end
      end
      CACHE_ACCESS:begin/// والله ما لها داعي
         next_state        = NORMAL_OP;
         cache_wren        = 1'b0;
         mem_rden          = 1'b0;   
         set_valid         = 1'b0;    
         replace_tag       = 1'b0;
         stall             = 1'b0;
         addr_sel          = 1'b0;
         set_valid_align   = 1'b0;
         replace_tag_align = 1'b0; ////
      end
      ALLOCATE_2:begin
      if(mem_ready) begin//not memory ready it means read from memory done (read valid)
         next_state          = CACHE_ACCESS;
         cache_wren          = 1'b1;
         mem_rden            = 1'b0; 
         set_valid           = 1'b0;
         replace_tag         = 1'b0;  
         set_valid_align     = 1'b1;    
         replace_tag_align   = 1'b1;
         stall               = 1'b1;
         addr_sel            = 1'b1;
       end
       else begin
         next_state        = ALLOCATE_2;
         cache_wren        = 1'b1;
         mem_rden          = 1'b1;  
         set_valid         = 1'b0;  
         replace_tag       = 1'b0;
         stall             = 1'b1;
         addr_sel          = 1'b1;
         set_valid_align   = 1'b0;
         replace_tag_align = 1'b0;
       end
      end
      default:begin
        next_state        = NORMAL_OP;
        cache_wren        = 1'b0;
        mem_rden          = 1'b0;  
        set_valid         = 1'b0;    
        replace_tag       = 1'b0;
        stall             = 1'b0;
        addr_sel          = 1'b0;
        set_valid_align   = 1'b0;
        replace_tag_align = 1'b0;   
      end
      
    endcase
  end
endmodule