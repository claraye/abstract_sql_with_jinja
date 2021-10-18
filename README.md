# abstract_sql_with_jinja
Create maintainable SQL queries powered Jinja macros (and stored procedures).

### :zap: Summary :zap:
This repo explores better abstractions for SQL queries, with the help of Jinja macros and stored procedures. \

The sample template _feature_temp.sql_ shows an extractable way to aggregate returns over user-specified time periods, and calculate trailing performance metrics such as IR (information ratio) and Sortino ratio.

Ref: https://towardsdatascience.com/jinja-sql-%EF%B8%8F-7e4dff8d8778

### :zap: Benefits :zap:
1. Well organized and highly extensible codes
2. Parametrized and composable queries, help users better focused on data engineering
3. Improve the efficiency of queries creation and unit testing

