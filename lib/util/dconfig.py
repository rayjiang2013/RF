from robot.api import logger
import os, sys
import ast
import re

def convert_config_data(cdata, mdata):
    '''
    This python API convert base config data to configurable data
    '''
    fdata = []

    # Display parameters on Robot framework console
    logger.console(cdata)
    logger.console(mdata)

    # convert unicode to dictionary
    ddata = ast.literal_eval(mdata) 

    # convert unicode to list
    udata_list = cdata.split('\n')
    cdata_list = [str(x) for x in udata_list]

    # check each mdata pair, debugging purpose only
    for key in ddata:
        logger.console("\t%s=%s" % (key, ddata[key]))
        
    # replace variables in cdata with a real value
    lcount = ddata['loop_count']
    for x in range (0, lcount):
        for line in cdata_list:
            line = line.strip()
            if re.search(r'\$A', line):
                if x == 0:
                    A_tmp = re.search(r'([0-9]+)\?([0-9])', ddata['A'])
                    A_base_int = int(A_tmp.group(1))
                    A_incr_int = int(A_tmp.group(2))
                    A_value = re.sub(r"\?[0-9]", "", ddata['A'])
                    #logger.console("A_tmp=%s, A_base_int=%d, A_incr_int=%d, A_value=%s" % (A_tmp, A_base_int, A_incr_int, A_value))
                else:
                    A_value_str = str(A_base_int + (A_incr_int * x))
                    A_value = re.sub(r"[0-9]+\?[0-9]", A_value_str, ddata['A'])
                    #logger.console("A_value_str=%s, A_value=%s" % (A_value_str, A_value))
                rep_line = re.sub(r'\$A', A_value, line)
                fdata.append(rep_line)
            elif re.search(r'\$B', line):
                if x == 0:
                    B_tmp = re.search(r'([0-9]+)\?([0-9])', ddata['B'])
                    B_base_int = int(B_tmp.group(1))
                    B_incr_int = int(B_tmp.group(2))
                    B_value = re.sub(r"\?[0-9]", "", ddata['B'])
                    #logger.console("B_tmp=%s, B_base_int=%d, B_incr_int=%d, B_value=%s" % (B_tmp, B_base_int, B_incr_int, B_value))
                else:
                    B_value_str = str(B_base_int + (B_incr_int * x))
                    B_value = re.sub(r"[0-9]+\?[0-9]", B_value_str, ddata['B'])
                    #logger.console("B_value_str=%s, B_value=%s" % (B_value_str, B_value))
                rep_line = re.sub(r'\$B', B_value, line)
                fdata.append(rep_line)
            elif re.search(r'\$C', line):
                if x == 0:
                    C_tmp = re.search(r'([0-9]+)\?([0-9])', ddata['C'])
                    C_base_int = int(C_tmp.group(1))
                    C_incr_int = int(C_tmp.group(2))
                    C_value = re.sub(r"\?[0-9]", "", ddata['C'])
                    #logger.console("C_tmp=%s, C_base_int=%d, C_incr_int=%d, C_value=%s" % (C_tmp, C_base_int, C_incr_int, C_value))
                else:
                    C_value_str = str(C_base_int + (C_incr_int * x))
                    C_value = re.sub(r"[0-9]+\?[0-9]", C_value_str, ddata['C'])
                    #logger.console("C_value_str=%s, C_value=%s" % (C_value_str, C_value))
                rep_line = re.sub(r'\$C', C_value, line)
                fdata.append(rep_line)
            elif re.search(r'\$D', line):
                if x == 0:
                    D_tmp = re.search(r'([0-9]+)\?([0-9])', ddata['D'])
                    D_base_int = int(D_tmp.group(1))
                    D_incr_int = int(D_tmp.group(2))
                    D_value = re.sub(r"\?[0-9]", "", ddata['D'])
                    #logger.console("D_tmp=%s, D_base_int=%d, D_incr_int=%d, D_value=%s" % (D_tmp, D_base_int, D_incr_int, D_value))
                else:
                    D_value_str = str(D_base_int + (D_incr_int * x))
                    D_value = re.sub(r"[0-9]+\?[0-9]", D_value_str, ddata['D'])
                    #logger.console("D_value_str=%s, D_value=%s" % (D_value_str, D_value))
                rep_line = re.sub(r'\$D', D_value, line)
                fdata.append(rep_line)
            elif re.search(r'\$E', line):
                if x == 0:
                    E_tmp = re.search(r'([0-9]+)\?([0-9])', ddata['E'])
                    E_base_int = int(E_tmp.group(1))
                    E_incr_int = int(E_tmp.group(2))
                    E_value = re.sub(r"\?[0-9]", "", ddata['E'])
                    #logger.console("E_tmp=%s, E_base_int=%d, E_incr_int=%d, E_value=%s" % (E_tmp, E_base_int, E_incr_int, E_value))
                else:
                    E_value_str = str(E_base_int + (E_incr_int * x))
                    E_value = re.sub(r"[0-9]+\?[0-9]", E_value_str, ddata['E'])
                    #logger.console("E_value_str=%s, E_value=%s" % (E_value_str, E_value))
                rep_line = re.sub(r'\$E', E_value, line)
                fdata.append(rep_line)
            else:
                fdata.append(line)
                #logger.console("There is no variable in this line %s" % line)
    return fdata
