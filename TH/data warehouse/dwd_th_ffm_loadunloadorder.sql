
/*=====================================================================+
表名称：  dwd_th_ffm_loaduploadorder
功能描述：  泰国ffm装卸单

需求来源：
编写人员: wangdongchen
设计日期：2025/4/15
修改日期:
修改人员:
修改原因:

-----------------------------------------------------------------------
---存在问题：
-----------------------------------------------------------------------
+===================================================================== */
-- drop table if exists dwm.dwd_th_ffm_loaduploadorder;
-- create table dwm.dwd_th_ffm_loaduploadorder as
# delete from dwm.dwd_th_ffm_loaduploadorder where created_date >= date_sub(date(now() + interval -1 hour),interval 90 day); -- 先删除数据
# insert into dwm.dwd_th_ffm_loaduploadorder -- 再插入数据
select
    type
    ,type_name
    ,sn
    ,status
    ,status_name
    ,source_id
    ,source_sn
    ,warehouse_id
    ,warehouse_name
    ,warehouse_shortname
    ,seller_id
    ,seller_name
    ,party
    ,start_at
    ,start_at_format
    ,end_at
    ,end_at_format
    ,carrier
    ,pno
    ,delivery_man
    ,delivery_phone
    ,delivery_plate
    ,volume
    ,theory_volume
    ,weight
    ,theory_weight
    ,remark
    ,audit_id
    ,audit_by
    ,audit_time
    ,audit_time_format
    ,create_id
    ,create_name
    ,created
    ,created_format
    ,date(created_format) created_format_dt
    ,modified
    ,modified_format
    ,is_cab
    ,cab_size
    ,goods_num
    ,volume_m3
from
(

    select
        luo.type
        ,case luo.type
            when 1 then '装货单'
            when 2 then '卸货单'
            end as type_name
        ,luo.sn
        ,luo.status
        ,case luo.status
            when 1010 then '待审核'
            when 1020 then '已审核'
            end as status_name
        ,luo.source_id
        ,luo.source_sn
        ,luo.warehouse_id
        ,luo.warehouse_name
        ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓')   then 'AGV'
            when w.name='BPL-Return Warehouse'  then 'BPL-Return'
            when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
            when w.name='BangsaoThong'  then 'BST'
            when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
            end warehouse_shortname
        ,luo.seller_id
        ,luo.seller_name
        ,luo.party
        ,luo.start_at
        ,date_format(FROM_UNIXTIME(luo.start_at),'%Y-%m-%d %T') start_at_format
        ,luo.end_at
        ,date_format(FROM_UNIXTIME(luo.end_at),'%Y-%m-%d %T') end_at_format
        ,luo.carrier
        ,luo.pno
        ,luo.delivery_man
        ,luo.delivery_phone
        ,luo.delivery_plate
        ,luo.volume
        ,luo.theory_volume
        ,luo.weight
        ,luo.theory_weight
        ,luo.remark
        ,luo.audit_id
        ,luo.audit_by
        ,luo.audit_time
        ,date_format(FROM_UNIXTIME(luo.audit_time),'%Y-%m-%d %T') audit_time_format
        ,luo.create_id
        ,luo.create_name
        ,luo.created
        ,date_format(FROM_UNIXTIME(luo.created),'%Y-%m-%d %T') created_format
        ,luo.modified
         ,date_format(FROM_UNIXTIME(luo.modified),'%Y-%m-%d %T') modified_format
        ,luo.is_cab
        ,luo.cab_size
        ,luo.goods_num
        ,luo.volume/1000/1000/1000 as volume_m3
    from wms_production.load_unload_order luo
    left join wms_production.warehouse w ON luo.warehouse_id=w.id
    where luo.created>=1743436800 -- 2025-04-01
) t0
where warehouse_shortname is not null
;
