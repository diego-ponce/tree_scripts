Scripts for working with trees
================

# A few tools for Working with trees

dependencies on

-   `data.tree` by Christoph Glur for converting data between tree
    representations and dataframes
-   `networkD3` by Christopher Gandrud, JJ Allaire, Kent Russell, & CJ
    Yetman for representing series of tree levels as Sankey diagrams
-   `tidyverse` by Hadley Wickham et al. for dataframe manipulations

## Example Data: SomeCo org charts

## `naive_level_order` - Organize a DF to make it most likely a Tree can be resolved

``` r
#TODO add naive_level_node example
```

## `equivalent_leaves` - search a tree for nodes with the same leaves as a node in another tree

``` r
df <- read_csv("SomeCoOrg.csv")
```

    ## 
    ## -- Column specification --------------------------------------------------------
    ## cols(
    ##   `Company ID` = col_character(),
    ##   `Org ID` = col_character(),
    ##   `Div ID` = col_character(),
    ##   `Company Name` = col_character(),
    ##   `Org Name` = col_character(),
    ##   `Div Name` = col_character(),
    ##   `Unit Name` = col_character(),
    ##   `Unit ID` = col_character()
    ## )

``` r
id_tree <-  df %>% naive_level_order() %>% select(ends_with("ID")) %>% df_to_tree()
name_tree <- df %>% naive_level_order() %>% select(ends_with("Name"), "Unit ID") %>% df_to_tree()
print(name_tree)
```

    ##                               levelName
    ## 1  SomeCo                              
    ## 2   ¦--Finance                         
    ## 3   ¦   ¦--Accounting                  
    ## 4   ¦   ¦   ¦--Corporate Accounting    
    ## 5   ¦   ¦   ¦   °--001                 
    ## 6   ¦   ¦   °--Reporting               
    ## 7   ¦   ¦       °--002                 
    ## 8   ¦   °--Forecasting                 
    ## 9   ¦       °--FP&A                    
    ## 10  ¦           °--003                 
    ## 11  ¦--Operations                      
    ## 12  ¦   ¦--Customer                    
    ## 13  ¦   ¦   ¦--Customer Service        
    ## 14  ¦   ¦   ¦   °--004                 
    ## 15  ¦   ¦   ¦--Customer Billing        
    ## 16  ¦   ¦   ¦   °--005                 
    ## 17  ¦   ¦   ¦--Marketing               
    ## 18  ¦   ¦   ¦   °--006                 
    ## 19  ¦   ¦   °--Research                
    ## 20  ¦   ¦       °--007                 
    ## 21  ¦   ¦--Maintenance                 
    ## 22  ¦   ¦   ¦--Facilities              
    ## 23  ¦   ¦   ¦   °--008                 
    ## 24  ¦   ¦   °--Landscaping             
    ## 25  ¦   ¦       °--009                 
    ## 26  ¦   °--Security                    
    ## 27  ¦       °--Building                
    ## 28  ¦           °--010                 
    ## 29  ¦--Human Resources                 
    ## 30  ¦   ¦--Benefits                    
    ## 31  ¦   ¦   ¦--Compensation            
    ## 32  ¦   ¦   ¦   °--011                 
    ## 33  ¦   ¦   °--Insurance               
    ## 34  ¦   ¦       °--012                 
    ## 35  ¦   °--Talent                      
    ## 36  ¦       ¦--Recruiting              
    ## 37  ¦       ¦   °--013                 
    ## 38  ¦       °--Education               
    ## 39  ¦           °--014                 
    ## 40  °--IT                              
    ## 41      ¦--Information Security        
    ## 42      ¦   ¦--Vulnerability Management
    ## 43      ¦   ¦   °--015                 
    ## 44      ¦   °--Incident Response       
    ## 45      ¦       °--016                 
    ## 46      °--Network                     
    ## 47          ¦--On-Prem                 
    ## 48          ¦   °--017                 
    ## 49          °--Cloud                   
    ## 50              °--018

