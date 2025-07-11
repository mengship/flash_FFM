 SELECT
      left(统计日期,7) 月份
      ,仓库 物理仓
      ,人员信息
      ,职位类别
      ,sum(应出勤) 应出勤
      ,sum(出勤) 出勤
      ,sum(迟到) 迟到
      -- ,sum(请假) 请假
      ,sum(旷工) 旷工
      ,sum(年假) 年假
      ,sum(事假) 事假
      ,sum(病假) 病假
      ,sum(产假) 产假
      ,sum(丧假) 丧假
      ,sum(婚假) 婚假
      ,sum(公司培训假) 公司培训假
      FROM
      (
      SELECT * FROM `dwm`.`dwd_th_ffm_attendance_detail1`
               where 人员信息 = '722617'
      ) ad
      where 人员信息 = '722617'
      GROUP BY     仓库
      ,人员信息
      ,部门
      ,职位类别;

select
    *
FROM `bi_pro`.`attendance_data_v2` ad
where stat_date='2025-06-30'
and     staff_info_id='722617'