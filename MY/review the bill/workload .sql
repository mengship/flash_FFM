-- 上月账单审账单
select -- 整体业务单量
    a.warehouse_name
    ,a.seller_name
    ,a.comment
    ,a. months
    ,a.type
    ,a.count_id as 本期单量
    ,number as 本期件量
from
(
    select
        b.name as warehouse_name
        ,a.name as seller_name
        ,kk.months
        ,kk.type
        ,count(distinct kk.id) as count_id
        ,a.comment
        ,sum( number) number
    from
    (
        select
            a.seller_id,
            a.warehouse_id,
            a.id ,
            '入库单' as type,
            date_format(a.complete_time,'%y#%m') as months, ba.in_num  number
        from wms_production.arrival_notice as a
        left join wms_production.arrival_notice_goods ba  on a.id=ba.`arrival_notice_id`
        where DATE(a.complete_time)
        between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
        and date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
        union all
        (
            select
                ba.seller_id,
                ba.warehouse_id,
                ba.id ,
                '销退单'as type,
                date_format(ba.complete_time,'%y#%m') as months,bb.`back_goods_in_number` number
            from wms_production.delivery_rollback_order ba
            left join `wms_production`.`delivery_rollback_order_goods` bb on ba.`id` =bb.`delivery_rollback_order_id`
            where date(ba.complete_time)
              between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
              and date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
        )
        union all
        (
            select
                d.seller_id,
                d.warehouse_id,
                d.id,
                '发货单'as type,
                date_format(d.delivery_time,'%y#%m')as months,dd.`goods_number` as number
            from wms_production.delivery_order d
            left join `wms_production`.`delivery_order_goods` dd on  d.id=dd.`delivery_order_id`
            where date(d.delivery_time)
              between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
              and date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
        )
        union  all
        (
            select
                r.seller_id,
                r.warehouse_id,
                r.id,
                '出库单'as type,
                date_format(r.out_warehouse_time,'%y#%m')as months,rr.`out_num` as number
            from wms_production.return_warehouse  r
            left join `wms_production`.`return_warehouse_goods` as rr on r.id=rr.`return_warehouse_id`
            where date(r.out_warehouse_time)
                between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
              and date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
              and type=1
        )
        union all
        (
            select
                ip.seller_id,
                ip.warehouse_id,
                ip.id,
                '拦截单'as type,
                date_format(ip.shelf_on_end_time,'%y#%m')as months,ipp.had_on_num as number
            from wms_production.intercept_place ip
            left join `wms_production`.`intercept_place_goods`as ipp on ip.id=ipp.intercept_place_id
            where date(ip.shelf_on_end_time)
              between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
              and date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
        )
        union all
        (
            select
                ac.seller_id,
                ac.warehouse_id,
                ac.id,
                '贴码单'as type,
                date_format(ac.mark_time,'%y#%m')as months,acc.`affixed_code_num`  as number
            from wms_production.affixed_code ac
            left join `wms_production`.`affixed_code_goods` as acc on ac.`id` =acc.`affixed_code_id`
            where date(ac.mark_time)
              between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
              and date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
        )
        union all
        (
            select
                seller_id,
                warehouse_id,
                id,
                '卸货费'as type,
                date_format(FROM_UNIXTIME(audit_time),'%y#%m')as months,volume/1000/1000/1000 as number
            from wms_production.load_unload_order
            where date(FROM_UNIXTIME(audit_time))
                between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
              and date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
              and type=2
        )
        union all
        (
            select
                seller_id,
                warehouse_id,
                id,
                '装货费'as type,
                date_format(FROM_UNIXTIME(audit_time),'%y#%m')as months,volume/1000/1000/1000 as number
            from wms_production.load_unload_order
            where date(FROM_UNIXTIME(audit_time))
              between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
              and date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
          and type=1
        )
        union all
        (
            select
                ba.from_seller_id,
                ba.warehouse_id,
                ba.id ,
                '货权转出'as type,
                date_format(ba.complete_time,'%y#%m') as months,ba.actual_num number
            from wms_production.transfer_order ba
            where date(ba.complete_time)
              between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
              and date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
        )
        union all
        (
            select
                ba.to_seller_id,
                ba.warehouse_id,
                ba.id ,
                '货权转入'as type,
                date_format(ba.complete_time,'%y#%m') as months,ba.actual_num number
            from wms_production.transfer_order ba
            where date(ba.complete_time)
              between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
              and date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
        )
        union all
        (
            select
                ba.seller_id,
                ba.warehouse_id,
                ba.id ,
                '报废单'as type,
                date_format(ba.complete_time,'%y#%m') as months,ba.goods_num number
            from wms_production.destroy_order ba
            where date(ba.complete_time)
            between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
              and date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
        )
    )  as kk
    left join wms_production.seller as a on kk.seller_id=a.id
    left join wms_production.warehouse as b on kk.warehouse_id=b.id
    group by
    kk.months,
    kk.warehouse_id,
    kk.seller_id,
    kk.type,
    a.comment
) as a
where 1=1
-- and seller_name in (
--   'LGF 枣粮先生 ZaoLiang'
-- )
order by months ,warehouse_name,seller_name,type asc
;


