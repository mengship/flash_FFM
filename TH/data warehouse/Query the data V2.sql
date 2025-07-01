select
    日期
    , 周
    , 仓库名称
    , seller_name
    , sum(if(收入类型分类='入库费', 0, amount)) 入库费
    , sum(if(收入类型分类='出库费', 0, amount)) 出库费
    , sum(if(收入类型分类='操作费', 0, amount)) 操作费
    , sum(if(收入类型分类='仓储费', 0, amount)) 仓储费
    , sum(if(收入类型分类='包材费', 0, amount)) 包材费
    , sum(if(收入类型分类='增值服务', 0, amount)) 增值服务
    , sum(if(收入类型分类='销退拦截', 0, amount)) 销退拦截
from
(
    select
        blp.billing_name_zh 收入类型,
        CASE WHEN LEFT(blp.billing_name_zh,3) IN ('仓储费','入库费','出库费','包材费','卸货费') THEN LEFT(blp.billing_name_zh,3)
            ELSE blp.billing_name_zh END 收入类型2,
        dtfi.收入类型分类,
        left(bld.business_date,10) 日期,
        week(left(bld.business_date,10)+ interval 1 day) 周,
        case when  w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓') then 'AGV'
                when w.name='BPL-Return Warehouse' then 'BPL-Return'
                when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                when w.name in ('BangsaoThong','BST-FMCG')  then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓') then 'LAS'
                when w.name='LCP Warehouse' then 'LCP'
                 end 仓库名称,
        bld.settlement_amount/100 amount, -- 结算金额
        s.name seller_name

    from wms_production.billing_detail bld
    left join wms_production.billing_projects blp on bld.billing_projects_id= blp.id
    left join wms_production.warehouse w on bld.warehouse_id=w.id
    left join dwm.dim_th_ffm_incometype dtfi on blp.billing_name_zh = dtfi.收入类型
    left join wms_production.seller s on bld.seller_id = s.id
    where 1=1
        -- and bl.type='1'
        -- and billing_name_zh='操作费'
        and left(bld.business_date,10) >=left(now() - interval 90 day,10)
        and LEFT(blp.billing_name_zh,2) <> '快递'

) t0
group by 1,2,3,4
having 仓库名称 is not null;

select *from tmpale.dim_th_ffm_incometype;
desc dwm.dim_th_ffm_incometype;

select
    一级部门
    ,二级部门
    ,月份
    ,sum(人力总成本)
    ,sum(提成)
    ,sum(发薪总人数)
    from
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
group by 一级部门
    ,二级部门
    ,月份
having 月份>='2025-01'
and 二级部门 in('AGV Warehouse','Bangphli Livestream Warehouse','BPL2-Bangphli Return Warehouse','BST-Bang Sao Thong Warehouse','LAS-Lasalle Material Warehouse','BKK-WH-LAS2 E-Commerce Warehouse')
;

select * from wms_production.location_accuracy_rate_scan_detail;

select * from wms_production.sku_location_check_task_data;

select
                    'wms拦截单' source
                    ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓') then 'AGV'
                        when w.name='BPL-Return Warehouse' then 'BPL-Return'
                        when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                        when w.name='BangsaoThong' then 'BST'
                        when w.name IN ('BKK-WH-LAS2电商仓')         then 'LAS'
                        when w.name='LCP Warehouse' then 'LCP' end warehouse_name
                    ,case when w.name='AutoWarehouse' then 'AGV'
                        when w.name='AutoWarehouse-人工仓' then 'AGV-人工仓'
                        when w.name='BPL-Return Warehouse' then 'BPL-Return'
                        when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                        when w.name='BangsaoThong' then 'BST'
                        when w.name IN ('BKK-WH-LAS2电商仓')         then 'LAS'
                        when w.name='LCP Warehouse' then 'LCP' end warehouse_detailname
                    ,s.name seller_name
                    ,ip.intercept_sn
                    ,LEFT(ip.created - INTERVAL 1 HOUR,10) created_date
                    ,ip.created - INTERVAL 1 HOUR created_time
                    ,LEFT(ip.shelf_on_end_time,10)  shelf_on_end_date
                    ,ip.shelf_on_end_time
                    from wms_production.intercept_place ip
                    LEFT JOIN wms_production.warehouse w ON ip.warehouse_id=w.id
                    left join wms_production.seller s on ip.seller_id = s.id
                where 1=1
                    and ip.status <>'1000'
                    and ip.created >= convert_tz(date_sub(date(now() + interval -1 hour),interval 90 day), '+07:00', '+08:00')
                    -- and ip.created >= convert_tz('2023-12-01', '+07:00', '+08:00')
