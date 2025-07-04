/*=====================================================================+
表名称：  dwm_th_ffm_income_day
功能描述： 仓库收入表（操作费）

需求来源：
编写人员: 王昱棋
设计日期：2024/11/18
        修改日期:
        修改人员:
        修改原因:
-----------------------------------------------------------------------
---存在问题：
-----------------------------------------------------------------------
+=====================================================================*/

-- drop table if exists dwm.dwm_th_ffm_income_day;
-- create table dwm.dwm_th_ffm_income_day as
# delete from dwm.dwm_th_ffm_income_day where 日期 >= date_sub(date(now() + interval -1 hour),interval 90 day); -- 先删除数据
# insert into dwm.dwm_th_ffm_income_day -- 再插入数据
select
    日期
    , 周
    , 仓库名称
    , 仓库明细名称
#     , seller_name
    , sum(if(收入类型分类='入库费', amount, 0)) 入库费
    , sum(if(收入类型分类='出库费', amount, 0)) 出库费
    , sum(if(收入类型分类='操作费', amount, 0)) 操作费
    , sum(if(收入类型分类='仓储费', amount, 0)) 仓储费
    , sum(if(收入类型分类='包材费', amount, 0)) 包材费
    , sum(if(收入类型分类='增值服务', amount, 0)) 增值服务
    , sum(if(收入类型分类='销退拦截', amount, 0)) 销退拦截
from
(
    select
        blp.billing_name_zh 收入类型,
        CASE WHEN LEFT(blp.billing_name_zh,3) IN ('仓储费','入库费','出库费','包材费','卸货费') THEN LEFT(blp.billing_name_zh,3)
            ELSE blp.billing_name_zh END 收入类型2,
        dtfi.收入类型分类,
        left(bld.business_date,10) 日期,
        week(left(bld.business_date,10)+ interval 1 day) 周,
        case when  w.name in ('AutoWarehouse', 'AutoWarehouse-2') then 'AGV'
                when w.name='BPL-Return Warehouse' then 'BPL-Return'
                when w.name in ('BangsaoThong','BST-FMCG')  then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓') then 'LAS'
                 end 仓库名称,
        case when  w.name in ('AutoWarehouse') then 'AGV'
                when  w.name in ('AutoWarehouse-2') then 'AutoWarehouse-2'
                when w.name='BPL-Return Warehouse' then 'BPL-Return'
                when w.name in ('BangsaoThong')  then 'BST'
                when w.name in ('BST-FMCG')  then 'BST-FMCG'
                when w.name IN ('BKK-WH-LAS2电商仓') then 'LAS'
                 end 仓库明细名称,
        bld.settlement_amount/100 amount, -- 结算金额
        s.name seller_name

    from wms_production.billing_detail bld
    left join wms_production.billing_projects blp on bld.billing_projects_id= blp.id
    left join wms_production.warehouse w on bld.warehouse_id=w.id
    left join dwm.dim_th_ffm_incometype dtfi on blp.billing_name_zh = dtfi.收入类型
    left join wms_production.seller s on bld.seller_id = s.id
    where 1=1
        -- and bl.type='1'
        -- and billing_name_zh='操作费'
        and left(bld.business_date,10) >=left(now() - interval 1 day,10)
        and LEFT(blp.billing_name_zh,2) <> '快递'
    and w.name in ('AutoWarehouse-2')

) t0
group by 1,2,3,4

having 仓库名称 is not null
order by 3
;


select  * from dwm.dim_th_ffm_incometype