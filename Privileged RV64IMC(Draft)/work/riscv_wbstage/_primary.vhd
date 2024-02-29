library verilog;
use verilog.vl_types.all;
entity riscv_wbstage is
    generic(
        width           : integer := 64
    );
    port(
        i_riscv_wb_resultsrc: in     vl_logic_vector(1 downto 0);
        i_riscv_wb_pcplus4: in     vl_logic_vector;
        i_riscv_wb_result: in     vl_logic_vector;
        i_riscv_wb_memload: in     vl_logic_vector;
        i_riscv_wb_uimm : in     vl_logic_vector;
        o_riscv_wb_rddata: out    vl_logic_vector;
        i_riscv_wb_csrout: in     vl_logic_vector;
        i_riscv_wb_iscsr: in     vl_logic;
        i_riscv_wb_gototrap: in     vl_logic;
        i_riscv_wb_returnfromtrap: in     vl_logic;
        o_riscv_wb_pcsel: out    vl_logic_vector(1 downto 0);
        o_riscv_wb_flush: out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end riscv_wbstage;
