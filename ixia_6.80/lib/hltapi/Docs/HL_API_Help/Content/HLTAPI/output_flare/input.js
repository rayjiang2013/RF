$(document).ready( function() {
    var tbl = [$('#arguments-tcl')[0], $('#arguments-perl')[0], $('#arguments-python')[0]],
        nrCols;

    var link, img, headers, tables, argTags,
        rowVisible = false;
        notArgTag = true;

    var aTags = $('a');

    // iterate tables and insert inputs and combo
    for (var i = 0; i < tbl.length; i++) {
        if (tbl[i] !== undefined) {
            nrCols = tbl[i].children[0].children.length;
            insertInput(tbl[i], tbl[i].id);
            insertCombo(tbl[i], tbl[i].id);
        }
    }

    function createInput(id) {
        var inputfld = document.createElement("input");

        inputfld.setAttribute('type', 'text');
        inputfld.setAttribute('id', 'search-' + id);
        inputfld.setAttribute('placeholder', 'Type to search');
        inputfld.onkeyup = function() {
            handleInput(id);
        };

        return inputfld;
    }

    function insertInput(table, initId) {
        var col,
            row = table.insertRow(0);

        for (var i = 0; i < nrCols-1; i++) {
            col = row.insertCell(i);
            input = createInput(initId + '-' +i);
            col.appendChild(input);
        }
    }

    function handleInput(id) {
        // jquery selector to get visible table rows per each active tab
        if (id.indexOf('tcl') != -1) {
            var $rows = $('#arguments-tcl tr:visible').slice(2);
        } else if (id.indexOf('perl') != -1) {
                var $rows = $('#arguments-perl tr:visible').slice(2);
            } else if (id.indexOf('python') != -1) {
                    var $rows = $('#arguments-python tr:visible').slice(2);
                }

        $('#search-' + id +'').keyup(function() {
            var val = $.trim($(this).val()).replace(/ +/g, ' ').toLowerCase();

            $rows.show().filter(function() {
                var nr = id.match(/\d+/g),
                    usedId = parseInt(nr[0]);

                text = $(this).children()[usedId].innerHTML.replace(/\s+/g, ' ').toLowerCase();
                return !~text.indexOf(val);
            }).hide();
        });
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //headersID = tclargh-_
    //tablesID = tclargt-_

    headers = $('h4').filter(function() {
            if (this.id.indexOf('tclargh') != -1 || this.id.indexOf('perlargh') != -1 || this.id.indexOf('pythonargh') != -1) {
                return this;
            }
        });

    tables = $('table').filter(function() {
            if (this.id.indexOf('tclargt') != -1 || this.id.indexOf('perlargt') != -1 || this.id.indexOf('pythonargt') != -1) {
                return this;
            }
        });

    for (var i=0, len=headers.length; i<len; i++) {
        var init_anchor,
            id = headers[i].id,
            tblId = tables[i].id;

        if (id.indexOf('tcl') != -1) {
            init_anchor = headers[i].innerHTML.slice(1);
        } else if (id.indexOf('perl') != -1) {
                init_anchor = headers[i].innerHTML;
            } else if (id.indexOf('python') != -1) {
                    init_anchor = headers[i].innerHTML;
                }

        anchor =  setAnchor(init_anchor, id);
        img = createImg();
        link = createLink(anchor, tblId, img);

        link.appendChild(img);
        $('#'+id)[0].appendChild(link);

        tables[i].style.display = "none";
    }

    function setAnchor(anchor, id) {
        if (id.indexOf('tcl') != -1) {
            return anchor + '_tcl_note';
        } else if (id.indexOf('perl') != -1) {
                return anchor + '_perl_note';
            } else if (id.indexOf('python') != -1) {
                return anchor + '_python_note';
                }
    }

    function createLink(anchor, id, img) {
        var link = document.createElement("a");
        link.href = '#' + anchor;

        //link.setAttribute('onclick', toggleDisplay( $('#' + id)[0] ) );
        link.onclick = function() {
            toggleDisplay( $('#'+id)[0], img );

            return false;
        };

        return link;
    }

    function createImg() {
        var im = document.createElement("img");
        im.src = "../../Resources/Images/plus.png";

        return im;
    }

    function toggleDisplay(tbl, img) {
        var tblRows = tbl.rows;
            haveExpanded = false;
            isSelf = false;
            getTables = $('table').filter(function() {
                if (this.id.indexOf('tclargt') != -1 || this.id.indexOf('perlargt') != -1 || this.id.indexOf('pythonargt') != -1) {
                    return this;
                }
            });
            $.each(getTables, function(index, ctbl) {
                if (ctbl.style.display != "none" && tbl === ctbl) {
                        haveExpanded = false;
                        isSelf = true;
                        return false;
                }

                if (tbl.id.indexOf('tclargt') != -1 && ctbl.id.indexOf('tclargt') != -1 && ctbl.style.display != "none" && tbl !== ctbl) {
                    haveExpanded = true;
                } else if (tbl.id.indexOf('perlargt') != -1 && ctbl.id.indexOf('perlargt') != -1 && ctbl.style.display != "none" && tbl !== ctbl) {
                        haveExpanded = true;
                    } else if (tbl.id.indexOf('pythonargt') != -1 && ctbl.id.indexOf('pythonargt') != -1 && ctbl.style.display != "none" && tbl !== ctbl) {
                            haveExpanded = true;
                        }
            });

        if (notArgTag) {
            if (haveExpanded) {
                rowVisible = false;
            }
            if (isSelf) {
                rowVisible = true;
            }
        }

        tbl.style.display = (rowVisible) ? "none" : "";
        if (tbl.style.display!="") {
            img.src = "../../Resources/Images/plus.png";
        } else {
            img.src = "../../Resources/Images/minus.png";
        }
        rowVisible = !rowVisible;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // set anchor on <<Arguments>> header
    argTags = $('a').filter(function() {
        if (this.name.indexOf('ARGUMENTS_TCL') != -1 || this.name.indexOf('ARGUMENTS_PERL') != -1 || this.name.indexOf('ARGUMENTS_PYTHON') != -1) {
            return this;
        }
    });

    argTags.each(function() {
        var link = document.createElement("a");
            imgArg = createImg();
            argsRowVisible = false;

        link.href = '#' + this.name;
        link.appendChild(imgArg);

        link.onclick = function() {
            var isTCL, isPERL, isPYTHON, tablesArgTags;

            if (this.href.indexOf('TCL') != -1) {
                isTCL = true;
                isPERL = false;
                isPYTHON = false;
                tablesArgTags = $('table').filter(function() {
                    if (this.id.indexOf('tclargt') != -1) {
                        return this;
                    }
                });
                headersArgTags = $('h4').filter(function() {
                        if (this.id.indexOf('tclargh') != -1) {
                            return this;
                        }
                    });
            } else if (this.href.indexOf('PERL') != -1) {
                    isTCL = false;
                    isPERL = true;
                    isPYTHON = false;
                    tablesArgTags = $('table').filter(function() {
                        if (this.id.indexOf('perlargt') != -1) {
                            return this;
                        }
                    });
                    headersArgTags = $('h4').filter(function() {
                            if (this.id.indexOf('perlargh') != -1) {
                                return this;
                            }
                        });
                } else if (this.href.indexOf('PYTHON') != -1) {
                        isTCL = false;
                        isPERL = false;
                        isPYTHON = true;
                        tablesArgTags = $('table').filter(function() {
                            if (this.id.indexOf('pythonargt') != -1) {
                                return this;
                            }
                        });
                        headersArgTags = $('h4').filter(function() {
                                if (this.id.indexOf('pythonargh') != -1) {
                                    return this;
                                }
                            });
                    }

            for(var i=0, len=tablesArgTags.length; i<len; i++) {
                var tblId = tablesArgTags[i].id,
                    id = headersArgTags[i].id;

                if ((id.indexOf('tcl') != -1 && isTCL) || (id.indexOf('perl') != -1 && isPERL) || (id.indexOf('python') != -1 && isPYTHON)) {
                    var tbl = $('#'+tblId)[0];

                    if (tbl.style.display === "none" && argsRowVisible === false) {
                        rowVisible = false;
                    } else {
                        if (tbl.style.display === "" && argsRowVisible === false) {
                            rowVisible = false;
                        } else {
                            if (tbl.style.display === "none" && argsRowVisible === true) {
                                rowVisible = true;
                            } else {
                                if (tbl.style.display === "" && argsRowVisible === true) {
                                    rowVisible = true;
                                }
                            }
                        }
                    }
                    notArgTag = false;
                    $('#'+id)[0].children[0].onclick();
                }
            }
            if (argsRowVisible === false) {
                this.children[0].src = "../../Resources/Images/minus.png";
            } else {
                this.children[0].src = "../../Resources/Images/plus.png";
            }
            argsRowVisible = !argsRowVisible;
            notArgTag = !notArgTag;

            return false;
        };

        if (this.children[0] !== undefined) {
            this.children[0].appendChild(link);
        }
    });

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // get all <a> tags

    for (var i=0, len=aTags.length; i<len; i++) {
        if (aTags[i].className.indexOf('Ixia') != -1 || aTags[i].className.indexOf('Cisco') != -1) {
            aTags[i].onclick = function() {
                var tableTag = this.href.match(/#(.*)/g);
                    header = $('a[href=' + tableTag + '_note]')[0];

                rowVisible = false;
                header.onclick();

                return true;
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // create combo
    function createCombo(id) {

        /* create select */
        var select = document.createElement("select");
        var option;

        select.setAttribute("name", "select-"+ id);
        select.setAttribute("id", "select-"+ id);
        select.style.width = "150px";

        /* we are going to add three options */
        /* create options elements */
        option = document.createElement("option");
        option.setAttribute("value", "");
        option.innerHTML = "All";
        select.appendChild(option);

        option = document.createElement("option");
        option.setAttribute("value", "Cisco_D");
        option.innerHTML = "Cisco Defined";
        select.appendChild(option);

        option = document.createElement("option");
        option.setAttribute("value", "Ixia_D");
        option.innerHTML = "Ixia Defined";
        select.appendChild(option);

        option = document.createElement("option");
        option.setAttribute("value", "Ixia_NS");
        option.innerHTML = "Ixia NotSupported";
        select.appendChild(option);

        /* setting an onchange event */
        select.onchange = function() {
            handleSelect(this, id);
        };

        return select;
    }

    function insertCombo(table, initId) {
        var col,
            row = table.insertRow(1);

        col = row.insertCell(0);
        combo = createCombo(initId + '-0');
        col.appendChild(combo);
    }

    function handleSelect(sel, id) {
        var val = sel.value;

        // jquery selector to get visible table rows per each active tab
        if (id.indexOf('tcl') != -1) {
            var $rows = $('#arguments-tcl tr').slice(2);
        } else if (id.indexOf('perl') != -1) {
                var $rows = $('#arguments-perl tr').slice(2);
            } else if (id.indexOf('python') != -1) {
                    var $rows = $('#arguments-python tr').slice(2);
                }

        //clear inputs
        $('input').each( function() {
                this.value = "";
        })

        $rows.show().filter(function() {
            var className = this.children[0].children[0].children[0].children[0].className;
            if (className !== val && val !== "") {
                return this;
            } else {
                return false;
            }
        }).hide();
    }
    //create tooltip
    langs = ["tcl","perl","python"];
    tooltip_text = new Array(3);
    tooltip_text[0] = '<p>A namespace is a collection of commands and variables. It encapsulates the commands and variables to ensure they do not interfere with the commands and variables of other namespaces.</p><p>Tcl:</p><ul><li value="1"><span class="Code">::ixia</span> – This namespace is valid for HLT commands using IxOS, IxNetwork-FT, IxNetwork legacy, IxLoad functionality.</li><li value="2"><span class="Code">::ixiangpf</span>  – This namespace is valid for HLT commands using NGPF IxNetwork functionality.</li></ul><p>For details about the Protocols and their supported APIs please see the "About this Guide | About HLTAPI | Protocols and Required APIs" section.</p>';
    tooltip_text[1] = '<p>A namespace is a collection of commands and variables. It encapsulates the commands and variables to ensure they do not interfere with the commands and variables of other namespaces.</p><p>Perl:</p><ul><li value="1"><span class="Code">::ixiahlt</span> – This namespace is valid for HLP commands using IxNetwork legacy functionality.</li><li value="2"><span class="Code">::ixiahltgenerated</span> – This namespace is valid for HLP commands using IxNetwork legacy functionality for FCoE, DCBX/LLDP, PTP, ESMC.</li><li value="3"><span class="Code">::ixiatcl</span> – This namespace is used for calling Tcl native commands in a PERL script (set, list, array, etc).</li><li value="4"><span class="Code">::ixiangpf</span> –This namespace is valid for HLT commands using NGPF IxNetwork functionality.</li></ul><p>For details about the Protocols and their supported APIs please see the "About this Guide | About HLPAPI | Protocols and Required APIs" section.</p>';
    tooltip_text[2] = '<p>A namespace is a collection of commands and variables. It encapsulates the commands and variables to ensure they do not interfere with the commands and variables of other namespaces.</p><p>Python:</p><ul><li value="1"><span class="Code">::ixiangpf</span> – This namespace is valid for HLPy commands using NGPF IxNetwork functionality.</li></ul><p>For details about the Protocols and their supported APIs please see the "About this Guide | About HLPython API | Protocols and Required APIs" section.</p>';
    var i=0;
    for (;langs[i];) {
        for (j=1; j<=4; j++){
            crtElem = "#" + langs[i] + "-arg" + j
            $(crtElem).tooltip({
                content: tooltip_text[i]
            });
        }
        i++;
    }
});
