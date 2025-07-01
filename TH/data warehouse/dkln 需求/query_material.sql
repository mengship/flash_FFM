# 道麟哥需求 包材明细数据
# 日期 0526
select
         *
    from
    (
        select
            '出库' title_name
            ,warehouse_detailname warehouse_name
            ,do.seller_name
            ,do.delivery_sn
#             ,mb.job_number out_operator
            ,date(do.delivery_time) now_date
            ,case
                when f.bar_code in ('L', 'L1', 'L2') then f.name
                when f.bar_code in ('M', 'M1') then f.name
                when f.bar_code in ('S','S1','MINI','MINI1') then f.name
                else '其他包材'
                    end as meterialsize
        from dwm.dwd_th_ffm_outbound_dayV2 do
        join wms_production.`delivery_order` do1 on do.delivery_sn = do1.delivery_sn
        left join wms_production.delivery_box db on do1.id = db.delivery_order_id
        left join wms_production.container_order as b on db.id = b.box_id # do1.id = b.business_id
        left join wms_production.container_inventory_log as g on g.container_order_id=b.id
        left join wms_production.container as f on f.id=g.container_id
        LEFT JOIN `wms_production`.`member` mb on do1.operator_id=mb.`id`
        where 1=1
            and do.warehouse_name in ('BST', 'AGV', 'LAS', '')
            and 'B2C'=do.TYPE
            and ifnull(do.seller_name, 999)<>'FFM-TH'
            and do.delivery_time >= date_sub(date(now() + interval -1 hour),interval 90 day)
    ) t_out
where t_out.meterialsize<>'其他包材'