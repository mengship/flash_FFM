-- 库龄 面积 计算仓储费
 select
        t2.date
        ,s.name
        ,T2.计费数据
        ,decode(l.location_attribute,  1 ,'小货架',2, '中货架',3 ,'大货架',4, '落地货架',5, '其他',location_attribute)货位属性
        ,sum(l.length / 1000 * l.width / 1000 ) AS total_area_nopublic
        ,sum(l.length / 1000 * l.width / 1000 * ( 100 + r.share_ratio ) / 100) AS total_area_public
        ,sum(l.length / 1000 * l.width / 1000 *l.height/ 1000 * ( 100 + r.share_ratio ) / 100) AS total_volume

    from
    (
        select
            distinct
            t1.date
            ,t1.计费数据
            ,t1.location_id
            ,t1.seller_id
        from
        (
            select
                a.date
                ,a.location_id
                ,a.seller_id
                ,t.计费数据
                ,case when a.in_days <=t.免租期 then '90天'
                    else '120天'
                    end age
            from
            wms_production.seller_goods_batch_location_days_stock_snapshot a
            left join wms_production.seller s on a.seller_id =s.id
            left join (select * from tmpale.tmp_my_sellerrule202503 where 计费数据 in ('货位面积（按公摊系数-不区分货位）㎡', '货位面积（不含公摊系数）㎡')) t on s.name = t.货主
            where 1=1
            and date between date('2025-04-01') and date('2025-04-30')
            and t.货主 is not null
        )T1
            where age='120天'
    )T2
    left join wms_production.seller s on t2.seller_id =s.id
    left join wms_production.location l    on t2.location_id=l.id
    left join wms_production.repository r  on l.repository_id = r.id
    where 1=1
      and r.use_attribute NOT IN ( 'temporary', 'waitingTemporary' )
    -- and s.name ='FeiSiDeLin 菲斯德林'
    group by t2.date,s.name,T2.计费数据
order by s.name,t2.date;