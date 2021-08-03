A few helper functions for working with trees
================

dependencies on

  - `data.tree` by Christoph Glur for converting data between tree
    representations and dataframes
  - `networkD3` by Christopher Gandrud, JJ Allaire, Kent Russell, & CJ
    Yetman for representing series of tree levels as Sankey diagrams
  - `tidyverse` by Hadley Wickham et al. for dataframe manipulations

## Example Data: SomeCo org charts

A simple org chart with department names and id in the same table (ID is
just a truncated MD5 hash of the department name)

``` r
df <- read_csv("SomeCoOrg.csv")
```

    ## Parsed with column specification:
    ## cols(
    ##   `Company ID` = col_character(),
    ##   `Company Name` = col_character(),
    ##   `Org ID` = col_character(),
    ##   `Org Name` = col_character(),
    ##   `Div ID` = col_character(),
    ##   `Div Name` = col_character(),
    ##   `Unit Name` = col_character(),
    ##   `Unit ID` = col_character()
    ## )

``` r
df %>% kable()
```

| Company ID | Company Name | Org ID | Org Name   | Div ID | Div Name    | Unit Name            | Unit ID |
| :--------- | :----------- | :----- | :--------- | :----- | :---------- | :------------------- | :------ |
| a9621      | SomeCo       | c4829  | Finance    | 9bbd4  | Accounting  | Corporate Accounting | 001     |
| a9621      | SomeCo       | c4829  | Finance    | 9bbd4  | Accounting  | Reporting            | 002     |
| a9621      | SomeCo       | c4829  | Finance    | 0de29  | Forecasting | FP\&A                | 003     |
| a9621      | SomeCo       | 456d0  | Operations | ce266  | Customer    | Customer Service     | 004     |
| a9621      | SomeCo       | 456d0  | Operations | ce266  | Customer    | Customer Billing     | 005     |
| a9621      | SomeCo       | 456d0  | Operations | ce266  | Customer    | Marketing            | 006     |
| a9621      | SomeCo       | 456d0  | Operations | ce266  | Customer    | Research             | 007     |
| a9621      | SomeCo       | 456d0  | Operations | 10d0d  | Maintenance | Facilities           | 008     |
| a9621      | SomeCo       | 456d0  | Operations | 10d0d  | Maintenance | Landscaping          | 009     |
| a9621      | SomeCo       | 456d0  | Operations | 2fae3  | Security    | Building             | 010     |

## `naive_level_order` - Organize a DF to make it most likely a Tree can be resolved

What if we get a levelized tree, but the columns are not arranged
left-to-right higher-to-lower level (the order used by
`data.tree::FromDataFrameTable`)? `naive_level_order` takes the df and
orders columns by least to most distinct values (which approximates the
LtoR HtoL order described above).

``` r
set.seed(1234)
randomized_df <- df %>% select(sample(names(df %>% select(ends_with("Name"), "Unit ID"))))
randomized_df %>% kable()
```

| Unit Name            | Unit ID | Org Name   | Div Name    | Company Name |
| :------------------- | :------ | :--------- | :---------- | :----------- |
| Corporate Accounting | 001     | Finance    | Accounting  | SomeCo       |
| Reporting            | 002     | Finance    | Accounting  | SomeCo       |
| FP\&A                | 003     | Finance    | Forecasting | SomeCo       |
| Customer Service     | 004     | Operations | Customer    | SomeCo       |
| Customer Billing     | 005     | Operations | Customer    | SomeCo       |
| Marketing            | 006     | Operations | Customer    | SomeCo       |
| Research             | 007     | Operations | Customer    | SomeCo       |
| Facilities           | 008     | Operations | Maintenance | SomeCo       |
| Landscaping          | 009     | Operations | Maintenance | SomeCo       |
| Building             | 010     | Operations | Security    | SomeCo       |

``` r
randomized_df %>% naive_level_order() %>% kable()
```

