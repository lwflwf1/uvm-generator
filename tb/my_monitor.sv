///////////////////////////////////////////////
// file name  : my_monitor.sv
// creat time : 2020-04-11
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_monitor.sv
// log        : no
///////////////////////////////////////////////

//  Class: my_monitor
//
class my_monitor extends uvm_monitor;
    `uvm_component_utils(my_monitor)

    //  Group: Config
    my_tb_config tbcfg;
    

    //  Group: Variables
    virtual my_interface vif;

    //  Group: Ports
    

    //  Group: Functions
    extern virtual virtual task collect_one_pkt(input my_transaction tr);

    //  Constructor: new
    function new(string name = "my_monitor", uvm_component parent);
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
    
endclass: my_monitor


/*----------------------------------------------------------------------------*/
/*  UVM Build Phases                                                          */
/*----------------------------------------------------------------------------*/
function void my_monitor::build_phase(uvm_phase phase);
    /*  note: Do not call super.build_phase() from any class that is extended from an UVM base class!  */
    /*  For more information see UVM Cookbook v1800.2 p.503  */
    // super.build_phase(phase);
    if (!uvm_config_db#(my_tb_config)::get(this, "", "tbcfg", tbcfg)) begin
        `uvm_fatal(get_type_name(), "cannot get tbcfg")
    end
    if (!uvm_config_db#(virtual my_interface)::get(this, "", "vif", vif)) begin
        `uvm_fatal(get_type_name(), "cannot get interface")
    end

    // create ports

endfunction: build_phase


function void my_monitor::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase


function void my_monitor::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase


/*----------------------------------------------------------------------------*/
/*  UVM Run Phases                                                            */
/*----------------------------------------------------------------------------*/
function void my_monitor::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase


task my_monitor::reset_phase(uvm_phase phase);
endtask: reset_phase


task my_monitor::configure_phase(uvm_phase phase);
endtask: configure_phase


task my_monitor::main_phase(uvm_phase phase);
endtask: main_phase


task my_monitor::shutdown_phase(uvm_phase phase);
endtask: shutdown_phase


task my_monitor::run_phase(uvm_phase phase);
    my_transaction tr;
    wait(vif.rst_n == 1);
    forever begin
        tr = my_transaction::type_id::create("tr");
        collect_one_pkt(tr);
    end
endtask: run_phase



/*----------------------------------------------------------------------------*/
/*  UVM Cleanup Phases                                                        */
/*----------------------------------------------------------------------------*/
function void my_monitor::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction: report_phase


function void my_monitor::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
endfunction: extract_phase


/*----------------------------------------------------------------------------*/
/*  Other Class Functions and Tasks                                           */ 
/*----------------------------------------------------------------------------*/
task my_monitor::collect_one_pkt(input my_transaction tr);
    @(posedge vif.clk);
endtask: collect_one_pkt

