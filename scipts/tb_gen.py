#!/home/gongyf/.conda/envs/gong/bin/python

from glob import glob
import re
import json
import subprocess
import shutil
from datetime import date
import os
import sys


def filelist_gen(cfg):
    def sort_key_for_filelist(f):
        dict_for_filelist = {
            r'transaction'           : 1,
            r'tb_config'             : 1,
            r'interface'             : 1,
            r'(?<!virtual_)sequencer': 2,
            r'driver'                : 2,
            r'monitor'               : 2,
            r'agent'                 : 3,
            r'subscriber'            : 3,
            r'model'                 : 3,
            r'scoreboard'            : 3,
            r'virtual_sequencer'     : 3,
            r'env'                   : 4,
            r'test'                  : 5,
            r'top'                   : 6,
        }
        for pattern in dict_for_filelist:
            if re.search(pattern, f) is not None:
                return dict_for_filelist[pattern]
    

    files = sorted(glob('./tb/*.sv'), key=sort_key_for_filelist)
    with open('./filelist/filelist.f', 'w', encoding='utf-8') as f:
        f.write('./common/define.sv\n')
        for x in files:
            f.write(f'{x}\n') 
    rtl = glob(f'{cfg["rtl_path"]}/*')
    with open('./filelist/filelist.f', 'a', encoding='utf-8') as f:
        for x in rtl:
            f.write(f'{x}\n')


def parse_cfg(cfg_path):
    with open(cfg_path, 'r', encoding='utf-8') as f:
        cfg = json.load(f)
    if cfg['author'] == '':
        raise ValueError('"author" not set!')
    if cfg['module_name'] == '':
        raise ValueError('"module_name" not set!')
    if cfg['rtl_top_path'] == '':
        raise ValueError('"rtl_top_path" not set!')
    if cfg['ref_mdl_to_scb'] == 0:
        raise ValueError('"ref_mdl_to_scb" not set!')
    agent_type_number = len(cfg['agent']['type'])
    if agent_type_number == 0:
        raise ValueError('"agent name" not set!')
    if len(cfg['agent']['inst_number']) != agent_type_number:
        raise ValueError(f'"agent inst_number" is not correct!')
    if len(cfg['agent']['to_sbr']) != agent_type_number:
        raise ValueError(f'"agent to_sbr" is not correct!')
    if len(cfg['agent']['to_scb']) != agent_type_number:
        raise ValueError(f'"agent to_scb" is not correct!')
    if len(cfg['agent']['to_ref_mdl']) != agent_type_number:
        raise ValueError(f'"agent to_ref_mdl" is not correct!')
    cfg['time'] = date.today()
    cfg['agent_type_number'] = agent_type_number
    os.mkdir('./tmp')
    os.mkdir('./tmp/my_case1')
    for f in glob('./tb/*.sv'):
        shutil.move(f, f.replace('tb', 'tmp', 1))
    for f in glob('./tc/my_case1/*'):
        shutil.move(f, f.replace('tc', 'tmp'))
    return cfg


