/*=====================================================================+
表名称：  dim_th_ffm_timeconfig
功能描述：  泰国ffm 仓库+日期+时效 维表

需求来源：
编写人员: wangdongchen
设计日期：2024/11/29
修改日期:
修改人员:
修改原因:

-----------------------------------------------------------------------
---存在问题：
-----------------------------------------------------------------------
+===================================================================== */

-- drop table if exists dwm.dim_th_ffm_timeconfig;
-- create table dwm.dim_th_ffm_timeconfig as
# delete from dwm.dim_th_ffm_timeconfig where dt >= current_date+ interval -1 day; -- 先删除数据
# insert into dwm.dim_th_ffm_timeconfig -- 再插入数据

select
title
,country
,platform_source
,dt
,operation
,case -- 3月
    when operation='出库' and platform_source='Shopee' and dt in ('2025-03-01', '2025-03-02', '2025-03-03', '2025-03-04', '2025-03-05', '2025-03-06') then 1
    when operation='出库' and platform_source='LAZADA' and dt in ('2025-03-02', '2025-03-03', '2025-03-04', '2025-03-05') then 1
    -- 4月
    when operation='交接' and platform_source='Shopee' and dt in ('2025-04-02', '2025-04-03', '2025-04-04', '2025-04-05', '2025-04-06', '2025-04-07') then 1
    when operation='交接' and platform_source='LAZADA' and dt in ('2025-04-03', '2025-04-04', '2025-04-05', '2025-04-06', '2025-04-07') then 1
    when operation='出库' and platform_source='Shopee' and dt in ('2025-04-02', '2025-04-03', '2025-04-04', '2025-04-05', '2025-04-06', '2025-04-07') then 1
    when operation='出库' and platform_source='LAZADA' and dt in ('2025-04-03', '2025-04-04', '2025-04-05', '2025-04-06', '2025-04-07') then 1
    -- 宋干节
    when operation in ('交接', '出库') and platform_source='Shopee' and dt in ('2025-04-12' ,'2025-04-13' ,'2025-04-14' ,'2025-04-15' ,'2025-04-16' ,'2025-04-17') then 1
    when operation in ('交接', '出库') and platform_source='LAZADA' and dt in ('2025-04-12' ,'2025-04-13' ,'2025-04-14' ,'2025-04-15' ,'2025-04-16' ,'2025-04-17') then 1
    else cutoff end cutoff
,case -- 3月
    when operation='出库' and platform_source='Shopee' and dt in ('2025-03-01', '2025-03-02', '2025-03-04', '2025-03-05', '2025-03-06') then 1
    when operation='出库' and platform_source='Shopee' and dt in ('2025-03-03') then 2
    when operation='出库' and platform_source='LAZADA' and dt in ('2025-03-03', '2025-03-04', '2025-03-05') then 2
    when operation='出库' and platform_source='LAZADA' and dt in ('2025-03-02') then 3
    -- 4月 交接
    when operation='交接' and platform_source='Shopee' and dt in ('2025-04-02', '2025-04-03', '2025-04-04', '2025-04-07') then 1
    when operation='交接' and platform_source='Shopee' and dt in ('2025-04-06') then 2
    when operation='交接' and platform_source='Shopee' and dt in ('2025-04-05') then 3
    when operation='交接' and platform_source='LAZADA' and dt in ('2025-04-03', '2025-04-04') then 1
    when operation='交接' and platform_source='LAZADA' and dt in ('2025-04-05', '2025-04-06') then 3
    when operation='交接' and platform_source='LAZADA' and dt in ('2025-04-07') then 2
    -- 4月 出库
    when operation='出库' and platform_source='Shopee' and dt in ('2025-04-02', '2025-04-03', '2025-04-04', '2025-04-07') then 1
    when operation='出库' and platform_source='Shopee' and dt in ('2025-04-06') then 2
    when operation='出库' and platform_source='Shopee' and dt in ('2025-04-05') then 3
    when operation='出库' and platform_source='LAZADA' and dt in ('2025-04-03') then 1
    when operation='出库' and platform_source='LAZADA' and dt in ('2025-04-07') then 3
    when operation='出库' and platform_source='LAZADA' and dt in ('2025-04-04', '2025-04-05', '2025-04-06') then 4
    -- 宋干节 shopee
    when operation in ('交接', '出库') and platform_source='Shopee' and dt in ('2025-04-12') then 5
    when operation in ('交接', '出库') and platform_source='Shopee' and dt in ('2025-04-13') then 4
    when operation in ('交接', '出库') and platform_source='Shopee' and dt in ('2025-04-14') then 3
    when operation in ('交接', '出库') and platform_source='Shopee' and dt in ('2025-04-15') then 2
    when operation in ('交接', '出库') and platform_source='Shopee' and dt in ('2025-04-16', '2025-04-17') then 1
    -- 宋干节 LAZADA 交接
    when operation='交接' and platform_source='LAZADA' and dt in ('2025-04-12', '2025-04-13') then 5
    when operation='交接' and platform_source='LAZADA' and dt in ('2025-04-14') then 5
    when operation='交接' and platform_source='LAZADA' and dt in ('2025-04-15') then 5
    when operation='交接' and platform_source='LAZADA' and dt in ('2025-04-16') then 5
    when operation='交接' and platform_source='LAZADA' and dt in ('2025-04-17') then 5
    -- 宋干节 LAZADA 出库
    when operation='出库' and platform_source='LAZADA' and dt in ('2025-04-12') then 7
    when operation='出库' and platform_source='LAZADA' and dt in ('2025-04-13') then 6
    when operation='出库' and platform_source='LAZADA' and dt in ('2025-04-14') then 5
    when operation='出库' and platform_source='LAZADA' and dt in ('2025-04-15') then 4
    when operation='出库' and platform_source='LAZADA' and dt in ('2025-04-16') then 3
    when operation='出库' and platform_source='LAZADA' and dt in ('2025-04-17') then 2
    else befcutoffday end befcutoffday
