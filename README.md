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
