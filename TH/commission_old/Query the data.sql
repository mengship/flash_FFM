SELECT
        LEFT(payment_timeadd3h,10) 日期
        ,warehouse_name
        ,warehouse_detailname
        ,seller_name
        ,'及时推单' 指标
        ,sum(if(platform_source='Tik Tok' and TYPE='B2C' and OrderPush_type = 'intime', 1, 0)) B2CTikTok及时推单
        ,sum(if(platform_source='Tik Tok' and TYPE='B2C' and OrderPush_type in ('intime', 'notintime'), 1, 0)) B2CTikTok应推单
        ,sum(if(platform_source='Tik Tok' and TYPE='B2C' and OrderPush_type = 'nooutbound', 1, 0)) B2CTikTok未及时推单
        ,sum(if(platform_source='Tik Tok' and TYPE='B2C' and OrderPush_type = 'nopayment_time', 1, 0)) B2CTikTok无付款时间
    FROM dwm.dwd_th_ffm_outbound_dayV2
    where 1=1
        and payment_timeadd3h >= date_sub(date(now() + interval -1 hour),interval 90 day)
        and payment_timeadd3h>='2025-03-25'
    GROUP BY 1,2,3,4

select
    dt
    ,count(delivery_sn) cnt
    ,count(if(buy_time is null ,delivery_sn , null)) null_value
    ,count(if(buy_time is null ,delivery_sn , null)) / count(delivery_sn)
from
(
    select
    delivery_sn
    ,order_source_type
    ,order_from
    ,dt
    ,source
    ,payment_time
    ,buy_time
    ,platform_source
    ,is_tiktok
     ,case when is_tiktok is not null then 'Tik Tok'
        when left(order_sn, 1)='5' then 'Tik Tok'
        when platform_source in ('Tik Tok', 'TikTok') then 'Tik Tok'
        when platform_source in ('Shopee') then 'Shopee'
        when platform_source in ('LAZADA', 'Lazada') then 'LAZADA'
        ELSE 'Other' end as platform_sourcev1
        from
    (
    select
            do.delivery_sn
            ,do.order_source_type
            ,oe.order_from
             ,date(do.`created`) dt
            ,case
                when do.order_source_type = 1 then 'Created - manual'
                when do.order_source_type = 2 then 'Created - batch import'
                when do.order_source_type = 3 and oe.order_from=1000 then 'ERP_COMMON'
                when do.order_source_type = 3 and oe.order_from=1001 then 'ERP_MABANG'
                when do.order_source_type = 3 and oe.order_from=1002 then 'ERP_QIANYI'
                when do.order_source_type = 3 and oe.order_from=1003 then 'ERP_JIJIA'
                when do.order_source_type = 3 and oe.order_from=1004 then 'ERP_JST'
                when do.order_source_type = 3 and oe.order_from=1005 then 'ERP_WDT'
                when do.order_source_type = 3 and oe.order_from=1006 then 'ERP_DXM'
                when do.order_source_type = 3 and oe.order_from=1007 then 'QIMEN'
                when do.order_source_type = 3 then 'Created - API'
                when do.order_source_type = 4 then 'Created - auto'
                when do.order_source_type = 5 then 'Created - AI'
                when do.order_source_type = 6 then 'Created - Push by Tmall'
                when do.order_source_type = 8 then 'Created - Push by LGF'
                when do.order_source_type = 9 then 'Created - Push by PDD'
                end as erp_source
            ,do.payment_time
            ,do.buy_time
            ,if(left(date_add(do.`created`, interval -60 minute), 10) <'2024-10-31', ps.`name`, i18.th) platform_source
            ,wd.id is_tiktok
            ,do.order_sn
        from
            wms_production.delivery_order do
        left join wms_production.order_extra oe on do.id = oe.order_id
        LEFT JOIN `wms_production`.`seller_platform_source` sps on do.`platform_source_id`=sps.`id`
        LEFT JOIN `wms_production`.`platform_source` ps on sps.`platform_source_id`=ps.`id`
        left join wms_production.delivery_order_extra doe on do.id = doe.delivery_order_id
        left join wms_production.i18 on concat('deliveryOrder.salesPlatform.',doe.platform_from) = i18.key
        left join (select delivery_order_id,mark_id from wms_production.`delivery_order_mark_relation` where mark_id in (201, 200)) domr on domr.delivery_order_id = do.id
        left join (select id from wms_production.wordbook_detail where `wordbook_id` = 10 and (zh = 'TT3' or zh='TT')) wd on domr.mark_id=wd.id
        where 1=1
        and do.`created` >= convert_tz(date_sub(date(now() + interval -1 hour),interval 90 day), '+07:00', '+08:00')
    ) t0
) t1
where 1=1
and platform_sourcev1='Tik Tok'
group by dt
order by dt;