-- 月度周转率
select
    a.name
    ,all_volume
    ,v1
    ,v2
    ,all_volume/ifnull(v1,1)
    ,all_volume/ifnull(v2,1)
    ,all_volume/if(ifnull(v1,0)+ifnull(v2,0)=0,1,ifnull(v1,0)+ifnull(v2,0))
from
(
    select
        s.name,
        sum(sg.length/1000*sg.width/1000*sg.height /1000*a.total_inventory)  as all_volume
    from  wms_production.seller_goods_location_ref_snapshot  as a
    left join wms_production.seller s on a.seller_id =s.id
    left join wms_production.location l    on a.location_id=l.id
    left join wms_production.seller_goods sg on sg.id =a.seller_goods_id
    where a.date between date('2025-02-01') and date('2025-02-28')
    and s.name ='虾米盒子 Xiami Box'
    group by s.name
) as a
left join
(
    select
        s.name
        ,ifnull(sum(dog.goods_number*sg.volume/1000/1000/1000) ,0)v1
    from wms_production.delivery_order do
    left join wms_production.delivery_order_goods dog on do.id=dog.delivery_order_id
    left join wms_production.seller_goods sg on dog.seller_goods_id =sg.id
    left join wms_production.seller s on do.seller_id =s.id
    where s.name='虾米盒子 Xiami Box' and date(do.delivery_time) between  date('2025-02-01') and date('2025-02-28')
    group by s.name
) b on a.name=b.name
left join
(
    select
        s.name
        ,ifnull(sum(dog.out_num *sg.volume/1000/1000/1000),0) v2
    from wms_production.return_warehouse   do
    left join wms_production.return_warehouse_goods  dog on do.id=dog.return_warehouse_id
    left join wms_production.seller_goods sg on dog.seller_goods_id  =sg.id
    left join wms_production.seller s on do.seller_id =s.id
    where s.name='虾米盒子 Xiami Box' and date(do.out_warehouse_time) between  date('2025-02-01') and date('2025-02-28')
    group by s.name
) c
on a.name=b.name;

# 本月账单
-- 审账单
select -- 整体业务单量
    a.warehouse_name
    ,a.seller_name
    ,a.comment
    ,a. months
    ,a.type
    ,a.count_id as 本期单量
    ,number as 本期件量
