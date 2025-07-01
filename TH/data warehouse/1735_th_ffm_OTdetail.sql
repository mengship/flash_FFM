select
    warehouse_name
    ,seller_name
    ,type
    ,sn
    ,express_name
    ,reg_time time
from
(
    select
        仓库名称 warehouse_name
        ,seller_name
        ,'入库单超48H' type
        ,notice_number sn
        ,null express_name
        ,reg_time
    from
    dwm.dwd_th_ffm_arrivalnotice_dayV2
    where 1=1
    and 单据='采购订单'
    and is_OT48h=1

    union all
    select
        仓库名称
        ,seller_name
        ,'销退单超48H' type
        ,notice_number sn
        ,null express_name
        ,reg_time
    from
    dwm.dwd_th_ffm_arrivalnotice_dayV2
    where 1=1
    and 单据='销退订单'
    and is_OT48h=1

    union all
    select
        warehouse_name
        ,seller_name
        ,'上架单超48H' type
        ,order_sn sn
        ,null express_name
        ,create_time
    from
    dwm.dwd_th_ffm_shelf_detail
    where 1=1
    and is_OT48h=1

    union all
    select
        warehouse_name
        ,seller_name
        ,'发货单超48H' type
        ,delivery_sn sn
        ,null express_name
        ,audit_time
    from
    dwm.dwd_th_ffm_outboundsku_day
    where 1=1
    and 'B2C'=TYPE
    and is_OT48h=1
    and is_visible=1
    group by 1,2,3,4,5,6

    union all
    select
        warehouse_name
        ,seller_name
        ,'2C待审核单量超48H' type
        ,delivery_sn sn
        ,null express_name
        ,created_time
    from
    dwm.dwd_th_ffm_outboundsku_day
    where 1=1
    and 'B2C'=TYPE
    and is_2CcreateOT48h=1
    and is_visible=1
    group by 1,2,3,4,5,6

	union all
    select
        warehouse_name
        ,seller_name
        ,'仓库已发货快递未确认超48H' type
        ,delivery_sn sn
        ,express_name
        ,delivery_time
    from
    dwm.dwd_th_ffm_outboundsku_day
    where 1=1
    and 'B2C'=TYPE
    and is_2CdeliveryOT48h=1
    and delivery_time>='2025-02-26'
    and is_visible=1
    group by 1,2,3,4,5,6

    union all
    select
        warehouse_name
        ,seller_name
        ,'出库单超72H' type
        ,delivery_sn sn
        ,null express_name
        ,audit_time
    from
    dwm.dwd_th_ffm_outboundsku_day
    where 1=1
    and 'B2B'=TYPE
    and is_OT72h=1
    and is_visible=1
    group by 1,2,3,4,5,6

    union all
    select
        warehouse_name
        ,seller_name
        ,'拦截单超48H' type
        ,intercept_sn sn
        ,null express_name
        ,created_time
    from
    dwm.dwd_th_ffm_intercept_abnormal_day
    where 1=1
    and '拦截单'=SUBSTRING(source, -3)
    and is_OT48h=1
    group by 1,2,3,4,5

    union all
    select
        warehouse_name
        ,seller_name
        ,'异常单超48H' type
        ,intercept_sn sn
        ,null express_name
        ,created_time
    from
    dwm.dwd_th_ffm_intercept_abnormal_day
    where 1=1
    and '异常单'=SUBSTRING(source, -3)
    and is_OT48h=1
    group by 1,2,3,4,5

    union all
    select
        warehouse_shortname
        ,seller_name
        ,'待审核装卸单' type
        ,sn
        ,null express_name
        ,created_format created_time
    from
    dwm.dwd_th_ffm_loaduploadorder
    where 1=1
    and created_format_dt>='2025-04-01'
    and status_name='待审核'
    group by 1,2,3,4,5
) ta
where 1=1
# ${if(len(warehouse_name) == 0,"","and warehouse_name in ('" + warehouse_name + "')")}
# ${if(len(type) == 0,"","and type in ('" + type + "')")}