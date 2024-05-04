  ##########################################################################
  # This is generalized syn_script, you have to change only the following: #
  # top_design variable                                                    #
  # design_files variable                                                  #
  # Also, check for the paths                                              # 
  ##########################################################################

	########################### Define Top Module ############################
													   
	set top_module riscv_datapath
  set design_files [list riscv_alu.v riscv_branch.v riscv_compressed_decoder.v riscv_control_unit.v riscv_core.v riscv_counter.v riscv_csrfile.v riscv_datapath.v riscv_dcache_amo.v riscv_dcache_data.v riscv_dcache_fsm.v riscv_dcache_tag.v riscv_dcache_top.v riscv_decode_stage.v riscv_divider.v riscv_dram_counter.v riscv_dram_data.v riscv_dram_model.v riscv_execute_stage.v riscv_extend.v riscv_fetch_stage.v riscv_hazardunit.v riscv_icache_fsm.v riscv_icache_inst.v riscv_icache_tag.v riscv_icache_top.v riscv_ICU.v riscv_iram_counter.v riscv_iram_data.v riscv_iram_model.v riscv_lsu.v riscv_memext.v riscv_mem_stage.v riscv_misalignment_unit.v riscv_multiplier.v riscv_mux2.v riscv_mux3.v riscv_mux4.v riscv_mux5.v riscv_pc.v riscv_pcadder.v riscv_ppreg_de.v riscv_ppreg_em.v riscv_ppreg_fd.v riscv_ppreg_mw.v riscv_rf.v riscv_timer_irq.v riscv_tracer.v riscv_trap_wb.v riscv_wb_stage.v riscv_zeroextend.v]
  set_svf $top_module.svf
  set GUI 0

  # ignore certain warnings
  suppress_message {VO-4 OPT-998 ELAB-311}

	##################### Define Working Library Directory ######################
													   
	define_design_lib work -path ./work

	################## Design Compiler Library Files #setup ######################

	puts "###########################################"
	puts "#      #setting Design Libraries          #"
	puts "###########################################"

	#Add the path of the libraries to the search_path variable
	lappend search_path /home/IC/tsmc_fb_cl013g_sc/aci/sc-m/synopsys
	lappend search_path /home/IC/RISCV/rtl

	set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
	set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
	set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

	## Standard Cell libraries 
	set target_library [list $SSLIB $TTLIB $FFLIB]

	## Standard Cell & Hard Macros libraries 
	set link_library [list * $SSLIB $TTLIB $FFLIB]  

	######################## Reading RTL Files #################################

	puts "###########################################"
	puts "#             Reading RTL Files           #"
	puts "###########################################"

	set file_format verilog

	read_file -format $file_format $design_files

	###################### Defining toplevel ###################################

	current_design $top_module

	#################### Liniking All The Design Parts #########################
	puts "###############################################"
	puts "######## Liniking All The Design Parts ########"
	puts "###############################################"

	link 

	#################### Liniking All The Design Parts #########################
	puts "###############################################"
	puts "######## checking design consistency ##########"
	puts "###############################################"

	check_design	

	############################### Path groups ################################
	puts "###############################################"
	puts "################ Path groups ##################"
	puts "###############################################"

	group_path -name INREG 	-from 	[all_inputs]
	group_path -name REGOUT -to  	  [all_outputs]
	group_path -name INOUT 	-from 	[all_inputs] -to [all_outputs]

	#################### Define Design Constraints #########################
	puts "###############################################"
	puts "############ Design Constraints #### ##########"
	puts "###############################################"

	source -echo ./cons.tcl

	###################### Mapping and optimization ########################
	puts "###############################################"
	puts "########## Mapping & Optimization #############"
	puts "###############################################"

	compile -map_effort high

	#############################################################################
	# Write out Design after initial compile
	#############################################################################
	set_svf 	  -off
	#change_name -hier           -rule verilog
	write_file -format verilog 	-hierarchy -output 	$top_module.v
	write_file -format ddc 		  -hierarchy -output 	$top_module.ddc
	write_sdc  -nosplit 							              $top_module.sdc
	write_sdf           							              $top_module.sdf

	################# reporting #######################

	report_area 		    -hierarchy 						          > "area.rpt"
	report_power 		    -hierarchy 						          > "power.rpt"
	report_timing 		  -max_paths 100 -delay_type min 	> "hold.rpt"
	report_timing 		  -max_paths 100 -delay_type max 	> "setup.rpt"
	report_clock 		    -attributes 					          > "clocks.rpt"
	report_constraint 	-all_violators 					        > "constraints.rpt"

	################# starting graphical user interface #######################

	if {$GUI} {
    gui_start
  }

	#exit
