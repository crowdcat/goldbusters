library("XML")
library("stringr")
library("Hmisc")

source("parse_xml_helpers.R")

# the variable gets reused: set of all cml: elements that require contributor response
possible_elements = c("textarea", "text",
                      "checkbox", "checkboxes",
                      "radios", "radio",
                      "select", "option", "group", "html",
                      "taxonomy")

possible_elements_parent = c("textarea", "text", 
                             "checkbox", "checkboxes",
                             "radios",
                             "select",
                             "taxonomy")


change_cml_R <- function(old_cml) {
  if (is.null(old_cml) || is.na(old_cml) || old_cml=="") {
    return("")
  } else {
    ## parse with html parser
    url = "~/Documents/new_goldbuster_app/some_file.json"
    parsed_json = fromJSON(file = url) # in the future this will be a text file
    cml = parsed_json$cml
    doc = xmlTreeParse(cml, useInternalNodes = T,
                       fullNamespaceInfo=F, isHTML=T)
    # doc_string = as(doc, "character")# this will be used later during replacements
    #doc_string = escapeRegex(doc_string)
    # "possible_elements" is defined on line 5
    element_vector = list()
    type_vector = list()
    ind =1 
    #find all elements
    for (el_name in possible_elements_parent) {
      print(paste("The el_name is", el_name))
      radios_all = NULL # clear radios all
      if (el_name == "checkbox") {
        #  For single checkboxes: xmlName(xmlParent(radio))
        radios_all = getNodeSet(doc, paste("//", el_name, sep=""), addFinalizer=T)
        if (length(radios_all) > 0) {
          for (ch_index in length(radios_all):1) {
            parent = xmlName(xmlParent(radios_all[[ch_index]]))
            if (parent == "checkboxes") {
              radios_all[[ch_index]] = NULL
            }
          }
        }
        # radios_all = radios_all[!parent_is_checkboxes] # right now this kills the class
      } else {
        radios_all = getNodeSet(doc, paste("//", el_name, sep=""), addFinalizer=T)
      }
      if (length(radios_all)>0) {
        element_vector[[ind]] = radios_all
        type_vector[[ind]] = el_name
        ind = ind+1
      }
    }
    
    multiples_vector = list()
    reasons_vector = list()
    ind =1 
    #transform all elements
    if (length(element_vector) >0) {
      # first, update the elements and make reasons
      for (i in 1:length(element_vector)) {
        radios_all = element_vector[[i]]
        el_name = type_vector[[i]]
        print(paste("Found some", el_name))
        radios_attributes = xmlApply(radios_all,xmlAttrs)
        ## transform radios to make them into checkboxes
        print("transforming: multiply")
        sapply(1:length(radios_all), function(i) {
          multiples(element_node= radios_all[[i]], element_attributes= radios_attributes[[i]], type=el_name)
        })
        radios_reasons = sapply(radios_attributes, function(x) make_reason_for_element(x, el_name))
        #substitute old elements with new elements and reasons in doc_string
        reasons_vector[[ind]] = radios_reasons
        ind = ind + 1
      }
      # second, update the nodes in the doc 
      for (j in 1:length(element_vector)) {
        radios_all = element_vector[[j]]
        radios_reasons = reasons_vector[[j]]
        for (p in 1:length(radios_all)) {
          reason_node = newXMLTextNode(radios_reasons[[p]])
          break_node = newXMLNode("br")
          # add reason node behind the current node
          addSibling(radios_all[[p]], kids = list(break_node,reason_node,break_node), after=TRUE)
        }
        
      }
    } else {
      print("No elements found")
    }
    # update logic done in groups
    group_elements = getNodeSet(doc, paste("//", "group", sep=""), addFinalizer=T)
    if (length(group_elements)>0) {
      update_logic_in_groups(group_elements)
    }
    doc_string = as(doc, "character") 
    # XML text butchers the <>, replace them back
    doc_string = str_split(doc_string, pattern="\n", n=2)[[1]][2] # drop the "<?xml version=\"1.0\"?>" line
    # drop the <html><body> and </body></html> tags
    doc_string = gsub(doc_string, pattern="^<html><body>", replacement="")
    doc_string = gsub(doc_string, pattern="</body></html>$", replacement="")
    # replace the faulty multiplez
    doc_string = gsub(doc_string, pattern="multiplez=", replacement="multiple=")
    # correct lts and gts
    doc_string = correct_let_gts(doc_string)
    # replace %7B and %7D with { and }
    doc_string = prepend_with_newlines(doc_string)
    output_string = substitute_cml_tags(doc_string)
    # create a fake "spotcheck" flag
    make_spotcheck = "false" # <<<<<< fake spotcheck flag
    if (make_spotcheck == "false") {
      # add skip wrapper
      prepend = paste0("<cml:checkbox label=\"This is not a good Gold unit, I'd like to skip it.\" name='skip'></cml:checkbox>",
                       "\n","<cml:textarea only-if=\"!skip:unchecked\" name=\"skip_reason\"",
                       " label=\"Why is this not a good test question?\"  validates=\"required\"></cml:textarea>",
                       "\n","<cml:group name='gold_group' label='' only-if='skip:unchecked'>","\n")
      append = paste0("\n","</cml:group>")
      output_string = paste(prepend, output_string, append, sep="\n")
    }
    return(output_string)
  }
  
}