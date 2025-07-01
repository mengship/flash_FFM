
/*=====================================================================+
表名称：  dwm_th_ffm_ttordertimelyout_day
功能描述：泰国发货单 tt时效 情况

需求来源：
编写人员: 王昱棋
设计日期：2025/04/29
        修改日期:
        修改人员:
        修改原因:
-----------------------------------------------------------------------
---存在问题：
-----------------------------------------------------------------------
+=====================================================================*/

# -- drop table if exists dwm.dwm_th_ffm_ttordertimelyout_day;
# -- create table dwm.dwm_th_ffm_ttordertimelyout_day as
# delete from dwm.dwm_th_ffm_ttordertimelyout_day where dt >= date_sub(date(now() + interval -1 hour),interval 90 day); -- 先删除数据
# insert into dwm.dwm_th_ffm_ttordertimelyout_day -- 再插入数据
select
    dt.warehouse_name
    ,dt.warehouse_detailname
    ,dt.seller_name
    ,dt.dt

    ,hand.B2CTikTok及时交接
    ,hand.B2CTikTok应交接
    ,hand.B2CTikTok未及时交接

    ,out.B2CTikTok及时发货
    ,out.B2CTikTok应发货
    ,out.B2CTikTok未及时发货

    ,push.B2CTikTok及时推单
    ,push.B2CTikTok应推单
    ,push.B2CTikTok未及时推单
    ,push.B2CTikTok无付款时间
from
(
    select
     	dt
     	,warehouse_name
        ,warehouse_detailname
        ,seller_name
	 from dwm.dim_th_ffm_warehousedetailseller_day
    where 1=1
    and dt >= date_sub(date(now() + interval -1 hour),interval 90 day)
    and dt >='2025-04-01'
) dt
left join -- 交接时效
(
   SELECT
        LEFT(2Chand_deadline,10) 日期
        ,warehouse_name
        ,warehouse_detailname
        ,seller_name
        ,'及时交接' 指标
        ,sum(if(platform_source='Tik Tok' and TYPE='B2C' and handtimetype = 'hand intime', 1, 0)) B2CTikTok及时交接
        ,sum(if(platform_source='Tik Tok' and TYPE='B2C' and handtimetype in ('hand intime','nohand intime'), 1, 0)) B2CTikTok应交接
        ,sum(if(platform_source='Tik Tok' and TYPE='B2C' and handtimetype = 'nohand intime', 1, 0)) B2CTikTok未及时交接
    FROM dwm.dwd_th_ffm_outbound_dayV2
    where 1=1
        and 2Chand_deadline >= date_sub(date(now() + interval -1 hour),interval 90 day)
    GROUP BY 1,2,3,4
) hand on dt.warehouse_detailname = hand.warehouse_detailname and dt.dt = hand.日期 and dt.seller_name = hand.seller_name
left join -- 发货时效
(
    SELECT
        LEFT(2Cdeadline,10) 日期
        ,warehouse_name
        ,warehouse_detailname
        ,seller_name
        ,'及时发货' 指标
        ,sum(if(platform_source='Tik Tok' and TYPE='B2C' and outtimetype = 'outbound intime', 1, 0)) B2CTikTok及时发货
        ,sum(if(platform_source='Tik Tok' and TYPE='B2C' and outtimetype in ('nooutbound intime', 'outbound intime'), 1, 0)) B2CTikTok应发货
        ,sum(if(platform_source='Tik Tok' and TYPE='B2C' and outtimetype = 'nooutbound intime', 1, 0)) B2CTikTok未及时发货
    FROM dwm.dwd_th_ffm_outbound_dayV2
    where 1=1
        and 2Cdeadline >= date_sub(date(now() + interval -1 hour),interval 90 day)
    GROUP BY 1,2,3,4
) `out` on dt.warehouse_detailname = out.warehouse_detailname and dt.dt = out.日期 and dt.seller_name = out.seller_name
left join -- 推单时效
(
    SELECT
        LEFT(created_date,10) 日期
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
        and created_date >= date_sub(date(now() + interval -1 hour),interval 90 day)
        and created_date>='2025-03-25'
    GROUP BY 1,2,3,4
) `push` on dt.warehouse_detailname = push.warehouse_detailname and dt.dt = push.日期 and dt.seller_name = push.seller_name
# where dt.warehouse_detailname='AGV-人工仓'
;


desc dwm.dwd_th_ffm_outbound_dayV2;
select * from dwm.dwd_th_ffm_outbound_dayV2 order by 2Cdeadline desc;

desc dwm.dwm_th_ffm_ttordertimelyout_day;
select
    warehouse_name
    ,warehouse_detailname
    ,seller_name
    ,dt
    ,B2CTikTok及时交接
    ,B2CTikTok应交接
    ,B2CTikTok未及时交接
    ,B2CTikTok及时发货
    ,B2CTikTok应发货
    ,B2CTikTok未及时发货
    ,B2CTikTok及时推单
    ,B2CTikTok应推单
    ,B2CTikTok未及时推单
    ,B2CTikTok无付款时间
from dwm.dwm_th_ffm_ttordertimelyout_day