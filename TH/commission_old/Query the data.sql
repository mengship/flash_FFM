select 一级部门,二级部门,月份,sum(人力总成本),sum(提成),sum(发薪总人数) from
(
    SELECT
        if(gz.公司='Flash Supply Chain Management',gz.公司,gz.`work_company`) as 公司
         ,gz.公司
        ,gz.一级部门
        ,gz.二级部门
        ,gz.country as 所属国家
        ,gz.posistion_type as 成本中心类别
        ,gz.excel_month as 月份
        ,gz.is_share 是否共享
        ,count(distinct gz.staff_info_id) as 发薪总人数
        ,avg(gz.total_working_days) as 平均出勤天数
        ,sum(gz.base_salary) as 基本薪资
        ,sum(gz.car) as 车补
        ,sum(gz.food) as 饭补
        ,sum(gz.incentive) as 提成
        ,sum(gz.ot) as ot
        ,sum(gz.bonus) as 年终奖
        ,sum(gz.other_income) as 其他收入
        ,sum(gz.total_income) as total_income
        ,sum(gz.all_tax) as tax
        ,sum(gz.social) as social
        ,sum(gz.other_deduct) as 其他扣款项
        ,sum(gz.total_deduct) as total_deduct
        ,sum(gz.net_income) as net_pay
        ,sum(gz.total_income)+sum(gz.social)+sum(gz.bonus) as 人力总成本
        ,(sum(gz.total_income)+sum(gz.social)+sum(gz.bonus))/count(distinct gz.staff_info_id) as 人均成本
        ,1 as currency
    FROM
        (
        SELECT
            sg.`staff_info_id`
            ,sg.`excel_month`
            ,sg.`staff_name`
            ,sg.`job_title_name`
            ,sg.`job_title_id`
            ,sg.`department_id`
            ,sg.`department_name`
            ,sg.`company_id`
            ,case sg.`company_id`
                when 1 then 'Express'
                when 2 then 'FFM'
                when 3 then 'Flash Money'
                when 5 then 'F-Commerce'
                when 6 then 'Flash Pay'
                when 7 then 'PKI'
                when 8 then 'SOFTWARE'
                when 9 then 'FlASH_HOME'
                end as 'work_company'
            ,sd.公司
            ,sd.一级部门
            ,sd.二级部门
            ,case htt.value
                when '1' then '泰国'
                when '2' then '中国'
                when '3' then '马来西亚'
                when '4' then '菲律宾'
                when '5' then '越南'
                when '6' then '老挝'
                when '7' then '印度尼西亚'
                when '8' then '新加坡'
                else '其它'
                end as 'country'
            ,case
                when srjc.type=1 then '销售'
                when srjc.type=2 then '运营'
                else '管理岗'
                end as posistion_type
            ,if(htt.value='1','否','是') as is_share
            ,sg.`total_working_days`
            ,sg.`salary` #基本薪资
            ,sg.`position` #基本薪资
            ,sg.`experience` #基本薪资
            ,sg.`salary`+sg.`position`+sg.`experience` as base_salary
            ,sg.`car`
            ,sg.`food`
            ,sg.`incentive`
            ,sg.`ot`
            ,sg.`tax` #SUMAllTax
            ,sg.`tax_compensation` #SUMAllTax
            ,sg.`tax_retirement_over5y` #SUMAllTax
            ,sg.`tax`+sg.`tax_compensation`+sg.`tax_retirement_over5y` as all_tax
            ,sg.`bonus`  #年终奖
            ,sg.`total_income`
            ,sg.`total_deduct`
            ,sg.`total_deduct`-sg.`tax` as other_deduct
            ,sg.`net_income`
            ,sg.`social`
            ,sg.`total_income` -sg.`salary` -sg.`car` -sg.`food` -sg.`bonus`-sg.`ot`  as other_income
        FROM `backyard_pro`.`salary_gongzi` sg
        LEFT JOIN `backyard_pro`.`hr_staff_info` hsi on hsi.`staff_info_id` =sg.`staff_info_id`
        LEFT JOIN dwm.`dwd_hr_organizational_structure_detail` sd on sd.`id` =hsi.`node_department_id`
        LEFT JOIN `backyard_pro`.`hr_staff_items` htt on hsi.staff_info_id=htt.staff_info_id and htt.item='WORKING_COUNTRY'
        LEFT JOIN `backyard_pro`.`salary_report_job_config` srjc on srjc.node_department_id=hsi.node_department_id and srjc.job_title_id=hsi.job_title
        WHERE sg.excel_month>='2023-01'
            AND sg.`company_id`=2
            AND sd.一级部门='Thailand Fulfillment'
        ) gz
    GROUP BY 1,2,3,4,5,6,7,8
) t0
group by 1,2,3
having 月份>='2025-01'
and 二级部门 in('AGV Warehouse','BPL2-Bangphli Return Warehouse','BST-Bang Sao Thong Warehouse','LAS-Lasalle Material Warehouse','BKK-WH-LAS2 E-Commerce Warehouse')
;


select * from dwm.`dwd_hr_organizational_structure_detail`