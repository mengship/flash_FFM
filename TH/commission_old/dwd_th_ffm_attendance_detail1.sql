/*=====================================================================+
        表名称：  dwm.dwd_th_ffm_attendance_detail1
        功能描述：
        需求来源：
        编写人员:
        设计日期：
        修改日期:
        修改人员:
        修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================*/
# drop table if exists dwm.dwd_th_ffm_attendance_detail1;
# create table dwm.dwd_th_ffm_attendance_detail1 as
-- delete from dwm.dwd_th_ffm_attendance_detail where left(统计日期,7)=left(date(date_add(now(), interval -60 minute)),7);
-- insert into dwm.dwd_th_ffm_attendance_detail
SELECT
    人员信息
    ,统计日期
    ,一级部门
    ,部门
    ,仓库
    ,职位类别
    ,职位
    ,上班打卡时间
    ,班次开始
    ,下班打卡时间
    ,班次结束
    ,公休日
    ,休息日
    ,应出勤
    ,出勤
    -- ,应出勤-请假-旷工 出勤
    -- ,未出勤
    ,if(应出勤=0, 0, 请假) 请假
    -- ,请假时段
    ,if(迟到>0,floor(迟到),0) 迟到
    ,旷工
    ,if(应出勤=0, 0, 年假) 年假
    ,if(应出勤=0, 0, 事假) 事假
    ,if(应出勤=0, 0, 病假) 病假
    ,if(应出勤=0, 0, 产假) 产假
    ,if(应出勤=0, 0, 丧假) 丧假
    ,if(应出勤=0, 0, 婚假) 婚假
    ,if(应出勤=0, 0, 公司培训假) 公司培训假
    ,if(应出勤=0, 0, 跨国探亲假) 跨国探亲假
    ,旷工最晚时间
    ,now() + interval -1 hour update_time
