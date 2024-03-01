  module riscv_mstage #(parameter width=64)(
    input  logic [width-1:0] i_riscv_mstage_dm_rdata,
    input  logic [2:0]      i_riscv_mstage_memext,
    output logic [width-1:0] o_riscv_mstage_memload 

     //input logic          i_riscv_core_timerinterupt  ,
     //input logic          i_riscv_core_externalinterupt

    //trap 
  //  input  logic             i_riscv_csr_

 );
  riscv_memext u_riscv_memext(
    .i_riscv_memext_sel(i_riscv_mstage_memext),
    .i_riscv_memext_data(i_riscv_mstage_dm_rdata),
    .o_riscv_memext_loaded(o_riscv_mstage_memload)
  );

    
  endmodule
 /*
 riscv_csrfile csr_file

    (  
        .i_riscv_csr_clk() ,
        .i_riscv_csr_rst() ,
       .i_riscv_csr_address() ,   //  [11:0]
        .i_riscv_csr_op() ,    // [2:0] 
        .i_riscv_csr_wdata() ,   // [MXLEN-1:0]
        .o_riscv_csr_rdata() ,    //[MXLEN-1:0]
        .o_riscv_csr_sideeffect_flush() ,
     
         
            // Interrupts
        .i_riscv_csr_external_int() , //interrupt from external source
        //input wire i_riscv_csr_software_interrupt, //interrupt from software (inter-processor interrupt)
        .i_riscv_csr_timer_int(), //interrupt from timer

            /// Exceptions ///
        .i_riscv_csr_illegal_inst(), //illegal instruction (From decoder) ??check if can come from csr
       .i_riscv_csr_ecall_u() ,        //ecall instruction from user mode
        .i_riscv_csr_ecall_s() ,        //ecall instruction from s mode
       .i_riscv_csr_ecall_m() ,        //ecall instruction from m mode
        //input csr_op_logic        i_is_mret,         //mret (return from trap) instruction
       .i_riscv_csr_inst_addr_misaligned() , 
        .i_riscv_csr_load_addr_misaligned() , 
        .i_riscv_csr_store_addr_misaligned() , 

     

        .o_riscv_csr_return_address(), //[MXLEN-1:0]
        .o_riscv_csr_trap_address()   ,  //[MXLEN-1:0]

        
        // Trap-Handler  // Interrupts/Exceptions

        .o_riscv_csr_gotoTrap_cs(), //high before going to trap (if exception/interrupt detected)  // Output the exception PC to PC Gen, the correct CSR (mepc, sepc) is set accordingly
        .o_riscv_csr_returnfromTrap_cs() , //high before returning from trap (via mret)
                   
        //output logic              eret_o,                     // Return from exception, set the PC of epc_o  //make mux input this signal to it asserted when mret instrution reaches csr
       

        
        .i_riscv_csr_pc() ,          //[63:0]
        .i_riscv_csr_addressALU() , // [63:0] address  from ALU  used in load/store/jump/branch)

           /// Instruction/Load/Store Misaligned Exception///
        //input wire    [`OPCODE_WIDTH-1:0] i_opcode, //opcode types
        //input wire    [31:0] i_y, //y value from ALU (address used in load/store/jump/branch) // to check if its misaligned or not

        .o_riscv_csr_privlvl()  ,  //[1:0]

        .o_riscv_csr_flush()
     
   // input wire writeback_change_pc, //high if writeback will issue change_pc (which will override this stage)

 );  */

 
