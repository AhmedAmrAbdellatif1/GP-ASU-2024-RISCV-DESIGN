library verilog;
use verilog.vl_types.all;
entity riscv_estage is
    generic(
        width           : integer := 64
    );
    port(
        i_riscv_estage_clk: in     vl_logic;
        i_riscv_estage_rst: in     vl_logic;
        i_riscv_estage_imm_m: in     vl_logic_vector;
        i_riscv_estage_rs1data: in     vl_logic_vector;
        i_riscv_estage_rs2data: in     vl_logic_vector;
        i_riscv_estage_fwda: in     vl_logic_vector(1 downto 0);
        i_riscv_estage_fwdb: in     vl_logic_vector(1 downto 0);
        i_riscv_estage_rdata_wb: in     vl_logic_vector;
        i_riscv_estage_rddata_m: in     vl_logic_vector;
        i_riscv_estage_oprnd1sel: in     vl_logic;
        i_riscv_estage_oprnd2sel: in     vl_logic;
        i_riscv_estage_pc: in     vl_logic_vector;
        i_riscv_estage_aluctrl: in     vl_logic_vector(5 downto 0);
        i_riscv_estage_mulctrl: in     vl_logic_vector(3 downto 0);
        i_riscv_estage_divctrl: in     vl_logic_vector(3 downto 0);
        i_riscv_estage_funcsel: in     vl_logic_vector(1 downto 0);
        i_riscv_estage_simm: in     vl_logic_vector;
        i_riscv_estage_bcond: in     vl_logic_vector(3 downto 0);
        o_riscv_estage_result: out    vl_logic_vector;
        o_riscv_estage_store_data: out    vl_logic_vector;
        o_riscv_estage_branchtaken: out    vl_logic;
        o_riscv_estage_div_en: out    vl_logic;
        o_riscv_estage_mul_en: out    vl_logic;
        o_riscv_estage_icu_valid: out    vl_logic;
        i_riscv_estage_imm_reg: in     vl_logic;
        i_riscv_estage_immextended: in     vl_logic_vector;
        o_riscv_estage_csrwritedata: out    vl_logic_vector;
        i_riscv_stage_opcode: in     vl_logic_vector(6 downto 0);
        i_riscv_estage_memext: in     vl_logic_vector(2 downto 0);
        i_riscv_estage_storesrc: in     vl_logic_vector(1 downto 0);
        o_riscv_estage_inst_addr_misaligned: out    vl_logic;
        o_riscv_estage_store_addr_misaligned: out    vl_logic;
        o_riscv_estage_load_addr_misaligned: out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end riscv_estage;
