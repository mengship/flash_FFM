select
    月份,
    人员信息,
    入职日期,
    离职日期,
    dept_1_name,
    dept_2_name,
        dept_3_name,
        dept_4_name,
    职位,
    应出勤,
    出勤,
    迟到,
    旷工,
    年假,
    事假,
    病假,
    产假,
    丧假,
    婚假,
    公司培训假,
    跨国探亲假
from
(
    select
        left(stat_date, 7) 月份,
        staff_info_id 人员信息,
        hire_date 入职日期,
        leave_date 离职日期,
        job_name 职位,
        is_on_job 在职状态,
        dept_1_name,
        dept_2_name,
        dept_3_name,
        dept_4_name,
        sum(fact_required_attend_flag) 应出勤,
        sum(attendance_days) 出勤,
        sum(late_flag) 迟到,
        sum(skipwork_days_wh) 旷工,
        sum(leave_year_days) 年假,
        sum(leave_sth_days) 事假,
        sum(leave_ill_days) 病假,
        sum(leave_born_days) 产假,
        sum(leave_funeral_days) 丧假,
        sum(leave_marry_days) 婚假,
        sum(leave_train_days) 公司培训假,
        sum(leave_family_days) 跨国探亲假
    from
    dwm.dwd_th_ffm_staff_dayV3 OA
    where
    1=1
    -- and dept_2_name='Warehouse Audit'
#     and `dept_1_name` = 'Thailand Fulfillment'
    and left(stat_date, 7)=substr(date_sub(now()+ interval -1 hour,interval 1 month), 1,7)
    and staff_info_id in ('626099', '681076')
    group by
        1,
        2,
        3,
        4,
        5,
        6
) t0
where
1=1
#     and 应出勤 = 出勤
#     and 迟到 <= 0
#     and (
#         在职状态 = 1
#         or 离职日期 >= DATE_ADD(concat(月份, '-01'), interval 1 month)
#     )
#     and 入职日期 <= concat(月份, '-01')
ORDER BY
    应出勤 desc