def comp_gen(comp, cfg, an_index=None):

    def port_gen():
        if comp in ['agent', 'driver', 'monitor', 'sequencer']:
            if port_p.search(line):
                if cfg['agent']['to_ref_mdl'][an_index]:
                    s = f'    uvm_analysis_port #(my_{comp_name}_transaction) to_ref_mdl_ap;\n'
                    f.write(s)
                if cfg['agent']['to_scb'][an_index]:
                    s = f'    uvm_analysis_port #(my_{comp_name}_transaction) to_scb_ap;\n'
                    f.write(s)
                if cfg['agent']['to_sbr'][an_index]:
                    s = f'    uvm_analysis_port #(my_{comp_name}_transaction) to_sbr_ap;\n'
                    f.write(s)
            if comp == 'agent':
                if connect_p.search(line):
                    if cfg['agent']['to_ref_mdl'][an_index]:
                        s = f'    to_ref_mdl_ap = m_mon.to_ref_mdl_ap;\n'
                        f.write(s)
                    if cfg['agent']['to_scb'][an_index]:
                        s = f'    to_scb_ap = m_mon.to_scb_ap;\n'
                        f.write(s)
                    if cfg['agent']['to_sbr'][an_index]:
                        s = f'    to_sbr_ap = m_mon.to_sbr_ap;\n'
                        f.write(s)
            else:
                if create_port_p.search(line):
                    if cfg['agent']['to_ref_mdl'][an_index]:
                        s = f'    to_ref_mdl_ap = new("to_ref_mdl_ap", this);\n'
                        f.write(s)
                    if cfg['agent']['to_scb'][an_index]:
                        s = f'    to_scb_ap = new("to_scb_ap", this);\n'
                        f.write(s)
                    if cfg['agent']['to_sbr'][an_index]:
                        s = f'    to_sbr_ap = new("to_sbr_ap", this);\n'
                        f.write(s)
        elif 'reference' in comp:
            if decl_p.search(line):
                for i, x in enumerate(cfg['agent']['to_ref_mdl']):
                    if x:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    `uvm_analysis_imp_decl(_{cfg["agent"]["type"][i]})\n')
                        else:
                            for j in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    `uvm_analysis_imp_decl(_{cfg["agent"]["type"][i]}{j})\n')
            if port_p.search(line):
                for i, x in enumerate(cfg['agent']['to_ref_mdl']):
                    if x:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    uvm_analysis_imp_{cfg["agent"]["type"][i]} #(my_{cfg["module_name"]}_{cfg["agent"]["type"][i]}_transaction, my_{cfg["module_name"]}_reference_model) imp_{cfg["agent"]["type"][i]};\n')
                        else:
                            for j in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    uvm_analysis_imp_{cfg["agent"]["type"][i]}{j} #(my_{cfg["module_name"]}_{cfg["agent"]["type"][i]}_transaction, my_{cfg["module_name"]}_reference_model) imp_{cfg["agent"]["type"][i]}{j};\n')
                if cfg['ref_mdl_to_scb'] == 1:
                    f.write(f'    uvm_analysis_port #(my_{cfg["module_name"]}_transaction) to_scb_ap;\n')
                else:
                    f.write(f'    uvm_analysis_port #(my_{cfg["module_name"]}_transaction) to_scb_ap[{cfg["ref_mdl_to_scb"]}];\n')
            if create_port_p.search(line):
                for i, x in enumerate(cfg['agent']['to_ref_mdl']):
                    if x:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    imp_{cfg["agent"]["type"][i]} = new("imp_{cfg["agent"]["type"][i]}", this);\n')
                        else:
                            for j in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    imp_{cfg["agent"]["type"][i]}{j} = new("imp_{cfg["agent"]["type"][i]}{j}", this);\n')
                if cfg['ref_mdl_to_scb'] == 1:
                    f.write(f'    to_scb_ap = new("to_scb_ap", this);\n')
                else:
                    s = f'''    for(int i = 0; i < {cfg['ref_mdl_to_scb']}; i++) begin
        to_scb_ap[i] = new($sformatf("to_scb_ap[%0d]", i), this);
    end\n'''
                    f.write(s)
        elif 'score' in comp:
            if decl_p.search(line):
                for i, x in enumerate(cfg['agent']['to_scb']):
                    if x:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    `uvm_analysis_imp_decl(_{cfg["agent"]["type"][i]})\n')
                        else:
                            for j in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    `uvm_analysis_imp_decl(_{cfg["agent"]["type"][i]}{j})\n')
                if cfg['ref_mdl_to_scb'] == 1:
                    f.write(f'    `uvm_analysis_imp_decl(_ref);\n')
                else:
                    for i in range(cfg['ref_mdl_to_scb']):
                        f.write(f'    `uvm_analysis_imp_decl(_ref{i});\n')
            if port_p.search(line):
                for i, x in enumerate(cfg['agent']['to_scb']):
                    if x:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    uvm_analysis_imp_{cfg["agent"]["type"][i]} #(my_{cfg["module_name"]}_{cfg["agent"]["type"][i]}_transaction, my_{cfg["module_name"]}_scoreboard) imp_{cfg["agent"]["type"][i]};\n')
                        else:
                            for j in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    uvm_analysis_imp_{cfg["agent"]["type"][i]}{j} #(my_{cfg["module_name"]}_{cfg["agent"]["type"][i]}_transaction, my_{cfg["module_name"]}_scoreboard) imp_{cfg["agent"]["type"][i]}{j};\n')
                if cfg['ref_mdl_to_scb'] == 1:
                    f.write(f'    uvm_analysis_imp_ref #(my_{cfg["module_name"]}_transaction, my_{cfg["module_name"]}_scoreboard) imp_ref;\n')
                else:
                    for i in range(cfg['ref_mdl_to_scb']):
                        f.write(f'    uvm_analysis_imp_ref{i} #(my_{cfg["module_name"]}_transaction, my_{cfg["module_name"]}_scoreboard) imp_ref{i};\n')
            if create_port_p.search(line):
                for i, x in enumerate(cfg['agent']['to_scb']):
                    if x:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    imp_{cfg["agent"]["type"][i]} = new("imp_{cfg["agent"]["type"][i]}", this);\n')
                        else:
                            for j in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    imp_{cfg["agent"]["type"][i]}{j} = new("imp_{cfg["agent"]["type"][i]}{j}", this);\n')
                if cfg['ref_mdl_to_scb'] == 1:
                    f.write(f'    imp_ref = new("imp_ref", this);\n')
                else:
                    for i in range(cfg['ref_mdl_to_scb']):
                        f.write(f'    imp_ref{i} = new("imp_ref{i}", this);\n')
        elif 'env' in comp:
            if connect_p.search(line):
                for i, x in enumerate(cfg['agent']['to_ref_mdl']):
                    if x:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    m_{cfg["agent"]["type"][i]}_agt.to_ref_mdl_ap.connect(m_ref_mdl.imp_{cfg["agent"]["type"][i]});\n')
                        else:
                            for j in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    m_{cfg["agent"]["type"][i]}_agt[{j}].to_ref_mdl_ap.connect(m_ref_mdl.imp_{cfg["agent"]["type"][i]}{j});\n')
                for i, x in enumerate(cfg['agent']['to_scb']):
                    if x:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    m_{cfg["agent"]["type"][i]}_agt.to_scb_ap.connect(m_scb.imp_{cfg["agent"]["type"][i]});\n')
                        else:
                            for j in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    m_{cfg["agent"]["type"][i]}_agt[{j}].to_scb_ap.connect(m_scb.imp_{cfg["agent"]["type"][i]}{j});\n')
                for i, x in enumerate(cfg['agent']['to_sbr']):
                    if x:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    m_{cfg["agent"]["type"][i]}_agt.to_sbr_ap.connect(m_sbr.imp_{cfg["agent"]["type"][i]});\n')
                        else:
                            for j in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    m_{cfg["agent"]["type"][i]}_agt[{j}].to_sbr_ap.connect(m_sbr.imp_{cfg["agent"]["type"][i]}{j});\n')
                if cfg['ref_mdl_to_scb'] == 1:
                    f.write(f'    m_ref_mdl.to_scb_ap.connect(m_scb.imp_ref);\n')
                else:
                    for i in range(cfg['ref_mdl_to_scb']):
                        f.write(f'    m_ref_mdl.to_scb_ap[{i}].connect(m_scb.imp_ref{i});\n')
        elif 'subs' in comp:
            if decl_p.search(line):
                for i, x in enumerate(cfg['agent']['to_sbr']):
                    if x:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    `uvm_analysis_imp_decl(_{cfg["agent"]["type"][i]})\n')
                        else:
                            for j in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    `uvm_analysis_imp_decl(_{cfg["agent"]["type"][i]}{j})\n')
            if port_p.search(line):
                for i, x in enumerate(cfg['agent']['to_sbr']):
                    if x:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    uvm_analysis_imp_{cfg["agent"]["type"][i]} #(my_{cfg["module_name"]}_{cfg["agent"]["type"][i]}_transaction, my_{cfg["module_name"]}_subscriber) imp_{cfg["agent"]["type"][i]};\n')
                        else:
                            for j in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    uvm_analysis_imp_{cfg["agent"]["type"][i]}{j} #(my_{cfg["module_name"]}_{cfg["agent"]["type"][i]}_transaction, my_{cfg["module_name"]}_subscriber) imp_{cfg["agent"]["type"][i]}{j};\n')
            if create_port_p.search(line):
                for i, x in enumerate(cfg['agent']['to_sbr']):
                    if x:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    imp_{cfg["agent"]["type"][i]} = new("imp_{cfg["agent"]["type"][i]}", this);\n')
                        else:
                            for j in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    imp_{cfg["agent"]["type"][i]}{j} = new("imp_{cfg["agent"]["type"][i]}{j}", this);\n')


    def add_sqr_to_vsqr():
        if statement_p.search(line):
            for i, x in enumerate(cfg["agent"]["to_ref_mdl"]):
                if x:
                    if cfg['agent']['inst_number'][i] == 1:
                        f.write(f'    my_{cfg["module_name"]}_{cfg["agent"]["type"][i]}_sequencer m_{cfg["agent"]["type"][i]}_sqr;\n')
                    else:
                        f.write(f'    my_{cfg["module_name"]}_{cfg["agent"]["type"][i]}_sequencer m_{cfg["agent"]["type"][i]}_sqr[{cfg["agent"]["inst_number"][i]}];\n')

    def connect_sqr():
        if connectsqr_p.search(line):
            for i, x in enumerate(cfg['agent']['to_ref_mdl']):
                if x:
                    if cfg['agent']['inst_number'][i] == 1:
                        f.write(f'    m_vsqr.m_{cfg["agent"]["type"][i]}_sqr = m_{cfg["agent"]["type"][i]}_agt.m_sqr;\n')
                    else:
                        s = f'''    for (int i = 0; i < {cfg["agent"]["inst_number"][i]}; i++) begin
        m_vsqr.m_{cfg["agent"]["type"][i]}_sqr[i] = m_{cfg["agent"]["type"][i]}_agt[i].m_sqr;
    end\n'''
                        f.write(s)

    def create_agt():
        if statement_p.search(line):
            for i in range(cfg['agent_type_number']):
                if cfg['agent']['inst_number'][i] == 1:
                    f.write(f'    my_{cfg["module_name"]}_{cfg["agent"]["type"][i]}_agent m_{cfg["agent"]["type"][i]}_agt;\n')
                else:
                    f.write(f'    my_{cfg["module_name"]}_{cfg["agent"]["type"][i]}_agent m_{cfg["agent"]["type"][i]}_agt[{cfg["agent"]["inst_number"][i]}];\n')
        if create_comp_p.search(line):
            for i in range(cfg['agent_type_number']):
                if cfg['agent']['inst_number'][i] == 1:
                    f.write(f'    m_{cfg["agent"]["type"][i]}_agt = my_{cfg["module_name"]}_{cfg["agent"]["type"][i]}_agent::type_id::create("m_{cfg["agent"]["type"][i]}_agt", this);\n')
                else:
                    s = f'''    for (int i = 0; i < {cfg["agent"]["inst_number"][i]}; i++) begin
        m_{cfg["agent"]["type"][i]}_agt[i] = my_{cfg["module_name"]}_{cfg["agent"]["type"][i]}_agent::type_id::create($sformatf("m_{cfg["agent"]["type"][i]}_agt[%0d]", i), this);
    end\n'''
                    f.write(s)


    def add_write_func():
        if write_p.search(line):
            if 'ref' in comp:
                for i in range(cfg['agent_type_number']):
                    if cfg['agent']['to_ref_mdl'][i]:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'function void my_{comp_name}_{comp}::write_{cfg["agent"]["type"][i]}(input my_{comp_name}_{cfg["agent"]["type"][i]}_transaction tr);\n')
                            f.write(f'endfunction\n\n\n')
                        else:
                            for k in range(cfg['agent']['inst_number'][i]):
                                f.write(f'function void my_{comp_name}_{comp}::write_{cfg["agent"]["type"][i]}{k}(input my_{comp_name}_{cfg["agent"]["type"][i]}_transaction tr);\n')
                                f.write(f'endfunction\n\n\n')
            if 'score' in comp:
                for i in range(cfg['agent_type_number']):
                    if cfg['agent']['to_scb'][i]:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'function void my_{comp_name}_{comp}::write_{cfg["agent"]["type"][i]}(input my_{comp_name}_{cfg["agent"]["type"][i]}_transaction tr);\n')
                            f.write(f'endfunction\n\n\n')
                        else:
                            for k in range(cfg['agent']['inst_number'][i]):
                                f.write(f'function void my_{comp_name}_{comp}::write_{cfg["agent"]["type"][i]}{k}(input my_{comp_name}_{cfg["agent"]["type"][i]}_transaction tr);\n')
                                f.write(f'endfunction\n\n\n')
                if cfg['ref_mdl_to_scb'] == 1:
                    f.write(f'function void my_{comp_name}_{comp}::write_ref(input my_{comp_name}_transaction tr);\n')
                    f.write(f'endfunction\n\n\n')
                else:
                    for i in range(cfg['ref_mdl_to_scb']):
                        f.write(f'function void my_{comp_name}_{comp}::write_ref{i}(input my_{comp_name}_transaction tr);\n')
                        f.write(f'endfunction\n\n\n')
            if 'subs' in comp:
                for i in range(cfg['agent_type_number']):
                    if cfg['agent']['to_sbr'][i]:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'function void my_{comp_name}_{comp}::write_{cfg["agent"]["type"][i]}(input my_{comp_name}_{cfg["agent"]["type"][i]}_transaction tr);\n')
                            f.write(f'endfunction\n\n\n')
                        else:
                            for k in range(cfg['agent']['inst_number'][i]):
                                f.write(f'function void my_{comp_name}_{comp}::write_{cfg["agent"]["type"][i]}{k}(input my_{comp_name}_{cfg["agent"]["type"][i]}_transaction tr);\n')
                                f.write(f'endfunction\n\n\n')
        if func_p.search(line):
            if 'ref' in comp:
                for i in range(cfg['agent_type_number']):
                    if cfg['agent']['to_ref_mdl'][i]:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    extern virtual function void write_{cfg["agent"]["type"][i]}(input my_{comp_name}_{cfg["agent"]["type"][i]}_transaction tr);\n')
                        else:
                            for k in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    extern virtual function void write_{cfg["agent"]["type"][i]}{k}(input my_{comp_name}_{cfg["agent"]["type"][i]}_transaction tr);\n')
            if 'score' in comp:
                for i in range(cfg['agent_type_number']):
                    if cfg['agent']['to_scb'][i]:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    extern virtual function void write_{cfg["agent"]["type"][i]}(input my_{comp_name}_{cfg["agent"]["type"][i]}_transaction tr);\n')
                        else:
                            for k in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    extern virtual function void write_{cfg["agent"]["type"][i]}{k}(input my_{comp_name}_{cfg["agent"]["type"][i]}_transaction tr);\n')
                if cfg['ref_mdl_to_scb'] == 1:
                    f.write(f'    extern virtual function void write_ref(input my_{comp_name}_transaction tr);\n')
                else:
                    for i in range(cfg['ref_mdl_to_scb']):
                        f.write(f'    extern virtual function void write_ref{i}(input my_{comp_name}_transaction tr);\n')
            if 'subs' in comp:
                for i in range(cfg['agent_type_number']):
                    if cfg['agent']['to_sbr'][i]:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    extern virtual function void write_{cfg["agent"]["type"][i]}(input my_{comp_name}_{cfg["agent"]["type"][i]}_transaction tr);\n')
                        else:
                            for k in range(cfg['agent']['inst_number'][i]):
                                f.write(f'    extern virtual function void write_{cfg["agent"]["type"][i]}{k}(input my_{comp_name}_{cfg["agent"]["type"][i]}_transaction tr);\n')
            
    def add_tbcfg():
        if setcfg_p.search(line):
            for i in range(cfg['agent_type_number']):
                if cfg['agent']['inst_number'][i] == 1:
                    f.write(f'    m_{cfg["agent"]["type"][i]}_agt.is_active = tbcfg.{cfg["agent"]["type"][i]}_agt_is_active;\n')
                else:
                    s = f'''    for (int i = 0; i < {cfg['agent']['inst_number'][i]}; i++) begin
        m_{cfg["agent"]["type"][i]}_agt[i].is_active = tbcfg.{cfg["agent"]["type"][i]}_agt_is_active[i];
    end\n'''
                    f.write(s)

    def add_config_to_tb_config():
        if statement_p.search(line):
            for i in range(cfg['agent_type_number']):
                if cfg['agent']['inst_number'][i] == 1:
                    f.write(f'    uvm_active_passive_enum {cfg["agent"]["type"][i]}_agt_is_active;\n')
                else:
                    f.write(f'    uvm_active_passive_enum {cfg["agent"]["type"][i]}_agt_is_active[{cfg["agent"]["inst_number"][i]}];\n')


    comp_name = f'{cfg["module_name"]}_{cfg["agent"]["type"][an_index]}' if an_index is not None else cfg["module_name"]
    with open(f'./tmp/my_{comp}.sv', 'r') as tf, open(f'./tb/my_{comp_name}_{comp}.sv', 'w') as f:
        for line in tf:
            line = re.sub(r'Gong Yingfan', f'{cfg["author"]}', line)
            line = re.sub(r'2020-04-11', f'{cfg["time"]}', line)
            line = re.sub(r'my', f'my_{comp_name}', line)
            line = re.sub(r'my.*face', f'my_{cfg["module_name"]}_interface', line)
            line = re.sub(r'my.*tb_config', f'my_{cfg["module_name"]}_tb_config', line)
            f.write(line)
            port_gen()
            if 'virtual' in comp:
                add_sqr_to_vsqr()
            if 'env' in comp:
                connect_sqr()
                create_agt()
                add_tbcfg()
            if comp in ['reference_model', 'scoreboard', 'subscriber']:
                add_write_func()
            if comp == 'tb_config':
                add_config_to_tb_config()
        