,case -- 3月
    when operation='出库' and platform_source='Shopee' and dt in ('2025-03-01', '2025-03-02', '2025-03-03', '2025-03-04', '2025-03-05', '2025-03-06') then '23:59:59'
    when operation='出库' and platform_source='LAZADA' and dt in ('2025-03-02', '2025-03-03', '2025-03-04', '2025-03-05') then '23:59:59'
    -- 4月
    when operation='交接' and platform_source='Shopee' and dt in ('2025-04-02', '2025-04-03', '2025-04-04', '2025-04-05', '2025-04-06', '2025-04-07') then '23:59:59'
    when operation='交接' and platform_source='LAZADA' and dt in ('2025-04-03', '2025-04-04', '2025-04-05', '2025-04-06', '2025-04-07') then '23:59:59'
    when operation='出库' and platform_source='Shopee' and dt in ('2025-04-02', '2025-04-03', '2025-04-04', '2025-04-05', '2025-04-06', '2025-04-07') then '23:59:59'
	when operation='出库' and platform_source='LAZADA' and dt in ('2025-04-03', '2025-04-04', '2025-04-05', '2025-04-06', '2025-04-07') then '23:59:59'
    -- 宋干节
    when operation in ('交接', '出库') and platform_source='Shopee' and dt in ('2025-04-12' ,'2025-04-13' ,'2025-04-14' ,'2025-04-15' ,'2025-04-16' ,'2025-04-17') then '23:59:59'
    when operation in ('交接', '出库') and platform_source='LAZADA' and dt in ('2025-04-12' ,'2025-04-13' ,'2025-04-14' ,'2025-04-15' ,'2025-04-16' ,'2025-04-17') then '23:59:59'
    else befcutofftime end befcutofftime