| Company Name | Org Name   | Div Name    | Unit Name            | Unit ID |
| :----------- | :--------- | :---------- | :------------------- | :------ |
| SomeCo       | Finance    | Accounting  | Corporate Accounting | 001     |
| SomeCo       | Finance    | Accounting  | Reporting            | 002     |
| SomeCo       | Finance    | Forecasting | FP\&A                | 003     |
| SomeCo       | Operations | Customer    | Customer Service     | 004     |
| SomeCo       | Operations | Customer    | Customer Billing     | 005     |
| SomeCo       | Operations | Customer    | Marketing            | 006     |
| SomeCo       | Operations | Customer    | Research             | 007     |
| SomeCo       | Operations | Maintenance | Facilities           | 008     |
| SomeCo       | Operations | Maintenance | Landscaping          | 009     |
| SomeCo       | Operations | Security    | Building             | 010     |

## `equivalent_leaves` - search a tree for nodes with the same leaves as a node in another tree

``` r
id_tree <-  df %>% naive_level_order() %>% select(ends_with("ID")) %>% df_to_tree()
name_tree <- df %>% naive_level_order() %>% select(ends_with("Name"), "Unit ID") %>% df_to_tree()
print(name_tree)
```

    ##                           levelName
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
    ## 11  °--Operations                  
    ## 12      ¦--Customer                
    ## 13      ¦   ¦--Customer Service    
    ## 14      ¦   ¦   °--004             
    ## 15      ¦   ¦--Customer Billing    
    ## 16      ¦   ¦   °--005             
    ## 17      ¦   ¦--Marketing           
    ## 18      ¦   ¦   °--006             
    ## 19      ¦   °--Research            
    ## 20      ¦       °--007             
    ## 21      ¦--Maintenance             
    ## 22      ¦   ¦--Facilities          
    ## 23      ¦   ¦   °--008             
    ## 24      ¦   °--Landscaping         
    ## 25      ¦       °--009             
    ## 26      °--Security                
    ## 27          °--Building            
    ## 28              °--010

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
    ## 8   °--456d0      
    ## 9       ¦--ce266  
    ## 10      ¦   ¦--004
    ## 11      ¦   ¦--005
    ## 12      ¦   ¦--006
    ## 13      ¦   °--007
    ## 14      ¦--10d0d  
    ## 15      ¦   ¦--008
    ## 16      ¦   °--009
    ## 17      °--2fae3  
    ## 18          °--010

``` r
equivalent_leaves(id_tree, name_tree) %>% kable()
```

| columnA    | nodeA | columnB      | nodeB       |
| :--------- | :---- | :----------- | :---------- |
| Company ID | a9621 | Company Name | SomeCo      |
| Org ID     | c4829 | Org Name     | Finance     |
| Org ID     | 456d0 | Org Name     | Operations  |
| Div ID     | 9bbd4 | Div Name     | Accounting  |
| Div ID     | 0de29 | Unit Name    | FP\&A       |
| Div ID     | 0de29 | Div Name     | Forecasting |
| Div ID     | ce266 | Div Name     | Customer    |
| Div ID     | 10d0d | Div Name     | Maintenance |
| Div ID     | 2fae3 | Unit Name    | Building    |
| Div ID     | 2fae3 | Div Name     | Security    |

``` r
equivalent_leaves(name_tree, id_tree) %>% kable()
```

| columnA      | nodeA       | columnB    | nodeB |
| :----------- | :---------- | :--------- | :---- |
| Company Name | SomeCo      | Company ID | a9621 |
| Org Name     | Finance     | Org ID     | c4829 |
| Org Name     | Operations  | Org ID     | 456d0 |
| Div Name     | Accounting  | Div ID     | 9bbd4 |
| Div Name     | Forecasting | Div ID     | 0de29 |
| Div Name     | Customer    | Div ID     | ce266 |
| Div Name     | Maintenance | Div ID     | 10d0d |
| Div Name     | Security    | Div ID     | 2fae3 |
| Unit Name    | FP\&A       | Div ID     | 0de29 |
| Unit Name    | Building    | Div ID     | 2fae3 |

