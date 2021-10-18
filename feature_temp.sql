{%- macro agg_features(feat_name, month_range) -%}
    , MIN(DATA_DT) OVER (PARTITION BY PORTFOLIO ORDER BY DATA_DT ROWS 20*month_range PRECEDING) AS date_prev{{ month_range }}m
    , AVG(RET_PCT) OVER (PARTITION BY PORTFOLIO ORDER BY DATA_DT ROWS 20*month_range PRECEDING) AS {{ feat_name }}_avg{{ month_range }}m
    , STDEV(RET_PCT) OVER (PARTITION BY PORTFOLIO ORDER BY DATA_DT ROWS 20*month_range PRECEDING) AS {{ feat_name }}_sd{{ month_range }}m
    , STDEV(CASE WHEN RET_PCT<0 THEN RET_PCT) OVER (PARTITION BY PORTFOLIO ORDER BY DATA_DT ROWS 20*month_range PRECEDING) AS {{ feat_name }}_neg_sd{{ month_range }}m
{%- endmacro -%}


{%- macro ret_ir_sortino(feat_name, month_range) -%}
    , date_prev{{ month_range }}m
    , {{ feat_name }}_avg{{ month_range }}m as {{ feat_name }}_{{ month_range }}M
    , {{ feat_name }}_avg{{ month_range }}m / {{ feat_name }}_sd{{ month_range }}m *SQRT(252) AS IR_{{ month_range }}M
    , {{ feat_name }}_avg{{ month_range }}m / {{ feat_name }}_neg_sd{{ month_range }}m *SQRT(252) AS SORTINO_{{ month_range }}M
{%- endmacro -%}


CREATE PROCEDURE UPDATE_IR_SORTINO 
    @HORIZON_DATESTR VARCHAR(6)
AS
BEGIN
WITH RET_AGG AS (
    SELECT
           DATA_DT
         , PORTFOLIO
         {{ agg_features('Ret', 1) }}
         {{ agg_features('Ret', 3) }}
         {{ agg_features('Ret', 6) }}
    FROM
        PNL
    WHERE
        DATA_DT > DATEADD(DAY, -366, @HORIZON_DATESTR)
)
SELECT
      DATA_DT
    , PORTFOLIO
    {{ ret_ir_sortino('Ret', 1) }}
    {{ ret_ir_sortino('Ret', 3) }}
    {{ ret_ir_sortino('Ret', 6) }}
FROM
    RET_AGG
ORDER BY 
      RET_AGG.DATA_DT
    , RET_AGG.PORTFOLIO
END
GO;

EXEC UPDATE_IR_SORTINO @HORIZON_DATESTR='20201130'
