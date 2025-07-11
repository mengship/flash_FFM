-- 配置文件在was下面执行
-- AGV_June_Commission
select
    物理仓,
    工号,
    部门,
    分组,
    出勤,
    Inbound,
    Picking,
    Packing,
    Outbound,
    B2B,
    计提工作量,
    基础提成,
    提成,
    业务罚款,
    现场管理罚款,
    考勤罚款,
    全勤奖,
    奖励,
    ifnull(应发提成, 0) 应发提成,
    迟到,
    迟到v2,
    旷工,
    sd.skipwork_days 旷工v2,
    年假,
    事假,
    病假,
    产假,
    丧假,
    婚假,
    公司培训假,
    NSC,
    ifnull(NSC_commission, 0) NSC_commission,
    ifnull(应发提成, 0) + ifnull(NSC_commission, 0) 应发提成add_nsc
from
    dwm.dwd_th_ffm_commission_five f
left join
(
    select
        人员信息
        ,sum(迟到v2) 迟到v2
    from
        dwm.dwd_th_ffm_attendance_detail1
    where 统计日期 >=date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
    and 统计日期 <=date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
    group by 人员信息
) iidk on f.工号 = iidk.人员信息
left join
(
    select
        staff_info_id
        ,sum(skipwork_days) skipwork_days
    from
        dwm.dwd_th_ffm_staff_dayV3
    where stat_date >=date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
    and stat_date <=date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
    group by staff_info_id
) sd on f.工号 = sd.staff_info_id
left join
(
    select
        left(stat_date, 7) month
        ,staff_info_id
        ,count(stat_date) NSC
        ,count(stat_date)*70 NSC_commission
    from
    (
        select
            stat_date
            ,staff_info_id
            ,shift_start
            ,shift_end
            ,attend_start_time
            ,attend_end_time
        from
        dwm.dwd_th_ffm_staff_dayV3
        where 1=1
        and stat_date>='2025-06-18'
        and warehouse_name='AGV'
        and right(shift_start, 8)='20:00:00'
        and right(shift_end, 8)='05:00:00'
        and  stat_date >=date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
        and stat_date <=date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
        and attend_start_time is not null
        order by stat_date, staff_info_id
    ) t0
    group by left(stat_date, 7), staff_info_id
) t1 on f.工号 = t1.staff_info_id
where
    物理仓 = 'AGV'
order by
    物理仓,
    部门,
    分组;


-- 夜班
select
    left(stat_date, 7) month
    ,staff_info_id
    ,count(stat_date) NSC
    ,count(stat_date)*70 NSC_commission
from
(
    select
        stat_date
        ,staff_info_id
        ,shift_start
        ,shift_end
        ,attend_start_time
        ,attend_end_time
    from
    dwm.dwd_th_ffm_staff_dayV3
    where 1=1
    and stat_date>='2025-06-18'
    and warehouse_name='AGV'
    and right(shift_start, 8)='20:00:00'
    and right(shift_end, 8)='05:00:00'
    and  stat_date >=date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
    and stat_date <=date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
    and attend_start_time is not null
    order by stat_date, staff_info_id
) t0
group by left(stat_date, 7), staff_info_id




;
select * from  dwm.dwd_th_ffm_commission_four where 物理仓='AGV'
and 工号 in (
'607281',
'679056',
'707241',
'69102',
'86970',
'716394'
        );

select * from  dwm.dwd_th_ffm_commission_three where 物理仓='AGV'
and 工号 in (
'607281',
'679056',
'707241',
'69102',
'86970',
'716394'
        )