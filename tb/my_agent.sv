///////////////////////////////////////////////
// file name  : my_agent.sv
// creat time : 2020-04-11
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_agent.sv
// log        : no
///////////////////////////////////////////////

//  Class: my_agent
//
class my_agent extends uvm_agent;
    `uvm_component_utils(my_agent)

    //  Group: Config
    my_tb_config tbcfg;
    

    //  Group: Variables
    my_driver m_drv;
    my_monitor m_mon;
    my_sequencer m_sqr;

    //  Group: Ports


    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_agent", uvm_component parent);
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
    
endclass: my_agent


/*----------------------------------------------------------------------------*/
/*  UVM Build Phases                                                          */
/*----------------------------------------------------------------------------*/
function void my_agent::build_phase(uvm_phase phase);
    /*  note: Do not call super.build_phase() from any class that is extended from an UVM base class!  */
    /*  For more information see UVM Cookbook v1800.2 p.503  */
    // super.build_phase(phase);
    if (!uvm_config_db#(my_tb_config)::get(this, "", "tbcfg", tbcfg)) begin
        `uvm_fatal(get_type_name(), "cannot get tbcfg")
    end
    if (get_is_active()) begin
        m_drv = my_driver::type_id::create("m_drv", this);
        m_sqr = my_sequencer::type_id::create("m_sqr", this);
    end
    m_mon = my_monitor::type_id::create("m_mon", this);
endfunction: build_phase


function void my_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active()) begin
        m_drv.seq_item_port.connect(m_sqr.seq_item_export);
    end
    // connect ports

endfunction: connect_phase


function void my_agent::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase


/*----------------------------------------------------------------------------*/
/*  UVM Run Phases                                                            */
/*----------------------------------------------------------------------------*/
function void my_agent::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase


task my_agent::reset_phase(uvm_phase phase);
endtask: reset_phase


task my_agent::configure_phase(uvm_phase phase);
endtask: configure_phase


task my_agent::main_phase(uvm_phase phase);
endtask: main_phase


task my_agent::shutdown_phase(uvm_phase phase);
endtask: shutdown_phase


task my_agent::run_phase(uvm_phase phase);
endtask: run_phase

/*----------------------------------------------------------------------------*/
/*  UVM Cleanup Phases                                                        */
/*----------------------------------------------------------------------------*/
function void my_agent::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction: report_phase


function void my_agent::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
endfunction: extract_phase



/*----------------------------------------------------------------------------*/
/*  Other Class Functions and Tasks                                           */
/*----------------------------------------------------------------------------*/