`equivalent_leaves` also has a `verbose` parameter to inspect the search

``` r
equivalent_leaves(name_tree, id_tree, verbose=TRUE) %>% kable()
```

    ## 
    ## 
    ## ............... Searching for Matches to Node SomeCo .........................
    ## 0  SomeCo a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . SomeCo c4829 Org ID 
    ## SomeCo  has no subset relationship to  c4829 , moving on to next node
    ## 1 . SomeCo 456d0 Org ID 
    ## SomeCo  has no subset relationship to  456d0 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Finance .........................
    ## 0  Finance a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Finance c4829 Org ID 
    ##  checking children of Org ID c4829 
    ##   [ 9bbd4 ]...[ 0de29 ] 
    ## 2 . . Finance 9bbd4 Div ID 
    ## Finance  has no subset relationship to  9bbd4 , moving on to next node
    ## 2 . . Finance 0de29 Div ID 
    ## Finance  has no subset relationship to  0de29 , moving on to next node
    ## 1 . Finance 456d0 Org ID 
    ## Finance  has no subset relationship to  456d0 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Operations .........................
    ## 0  Operations a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Operations c4829 Org ID 
    ## Operations  has no subset relationship to  c4829 , moving on to next node
    ## 1 . Operations 456d0 Org ID 
    ##  checking children of Org ID 456d0 
    ##   [ ce266 ]...[ 10d0d ]...[ 2fae3 ] 
    ## 2 . . Operations ce266 Div ID 
    ## Operations  has no subset relationship to  ce266 , moving on to next node
    ## 2 . . Operations 10d0d Div ID 
    ## Operations  has no subset relationship to  10d0d , moving on to next node
    ## 2 . . Operations 2fae3 Div ID 
    ## Operations  has no subset relationship to  2fae3 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Accounting .........................
    ## 0  Accounting a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Accounting c4829 Org ID 
    ##  checking children of Org ID c4829 
    ##   [ 9bbd4 ]...[ 0de29 ] 
    ## 2 . . Accounting 9bbd4 Div ID 
    ##  checking children of Div ID 9bbd4 
    ##   [ 001 ]...[ 002 ] 
    ## 3 . . . Accounting 001 Unit ID 
    ## 3 . . . Accounting 002 Unit ID 
    ## 2 . . Accounting 0de29 Div ID 
    ## Accounting  has no subset relationship to  0de29 , moving on to next node
    ## 1 . Accounting 456d0 Org ID 
    ## Accounting  has no subset relationship to  456d0 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Forecasting .........................
    ## 0  Forecasting a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Forecasting c4829 Org ID 
    ##  checking children of Org ID c4829 
    ##   [ 9bbd4 ]...[ 0de29 ] 
    ## 2 . . Forecasting 9bbd4 Div ID 
    ## Forecasting  has no subset relationship to  9bbd4 , moving on to next node
    ## 2 . . Forecasting 0de29 Div ID 
    ##  checking children of Div ID 0de29 
    ##   [ 003 ] 
    ## 3 . . . Forecasting 003 Unit ID 
    ## 1 . Forecasting 456d0 Org ID 
    ## Forecasting  has no subset relationship to  456d0 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Customer .........................
    ## 0  Customer a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Customer c4829 Org ID 
    ## Customer  has no subset relationship to  c4829 , moving on to next node
    ## 1 . Customer 456d0 Org ID 
    ##  checking children of Org ID 456d0 
    ##   [ ce266 ]...[ 10d0d ]...[ 2fae3 ] 
    ## 2 . . Customer ce266 Div ID 
    ##  checking children of Div ID ce266 
    ##   [ 004 ]...[ 005 ]...[ 006 ]...[ 007 ] 
    ## 3 . . . Customer 004 Unit ID 
    ## 3 . . . Customer 005 Unit ID 
    ## 3 . . . Customer 006 Unit ID 
    ## 3 . . . Customer 007 Unit ID 
    ## 2 . . Customer 10d0d Div ID 
    ## Customer  has no subset relationship to  10d0d , moving on to next node
    ## 2 . . Customer 2fae3 Div ID 
    ## Customer  has no subset relationship to  2fae3 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Maintenance .........................
    ## 0  Maintenance a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Maintenance c4829 Org ID 
    ## Maintenance  has no subset relationship to  c4829 , moving on to next node
    ## 1 . Maintenance 456d0 Org ID 
    ##  checking children of Org ID 456d0 
    ##   [ ce266 ]...[ 10d0d ]...[ 2fae3 ] 
    ## 2 . . Maintenance ce266 Div ID 
    ## Maintenance  has no subset relationship to  ce266 , moving on to next node
    ## 2 . . Maintenance 10d0d Div ID 
    ##  checking children of Div ID 10d0d 
    ##   [ 008 ]...[ 009 ] 
    ## 3 . . . Maintenance 008 Unit ID 
    ## 3 . . . Maintenance 009 Unit ID 
    ## 2 . . Maintenance 2fae3 Div ID 
    ## Maintenance  has no subset relationship to  2fae3 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Security .........................
    ## 0  Security a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Security c4829 Org ID 
    ## Security  has no subset relationship to  c4829 , moving on to next node
    ## 1 . Security 456d0 Org ID 
    ##  checking children of Org ID 456d0 
    ##   [ ce266 ]...[ 10d0d ]...[ 2fae3 ] 
    ## 2 . . Security ce266 Div ID 
    ## Security  has no subset relationship to  ce266 , moving on to next node
    ## 2 . . Security 10d0d Div ID 
    ## Security  has no subset relationship to  10d0d , moving on to next node
    ## 2 . . Security 2fae3 Div ID 
    ##  checking children of Div ID 2fae3 
    ##   [ 010 ] 
    ## 3 . . . Security 010 Unit ID 
    ## 
    ## 
    ## ............... Searching for Matches to Node Corporate Accounting .........................
    ## 0  Corporate Accounting a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Corporate Accounting c4829 Org ID 
    ##  checking children of Org ID c4829 
    ##   [ 9bbd4 ]...[ 0de29 ] 
    ## 2 . . Corporate Accounting 9bbd4 Div ID 
    ##  checking children of Div ID 9bbd4 
    ##   [ 001 ]...[ 002 ] 
    ## 3 . . . Corporate Accounting 001 Unit ID 
    ## 3 . . . Corporate Accounting 002 Unit ID 
    ## 2 . . Corporate Accounting 0de29 Div ID 
    ## Corporate Accounting  has no subset relationship to  0de29 , moving on to next node
    ## 1 . Corporate Accounting 456d0 Org ID 
    ## Corporate Accounting  has no subset relationship to  456d0 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Reporting .........................
    ## 0  Reporting a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Reporting c4829 Org ID 
    ##  checking children of Org ID c4829 
    ##   [ 9bbd4 ]...[ 0de29 ] 
    ## 2 . . Reporting 9bbd4 Div ID 
    ##  checking children of Div ID 9bbd4 
    ##   [ 001 ]...[ 002 ] 
    ## 3 . . . Reporting 001 Unit ID 
    ## 3 . . . Reporting 002 Unit ID 
    ## 2 . . Reporting 0de29 Div ID 
    ## Reporting  has no subset relationship to  0de29 , moving on to next node
    ## 1 . Reporting 456d0 Org ID 
    ## Reporting  has no subset relationship to  456d0 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node FP&A .........................
    ## 0  FP&A a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . FP&A c4829 Org ID 
    ##  checking children of Org ID c4829 
    ##   [ 9bbd4 ]...[ 0de29 ] 
    ## 2 . . FP&A 9bbd4 Div ID 
    ## FP&A  has no subset relationship to  9bbd4 , moving on to next node
    ## 2 . . FP&A 0de29 Div ID 
    ##  checking children of Div ID 0de29 
    ##   [ 003 ] 
    ## 3 . . . FP&A 003 Unit ID 
    ## 1 . FP&A 456d0 Org ID 
    ## FP&A  has no subset relationship to  456d0 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Customer Service .........................
    ## 0  Customer Service a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Customer Service c4829 Org ID 
    ## Customer Service  has no subset relationship to  c4829 , moving on to next node
    ## 1 . Customer Service 456d0 Org ID 
    ##  checking children of Org ID 456d0 
    ##   [ ce266 ]...[ 10d0d ]...[ 2fae3 ] 
    ## 2 . . Customer Service ce266 Div ID 
    ##  checking children of Div ID ce266 
    ##   [ 004 ]...[ 005 ]...[ 006 ]...[ 007 ] 
    ## 3 . . . Customer Service 004 Unit ID 
    ## 3 . . . Customer Service 005 Unit ID 
    ## 3 . . . Customer Service 006 Unit ID 
    ## 3 . . . Customer Service 007 Unit ID 
    ## 2 . . Customer Service 10d0d Div ID 
    ## Customer Service  has no subset relationship to  10d0d , moving on to next node
    ## 2 . . Customer Service 2fae3 Div ID 
    ## Customer Service  has no subset relationship to  2fae3 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Customer Billing .........................
    ## 0  Customer Billing a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Customer Billing c4829 Org ID 
    ## Customer Billing  has no subset relationship to  c4829 , moving on to next node
    ## 1 . Customer Billing 456d0 Org ID 
    ##  checking children of Org ID 456d0 
    ##   [ ce266 ]...[ 10d0d ]...[ 2fae3 ] 
    ## 2 . . Customer Billing ce266 Div ID 
    ##  checking children of Div ID ce266 
    ##   [ 004 ]...[ 005 ]...[ 006 ]...[ 007 ] 
    ## 3 . . . Customer Billing 004 Unit ID 
    ## 3 . . . Customer Billing 005 Unit ID 
    ## 3 . . . Customer Billing 006 Unit ID 
    ## 3 . . . Customer Billing 007 Unit ID 
    ## 2 . . Customer Billing 10d0d Div ID 
    ## Customer Billing  has no subset relationship to  10d0d , moving on to next node
    ## 2 . . Customer Billing 2fae3 Div ID 
    ## Customer Billing  has no subset relationship to  2fae3 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Marketing .........................
    ## 0  Marketing a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Marketing c4829 Org ID 
    ## Marketing  has no subset relationship to  c4829 , moving on to next node
    ## 1 . Marketing 456d0 Org ID 
    ##  checking children of Org ID 456d0 
    ##   [ ce266 ]...[ 10d0d ]...[ 2fae3 ] 
    ## 2 . . Marketing ce266 Div ID 
    ##  checking children of Div ID ce266 
    ##   [ 004 ]...[ 005 ]...[ 006 ]...[ 007 ] 
    ## 3 . . . Marketing 004 Unit ID 
    ## 3 . . . Marketing 005 Unit ID 
    ## 3 . . . Marketing 006 Unit ID 
    ## 3 . . . Marketing 007 Unit ID 
    ## 2 . . Marketing 10d0d Div ID 
    ## Marketing  has no subset relationship to  10d0d , moving on to next node
    ## 2 . . Marketing 2fae3 Div ID 
    ## Marketing  has no subset relationship to  2fae3 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Research .........................
    ## 0  Research a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Research c4829 Org ID 
    ## Research  has no subset relationship to  c4829 , moving on to next node
    ## 1 . Research 456d0 Org ID 
    ##  checking children of Org ID 456d0 
    ##   [ ce266 ]...[ 10d0d ]...[ 2fae3 ] 
    ## 2 . . Research ce266 Div ID 
    ##  checking children of Div ID ce266 
    ##   [ 004 ]...[ 005 ]...[ 006 ]...[ 007 ] 
    ## 3 . . . Research 004 Unit ID 
    ## 3 . . . Research 005 Unit ID 
    ## 3 . . . Research 006 Unit ID 
    ## 3 . . . Research 007 Unit ID 
    ## 2 . . Research 10d0d Div ID 
    ## Research  has no subset relationship to  10d0d , moving on to next node
    ## 2 . . Research 2fae3 Div ID 
    ## Research  has no subset relationship to  2fae3 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Facilities .........................
    ## 0  Facilities a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Facilities c4829 Org ID 
    ## Facilities  has no subset relationship to  c4829 , moving on to next node
    ## 1 . Facilities 456d0 Org ID 
    ##  checking children of Org ID 456d0 
    ##   [ ce266 ]...[ 10d0d ]...[ 2fae3 ] 
    ## 2 . . Facilities ce266 Div ID 
    ## Facilities  has no subset relationship to  ce266 , moving on to next node
    ## 2 . . Facilities 10d0d Div ID 
    ##  checking children of Div ID 10d0d 
    ##   [ 008 ]...[ 009 ] 
    ## 3 . . . Facilities 008 Unit ID 
    ## 3 . . . Facilities 009 Unit ID 
    ## 2 . . Facilities 2fae3 Div ID 
    ## Facilities  has no subset relationship to  2fae3 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Landscaping .........................
    ## 0  Landscaping a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Landscaping c4829 Org ID 
    ## Landscaping  has no subset relationship to  c4829 , moving on to next node
    ## 1 . Landscaping 456d0 Org ID 
    ##  checking children of Org ID 456d0 
    ##   [ ce266 ]...[ 10d0d ]...[ 2fae3 ] 
    ## 2 . . Landscaping ce266 Div ID 
    ## Landscaping  has no subset relationship to  ce266 , moving on to next node
    ## 2 . . Landscaping 10d0d Div ID 
    ##  checking children of Div ID 10d0d 
    ##   [ 008 ]...[ 009 ] 
    ## 3 . . . Landscaping 008 Unit ID 
    ## 3 . . . Landscaping 009 Unit ID 
    ## 2 . . Landscaping 2fae3 Div ID 
    ## Landscaping  has no subset relationship to  2fae3 , moving on to next node
    ## 
    ## 
    ## ............... Searching for Matches to Node Building .........................
    ## 0  Building a9621 Company ID 
    ##  checking children of Company ID a9621 
    ##   [ c4829 ]...[ 456d0 ] 
    ## 1 . Building c4829 Org ID 
    ## Building  has no subset relationship to  c4829 , moving on to next node
    ## 1 . Building 456d0 Org ID 
    ##  checking children of Org ID 456d0 
    ##   [ ce266 ]...[ 10d0d ]...[ 2fae3 ] 
    ## 2 . . Building ce266 Div ID 
    ## Building  has no subset relationship to  ce266 , moving on to next node
    ## 2 . . Building 10d0d Div ID 
    ## Building  has no subset relationship to  10d0d , moving on to next node
    ## 2 . . Building 2fae3 Div ID 
    ##  checking children of Div ID 2fae3 
    ##   [ 010 ] 
    ## 3 . . . Building 010 Unit ID

| columnA      | nodeA       | columnB    | nodeB |
| :----------- | :---------- | :--------- | :---- |
| Company Name | SomeCo      | Company ID | a9621 |
| Org Name     | Finance     | Org ID     | c4829 |
| Org Name     | Operations  | Org ID     | 456d0 |
| Div Name     | Accounting  | Div ID     | 9bbd4 |
| Div Name     | Forecasting | Div ID     | 0de29 |
| Div Name     | Customer    | Div ID     | ce266 |
| Div Name     | Maintenance | Div ID     | 10d0d |
| Div Name     | Security    | Div ID     | 2fae3 |
| Unit Name    | FP\&A       | Div ID     | 0de29 |
| Unit Name    | Building    | Div ID     | 2fae3 |
