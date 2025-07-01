        /*=====================================================================+
        表名称：  dim_th_default_timeV2
        功能描述：  泰国节假日顺延表

        需求来源：
        编写人员: wangdongchen
        设计日期：2024/8/22
      	修改日期:
      	修改人员:
      	修改原因:

      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +===================================================================== */


-- drop table if exists dwm.dim_th_default_timeV2;
-- create table dwm.dim_th_default_timeV2 as
-- ALTER TABLE dwm.dim_th_default_timeV2 ADD COLUMN date5 varchar(64) DEFAULT NULL COMMENT 'date5' AFTER date4;
-- ALTER TABLE dwm.dim_th_default_timeV2 ADD COLUMN date6 varchar(64) DEFAULT NULL COMMENT 'date6' AFTER date5;
-- ALTER TABLE dwm.dim_th_default_timeV2 ADD COLUMN date7 varchar(64) DEFAULT NULL COMMENT 'date7' AFTER date6;
# REPLACE into dwm.dim_th_default_timeV2 -- 再插入数据
select
    created
    ,if_day_off
    ,case when if_day_off ='是' then date else date0 end created_mod
    ,case when if_day_off ='是' then date1 else date end date1
    ,case when if_day_off ='是' then date2 else date1 end date2
    ,case when if_day_off ='是' then date3 else date2 end date3
    ,case when if_day_off ='是' then date4 else date3 end date4
    ,case when if_day_off ='是' then date5 else date4 end date5
    ,case when if_day_off ='是' then date6 else date5 end date6
    ,case when if_day_off ='是' then date7 else date6 end date7
from
(
    select
        calendar.date created
        ,case when off_date is not null then '是' else '否' end if_day_off
        ,date0
        ,workdate.date date
        ,date1
        ,date2
        ,date3
        ,date4
        ,date5
        ,date6
        ,date7
    from
    -- 日历
    (
        select
            date
        from
        tmpale.ods_th_dim_date
        where date between date_sub(date(now() + interval -1 hour),interval 360 day) and date_add(date(now() + interval -1 hour), interval 360 day)
    ) calendar
    left join
    -- 假日表
    (
        select
            if(off_date='2025-05-12', '2025-05-11', off_date) off_date
        from
        fle_staging.sys_holiday
        where deleted = 0
            and company_category='2'
            and off_date between date_sub(date(now() + interval -1 hour),interval 360 day) and date_add(date(now() + interval -1 hour), interval 360 day)
        group by off_date
    ) offdate on calendar.date=off_date
    left join
    -- 仓库工作日表（date为工作日，date0上一个工作日，date1为下一个工作日，date2为下下一个工作日...）
    (
        select
            lag(date,1)over(order by date)date0
            ,date
            ,lead(date,1)over(order by date)date1
            ,lead(date,2)over(order by date)date2
            ,lead(date,3)over(order by date)date3
            ,lead(date,4)over(order by date)date4
            ,lead(date,5)over(order by date)date5
            ,lead(date,6)over(order by date)date6
            ,lead(date,7)over(order by date)date7
        from
        (
            select
                date
            from
            tmpale.ods_th_dim_date
            where date between date_sub(date(now() + interval -1 hour),interval 360 day) and date_add(date(now() + interval -1 hour), interval 360 day)
        ) d0
        left join
        (
            select
                if(off_date='2025-05-12', '2025-05-11', off_date) off_date
            from
            fle_staging.sys_holiday
            where deleted = 0
                and company_category='2'
                and off_date between date_sub(date(now() + interval -1 hour),interval 360 day) and date_add(date(now() + interval -1 hour), interval 360 day)
            group by off_date
        )t0 on date=off_date
        where off_date is null
    )workdate on calendar.date>=workdate.date0 and calendar.date<workdate.date
    where date0 is not null
) tca
order by created;

show create table dwm.dim_th_default_timeV2