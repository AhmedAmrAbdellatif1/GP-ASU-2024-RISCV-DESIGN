  ###############################################################################
  # This is generalized cons_script, you have to change only the following:     #
  # Clock Variables                                                             #
  # Inputs&Outputs Variables                                                    #
  # Also, check for the paths                                                   # 
  ###############################################################################

  ###############################################################################
	############################### Set Variables #################################
	###############################################################################
	
  ############################## Clock Variables ################################

  set CLK_PORT 	i_riscv_datapath_clk
  set RST_PORT 	i_riscv_datapath_rst  
  set CLK_NAME 	CLK
  set CLK_PER 	10
  set CLK_LAT 	0
  set CLK_TRANS	0.1
  set CAP_LOAD	0.5
  set CLK_SETUP_SKEW [expr $CLK_PER*0.25]
  set CLK_HOLD_SKEW  [expr $CLK_PER*0.05]

  ############################ Libraries Variables ##############################

  set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"
	set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c"
	set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c"
  
  ########################## Inputs&Outputs Variables ###########################
 
  set dont_touch [list $CLK_PORT $RST_PORT]

  set inputs [remove_from_collection [all_inputs] $dont_touch]
	
  set in_delay   [expr 0.3*$CLK_PER]
	set out_delay  [expr 0.3*$CLK_PER]
  

  ###############################################################################
	############################## Clock Definition ###############################
	###############################################################################

	############################### Master Clock ##################################

	create_clock 	-name $CLK_NAME						        \
					      -period $CLK_PER					        \
					      -waveform "0 [expr $CLK_PER/2]"		\
					      [get_ports $CLK_PORT]					      
					
	########################### Master Clock Uncertainty ##########################
					 
	set_clock_uncertainty -setup $CLK_SETUP_SKEW  [get_clocks $CLK_NAME]
	set_clock_uncertainty -hold  $CLK_HOLD_SKEW   [get_clocks $CLK_NAME]
	
	########################## Master Clock Transition ############################

	set_clock_transition $CLK_TRANS  [get_clocks $CLK_NAME]

	############################ Master Clock Latency #############################

	set_clock_latency $CLK_LAT [get_clocks $CLK_NAME]

	###############################################################################
	##################### Set input/output delay on ports #########################
	###############################################################################

	#Constrain Input Paths
	set_input_delay  $in_delay  -clock $CLK_NAME $inputs

	#Constrain Output Paths
	set_output_delay $out_delay -clock $CLK_NAME [all_outputs]

	#Dont Touch Network
	set_dont_touch_network $dont_touch
	
	##############################################################################
	############################## Driving cells #################################
	##############################################################################

	set_driving_cell 	-library $SSLIB		\
						        -lib_cell BUFX2M	\
                    -no_design_rule   \
						        -pin Y $inputs                  

	##############################################################################
	############################### Output load ##################################
	##############################################################################

	set_load $CAP_LOAD [all_outputs]
	
	##############################################################################
	########################### Operating Condition ##############################
	##############################################################################
	# Define the Worst Library for Max(#setup) analysis
	# Define the Best Library for Min(hold) analysis

	set_operating_conditions 	-min_library  $FFLIB		\
								            -min          $FFLIB    \
								            -max_library  $SSLIB		\
								            -max          $SSLIB               

	##############################################################################
	############################## Wireload Model ################################
	##############################################################################

	set_wire_load_model -name tsmc13_wl30 \
						          -library $SSLIB