def dut_gen(cfg):
    shutil.move(f'./tb/my_{cfg["module_name"]}_top.sv', './tb/top.sv')
    shutil.move(f'./tb/my_{cfg["module_name"]}_interface.sv', './tb/interface.sv')
    with open(cfg['rtl_top_path'], 'r') as f:
        dut = f.read()
        para_range = para_range_p.search(dut).group(2) if para_range_p.search(dut) is not None else None
        module_name, port_range = port_range_p.search(dut).groups()
        parameters = {k.strip(): v.strip() for k, v in para_p.findall(para_range)} if para_range is not None else None
        ports = {k: v for v, k in dut_port_p.findall(port_range)}
    macros = {}
    if parameters is not None:
        for macro, value in parameters.items():
            for k, v in ports.items():
                ports[k] = re.sub(f'({macro})', '`\g<1>', v)
            for k, v in parameters.items():
                parameters[k] = re.sub(f'({macro})', '`\g<1>', v)
            macros['`' + macro] = value
        with open('./common/define.sv', 'a') as f:
            for k, v in parameters.items():
                f.write(f'`ifndef {k}\n')
                f.write(f'`define {k} {v}\n')
                f.write(f'`endif\n\n')
    with open(f'./tb/my_{cfg["module_name"]}_interface.sv', 'w') as intf, open('./tb/interface.sv', 'r') as old_intf:
        for line in old_intf:
            intf.write(line)
            if re.search(r'DUT ports', line):
                for port, width in ports.items():
                    intf.write(f'    logic {width}{port};\n')
    with open(f'./tb/my_{cfg["module_name"]}_top.sv', 'w') as top, open('./tb/top.sv', 'r') as old_top:
        for line in old_top:
            top.write(line)
            if re.search(r'DUT', line):
                if parameters is not None:
                    top.write(f'    {module_name} #(\n')
                    i = 0
                    for p in macros.keys():
                        i += 1
                        if i == len(macros.keys()):
                            top.write(f'        .{p.replace("`", "")}({p})\n')
                        else:
                            top.write(f'        .{p.replace("`", "")}({p}),\n')
                    top.write(f'    ) {module_name}_dut (\n')
                else:
                    top.write(f'    {module_name} {module_name}_dut(\n')
                i = 0
                for p in ports.keys():
                    i += 1
                    if i == len(ports.keys()):
                        top.write(f'        .{p}(m_if.{p})\n')
                    else:
                        top.write(f'        .{p}(m_if.{p}),\n')
                top.write(f'    );\n')
    os.remove('./tb/top.sv')
    os.remove('./tb/interface.sv')

                
