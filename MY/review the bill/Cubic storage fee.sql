-- 库龄 体积 计算仓储费 仓储费是否收费，要看入库类型，需要 sql 调整
    select
        seller_name
        ,计费数据
        ,age
        ,date
        ,case when age='61-120' then sum(volume)*60
            when age='121-180' then sum(volume)*90
            when age='180以上' then sum(volume)*120
            else 0
            end charge
        ,sum(use_area)*1.3 use_area_public
        ,sum(volume) volume
        ,sum(volume)*1.3 volume_public
    from
    (
        select
            s.name seller_name
            ,a.seller_goods_id
            ,a.date
            ,a.in_days
            ,t.计费数据
            ,sg.length/1000*sg.width/1000*sg.height /1000*a.inventory  as volume
            ,sg.length/1000*sg.width/1000*a.inventory use_area
            -- ,case when a.in_days <=60 then '0-60天'
            --     when a.in_days between 61 and 120 then '61-120'
            --     when a.in_days between 121 and 180 then '121-180'
            --     else '180以上'
            --     end age
              ,case when a.in_days <=t.免租期 then '90天' # and 单号 is not null and
                else '120天'
                end age
        from wms_production.seller_goods_days_stock_snapshot  as a
        left join wms_production.seller s on a.seller_id =s.id
        left join wms_production.seller_goods sg on sg.id =a.seller_goods_id
        left join wms_production.warehouse w on a.warehouse_id =w.id
        left join (select * from tmpale.tmp_my_sellerrule202504 where 计费数据 in ('orderGoodsNumByDaysVolumeByShare', '商品体积（含公摊）', '商品体积（周转天数）', '商品库龄体积', '商品体积')) t on s.name = t.货主
#         left join 单号
        where 1=1
        and a.date between date('2025-04-01') and  date('2025-04-30')
        and t.货主 is not null
#         and s.name='GZ- 李陌茶 LiMoCha'
    ) t0
    where age='120天'
    group by 计费数据,age,seller_name,date
    order by seller_name, date;

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
    left join         wms_production.location l    on a.location_id=l.id
    left join wms_production.seller_goods sg on sg.id =a.seller_goods_id
    where a.date between date('2025-03-01') and date('2025-03-31')
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
    where s.name='虾米盒子 Xiami Box' and date(do.delivery_time) between date('2025-03-01') and date('2025-03-31')
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
    where s.name='虾米盒子 Xiami Box' and date(do.out_warehouse_time) between date('2025-03-01') and date('2025-03-31')
    group by s.name
) c
on a.name=b.name;

desc wms_production.seller_goods_batch_location_days_stock_snapshot