``` r
print(id_tree)
```

    ##          levelName
    ## 1  a9621          
    ## 2   ¦--c4829      
    ## 3   ¦   ¦--9bbd4  
    ## 4   ¦   ¦   ¦--001
    ## 5   ¦   ¦   °--002
    ## 6   ¦   °--0de29  
    ## 7   ¦       °--003
    ## 8   ¦--456d0      
    ## 9   ¦   ¦--ce266  
    ## 10  ¦   ¦   ¦--004
    ## 11  ¦   ¦   ¦--005
    ## 12  ¦   ¦   ¦--006
    ## 13  ¦   ¦   °--007
    ## 14  ¦   ¦--10d0d  
    ## 15  ¦   ¦   ¦--008
    ## 16  ¦   ¦   °--009
    ## 17  ¦   °--2fae3  
    ## 18  ¦       °--010
    ## 19  ¦--d1909      
    ## 20  ¦   ¦--e654f  
    ## 21  ¦   ¦   ¦--011
    ## 22  ¦   ¦   °--012
    ## 23  ¦   °--6d43c  
    ## 24  ¦       ¦--013
    ## 25  ¦       °--014
    ## 26  °--cd321      
    ## 27      ¦--0889f  
    ## 28      ¦   ¦--015
    ## 29      ¦   °--016
    ## 30      °--eec89  
    ## 31          ¦--017
    ## 32          °--018

``` r
equivalent_leaves(id_tree, name_tree)
```

    ## # A tibble: 16 x 4
    ##    columnA    nodeA columnB      nodeB               
    ##    <chr>      <chr> <chr>        <chr>               
    ##  1 Company ID a9621 Company Name SomeCo              
    ##  2 Org ID     c4829 Org Name     Finance             
    ##  3 Org ID     456d0 Org Name     Operations          
    ##  4 Org ID     d1909 Org Name     Human Resources     
    ##  5 Org ID     cd321 Org Name     IT                  
    ##  6 Div ID     9bbd4 Div Name     Accounting          
    ##  7 Div ID     0de29 Unit Name    FP&A                
    ##  8 Div ID     0de29 Div Name     Forecasting         
    ##  9 Div ID     ce266 Div Name     Customer            
    ## 10 Div ID     10d0d Div Name     Maintenance         
    ## 11 Div ID     2fae3 Unit Name    Building            
    ## 12 Div ID     2fae3 Div Name     Security            
    ## 13 Div ID     e654f Div Name     Benefits            
    ## 14 Div ID     6d43c Div Name     Talent              
    ## 15 Div ID     0889f Div Name     Information Security
    ## 16 Div ID     eec89 Div Name     Network

``` r
equivalent_leaves(name_tree, id_tree)
```

    ## # A tibble: 16 x 4
    ##    columnA      nodeA                columnB    nodeB
    ##    <chr>        <chr>                <chr>      <chr>
    ##  1 Company Name SomeCo               Company ID a9621
    ##  2 Org Name     Finance              Org ID     c4829
    ##  3 Org Name     Operations           Org ID     456d0
    ##  4 Org Name     Human Resources      Org ID     d1909
    ##  5 Org Name     IT                   Org ID     cd321
    ##  6 Div Name     Accounting           Div ID     9bbd4
    ##  7 Div Name     Forecasting          Div ID     0de29
    ##  8 Div Name     Customer             Div ID     ce266
    ##  9 Div Name     Maintenance          Div ID     10d0d
    ## 10 Div Name     Security             Div ID     2fae3
    ## 11 Div Name     Benefits             Div ID     e654f
    ## 12 Div Name     Talent               Div ID     6d43c
    ## 13 Div Name     Information Security Div ID     0889f
    ## 14 Div Name     Network              Div ID     eec89
    ## 15 Unit Name    FP&A                 Div ID     0de29
    ## 16 Unit Name    Building             Div ID     2fae3