from
(
    select
        b.name as warehouse_name
        ,a.name as seller_name
        ,kk.months
        ,kk.type
        ,count(distinct kk.id) as count_id
        ,a.comment
        ,sum( number) number
    from
    (
        select
            a.seller_id,
            a.warehouse_id,
            a.id ,
            '入库单' as type,
            date_format(a.complete_time,'%y#%m') as months, ba.in_num  number
        from wms_production.arrival_notice as a
        left join wms_production.arrival_notice_goods ba  on a.id=ba.`arrival_notice_id`
        where DATE(a.complete_time)
        between date_add(current_date,interval -day(current_date)+1 day)
                and last_day(current_date)
        union all
        (
            select
                ba.seller_id,
                ba.warehouse_id,
                ba.id ,
                '销退单'as type,
                date_format(ba.complete_time,'%y#%m') as months,bb.`back_goods_in_number` number
            from wms_production.delivery_rollback_order ba
            left join `wms_production`.`delivery_rollback_order_goods` bb on ba.`id` =bb.`delivery_rollback_order_id`
            where date(ba.complete_time)
              between date_add(current_date,interval -day(current_date)+1 day)
                and last_day(current_date)
        )
        union all
        (
            select
                d.seller_id,
                d.warehouse_id,
                d.id,
                '发货单'as type,
                date_format(d.delivery_time,'%y#%m')as months,dd.`goods_number` as number
            from wms_production.delivery_order d
            left join `wms_production`.`delivery_order_goods` dd on  d.id=dd.`delivery_order_id`
            where date(d.delivery_time)
              between date_add(current_date,interval -day(current_date)+1 day)
                    and last_day(current_date)
        )
        union  all
        (
            select
                r.seller_id,
                r.warehouse_id,
                r.id,
                '出库单'as type,
                date_format(r.out_warehouse_time,'%y#%m')as months,rr.`out_num` as number
            from wms_production.return_warehouse  r
            left join `wms_production`.`return_warehouse_goods` as rr on r.id=rr.`return_warehouse_id`
            where date(r.out_warehouse_time)
                between date_add(current_date,interval -day(current_date)+1 day)
                    and last_day(current_date)
              and type=1
        )
        union all
        (
            select
                ip.seller_id,
                ip.warehouse_id,
                ip.id,
                '拦截单'as type,
                date_format(ip.shelf_on_end_time,'%y#%m')as months,ipp.had_on_num as number
            from wms_production.intercept_place ip
            left join `wms_production`.`intercept_place_goods`as ipp on ip.id=ipp.intercept_place_id
            where date(ip.shelf_on_end_time)
              between date_add(current_date,interval -day(current_date)+1 day)
                and last_day(current_date)
        )
        union all
        (
            select
                ac.seller_id,
                ac.warehouse_id,
                ac.id,
                '贴码单'as type,
                date_format(ac.mark_time,'%y#%m')as months,acc.`affixed_code_num`  as number
            from wms_production.affixed_code ac
            left join `wms_production`.`affixed_code_goods` as acc on ac.`id` =acc.`affixed_code_id`
            where date(ac.mark_time)
              between date_add(current_date,interval -day(current_date)+1 day)
                    and last_day(current_date)
        )
        union all
        (
            select
                seller_id,
                warehouse_id,
                id,
                '卸货费'as type,
                date_format(FROM_UNIXTIME(audit_time),'%y#%m')as months,volume/1000/1000/1000 as number
            from wms_production.load_unload_order
            where date(FROM_UNIXTIME(audit_time))
                between date_add(current_date,interval -day(current_date)+1 day)
                    and last_day(current_date)
              and type=2
        )
        union all
        (
            select
                seller_id,
                warehouse_id,
                id,
                '装货费'as type,
                date_format(FROM_UNIXTIME(audit_time),'%y#%m')as months,volume/1000/1000/1000 as number
            from wms_production.load_unload_order
            where date(FROM_UNIXTIME(audit_time))
              between date_add(current_date,interval -day(current_date)+1 day)
                    and last_day(current_date)
          and type=1
        )
        union all
        (
            select
                ba.from_seller_id,
                ba.warehouse_id,
                ba.id ,
                '货权转出'as type,
                date_format(ba.complete_time,'%y#%m') as months,ba.actual_num number
            from wms_production.transfer_order ba
            where date(ba.complete_time)
              between date_add(current_date,interval -day(current_date)+1 day)
                and last_day(current_date)
        )
        union all
        (
            select
                ba.to_seller_id,
                ba.warehouse_id,
                ba.id ,
                '货权转入'as type,
                date_format(ba.complete_time,'%y#%m') as months,ba.actual_num number
            from wms_production.transfer_order ba
            where date(ba.complete_time)
              between date_add(current_date,interval -day(current_date)+1 day)
                and last_day(current_date)
        )
        union all
        (
            select
                ba.seller_id,
                ba.warehouse_id,
                ba.id ,
                '报废单'as type,
                date_format(ba.complete_time,'%y#%m') as months,ba.goods_num number
            from wms_production.destroy_order ba
            where date(ba.complete_time)
            between date_add(current_date,interval -day(current_date)+1 day)
and last_day(current_date)
        )
    )  as kk
    left join wms_production.seller as a on kk.seller_id=a.id
    left join wms_production.warehouse as b on kk.warehouse_id=b.id
    group by
    kk.months,
    kk.warehouse_id,
    kk.seller_id,
    kk.type,
    a.comment
) as a
where 1=1
and seller_name in (
  'Dollbao International Ltd.'
)
order by months ,warehouse_name,seller_name,type asc;

select date_add(current_date,interval -day(current_date)+1 day)
and last_day(current_date)

-- 指定月份
-- 上月账单审账单
select -- 整体业务单量
    a.warehouse_name
    ,a.seller_name
    ,a.comment
    ,a. months
    ,a.type
    ,a.count_id as 本期单量
    ,number as 本期件量