def case1_gen(cfg):
    with open('./tmp/my_case1/my_case1.sv', 'r') as tf, open('./tc/my_case1/my_case1.sv', 'w') as f:
        for line in tf:
            line = re.sub(r'Gong Yingfan', f'{cfg["author"]}', line)
            line = re.sub(r'2020-04-11', f'{cfg["time"]}', line)
            line = re.sub(r'my', f'my_{cfg["module_name"]}', line)
            line = re.sub(f'my_{cfg["module_name"]}_case1', 'my_case1', line)
            f.write(line)
            if re.search(r'set tbcfg', line):
                for i in range(cfg['agent_type_number']):
                    if cfg['agent']['to_ref_mdl'][i]:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    tbcfg.{cfg["agent"]["type"][i]}_agt_is_active = UVM_ACTIVE;\n')
                        else:
                            s = f'''    for (int i = 0; i < {cfg["agent"]["inst_number"][i]}; i++) begin
        tbcfg.{cfg["agent"]["type"][i]}_agt_is_active[i] = UVM_ACTIVE;    
    end\n'''
                            f.write(s)
                    else:
                        if cfg['agent']['inst_number'][i] == 1:
                            f.write(f'    tbcfg.{cfg["agent"]["type"][i]}_agt_is_active = UVM_PASSIVE;\n')
                        else:
                            s = f'''    for (int i = 0; i < {cfg["agent"]["inst_number"][i]}; i++) begin
        tbcfg.{cfg["agent"]["type"][i]}_agt_is_active[i] = UVM_PASSIVE;    
    end\n'''
                            f.write(s)
    with open('./tmp/my_case1/my_case1.cfg', 'r') as tf, open('./tc/my_case1/my_case1.cfg', 'w') as f:
        for line in tf:
            line = re.sub(r'Gong Yingfan', f'{cfg["author"]}', line)
            line = re.sub(r'2020-04-11', f'{cfg["time"]}', line)
            f.write(line)


