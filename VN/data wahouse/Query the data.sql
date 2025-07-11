select
    *
from
    dwm.dws_vn_ffm_operateMonitor_day
where 日期>='2025-07-01';

SELECT
    人员信息 staff_info_id
    ,统计日期 stat_date
    ,一级部门 dept_1_name
    ,二级部门 dept_2_name
    ,三级部门 dept_3_name
    ,四级部门 dept_4_name
    ,2Bor2C
    ,部门 dept_name
    ,仓库 warehouse_name
    ,在职 is_on_job
    ,职位类别 job_type
    ,职位 job_name
    ,上班打卡时间  attend_start_time
    ,班次开始  shift_start
    ,下班打卡时间  attend_end_time
    ,班次结束 shift_end
    ,公休日 is_holiday
    ,休息日 is_restday
    ,if(出勤>应出勤, 出勤, 应出勤)  required_attend_flag -- 应出勤
    ,出勤 attendance_days
    --    ,应出勤-请假-旷工 出勤
    -- ,未出勤
    ,if(实际应出勤=0, 0, 请假) leave_days
    -- ,请假时段
    ,if(迟到>0,floor(迟到),0) late_flag -- 迟到
    ,旷工  skipwork_days_wh
    ,if(实际应出勤=0, 0, 年假)  leave_year_days
    ,if(实际应出勤=0, 0, 事假)  leave_sth_days
    ,if(实际应出勤=0, 0, 病假)  leave_ill_days
    ,if(实际应出勤=0, 0, 产假)  leave_born_days
    ,if(实际应出勤=0, 0, 丧假)  leave_funeral_days
    ,if(实际应出勤=0, 0, 婚假)  leave_marry_days
    ,if(实际应出勤=0, 0, 公司培训假) leave_train_days
    ,if(实际应出勤=0, 0, 跨国探亲假) leave_family_days
    ,旷工最晚时间  skipwork_lasttime
    ,job_title_grade_v2
    ,ABS  skipwork_days
    ,应出勤成本 required_attend_cost
    ,加班时长 ot_duration
    -- ,OT类型  ot_type
    ,加班时长10 ot_duration10
    ,加班时长15	ot_duration15
    ,加班时长30 ot_duration30
    ,入职日期 hire_date
    ,离职日期 leave_date
    ,if(出勤>实际应出勤, 出勤, 实际应出勤)   fact_required_attend_flag -- 实际应出勤
    ,wait_leave_state
    ,now() + interval -1 hour update_time
