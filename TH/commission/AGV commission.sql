-- 配置文件在was下面执行
-- AGV_May_Commission
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
    应发提成,
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
    公司培训假
from
    dwm.dwd_th_ffm_commission_five f
left join
(
    select
        人员信息
        ,sum(迟到v2) 迟到v2
    from
        dwm.dwd_th_ffm_attendance_detail1
    where 统计日期 >='2025-05-01'
    and 统计日期 <'2025-06-01'
    group by 人员信息
) iidk on f.工号 = iidk.人员信息
left join
(
    select
        staff_info_id
        ,sum(skipwork_days) skipwork_days
    from
        dwm.dwd_th_ffm_staff_dayV3
    where stat_date >='2025-05-01'
    and stat_date <'2025-06-01'
    group by staff_info_id
) sd on f.工号 = sd.staff_info_id
where
    物理仓 = 'AGV'
order by
    物理仓,
    部门,
    分组;

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