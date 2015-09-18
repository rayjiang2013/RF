// Original JavaScript code by Chirp Internet: www.chirp.com.au
// Please acknowledge use of this code by including this header.

// Code modified by Agilent Technologies to provide conceptual
// sorting by stripping verb prefixes from method names.

function sort(parent, childName, colName)
{
  var parent = parent;			// 'parent' node
  var childName = childName;	// nodeName for 'children'
  var colName = colName;		// nodeName for 'columns'
  var sorting = sorting;		// (a)lpha or (l)ogical

  // build array of 'child' nodes
  var items = parent.getElementsByTagName(childName);
  var N = items.length;

  // define private methods
  var get = function(i, col, tag)
  {
    var retval = null;
    var node = null;
    var sort;

    if(colName) {
      // sort by col'th element of i'th child
      node = items[i].getElementsByTagName(colName)[col];
    } else {
      // sort by i'th child
      node = items[i];
    }

    if(null != (sort = node.getAttribute("sort"))) {
      // use 'sort' attribute if available
      retval = sort;
    } else if(node.childNodes.length > 0) {
      if(tag) {
        // sort by contents of first 'tag' element in 'child'
        retval = node.getElementsByTagName(tag)[0].firstChild.nodeValue;
      } else {
        // sort by 'child' contents
        retval = node.firstChild.nodeValue;
      }
    } else {
      return "";
    }

    if(parseFloat(retval) == retval) return parseFloat(retval);
    return retval;
  }

  // strip the verb phrase from the front of the API method name
  var stripPrefix = function(str)
  {
      return str.replace(/^(Add|Advertise|Cancel|Clear|Close|Delete|Deselect|Disable|Enable|Force|Get|Is|Join|Leave|List|Open|Ready|Remove|Reset|Resume|Retry|Select|Send|Set|Shutdown|Signal|Standby|Start|Stop|Suspend|Unready|Unselect|Unset|Withdraw)/, "");
  }

  var compare = function(val1, val2, desc, sorting)
  {
      // sort alphabetically
      if (sorting == 'a')
      {
        return (desc) ? val1 > val2 : val1 < val2;
      }
      // sort conceptually, after stripping verb prefix
      else if (sorting == 'c')
      {
        var strip1 = stripPrefix(val1);
        var strip2 = stripPrefix(val2);
        if (desc)
        {
            if (strip1 > strip2)
            {
                return true;
            }
            else if (strip1 < strip2)
            {
                return false;
            }
            return val1 > val2;
        }
        else
        {
            if (strip1 < strip2)
            {
                return true;
            }
            else if (strip1 > strip2)
            {
               return false;
            }
            return val1 < val2;
        }
      }
  }

  var exchange = function(i, j)
  {
    parent.insertBefore(items[i], items[j]);
  }

  // define public method
  this.sort = function(col, desc, tag, sorting)
  {
    for(var j=N-1; j > 2; j--) {
      for(var i=2; i < j; i++) {
        if(compare(get(i+1, col, tag), get(i, col, tag), desc, sorting)) {
          exchange(i+1, i);
        }
      }
    }
  }
}

var sortBy = -1;
var desc = false;

function sortList(table, col, tag, sorting)
{
  var tableData = document.getElementById(table);
  if(tableData.nodeName != "tbody") {
    tableData = tableData.getElementsByTagName("tbody")[0];
  }
  var tableData = new sort(tableData, "tr", "td");

  desc = (col == sortBy) ? !desc : false;
  tableData.sort(col, desc, tag, sorting);
  sortBy = col;
}