FROM
(
    SELECT
        人员信息
        ,统计日期
        ,一级部门
        ,二级部门
        ,三级部门
        ,四级部门
        ,2Bor2C
        ,部门
        ,仓库
        ,职位类别
        ,职位
        ,在职
        ,上班打卡时间
        ,班次开始
        ,下班打卡时间
        ,班次结束
        ,公休日
        ,休息日
        ,应出勤
        ,出勤
        -- ,未出勤
        ,请假
        ,请假时段
        ,case when 应出勤=1 AND (上班打卡时间 is null or 下班打卡时间 is null) AND 请假=0 then 0
            when 应出勤=1 AND (上班打卡时间 is null or 下班打卡时间 is null) AND 请假=0.5 then 0
            when 应出勤=1 AND 请假=1 then 0
            when 应出勤=1 AND 请假=0.5 AND 请假时段='上午半天假' AND (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(旷工最晚时间))/60<=120 then (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(旷工最晚时间))/60
            when 应出勤=1 AND 请假=0.5 AND 请假时段='上午半天假' AND (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(旷工最晚时间))/60>120 then 0
            when 应出勤=1 AND 请假=0.5 AND 请假时段='下午半天假' AND (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(班次开始))/60<=120 then (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(班次开始))/60
            when 应出勤=1 AND 请假=0.5 AND 请假时段='下午半天假' AND (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(班次开始))/60>120 then 0
            when 应出勤=1 AND 请假=0 AND (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(班次开始))/60<=120 then (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(班次开始))/60
            when 应出勤=1 AND 请假=0 AND (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(班次开始))/60>120 then 0
            when 应出勤=1 AND 请假=0 AND (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(旷工最晚时间))/60>0 then 0
            else 0
            end 迟到
        -- 当天没有上班卡或者下班卡为全天旷工；迟到120分钟内，算作迟到，5泰铢/分钟罚款；迟到超过120分钟，算半天旷工；迟到超过13:00或19:00，算全天旷工
        ,case when 应出勤=1 AND (上班打卡时间 is null or 下班打卡时间 is null) AND 请假=0 then 1
            when 应出勤=1 AND (上班打卡时间 is null or 下班打卡时间 is null) AND 请假=0.5 then 0.5
            when 应出勤=1 AND 请假=1 then 0
            when 应出勤=1 AND 请假=0.5 AND 请假时段='上午半天假' AND (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(旷工最晚时间))/60<=120 then 0
            when 应出勤=1 AND 请假=0.5 AND 请假时段='上午半天假' AND (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(旷工最晚时间))/60>120 then 0.5
            when 应出勤=1 AND 请假=0.5 AND 请假时段='下午半天假' AND (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(班次开始))/60<=120 then 0
            when 应出勤=1 AND 请假=0.5 AND 请假时段='下午半天假' AND (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(班次开始))/60>120 then 0.5
            when 应出勤=1 AND 请假=0 AND (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(班次开始))/60<=120 then 0
            when 应出勤=1 AND 请假=0 AND (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(班次开始))/60>120 then 0.5
            when 应出勤=1 AND 请假=0 AND (UNIX_TIMESTAMP(上班打卡时间)-UNIX_TIMESTAMP(旷工最晚时间))/60>0 then 1
            else 0
            end 旷工
        ,年假
        ,事假
        ,病假
        ,产假
        ,丧假
        ,婚假
        ,公司培训假
        ,跨国探亲假
        ,旷工最晚时间
        ,job_title_grade_v2
        ,ABS
        ,应出勤成本
        ,加班时长
        ,加班时长10
        ,加班时长15
        ,加班时长30
        ,入职日期
        ,离职日期
        ,实际应出勤
        ,wait_leave_state
    FROM
    (
        SELECT
            人员信息
            ,统计日期
            ,一级部门
            ,二级部门
            ,三级部门
            ,四级部门
            ,2Bor2C
            ,部门
            ,仓库
            ,职位类别
            ,职位
            ,在职
            ,上班打卡时间
            ,班次开始
            ,下班打卡时间
            ,班次结束
            ,公休日
            ,休息日
            ,应出勤
            ,出勤
            ,未出勤
            ,请假
            ,请假时段
            ,年假
            ,事假
            ,病假
            ,产假
            ,丧假
            ,婚假
            ,公司培训假
            ,跨国探亲假
            ,concat(统计日期,' ',旷工最晚时间,':','00' ) 旷工最晚时间
            ,job_title_grade_v2
            ,ABS
            ,应出勤成本
            ,加班时长
            ,加班时长10
            ,加班时长15
            ,加班时长30
            ,入职日期
            ,离职日期
            ,实际应出勤
            ,wait_leave_state
        FROM
        (
            SELECT
                人员信息
                ,统计日期
                ,一级部门
                ,二级部门
                ,三级部门
                ,四级部门
                ,2Bor2C
                ,部门
                ,仓库
                ,职位类别
                ,职位
                ,在职
                ,上班打卡时间
                ,班次开始
                ,下班打卡时间
                ,班次结束
                ,公休日
                ,休息日
                ,if(应出勤>0 and 病假<=0 and 请假>0, 1-请假, 应出勤) 应出勤
                ,应出勤 实际应出勤
                ,出勤
                -- ,if(应出勤>0 and 事假>0 and 请假>0, 1-事假, 应出勤) 应出勤成本
                ,case when 应出勤>0 and 事假>0 and ABS >0 and 请假>0 then 1-事假-ABS -- 请事假，公司没有成本，事假以外的公司需要支付薪水，比如请半天事假
                    when 应出勤>0 and ABS >0 then 1-ABS -- 旷工，公司会少发工资，若旷工半天，另外半天公司需要支付薪水
                    when 应出勤>0 and 事假>0 then 1-事假
                    else 应出勤
                    end as 应出勤成本
                ,未出勤
                ,请假
                ,请假时段
                ,年假
                ,事假
                ,病假
                ,产假
                ,丧假
                ,婚假
                ,公司培训假
                ,跨国探亲假
                ,if(shift_start<'12:00','13:00','19:00') 旷工最晚时间
                ,job_title_grade_v2
                ,ABS
                ,加班时长
                ,加班时长10
                ,加班时长15
                ,加班时长30
                ,入职日期
                ,离职日期
                ,wait_leave_state
            FROM
            (
                SELECT
                    ad.`staff_info_id` 人员信息
                    ,ad.`stat_date` 统计日期
                    ,sd.`一级部门` 一级部门
                    ,sd.`二级部门` 二级部门
                    ,sd.三级部门
                    ,sd.四级部门
                    ,if(left(sd.三级部门, 3)='Out' and left(sd.四级部门, 3)='B2B', 'B2B', 'B2C') 2Bor2C
                    ,sd.`name` 部门
                    ,case when 三级部门 in ('GLK Warehouse') then 'GLK'
                                when 三级部门='CCK Warehouse' then 'CCK'
                                end 仓库
                    ,case
                        when left(sd.三级部门,4)='Pack' then 'Packing'
                        when left(sd.三级部门,4)='Pick' then 'Picking'
                        when left(sd.三级部门,3)='Out' then 'Outbound'
                        when left(sd.三级部门,3)='Inb' then 'Inbound'
                        when left(sd.三级部门,3)='B2B' then 'B2B'
                        else 'HO'
                        end 职位类别
                    ,hjt.`job_name` 职位
                    ,case when ad.state='1' then 1 else 0 end  在职
                    ,ad.`shift_start`
                    ,ad.`shift_end`
                    ,ad.`attendance_started_at` as 上班打卡时间
                    ,if(ad.`shift_start`<>'',concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ),null) as 班次开始
                    ,ad.`attendance_end_at` as 下班打卡时间
                    ,if(ad.`shift_end`<>'',concat(ad.`stat_date`,' ',ad.`shift_end`,':','00' ),null) as 班次结束
                    -- ,if
                    -- ,UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP((ad.`shift_start`<>'',concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ),null) )
                    -- ,ad.leave_type
                    ,case ad.leave_time_type when 1 then '上午半天'
                        when 2 then '下午半天'
                        when 3 then '全天'
                        end 请假时段
                    ,ad.attendance_time
                    -- ,ad.`AB`
                    ,if(ad.PH!=0,1,0) 公休日
                    ,if(ad.OFF!=0,1,0) 休息日
                    -- ,if(ad.PH=0 AND ad.OFF=0,1,0) 应出勤
                    -- ,CASE WHEN  ad.`attendance_started_at` IS NOT NULL THEN 1 ELSE 0 END 出勤
                    ,case when ad.PH=0 AND ad.OFF=0 then 1 # 当 ph=0 off=0 为当天应该出勤一天
                    when ad.PH=5 then 0.5 # 当 ph=5 或 off=0.5 应出勤半天
                    when ad.OFF=5 then 0.5
                    else 0 end as 应出勤
                    ,case
                        when (ad.attendance_time=0) and (ad.bt=0) then 0 # 正常考勤 和 出差都为 0，才是没有出勤
                        when (ad.attendance_time=5) or (ad.bt=5) then 0.5
                        when (ad.attendance_time=10) or (ad.bt=10) then 1
                        else 0
                    end 出勤
                    -- ,if(ad.PH=0 AND ad.OFF=0 AND ad.attendance_time=0,1,0) 未出勤天数
                    ,case when ad.PH=0 AND ad.OFF=0 AND ad.attendance_time=0 then 1
                        when ad.PH=0 AND ad.OFF=0 AND ad.attendance_time=5 then 0.5
                        when ad.PH=0 AND ad.OFF=0 AND ad.attendance_time=10 then 0
                        end 未出勤
                    ,ad.`AB`
                    ,case when ad.PH=0 AND ad.OFF=0
                            AND (ad.`attendance_started_at` is null or ad.`attendance_end_at` is null)
                            AND ad.leave_type not in (1,2,12,3,18,4,5,17,7,10,16,19) then 1
                        when ad.PH=0 AND ad.OFF=0
                            AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))>0
                            AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))<=30  then 0
                        when ad.PH=0 AND ad.OFF=0
                            AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))>30
                            AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))<=(UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_end`,':','00' ))-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' )))/2  then 0.5
                        -- when ad.PH=0 AND ad.OFF=0
                        --  AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))>240 then 1
                        when ad.PH=0 AND ad.OFF=0
                            AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))>(UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_end`,':','00' ))-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' )))/2 then 1
                        else 0
                        end 旷工
                    ,case when ad.`AB`=10 then 1 when ad.`AB`=5 then 0.5 else 0 end as ABS
                    ,case when ad.leave_type in (1,2,12,3,18,4,5,17,7,10,16,19) AND ad.leave_time_type=1 then 0.5
                        when ad.leave_type in (1,2,12,3,18,4,5,17,7,10,16,19) AND ad.leave_time_type=2 then 0.5
                        when ad.leave_type in (1,2,12,3,18,4,5,17,7,10,16,19) AND ad.leave_time_type=3 then 1
                        else 0
                        end 请假
                    ,case
                        when ad.leave_type=1 and ad.leave_time_type=1 then 0.5
                        when ad.leave_type=1 and ad.leave_time_type=2 then 0.5
                        when ad.leave_type=1 and ad.leave_time_type=3 then 1
                        else 0
                        end 年假
                    ,case
                        -- 带薪,不带薪事假
                        when ad.leave_type in (2,12) and ad.leave_time_type=1 then 0.5
                        when ad.leave_type in (2,12) and ad.leave_time_type=2 then 0.5
                        when ad.leave_type in (2,12) and ad.leave_time_type=3 then 1
                        else 0
                        end 事假
                    ,case
                        -- 带薪,不带薪病假
                        when ad.leave_type in (3,18) and ad.leave_time_type=1 then 0.5
                        when ad.leave_type in (3,18) and ad.leave_time_type=2 then 0.5
                        when ad.leave_type in (3,18) and ad.leave_time_type=3 then 1
                        else 0
                        end 病假
                    ,case
                        -- 产假,陪产假,产检
                        when ad.leave_type in (4,5,17) and ad.leave_time_type=1 then 0.5
                        when ad.leave_type in (4,5,17) and ad.leave_time_type=2 then 0.5
                        when ad.leave_type in (4,5,17) and ad.leave_time_type=3 then 1
                        else 0
                        end 产假
                    ,case
                        when ad.leave_type=7 and ad.leave_time_type=1 then 0.5
                        when ad.leave_type=7 and ad.leave_time_type=2 then 0.5
                        when ad.leave_type=7 and ad.leave_time_type=3 then 1
                        else 0
                        end 丧假
                    ,case
                        when ad.leave_type=10 and ad.leave_time_type=1 then 0.5
                        when ad.leave_type=10 and ad.leave_time_type=2 then 0.5
                        when ad.leave_type=10 and ad.leave_time_type=3 then 1
                        else 0
                        end 婚假
                    ,case
                        when ad.leave_type=16 and ad.leave_time_type=1 then 0.5
                        when ad.leave_type=16 and ad.leave_time_type=2 then 0.5
                        when ad.leave_type=16 and ad.leave_time_type=3 then 1
                        else 0
                        end 公司培训假
                    ,case
                        when ad.leave_type=19 and ad.leave_time_type=1 then 0.5
                        when ad.leave_type=19 and ad.leave_time_type=2 then 0.5
                        when ad.leave_type=19 and ad.leave_time_type=3 then 1
                        else 0
                        end 跨国探亲假
                    ,REPLACE(JSON_EXTRACT(hst.extend, '$.job_title_grade_v2'), '"', '') job_title_grade_v2
                    ,ot.加班时长
                    ,ot.加班时长10
                    ,ot.加班时长15
                    ,ot.加班时长30
                    ,si.hire_date 入职日期
                    ,si.leave_date 离职日期
                    ,hst.wait_leave_state -- 20241211 addby 王昱棋 待离职状态 1 为是，0为否，hcm页面上要把待离职的过滤掉，与hcm保持一致
                FROM `vn_bi`.`attendance_data_v2` ad
                LEFT JOIN `vn_staging`.`staff_info` si on si.`id` =ad.`staff_info_id`
                LEFT JOIN `vn_staging`.`sys_store` ss on ss.`id` =si.`organization_id`
                LEFT JOIN `vn_bi`.`hr_job_title` hjt on hjt.`id` =si.`job_title`
                left join vn_bi.hr_staff_transfer hst on ad.staff_info_id = hst.staff_info_id and ad.`stat_date` = hst.stat_date
                LEFT JOIN `dwm`.`dwd_hr_organizational_structure_detail` sd ON sd.`id`=hst.`node_department_id` -- 20241211 addby 王昱棋 取历史的部门（仓库）
                LEFT JOIN `vn_staging`.`sys_store` ss2 ON ss2.`id`=hst.`store_id` -- 20241211 addby 王昱棋 取历史的部门（仓库）
                left join
                (
                    select
                        申请日期
                        ,员工ID
                        ,sum(加班时长) 加班时长
                        ,sum(if(OT类型=1, 加班时长, 0)) 加班时长10
                        ,sum(if(OT类型=1.5, 加班时长, 0)) 加班时长15
                        ,sum(if(OT类型=3, 加班时长, 0)) 加班时长30
                    from
                    (
                        SELECT
                            ho.date_at 申请日期
                            ,ho.staff_id 员工ID
                            ,hsi.name 员工姓名
                            ,CASE hsi.state
                                    when 1 then '在职'
                                    when 2 then '离职'
                                    when 3 then '停职'
                                    else ht.state
                            end 在职状态
                            ,case when 二级部门 in ('GLK Warehouse') then 'GLK'
                                when 二级部门='CCK Warehouse' then 'CCK'
                                end 仓库
                            ,case
                                when left(三级部门,4)='Pack' then 'Packing'
                                when left(三级部门,4)='Pick' then 'Picking'
                                when left(三级部门,3)='Out' then 'Outbound'
                                when left(三级部门,3)='Inb' then 'Inbound'
                                    else 'HO'
                                end 职位类别
                            ,hjt.job_name 职位
                            ,sd2.name 部门
                            ,sd.一级部门
                            ,sd.二级部门
                            ,sd.三级部门
                            ,sd.四级部门
                            ,if(hsi.sys_store_id ='-1','Head Office',ss.name) 网点
                            ,CASE ho.`type`
                                    when 1 then 1.5
                                    when 2 then 3
                                    when 4 then 1
                                    ELSE 0
                            end OT类型
                            ,ho.start_time 开始时间
                            ,ho.end_time 结束时间
                            ,ho.duration 加班时长
                            ,o.day_of_week 周几
                            ,o.week_begin_date 周最早日期
                            ,o.week_end_date 周最晚日期
                            ,CASE when ho.`type` =4 and adv.times1 >0 then '是'
                                    when ho.`type` =1 and adv.times1_5 >0 then '是'
                                    when ho.`type` =2 and adv.times3 >0 then '是'
                                    ELSE '否'
                            END  是否给加班费
                        FROM vn_backyard.hr_overtime ho
                        LEFT JOIN vn_bi.hr_staff_info hsi on ho.staff_id =hsi.staff_info_id
                        LEFT JOIN vn_bi.hr_staff_transfer ht on ho.staff_id =ht.staff_info_id and ho.date_at =ht.stat_date
                        left join vn_staging.sys_department sd2 on sd2.id =hsi.node_department_id
                        left join vn_staging.sys_store ss on ss.id =hsi.sys_store_id
                        left join dwm.dwd_hr_organizational_structure_detail sd  on sd.id =ht.node_department_id  -- 20241211 addby 王昱棋 取历史的部门（仓库）
                        left join vn_bi.hr_job_title hjt on hjt.id =hsi.job_title
                        left join tmpale.ods_vn_dim_date o on o.`date` =ho.date_at
                        left join vn_bi.attendance_data_v2 adv on adv.stat_date =ho.date_at and adv.staff_info_id =ho.staff_id
                        WHERE ho.state =2 -- 审核通过
                        and ho.date_at >= '2023-12-01'
                        and sd.一级部门='Vietnam Fulfillment'
                        and ho.date_at >= date_sub(date(now() + interval -1 hour),interval 30 day)
                        -- and ho.staff_id='609471'
                    ) ot1
                    group by 1,2
                ) ot on ad.`staff_info_id` = ot.员工ID and ad.stat_date = ot.申请日期
                WHERE 1=1
#                     and sd.`一级部门`='Vietnam Fulfillment'
                    AND ad.`stat_date`>= date_sub(date(now() + interval -1 hour),interval 30 day)
                    AND ad.`stat_date`>='2025-07-07'
                    AND ad.`stat_date`<='2025-07-09'
            ) ad
        ) ad
    ) ad
) ad;


select
    *
from
`dwm`.`dwd_hr_organizational_structure_detail`;

select
    *
from
vn_bi.hr_staff_transfer hst
    where
stat_date='2025-07-08';


