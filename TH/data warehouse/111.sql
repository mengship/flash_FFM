select
    blp.billing_name_zh 收入类型,
    CASE WHEN LEFT(blp.billing_name_zh,3) IN ('仓储费','入库费','出库费','包材费','卸货费') THEN LEFT(blp.billing_name_zh,3)
        ELSE blp.billing_name_zh END 收入类型2,
    left(bld.business_date,10) 日期,
    week(left(bld.business_date,10)+ interval 1 day) 周,
    case when  w.name in ('AutoWarehouse', 'AutoWarehouse-2') then 'AGV'
            when w.name='BPL-Return Warehouse' then 'BPL-Return'
            when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
            when w.name in ('BangsaoThong','BST-FMCG')  then 'BST'
            when w.name IN ('BKK-WH-LAS2电商仓') then 'LAS'
            when w.name='LCP Warehouse' then 'LCP'
             end 仓库名称
    ,case when w.name='AutoWarehouse' then 'AGV'
                    when w.name='AutoWarehouse-2' then 'AutoWarehouse-2'
                    when w.name='BPL-Return Warehouse' then 'BPL-Return'
                    when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                    when w.name='BangsaoThong' then 'BST'
                    when w.name='BST-FMCG'  then 'BST-FMCG'
                    when w.name IN ('BKK-WH-LAS2电商仓')         then 'LAS' # ,'PMD-WH','BKK-WH-Ecommerce','BKK-WH-LAS物料仓'
                    end 仓库明细名称
    ,sum(bld.settlement_amount)/100 amount -- 结算金额
from wms_production.billing_detail bld
left join wms_production.billing_projects blp on bld.billing_projects_id= blp.id
left join wms_production.warehouse w on bld.warehouse_id=w.id
where 1=1
    and left(bld.business_date,10) >=left(now() - interval 70 day,10)
    and LEFT(blp.billing_name_zh,2) <> '快递'
    and w.name='AutoWarehouse-2'
group by 1,2,3,4,5
having 仓库明细名称 is not null

select distinct w.name
from wms_production.billing_detail bld
left join wms_production.billing_projects blp on bld.billing_projects_id= blp.id
left join wms_production.warehouse w on bld.warehouse_id=w.id
where 1=1
        and left(bld.business_date,10) >=left(now() - interval 90 day,10)
        and LEFT(blp.billing_name_zh,2) <> '快递'
        and w.name='AutoWarehouse-2';


select * from dwm.dwd_th_ffm_outbound_dayV2 where warehouse_detailname='AutoWarehouse-2';

select * from dwm.dwd_th_ffm_outbound_dayV2 where warehouse_detailname='AGV-人工仓';


UPDATE dwm.dwd_th_ffm_outbound_dayV2 SET warehouse_detailname='AutoWarehouse-2' WHERE warehouse_detailname='AGV-人工仓';
UPDATE dwm.dwm_th_ffm_arrivalnoticetimely_day SET warehouse_detailname='AutoWarehouse-2' WHERE warehouse_detailname='AGV-人工仓';
