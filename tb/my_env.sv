///////////////////////////////////////////////
// file name  : my_env.sv
// creat time : 2020-04-11
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_env.sv
// log        : no
///////////////////////////////////////////////

//  Class: my_env
//
class my_env extends uvm_env;
    `uvm_component_utils(my_env)

    //  Group: Config
    my_tb_config tbcfg;
    

    //  Group: Variables
    my_scoreboard m_scb;
    my_reference_model m_ref_mdl;
    my_subscriber m_sbr;
    my_virtual_sequencer m_vsqr;


    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_env", uvm_component parent);
        super.new(name, parent);
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
    
endclass: my_env


/*----------------------------------------------------------------------------*/
/*  UVM Build Phases                                                          */
/*----------------------------------------------------------------------------*/
function void my_env::build_phase(uvm_phase phase);
    /*  note: Do not call super.build_phase() from any class that is extended from an UVM base class!  */
    /*  For more information see UVM Cookbook v1800.2 p.503  */
    // super.build_phase(phase);
    // create component
    m_ref_mdl = my_reference_model::type_id::create("m_ref_mdl", this);
    m_sbr     = my_subscriber::type_id::create("m_sbr", this);
    m_scb     = my_scoreboard::type_id::create("m_scb", this);
    m_vsqr    = my_virtual_sequencer::type_id::create("m_vsqr", this);
    
    // get config
    if(!uvm_config_db#(my_tb_config)::get(this, "", "tbcfg", tbcfg)) begin
        `uvm_fatal(get_type_name(), "cannot get tbcfg!")
    end
    // set config
    
endfunction: build_phase


function void my_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // connect sequencer

    // connect ports

endfunction: connect_phase


function void my_env::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase


/*----------------------------------------------------------------------------*/
/*  UVM Run Phases                                                            */
/*----------------------------------------------------------------------------*/
function void my_env::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase


task my_env::reset_phase(uvm_phase phase);
endtask: reset_phase


task my_env::configure_phase(uvm_phase phase);
endtask: configure_phase


task my_env::main_phase(uvm_phase phase);
endtask: main_phase


task my_env::shutdown_phase(uvm_phase phase);
endtask: shutdown_phase


task my_env::run_phase(uvm_phase phase);
endtask: run_phase


/*----------------------------------------------------------------------------*/
/*  UVM Cleanup Phases                                                        */
/*----------------------------------------------------------------------------*/
function void my_env::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction: report_phase


function void my_env::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
endfunction: extract_phase


/*----------------------------------------------------------------------------*/
/*  Other Class Functions and Tasks                                           */
/*----------------------------------------------------------------------------*/
