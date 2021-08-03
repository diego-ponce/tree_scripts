# utility functions for working with trees
library(networkD3)
library(data.tree)
library(tidyverse)


stacked_df <- function(df, value, colms){
  select(df, value, colms) %>% 
    rename(source=2, target=3)
    }
            

source_target_df <- function(df, value, colms){
  vdf <- df %>% select(value)  
  cdf <- df %>% select(colms)
  for (i in seq_along(cdf)){cdf[[i]] <- paste0(cdf[[i]],"_",i)}
  df <- bind_cols(cdf, vdf)
  cols_w <- cdf %>% names()
  lop <- list(target = cols_w %>% head(-1), source = cols_w[-1])
  pol <- transpose(lop)
  pol %>% map_df(~stacked_df(df, value, as.character(.)))
  }


nest_exceptions <- function(df, value){
  compares <- df %>% select(-value) %>% names() 
  df %>% group_by_at(compares) %>% 
    tally() %>% 
    ungroup() %>% 
    group_by_at(compares[2]) %>% 
    tally() %>% filter(n>1)
    }


make_sankey <- function(df, value, compares ){
  sank_arr <- df %>%  select(compares) %>% 
  unique() %>% 
  t() %>% as.vector() %>% unique()
  
  
  links <- df %>% 
  source_target_df(value, compares) %>% 
  group_by(source, target) %>% 
  summarise(value = n()) %>% 
  ungroup() 
  
  nodes <- data.frame(
  name_id=c(as.character(links$source), 
       as.character(links$target)) %>% unique()
  )
  
  
  nodes$name <- sub('_[0-9]+$', '', nodes$name_id)
  
  nodes <- nodes[order(factor(nodes$name, levels=sank_arr)),]
  
  nodes$group <- as.factor(nodes$name %>% str_detect("^[[:upper:]_&]+$"))
  
  links$IDsource <- match(links$source, nodes$name_id)-1 
  links$IDtarget <- match(links$target, nodes$name_id)-1
  
  
  # Make the Network
  p <- sankeyNetwork(Links = links, Nodes = nodes,
                 Source = "IDsource", Target = "IDtarget",
                 Value = "value", NodeID = "name",
                 NodeGroup="group", fontSize = 10,
                 sinksRight=FALSE, iterations = 0)
  
  return(p)
  }


naive_level_order <- function(df){
  # vector of column names ordered by count of unique labels  
  df_nest_order <- df %>% 
    summarise_all(n_distinct) %>% 
    t() %>% 
    as.data.frame() %>% 
    rownames_to_column() %>% 
    arrange(V1) %>% 
    pull(rowname)
    
  return(df %>% select(all_of(df_nest_order))) 
}



df_to_tree <- function(tree_df, sep="#*#"){
  colNames <- colnames(tree_df)
  path_df <- tree_df %>% unite("pathString", sep=sep, na.rm=TRUE)
  atree <- FromDataFrameTable(path_df, pathDelimiter = sep)
  atree$Set(id=1:atree$totalCount)
  atree$Do(function(node) node$leavesVec <-  node$Get('name', filterFun= isLeaf) %>% unname(), filterFun = isNotLeaf)
  atree$Do(function(node) node$colName <- colNames[node$level])
  return(atree)
}


search_for_matching <- function(anode, bnode, search_depth=0, verbose=FALSE){
  if(verbose){
    if(search_depth==0){cat('\n\n............... Searching for Matches to Node', anode$name, '.........................\n')}
    cat(search_depth,rep("." , times = search_depth) ,anode$name, bnode$name,bnode$colName, "\n")
  }
  df <- c("columnA","nodeA","columnB", "nodeB") %>% purrr::map_dfc(setNames, object = list(character()))
  if(bnode$isLeaf) return(df)
  # if anode is a subset of bnode (all of anode is in bnode)
  if(all(anode$leavesVec %in% bnode$leavesVec)){
    if(verbose){
        cat(" checking children of", bnode$colName, bnode$name,  "\n\t", paste("[", bnode$children %>% names(), "]", collapse ="..."),"\n")
    }
    search_depth <- search_depth + 1
    df <- bnode$children %>% map_dfr(~ search_for_matching(anode, .x, search_depth=search_depth, verbose = verbose))
  
  }
  else if(verbose) cat(anode$name," has no subset relationship to ", bnode$name, ", moving on to next node\n")
  if(setequal(anode$leavesVec, bnode$leavesVec)){
    df <- df %>% add_row(columnA=anode$colName, nodeA=anode$name, 
               columnB=bnode$colName, nodeB=bnode$name)
  }
  return(df)
}


equivalent_leaves <- function(tree1, tree2, verbose=FALSE){
  Traverse(tree1, traversal = "level", filterFun = isNotLeaf) %>% map_dfr(~ search_for_matching(.x, tree2, verbose=verbose))
}