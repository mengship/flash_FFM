/*=====================================================================+
表名称：  dwm_th_ffm_staffworkload_month
功能描述：泰国发货单 交接单量 情况

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

-- drop table if exists dwm.dwm_th_ffm_staffworkload_month;
-- create table dwm.dwm_th_ffm_staffworkload_month as
# delete from dwm.dwm_th_ffm_staffworkload_month where month = left(date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month), 7); -- 先删除数据
# insert into dwm.dwm_th_ffm_staffworkload_month -- 再插入数据

select
    staff_info_id
#     ,warehouse_name warehouse_detailname
    ,if(warehouse_name='AGV-人工仓', 'AGV', warehouse_name) warehouse_name
    ,left(dt, 7) month
    ,sum(收货上架数量) 收货上架数量
    ,sum(补货上架) 补货上架
    ,sum(销退包裹量) 销退包裹量
    ,sum(拦截件数) 拦截件数
    ,sum(拣货件数) 拣货件数
    ,sum(拣货件数贴面单) 拣货件数贴面单
    ,sum(拣货件数批量小) 拣货件数批量小
    ,sum(拣货件数批量中) 拣货件数批量中
    ,sum(拣货件数批量大) 拣货件数批量大
    ,sum(拣货件数批量超大) 拣货件数批量超大
    ,sum(拣货件数小) 拣货件数小
    ,sum(拣货件数中) 拣货件数中
    ,sum(拣货件数大) 拣货件数大
    ,sum(拣货件数超大) 拣货件数超大
    ,sum(拣货件数信息不全) 拣货件数信息不全
    ,sum(打包件数) 打包件数
    ,sum(打包件数贴面单) 打包件数贴面单
    ,sum(打包件数批量小) 打包件数批量小
    ,sum(打包件数批量中) 打包件数批量中
    ,sum(打包件数批量大) 打包件数批量大
    ,sum(打包件数批量超大) 打包件数批量超大
    ,sum(打包件数PE) 打包件数PE
    ,sum(打包件数小) 打包件数小
    ,sum(打包件数中) 打包件数中
    ,sum(打包件数大) 打包件数大
    ,sum(打包件数超大) 打包件数超大
    ,sum(打包件数信息不全) 打包件数信息不全
    ,sum(出库包裹数) 出库包裹数
    ,sum(出库包裹数贴面单) 出库包裹数贴面单
    ,sum(出库包裹数PE) 出库包裹数PE
    ,sum(出库包裹数小) 出库包裹数小
    ,sum(出库包裹数中) 出库包裹数中
    ,sum(出库包裹数大) 出库包裹数大
    ,sum(出库包裹数超大) 出库包裹数超大
    ,sum(出库包裹数信息不全) 出库包裹数信息不全
    ,sum(收货件数) 收货件数
    ,sum(打包件数2B) 打包件数2B
from
dwm.dwd_th_ffm_staffworkload
where  1=1
-- and dt >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month) and dt < date_add(curdate() ,interval -day(curdate())+1 day)
and left(dt, 7) = '2025-01'
and warehouse_name in ('AGV', 'AGV-人工仓')
group by 1, 2, 3

select
    *
from
dwm.dwd_th_ffm_staffworkload
where dt>='2025-03-01'
and dt<'2025-04-01'
and warehouse_name='BST';
select * from dwm.dwm_th_ffm_staffworkload_month where 拣货件数贴面单>0
;

select
    *
from
dwm.dwm_th_ffm_staffworkload_month
where staff_info_id='668469';

select
    *
from
    dwm.dwm_th_ffm_staffworkload_month;


select
    ''
     ,warehouse_name
    ,date(delivery_time) delivery_date
    ,count(distinct delivery_sn) -- 375477
    ,sum(goods_num) goods_num -- 816528.0
from
dwm.dwd_th_ffm_outbound_dayV2
    where left(delivery_time, 7)='2025-01'
    and warehouse_name='AGV'
 group by warehouse_name, date(delivery_time);


select
    staff_info_id
    # ,warehouse_name warehouse_detailname
    ,if(warehouse_name='AGV-人工仓', 'AGV', warehouse_name) warehouse_name
    ,left(dt, 7) month
    ,now()
    ,sum(收货上架数量) 收货上架数量
    ,sum(补货上架) 补货上架
    ,sum(销退包裹量) 销退包裹量
    ,sum(拦截件数) 拦截件数
    ,sum(拣货件数) 拣货件数
    ,sum(拣货件数贴面单) 拣货件数贴面单
    ,sum(拣货件数批量小) 拣货件数批量小
    ,sum(拣货件数批量中) 拣货件数批量中
    ,sum(拣货件数批量大) 拣货件数批量大
    ,sum(拣货件数批量超大) 拣货件数批量超大
    ,sum(拣货件数小) 拣货件数小
    ,sum(拣货件数中) 拣货件数中
    ,sum(拣货件数大) 拣货件数大
    ,sum(拣货件数超大) 拣货件数超大
    ,sum(拣货件数信息不全) 拣货件数信息不全
    ,sum(打包件数) 打包件数
    ,sum(打包件数贴面单) 打包件数贴面单
    ,sum(打包件数批量小) 打包件数批量小
    ,sum(打包件数批量中) 打包件数批量中
    ,sum(打包件数批量大) 打包件数批量大
    ,sum(打包件数批量超大) 打包件数批量超大
    ,sum(打包件数PE) 打包件数PE
    ,sum(打包件数小) 打包件数小
    ,sum(打包件数中) 打包件数中
    ,sum(打包件数大) 打包件数大
    ,sum(打包件数超大) 打包件数超大
    ,sum(打包件数信息不全) 打包件数信息不全
    ,sum(出库包裹数) 出库包裹数
    ,sum(出库包裹数贴面单) 出库包裹数贴面单
    ,sum(出库包裹数PE) 出库包裹数PE
    ,sum(出库包裹数小) 出库包裹数小
    ,sum(出库包裹数中) 出库包裹数中
    ,sum(出库包裹数大) 出库包裹数大
    ,sum(出库包裹数超大) 出库包裹数超大
    ,sum(出库包裹数信息不全) 出库包裹数信息不全
    ,sum(收货件数) 收货件数
    ,sum(打包件数2B) 打包件数2B
from
dwm.dwd_th_ffm_staffworkload
where  1=1
# and dt >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month) and dt < date_add(curdate() ,interval -day(curdate())+1 day)
and dt >= '2025-01-01'
group by 1, 2, 3