FROM
    (
    SELECT
        人员信息
        ,统计日期
        ,一级部门
        ,部门
        ,仓库
        ,职位类别
        ,职位
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
    FROM
        (
        SELECT
            人员信息
            ,统计日期
            ,一级部门
            ,部门
            ,仓库
            ,职位类别
            ,职位
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
        FROM
            (
            SELECT
                人员信息
                ,统计日期
                ,一级部门
                ,部门
                ,仓库
                ,职位类别
                ,职位
                ,上班打卡时间
                ,班次开始
                ,下班打卡时间
                ,班次结束
                ,公休日
                ,休息日
                -- ,if(应出勤>0 and 病假<=0 and 请假>0, 1-请假, 应出勤) 应出勤
                -- ,应出勤
                ,if(出勤>应出勤, 出勤, 应出勤) 应出勤
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
                ,if(shift_start<'12:00','13:00','19:00') 旷工最晚时间
            FROM
                (
                SELECT
                    ad.`staff_info_id` 人员信息
                    ,ad.`stat_date` 统计日期
                    ,sd.`一级部门` 一级部门
                    ,sd.`name` 部门
                    ,case when 二级部门='AGV Warehouse' then 'AGV'
                        when 二级部门='BPL2-Bangphli Return Warehouse' then 'BPL-Return'
                        when 二级部门='Bangphli Livestream Warehouse' then 'BPL3'
                        when 二级部门='BST-Bang Sao Thong Warehouse' then 'BST'
                        when 二级部门='LAS-Lasalle Material Warehouse' then 'LAS'
                    end 仓库
                    ,case
                        when 三级部门 in ('Packing (AGV)','Packaging (LAS-Lasalle Material)','Packing (Bangphli Livestream)','Packing (BST-Bang Sao Thong)','Packing (BPL2)') then 'Packing'
                        when 三级部门 in ('Picking (BPL2)','Picking (BST-Bang Sao Thong)','Picking (AGV)','Picking (Bangphli Livestream)','Picking (LAS-Lasalle Material)') then 'Picking'
                        when 三级部门 in ('Outbound (Bangphli Livestream)','Outbound (AGV)','Outbound (BST-Bang Sao Thong)') then 'Outbound'
                        when 三级部门 in ('Inbound (BST-Bang Sao Thong)','Inbound (Bangphli Livestream)','Inbound (AGV)','Inbound (BPL2)','Inbound (LAS-Lasalle Material)') then 'Inbound'
                        when 三级部门 in ('B2B (BST-Bang Sao Thong)') then 'B2B'
                        else 'HO'
                    end 职位类别
                    ,hjt.`job_name` 职位
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
                    -- ,if(ad.PH=0 AND ad.OFF=0 AND ad.attendance_time>0,1,0) 出勤天数
                    -- ,case when ad.PH=0 AND ad.OFF=0 AND ad.attendance_time=0 then 0
                    --     when ad.PH=0 AND ad.OFF=0 AND ad.attendance_time=5 then 0.5
                    --     when ad.PH=0 AND ad.OFF=0 AND ad.attendance_time=10 then 1
                    --     end 出勤
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
                    -- ,UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' )) 迟到分钟
                    -- ,case when ad.PH=0 AND ad.OFF=0
                    --      AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))>0
                    --      AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))<=30 then UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))
                    --      else 0
                    --      end 迟到分钟
                    -- ,UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_end`,':','00' ))-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' )) 班次时长
                    -- 当天没有上班卡或者下班卡为全天旷工；迟到30分钟内，算作迟到，5泰铢/分钟罚款；迟到超过30分钟，算半天旷工；迟到超过4小时，算全天旷工
                    ,case when ad.PH=0 AND ad.OFF=0
                            AND (ad.`attendance_started_at` is null or ad.`attendance_end_at` is null)
                            AND ad.leave_type not in (1,2,12,3,18,4,5,17,7,10,16,19) then 1
                        when ad.PH=0 AND ad.OFF=0
                            AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))>0
                            AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))<=30  then 0
                        -- when ad.PH=0 AND ad.OFF=0
                        --  AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))>30
                        --  AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))<=240  then 0.5
                        when ad.PH=0 AND ad.OFF=0
                            AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))>30
                            AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))<=(UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_end`,':','00' ))-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' )))/2  then 0.5
                        -- when ad.PH=0 AND ad.OFF=0
                        --  AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))>240 then 1
                        when ad.PH=0 AND ad.OFF=0
                            AND UNIX_TIMESTAMP(ad.`attendance_started_at`)-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' ))>(UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_end`,':','00' ))-UNIX_TIMESTAMP(concat(ad.`stat_date`,' ',ad.`shift_start`,':','00' )))/2 then 1
                        else 0
                        end 旷工
                    ,case when ad.leave_type in (1,2,12,3,18,4,5,17,7,10,16,19,6) AND ad.leave_time_type=1 then 0.5
                        when ad.leave_type in (1,2,12,3,18,4,5,17,7,10,16,19,6) AND ad.leave_time_type=2 then 0.5
                        when ad.leave_type in (1,2,12,3,18,4,5,17,7,10,16,19,6) AND ad.leave_time_type=3 then 1
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
                FROM `bi_pro`.`attendance_data_v2` ad
                LEFT JOIN `fle_staging`.`staff_info` si on si.`id` =ad.`staff_info_id`
                LEFT JOIN `fle_staging`.`sys_store` ss on ss.`id` =si.`organization_id`
                LEFT JOIN `bi_pro`.`hr_job_title` hjt on hjt.`id` =si.`job_title`
                -- LEFT JOIN `fle_staging`.`sys_department` sd on sd.`id` =si.`department_id`
                LEFT JOIN `dwm`.`dwd_hr_organizational_structure_detail` sd ON sd.`id`=si.`department_id`
                WHERE sd.`一级部门`='Thailand Fulfillment'
                    AND left(ad.`stat_date`,7)=left(date_sub(now() + interval -1 hour,interval 1 month), 7)
                ) ad
            ) ad
        ) ad
    ) ad
ORDER BY 统计日期


