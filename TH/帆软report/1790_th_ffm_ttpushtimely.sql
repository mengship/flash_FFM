select
    warehouse_name
    ,warehouse_detailname
    ,seller_name
    ,dt
     ,concat('WEEK',week(dt)) 周
     ,concat('${week_s}','-','${week_e}') 周区间
    ,B2CTikTok及时交接
    ,B2CTikTok应交接
    ,B2CTikTok未及时交接
    ,B2CTikTok及时交接 / B2CTikTok应交接 交接及时率
    ,B2CTikTok及时发货
    ,B2CTikTok应发货
    ,B2CTikTok未及时发货
    ,B2CTikTok及时发货 / B2CTikTok应发货 发货及时率
    ,B2CTikTok及时推单
    ,B2CTikTok应推单
    ,B2CTikTok未及时推单
    ,B2CTikTok及时推单 / B2CTikTok应推单 推单及时率
    ,B2CTikTok无付款时间
from dwm.dwm_th_ffm_ttordertimelyout_day
where 1=1
-- and B2CTikTok应交接 + B2CTikTok应发货 + B2CTikTok应推单>0
and dt >= date_sub(date(now() + interval -1 hour),interval 90 day)
# and concat('WEEK',week(dt))>='${week_s}'
# and concat('WEEK',week(dt))<='${week_e}'
    and concat('WEEK',week(dt))>='WEEK26'
and concat('WEEK',week(dt))<='WEEK26'
and warehouse_name='BST'
and seller_name='Weida-维达'
# and seller_name='dahanchao（大汉朝）'
# ${if(len(warehouse_name) == 0,"","and warehouse_name in ('" + warehouse_name + "')")}
order by dt
;


select
    warehouse_name
    # ,warehouse_detailname
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
# and dt >= date_sub(date(now() + interval -1 hour),interval 90 day)
# and concat('WEEK',week(dt))>='${week_s}'
# and concat('WEEK',week(dt))<='${week_e}'
# ${if(len(warehouse_name) == 0,"","and warehouse_name in ('" + warehouse_name + "')")}
group by 1,2,3
order by dt