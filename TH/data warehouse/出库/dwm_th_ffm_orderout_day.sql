/*=====================================================================+
表名称：  dwm_th_ffm_orderout_day
功能描述：泰国发货单 2B（打包日期）出库情况

需求来源：
编写人员: 王昱棋
设计日期：2024/10/22
        修改日期:
        修改人员:
        修改原因:
-----------------------------------------------------------------------
---存在问题：
-----------------------------------------------------------------------
+=====================================================================*/

-- drop table if exists dwm.dwm_th_ffm_orderout_day;
-- create table dwm.dwm_th_ffm_orderout_day as
# delete from dwm.dwm_th_ffm_orderout_day where 日期 >= date_sub(date(now() + interval -1 hour),interval 90 day); -- 先删除数据
# insert into dwm.dwm_th_ffm_orderout_day -- 再插入数据
SELECT
    LEFT(delivery_time,10) 日期
    ,warehouse_name
    ,warehouse_detailname
#     ,seller_name
    ,sum(if(audit_time is not null and TYPE='B2C', goods_num, 0)) B2C商品数量
    ,COUNT(if(TYPE='B2C', delivery_sn, null)) B2C出库单量
FROM dwm.dwd_th_ffm_outbound_dayV2
where 1=1
    and is_visible=1
    and LEFT(delivery_time,10) BETWEEN LEFT(now() - INTERVAL 1 day,10) AND LEFT(now()- INTERVAL 1 day,10)
GROUP BY 1,2,3
order by 3