def main():
    cfg = parse_cfg('./common/tbcfg.json')

    for comp in ['agent', 'monitor', 'driver', 'sequencer']:
        for i in range(cfg['agent_type_number']):
            comp_gen(comp, cfg, i)
        os.remove(f'./tmp/my_{comp}.sv')
    comps = (re.sub(r'.*my_(.*).sv', '\g<1>', f) for f in glob('./tmp/*.sv'))
    for comp in comps:
        comp_gen(comp, cfg)
    for i in range(cfg['agent_type_number']):
        comp_gen('transaction', cfg, i)

    case1_gen(cfg)
    filelist_gen(cfg)
    shutil.rmtree('./tmp')
    if cfg['rtl_top_path'] != '':
        dut_gen(cfg)


def clean():
    cwd = os.getcwd()
    s = input(f'This will remove all files in "{cwd}"\nDo you want to continue? [y/n]:')
    if s == 'y':
        os.system('rm -rf ./* &')


if __name__ == '__main__':
    statement_p   = re.compile(r'Group: Variables')
    create_comp_p = re.compile(r'create component')
    create_port_p = re.compile(r'create ports')
    port_p        = re.compile(r'Group: Ports')
    connect_p     = re.compile(r'connect ports')
    connectsqr_p  = re.compile(r'connect sequencer')
    decl_p        = re.compile(r'uvm_component_utils')
    write_p       = re.compile(r'write functions')
    func_p        = re.compile(r'Group: Functions')
    port_range_p  = re.compile(r'module\s+(\w+).*?\((.*?)\);', flags=re.DOTALL)
    dut_port_p    = re.compile(r'\s*(?:input|output)\s+(\[[\w:\-\[\]]+\])?\s*(\w+)\s*(?:,|\);|\n)')
    para_range_p  = re.compile(r'module\s+(\w+)[\s\n]*#(.*?)\)', flags=re.DOTALL)
    para_p        = re.compile(r'(\w+)\s*=(.*?)(?:,|\n)')
    setcfg_p      = re.compile(r'set config')
    
    if len(sys.argv) == 2:
        if sys.argv[1] == 'clean':
            clean()
        else:
            raise RuntimeError('wrong argument!')
    elif len(sys.argv) > 2:
        raise RuntimeError('wrong argument!')
    else:
        main()