from
(
    select
        b.name as warehouse_name
        ,a.name as seller_name
        ,kk.months
        ,kk.type
        ,count(distinct kk.id) as count_id
        ,a.comment
        ,sum( number) number
    from
    (
        select
            a.seller_id,
            a.warehouse_id,
            a.id ,
            '入库单' as type,
            date_format(a.complete_time,'%y#%m') as months, ba.in_num  number
        from wms_production.arrival_notice as a
        left join wms_production.arrival_notice_goods ba  on a.id=ba.`arrival_notice_id`
        where DATE(a.complete_time)
        between '2025-02-01' and '2025-02-28'
        union all
        (
            select
                ba.seller_id,
                ba.warehouse_id,
                ba.id ,
                '销退单'as type,
                date_format(ba.complete_time,'%y#%m') as months,bb.`back_goods_in_number` number
            from wms_production.delivery_rollback_order ba
            left join `wms_production`.`delivery_rollback_order_goods` bb on ba.`id` =bb.`delivery_rollback_order_id`
            where date(ba.complete_time)
              between '2025-02-01' and '2025-02-28'
        )
        union all
        (
            select
                d.seller_id,
                d.warehouse_id,
                d.id,
                '发货单'as type,
                date_format(d.delivery_time,'%y#%m')as months,dd.`goods_number` as number
            from wms_production.delivery_order d
            left join `wms_production`.`delivery_order_goods` dd on  d.id=dd.`delivery_order_id`
            where date(d.delivery_time)
              between '2025-02-01' and '2025-02-28'
        )
        union  all
        (
            select
                r.seller_id,
                r.warehouse_id,
                r.id,
                '出库单'as type,
                date_format(r.out_warehouse_time,'%y#%m')as months,rr.`out_num` as number
            from wms_production.return_warehouse  r
            left join `wms_production`.`return_warehouse_goods` as rr on r.id=rr.`return_warehouse_id`
            where date(r.out_warehouse_time)
                between '2025-02-01' and '2025-02-28'
              and type=1
        )
        union all
        (
            select
                ip.seller_id,
                ip.warehouse_id,
                ip.id,
                '拦截单'as type,
                date_format(ip.shelf_on_end_time,'%y#%m')as months,ipp.had_on_num as number
            from wms_production.intercept_place ip
            left join `wms_production`.`intercept_place_goods`as ipp on ip.id=ipp.intercept_place_id
            where date(ip.shelf_on_end_time)
              between '2025-02-01' and '2025-02-28'
        )
        union all
        (
            select
                ac.seller_id,
                ac.warehouse_id,
                ac.id,
                '贴码单'as type,
                date_format(ac.mark_time,'%y#%m')as months,acc.`affixed_code_num`  as number
            from wms_production.affixed_code ac
            left join `wms_production`.`affixed_code_goods` as acc on ac.`id` =acc.`affixed_code_id`
            where date(ac.mark_time)
              between '2025-02-01' and '2025-02-28'
        )
        union all
        (
            select
                seller_id,
                warehouse_id,
                id,
                '卸货费'as type,
                date_format(FROM_UNIXTIME(audit_time),'%y#%m')as months,volume/1000/1000/1000 as number
            from wms_production.load_unload_order
            where date(FROM_UNIXTIME(audit_time))
                between '2025-02-01' and '2025-02-28'
              and type=2
        )
        union all
        (
            select
                seller_id,
                warehouse_id,
                id,
                '装货费'as type,
                date_format(FROM_UNIXTIME(audit_time),'%y#%m')as months,volume/1000/1000/1000 as number
            from wms_production.load_unload_order
            where date(FROM_UNIXTIME(audit_time))
              between '2025-02-01' and '2025-02-28'
          and type=1
        )
        union all
        (
            select
                ba.from_seller_id,
                ba.warehouse_id,
                ba.id ,
                '货权转出'as type,
                date_format(ba.complete_time,'%y#%m') as months,ba.actual_num number
            from wms_production.transfer_order ba
            where date(ba.complete_time)
              between '2025-02-01' and '2025-02-28'
        )
        union all
        (
            select
                ba.to_seller_id,
                ba.warehouse_id,
                ba.id ,
                '货权转入'as type,
                date_format(ba.complete_time,'%y#%m') as months,ba.actual_num number
            from wms_production.transfer_order ba
            where date(ba.complete_time)
              between '2025-02-01' and '2025-02-28'
        )
        union all
        (
            select
                ba.seller_id,
                ba.warehouse_id,
                ba.id ,
                '报废单'as type,
                date_format(ba.complete_time,'%y#%m') as months,ba.goods_num number
            from wms_production.destroy_order ba
            where date(ba.complete_time)
            between '2025-02-01' and '2025-02-28'
        )
    )  as kk
    left join wms_production.seller as a on kk.seller_id=a.id
    left join wms_production.warehouse as b on kk.warehouse_id=b.id
    group by
    kk.months,
    kk.warehouse_id,
    kk.seller_id,
    kk.type,
    a.comment
) as a
where 1=1
# and seller_name in (
#   'BaiShu 柏澍'
# )
order by months ,warehouse_name,seller_name,type asc;