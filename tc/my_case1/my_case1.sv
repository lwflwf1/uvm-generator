///////////////////////////////////////////////
// file name   : my_case1.sv
// create time : 2020-04-11
// author      : Gong Yingfan
// version     : v1.0
// cescript    : my_case1
// log         : no
///////////////////////////////////////////////

//  Class: my_virtual_sequence
//
class my_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(my_virtual_sequence)
    `uvm_declare_p_sequencer(my_virtual_sequencer)

    //  Group: Sequences
    

    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_virtual_sequence");
        super.new(name);
    endfunction: new

    // Task: body
    extern virtual task body();
    // Task: pre_start
    extern virtual task pre_start();
    // Task: post_start
    extern virtual task post_start();

    
endclass: my_virtual_sequence


// Task: body
task my_virtual_sequence::body();
    // start every sequence on each sequencer

    /*------------------------------------------------------------*/
    /* note: Be careful to start sequence array in fork join_none */
    /* Codes below will not work correctly because i is static                        
        for (int i = 0; i < 10; i++) begin
            fork
                `uvm_do_on(seq[i], p_sequencer.sqr[i]
            join_none
        end
    --------------------------------------------------------------*/

    /* note: Use tb_config to control whether to start a sequence */
    repeat(1000) @(posedge my_top.m_if.clk);
endtask: body


// Task: pre_start
task my_virtual_sequence::pre_start();
    if (starting_phase != null) begin
        starting_phase.raise_objection(this);
    end
endtask: pre_start


// Task: post_start
task my_virtual_sequence::post_start();
    if (starting_phase != null) begin
        starting_phase.drop_objection(this);
    end
endtask: post_start



/*---------------------------------------------------*/
/* sequeces                                          */
/*---------------------------------------------------*/









//  Class: my_case1
//
class my_case1 extends my_base_test;
    `uvm_component_utils(my_case1)

    //  Group: Config
    

    //  Group: Variables
    my_virtual_sequence m_vseq;
    

    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_case1", uvm_component parent);
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
    
endclass: my_case1


/*----------------------------------------------------------------------------*/
/*  UVM Build Phases                                                          */
/*----------------------------------------------------------------------------*/
function void my_case1::build_phase(uvm_phase phase);
    /*  note: Do not call super.build_phase() from any class that is extended from an UVM base class!  */
    /*  For more information see UVM Cookbook v1800.2 p.503  */

    // set tbcfg, this must before super.build_phase() 

    super.build_phase(phase);

endfunction: build_phase


function void my_case1::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // override report verbosity level, default is UVM_HIGH
    // m_env.set_report_verbosity_level_hier(UVM_HIGH);

    // override max quit count, default is 10
    // set_report_max_quit_count(10);

endfunction: connect_phase


function void my_case1::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase


/*----------------------------------------------------------------------------*/
/*  UVM Run Phases                                                            */
/*----------------------------------------------------------------------------*/
function void my_case1::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction: start_of_simulation_phase


task my_case1::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
endtask: reset_phase


task my_case1::configure_phase(uvm_phase phase);
    super.configure_phase(phase);
endtask: configure_phase


task my_case1::main_phase(uvm_phase phase);
    super.main_phase(phase);
endtask: main_phase


task my_case1::shutdown_phase(uvm_phase phase);
    super.shutdown_phase(phase);
endtask: shutdown_phase


task my_case1::run_phase(uvm_phase phase);
    super.run_phase(phase);
    // start vseq on vsqr
    m_vseq = my_virtual_sequence::type_id::create("m_vseq");
    m_vseq.starting_phase = phase;
    m_vseq.start(m_env.m_vsqr);
endtask: run_phase


/*----------------------------------------------------------------------------*/
/*  UVM Cleanup Phases                                                        */
/*----------------------------------------------------------------------------*/
function void my_case1::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction: report_phase


function void my_case1::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
endfunction: extract_phase


/*----------------------------------------------------------------------------*/
/*  Other Class Functions and Tasks                                           */
/*----------------------------------------------------------------------------*/
