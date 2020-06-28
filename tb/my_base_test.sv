///////////////////////////////////////////////
// file name  : my_base_test.sv
// creat time : 2020-04-11
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_base_test.sv
// log        : no
///////////////////////////////////////////////

//  Class: my_base_test
//
class my_base_test extends uvm_test;
    `uvm_component_utils(my_base_test)

    //  Group: Config
    my_tb_config tbcfg;


    //  Group: Variables
    my_env m_env;


    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_base_test", uvm_component parent);
        super.new(name, parent);
        tbcfg = my_tb_config::type_id::create("tbcfg");
    endfunction: new

    /*---  UVM Build Phases            ---*/
    /*------------------------------------*/
    //  Function: build_phase
    extern virtual function void build_phase(uvm_phase phase);
    //  Function: connect_phase
    extern virtual function void connect_phase(uvm_phase phase);
    //  Function: end_of_elaboration_phase
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);


    /*---  UVM Run Phases              ---*/
    /*------------------------------------*/
    //  Function: start_of_simulation_phase
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    //  Function: reset_phase
    extern virtual task reset_phase(uvm_phase phase);
    //  Function: configure_phase
    extern virtual task configure_phase(uvm_phase phase);
    //  Function: main_phase
    extern virtual task main_phase(uvm_phase phase);
    //  Function: shutdown_phase
    extern virtual task shutdown_phase(uvm_phase phase);
    //  Function: run_phase
    extern virtual task run_phase(uvm_phase phase);


    /*---  UVM Cleanup Phases          ---*/
    /*------------------------------------*/
    //  Function: extract_phase
    extern virtual function void extract_phase(uvm_phase phase);
    //  Function: report_phase
    extern virtual function void report_phase(uvm_phase phase);

endclass: my_base_test


/*----------------------------------------------------------------------------*/
/*  UVM Build Phases                                                          */
/*----------------------------------------------------------------------------*/
function void my_base_test::build_phase(uvm_phase phase);
    /*  note: Do not call super.build_phase() from any class that is extended from an UVM base class!  */
    /*  For more information see UVM Cookbook v1800.2 p.503  */
    // super.build_phase(phase);

    // create component
    m_env = my_env::type_id::create("m_env", this);

    // set config
    uvm_config_db#(virtual my_interface)::set(this, "m_env.*", "vif", my_top.m_if);
    uvm_config_db#(my_tb_config)::set(this, "m_env*", "tbcfg", tbcfg);

    // set timeout
    `ifndef PRESURE_TEST
    uvm_top.set_timeout(`TIMEOUT, 0);
    `endif

endfunction: build_phase


function void my_base_test::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // set report verbosity level
    m_env.set_report_verbosity_level_hier(UVM_HIGH);

    // set max quit count
    set_report_max_quit_count(10);

endfunction: connect_phase


function void my_base_test::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    // print the topology of the testbench
    uvm_top.print_topology();

endfunction: end_of_elaboration_phase


/*----------------------------------------------------------------------------*/
/*  UVM Run Phases                                                            */
/*----------------------------------------------------------------------------*/
function void my_base_test::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase


task my_base_test::reset_phase(uvm_phase phase);
endtask: reset_phase


task my_base_test::configure_phase(uvm_phase phase);
endtask: configure_phase


task my_base_test::main_phase(uvm_phase phase);
endtask: main_phase


task my_base_test::shutdown_phase(uvm_phase phase);
endtask: shutdown_phase


task my_base_test::run_phase(uvm_phase phase);
endtask: run_phase


/*----------------------------------------------------------------------------*/
/*  UVM Cleanup Phases                                                        */
/*----------------------------------------------------------------------------*/
function void my_base_test::report_phase(uvm_phase phase);
    uvm_report_server server;
    int err_num;

    super.report_phase(phase);

    server = get_report_server();
    err_num = server.get_severity_count(UVM_ERROR);

    // if (err_num == 0) begin
    //     `uvm_info("TEST CASE PASS", "", UVM_LOW)
    // end
    // else begin
    //     `uvm_error("TEST CASE FAIL", "")
    // end
endfunction: report_phase


function void my_base_test::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
endfunction: extract_phase


/*----------------------------------------------------------------------------*/
/*  Other Class Functions and Tasks                                           */
/*----------------------------------------------------------------------------*/