,aftcutoffday
,aftcutofftime
from
(
    -- 初始化
    -- 出库 2024-12-01以后
    select
    'config' title
    ,t0.country
    ,t0.platform_source
    ,th_dt.dt
    ,t0.operation
    ,t0.cutoff
    ,t0.befcutoffday
    ,t0.befcutofftime
    ,t0.aftcutoffday
    ,t0.aftcutofftime
    from
    (
        select
            'TH' country
            ,'Tik Tok' platform_source
            ,'出库' operation
            ,'18:00:00' cutoff
            ,'0' befcutoffday
            ,'23:59:59' befcutofftime
            ,'1' aftcutoffday
            ,'23:59:59' aftcutofftime
        union
        select
            'TH' country
            ,'Shopee' platform_source
            ,'出库' operation
            ,'16:00:00' cutoff
            ,'0' befcutoffday
            ,'23:59:59' befcutofftime
            ,'1' aftcutoffday
            ,'23:59:59' aftcutofftime
        union
        select
            'TH' country
            ,'LAZADA' platform_source
            ,'出库' operation
            ,'16:00:00' cutoff
            ,'0' befcutoffday
            ,'23:59:59' befcutofftime
            ,'1' aftcutoffday
            ,'23:59:59' aftcutofftime
        union
        select
            'TH' country
            ,'Other' platform_source
            ,'出库' operation
            ,'16:00:00' cutoff
            ,'0' befcutoffday
            ,'23:59:59' befcutofftime
            ,'1' aftcutoffday
            ,'23:59:59' aftcutofftime
    ) t0
    join
    (
        select
            date dt
        from tmpale.ods_th_dim_date
        where 1=1
        and date >= current_date+ interval -1 day
        and date <= current_date+ interval 1 day
    ) th_dt
    on 1=1

    /* union
    -- 出库 2024-12-01以前
    select
        'config'
        ,t0.country
        ,t0.platform_source
        ,th_dt.dt
        ,t0.operation
        ,t0.cutoff
        ,t0.befcutoffday
        ,t0.befcutofftime
        ,t0.aftcutoffday
        ,t0.aftcutofftime
    from
    (
        select
            'TH' country
            ,'Tik Tok' platform_source
            ,'出库' operation
            ,'18:00:00' cutoff
            ,'0' befcutoffday
            ,'23:59:59' befcutofftime
            ,'1' aftcutoffday
            ,'23:59:59' aftcutofftime
        union
        select
            'TH' country
            ,'Shopee' platform_source
            ,'出库' operation
            ,'16:00:00' cutoff
            ,'0' befcutoffday
            ,'23:59:59' befcutofftime
            ,'1' aftcutoffday
            ,'23:59:59' aftcutofftime
        union
        select
            'TH' country
            ,'LAZADA' platform_source
            ,'出库' operation
            ,'0' cutoff
            ,'0' befcutoffday
            ,'0' befcutofftime
            ,'2' aftcutoffday
            ,'0' aftcutofftime
        union
        select
            'TH' country
            ,'Other' platform_source
            ,'出库' operation
            ,'0' cutoff
            ,'0' befcutoffday
            ,'0' befcutofftime
            ,'1' aftcutoffday
            ,'0' aftcutofftime
    ) t0
    join
    (
        select
            date dt
        from tmpale.ods_th_dim_date
        where 1=1
        and date >= current_date+ interval -1 day
        and date <= current_date+ interval 1 day
    ) th_dt
    on 1=1 */
    -- 交接
    union
    select
        'config'
        ,t0.country
        ,t0.platform_source
        ,th_dt.dt
        ,t0.operation
        ,t0.cutoff
        ,t0.befcutoffday
        ,t0.befcutofftime
        ,t0.aftcutoffday
        ,t0.aftcutofftime
    from
    (
        select
            'TH' country
            ,'Tik Tok' platform_source
            ,'交接' operation
            ,'18:00:00' cutoff
            ,'0' befcutoffday
            ,'23:59:59' befcutofftime
            ,'1' aftcutoffday
            ,'23:59:59' aftcutofftime
        union
        select
            'TH' country
            ,'Shopee' platform_source
            ,'交接' operation
            ,'16:00:00' cutoff
            ,'0' befcutoffday
            ,'23:59:59' befcutofftime
            ,'1' aftcutoffday
            ,'23:59:59' aftcutofftime
        union
        select
            'TH' country
            ,'LAZADA' platform_source
            ,'交接' operation
            ,'16:00:00' cutoff
            ,'0' befcutoffday
            ,'23:59:59' befcutofftime
            ,'1' aftcutoffday
            ,'23:59:59' aftcutofftime
        union
        select
            'TH' country
            ,'Other' platform_source
            ,'交接' operation
            ,'16:00:00' cutoff
            ,'0' befcutoffday
            ,'23:59:59' befcutofftime
            ,'1' aftcutoffday
            ,'23:59:59' aftcutofftime
    ) t0
    join
    (
        select
            date dt
        from tmpale.ods_th_dim_date
        where 1=1
        and date >= current_date+ interval -1 day
        and date <= current_date+ interval 1 day
    ) th_dt
    on 1=1
) t0