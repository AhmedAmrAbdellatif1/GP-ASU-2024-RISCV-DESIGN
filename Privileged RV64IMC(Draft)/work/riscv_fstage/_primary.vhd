library verilog;
use verilog.vl_types.all;
entity riscv_fstage is
    generic(
        width           : integer := 64
    );
    port(
        i_riscv_fstage_clk: in     vl_logic;
        i_riscv_fstage_rst: in     vl_logic;
        i_riscv_fstage_stallpc: in     vl_logic;
        i_riscv_fstage_pcsrc: in     vl_logic;
        i_riscv_fstage_aluexe: in     vl_logic_vector;
        i_riscv_fstage_inst: in     vl_logic_vector(31 downto 0);
        o_riscv_fstage_inst: out    vl_logic_vector(31 downto 0);
        o_riscv_fstage_pcplus4: out    vl_logic_vector;
        i_riscv_fstage_pcsel: in     vl_logic_vector(1 downto 0);
        i_riscv_fstage_mtval: in     vl_logic_vector;
        i_riscv_fstage_mepc: in     vl_logic_vector;
        o_riscv_fstage_pcmux_trap: out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end riscv_fstage;
