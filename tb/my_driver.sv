///////////////////////////////////////////////
// file name  : my_driver.sv
// creat time : 2020-04-11
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_driver.sv
// log        : no
///////////////////////////////////////////////

//  Class: my_driver
//
class my_driver extends uvm_driver #(my_transaction);
    `uvm_component_utils(my_driver)

    //  Group: Config
    my_tb_config tbcfg;
    

    //  Group: Variables
    virtual my_interface vif;

    //  Group: Functions
    extern virtual task drive_one_pkt(input my_transaction req);
    extern virtual task drive_idle();

    //  Constructor: new
    function new(string name = "my_driver", uvm_component parent);
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

endclass: my_driver


/*----------------------------------------------------------------------------*/
/*  UVM Build Phases                                                          */
/*----------------------------------------------------------------------------*/
function void my_driver::build_phase(uvm_phase phase);
    /*  note: Do not call super.build_phase() from any class that is extended from an UVM base class!  */
    /*  For more information see UVM Cookbook v1800.2 p.503  */
    // super.build_phase(phase);
    if (!uvm_config_db#(my_tb_config)::get(this, "", "tbcfg", tbcfg)) begin
        `uvm_fatal(get_type_name(), "cannot get tbcfg")
    end
    if (!uvm_config_db#(virtual my_interface)::get(this, "", "vif", vif)) begin
        `uvm_fatal(get_type_name(), "cannot get interface")
    end
endfunction: build_phase


function void my_driver::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase


function void my_driver::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase


/*----------------------------------------------------------------------------*/
/*  UVM Run Phases                                                            */
/*----------------------------------------------------------------------------*/
function void my_driver::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase


task my_driver::reset_phase(uvm_phase phase);
endtask: reset_phase


task my_driver::configure_phase(uvm_phase phase);
endtask: configure_phase


task my_driver::main_phase(uvm_phase phase);
endtask: main_phase


task my_driver::shutdown_phase(uvm_phase phase);
endtask: shutdown_phase


task my_driver::run_phase(uvm_phase phase);
    wait(vif.rst_n == 1);
    forever begin
        seq_item_port.try_next_item(req);
        if (req != null) begin
            drive_one_pkt(req);
            seq_item_port.item_done();
        end
        else begin
            // insert an idle cycle
            drive_idle();
        end
    end
endtask: run_phase

/*----------------------------------------------------------------------------*/
/*  UVM Cleanup Phases                                                        */
/*----------------------------------------------------------------------------*/
function void my_driver::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction: report_phase


function void my_driver::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
endfunction: extract_phase


/*----------------------------------------------------------------------------*/
/*  Other Class Functions and Tasks                                           */
/*----------------------------------------------------------------------------*/
task my_driver::drive_one_pkt(input my_transaction req);
endtask: drive_one_pkt


task my_driver::drive_idle();
    @(posedge vif.clk);
endtask: drive_idle