select
    *
from
dwm.dwd_th_ffm_outbound_dayV2
where seller_name='Ondemand'
and created_date>='2025-06-15';

select
    warehouse_name

    ,seller_name

    ,dt
     ,concat('WEEK',week(dt)) 周
     ,concat('${week_s}','-','${week_e}') 周区间
     ,sum(B2CTikTok及时交接) B2CTikTok及时交接
	 ,sum(B2CTikTok应交接) B2CTikTok应交接
	 ,sum(B2CTikTok未及时交接) B2CTikTok未及时交接
	 ,sum(B2CTikTok及时交接) / sum(B2CTikTok应交接) 交接及时率
	 ,sum(B2CTikTok及时发货) B2CTikTok及时发货
	 ,sum(B2CTikTok应发货) B2CTikTok应发货
	 ,sum(B2CTikTok未及时发货) B2CTikTok未及时发货
	 ,sum(B2CTikTok及时发货) / sum(B2CTikTok应发货) 发货及时率
	 ,sum(B2CTikTok及时推单) B2CTikTok及时推单
	 ,sum(B2CTikTok应推单) B2CTikTok应推单
	 ,sum(B2CTikTok未及时推单) B2CTikTok未及时推单
	 ,sum(B2CTikTok及时推单) / sum(B2CTikTok应推单) 推单及时率
	 ,sum(B2CTikTok无付款时间) B2CTikTok无付款时间
from dwm.dwm_th_ffm_ttordertimelyout_day
where 1=1
-- and B2CTikTok应交接 + B2CTikTok应发货 + B2CTikTok应推单>0
and dt >= date_sub(date(now() + interval -1 hour),interval 90 day)
and concat('WEEK',week(dt))>='WEEK26'
and concat('WEEK',week(dt))<='WEEK26'
and warehouse_name='BST'
group by 1,2,3
having sum(B2CTikTok应交接) + sum(B2CTikTok应发货) + sum(B2CTikTok应推单)>0
order by dt
;

select *
from dwm.dwm_th_ffm_ttordertimelyout_day
where 1=1
-- and B2CTikTok应交接 + B2CTikTok应发货 + B2CTikTok应推单>0
and dt >= date_sub(date(now() + interval -1 hour),interval 90 day)
and concat('WEEK',week(dt))>='WEEK26'
and concat('WEEK',week(dt))<='WEEK26'
and warehouse_name='BST'
and seller_name='Wu han xia nan yang-武汉下南洋';

SELECT
        LEFT(payment_timeadd3h,10) 日期
        ,warehouse_name
        ,warehouse_detailname
        ,seller_name
        # ,erp_source
        ,'及时推单' 指标
        ,sum(if(platform_source='Tik Tok' and TYPE='B2C' and OrderPush_type = 'intime', 1, 0)) B2CTikTok及时推单
        ,sum(if(platform_source='Tik Tok' and TYPE='B2C' and OrderPush_type in ('intime', 'notintime'), 1, 0)) B2CTikTok应推单
        ,sum(if(platform_source='Tik Tok' and TYPE='B2C' and OrderPush_type = 'nooutbound', 1, 0)) B2CTikTok未及时推单
        ,sum(if(platform_source='Tik Tok' and TYPE='B2C' and OrderPush_type = 'nobuy_time', 1, 0)) B2CTikTok无付款时间
    FROM dwm.dwd_th_ffm_outbound_dayV2
    where 1=1
        and payment_timeadd3h >= '2025-06-29'
        and payment_timeadd3h>='2025-03-25'
        and warehouse_name='BST'
        and seller_name='Wu han xia nan yang-武汉下南洋'
    GROUP BY 1,2,3,4;

select *

    FROM dwm.dwd_th_ffm_outbound_dayV2
    where 1=1
        and date(payment_timeadd3h) = '2025-07-03'
        and warehouse_name='BST'
        and seller_name='Wu han xia nan yang-武汉下南洋'