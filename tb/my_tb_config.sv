///////////////////////////////////////////////
// file name  : my_tb_config.sv
// creat time : 2020-04-11
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_tb_config.sv
// log        : no
///////////////////////////////////////////////

//  Class: my_tb_config
//
class my_tb_config extends uvm_object;
    typedef my_tb_config this_type_t;
    /*   Be careful to use `uvm_field_* marco     */
    `uvm_object_utils(my_tb_config)

    //  Group: Variables
    bit coverage_enable = 0;
    

    //  Group: Functions

    //  Constructor: new
    function new(string name = "my_tb_config");
        super.new(name);
    endfunction: new

    //  Function: do_copy
    // extern virtual function void do_copy(uvm_object rhs);
    //  Function: do_compare
    // extern virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    //  Function: convert2string
    // extern virtual function string convert2string();
    //  Function: do_print
    // extern virtual function void do_print(uvm_printer printer);
    //  Function: do_record
    // extern virtual function void do_record(uvm_recorder recorder);
    //  Function: do_pack
    // extern virtual function void do_pack();
    //  Function: do_unpack
    // extern virtual function void do_unpack();

    
endclass: my_tb_config
