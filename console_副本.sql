select
    *
from
(
    select
        s.name
        , sb.warehouse_fee_period
        , case sb.warehouse_fee_period
            when 1 then '天'
            when 2 then '周'
            when 3 then '半月'
            when 4 then '月'
            when 5 then '季'
            when 6 then '半年'
                end as warehouse_fee_period_name
        , sb.express_fee_period
         , case sb.express_fee_period
            when 1 then '天'
            when 2 then '周'
            when 3 then '半月'
            when 4 then '月'
            when 5 then '季'
            when 6 then '半年'
                end as express_fee_period_name
        , sb.warehouse_fee_period_day
        , sb.express_fee_period_day
    from wms_production.seller s
    left join wms_production.seller_balance sb on s.id = sb.seller_id
#     where name like '%丝飘%'
) t0 where warehouse_fee_period_name<>express_fee_period_name or warehouse_fee_period_day<>express_fee_period_day;

select * from wms_production.seller;

select * from wms_production.warehouse;