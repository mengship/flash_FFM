select
    *
from
(
    SELECT
        left(delivery_time,7)
        ,warehouse_name
        ,case warehouse_name when 'BST' then 1
            when 'LAS' then 2
            when 'BPL-Return' then 3
            when 'AGV' then 4
            when 'BPL3' then 5
            end as num
        ,count(delivery_sn)
    from dwm.dwd_th_ffm_outbound_dayV2
    WHERE TYPE='B2C'
    AND left(delivery_time,7) = left(date_sub(date_add(now(),interval -60 minute),interval 1 month),7)
    group by 1,2
) t0
order by num;


-- 3.1 结算单量与结算金额
select
*
from
(
    SELECT
        left(business_date, 7) bisiness_month
        ,warehouse_name
        ,case warehouse_name when 'BST' then 1
                when 'LAS' then 2
                when 'BPL-Return' then 3
                when 'AGV' then 4
                when 'BPL3' then 5
                end as num
        ,count(delivery_sn)
        ,sum(amount)
    FROM    dwm.dwd_th_ffm_outbound_dayV2 do
    INNER JOIN
    (
        SELECT
            business_sn
            ,business_date
            ,sum(sa)/100 AS amount
        FROM
        (
            SELECT
                bld.business_date
                ,bld.serial_number
                ,bl.type,business_sn
                ,billing_name_zh
                , bld.settlement_amount AS sa
            FROM wms_production.billing bl
            LEFT JOIN  wms_production.billing_detail bld ON bl.id=bld.billing_id
            LEFT JOIN wms_production.billing_projects blp ON bld.billing_projects_id= blp.id
            WHERE LEFT(billing_name_zh,3) ='操作费'
            AND bl.type='1'
            AND LEFT(business_sn,2)='DO'
            AND left(bld.business_date,7) = left(date_sub(now() + interval -1 hour,interval 1 month), 7)
        )t0 GROUP BY 1,2

        union -- erp操作费
        (
            select
                order_sn
                ,date
                ,sum(amount)amount
            from
            erp_wms_prod.order_operation_billing_detail
            where left(date,7) = left(date_sub(now() + interval -1 hour,interval 1 month), 7)
            group by 1,2
        )
    ) rp ON do.delivery_sn = rp.business_sn
    -- left join wms_production.warehouse w on do.warehouse_id = w.id
    -- left join tmpale.dim_th_ffm_virtualphysical vp on w.name = vp.virtualwarehouse_name
    group by 1,2,3
) t0
order by num;


-- 薪资成本
select
    仓库,
    月份,
    sum(人力总成本)
from
(
    SELECT
        gz.仓库,
          case 仓库 when 'BST' then 1
                    when 'LAS' then 2
                    when 'BPL-Return' then 3
                    when 'AGV' then 4
                    when 'BPL3' then 5
                    end as num,
        gz.excel_month as 月份,
        sum(gz.total_income) + sum(gz.social) + sum(gz.bonus) as 人力总成本
    FROM
    (
        SELECT
            sg.`excel_month`,
            sd.一级部门,
            sd.二级部门,
            case when sd.二级部门='AGV Warehouse' then 'AGV'
              when sd.二级部门='BPL2-Bangphli Return Warehouse' then 'BPL-Return'
              when sd.二级部门='Bangphli Livestream Warehouse' then 'BPL3'
              when sd.二级部门='BST-Bang Sao Thong Warehouse' then 'BST'
              when sd.二级部门 in ('LAS-Lasalle Material Warehouse', 'BKK-WH-LAS2 E-Commerce Warehouse') then 'LAS'
              end 仓库,
            sg.`bonus`, #年终奖 人力总成本的一部分
            sg.`total_income`, -- 人力总成本的一部分
            sg.`social` -- 人力总成本的一部分
        FROM
            `backyard_pro`.`salary_gongzi` sg
            LEFT JOIN `backyard_pro`.`hr_staff_info` hsi on hsi.`staff_info_id` = sg.`staff_info_id`
            LEFT JOIN dwm.`dwd_hr_organizational_structure_detail` sd on sd.`id` = hsi.`node_department_id`
        WHERE
            sg.excel_month >= left(date_sub(date_add(now(),interval -60 minute),interval 1 month),7)
            AND sg.`company_id` = 2
            AND sd.一级部门 = 'Thailand Fulfillment'
            and 二级部门 in ( 'AGV Warehouse', 'Bangphli Livestream Warehouse', 'BPL2-Bangphli Return Warehouse', 'BST-Bang Sao Thong Warehouse', 'BKK-WH-LAS2 E-Commerce Warehouse' )
    ) gz
    GROUP BY
        1,
        2,
        3
) t0
group by
    1,
    2
order by num;

 -- 临时工成本 临时工成本 支付状态 未支付的不考虑
select
    仓库
    ,金额
    ,审核状态
    ,支付状态
    ,备注
from
(
    SELECT
        *
    FROM
    (
        -- 普通付款
        SELECT
            '普通付款' 付款类型
            ,bo.`name_cn` 付款项
            ,op.`apply_no` 付款单号
            -- ,op.`create_id`
            -- ,op.`create_name`
            ,op.`apply_id` 申请人ID
            ,op.`apply_name` 申请人名称
            ,op.`apply_company_name` 申请业务线
            -- ,op.`cost_department_name`
            ,op.`apply_node_department_name` 申请部门
            ,op.`apply_store_name` 申请网点
            ,case when op.`apply_store_name` in ('AGV Warehouse','AGV  Warehouse') then 'AGV'
                when op.`apply_store_name` in ('Fulfillment Bang Sao Thong warehouse','BST- Bang Sao Thong warehouse') then 'BST'
                when op.`apply_store_name` in ('LAS-Lasalle Material Warehouse') then 'LAS'
                when op.`apply_store_name` in ('BPL3-Bangphli Live Stream Warehouse') then 'BPL3'
                when op.`apply_store_name` in ('BPL2-Bangphli Return Warehouse') then 'BPL_return'
                when op.`apply_store_name` in ('LCP Warehouse') then 'LCP'
                when op.`apply_store_name` in ('Head Office','Header Office') then 'Head Office'
                else op.`apply_store_name`
                end 仓库
            ,case op.`currency`
                when 1 then op.`amount_total_actually`
                when 2 then op.`amount_total_actually`*32
                when 3 then op.`amount_total_actually`*5
                end 金额
            -- ,op.`amount_total_actually` 金额
            ,op.`created_at` 创建时间
            ,op.`should_pay_date` 支付时间
            ,left(op.`should_pay_date`, 7) 支付月份
            ,op.`remark` 备注
            ,case op.`approval_status`
                when 1 then '待审核'
                when 2 then '已驳回'
                when 3 then '已通过'
                when 4 then '已撤回'
                end 审核状态
            ,case op.`pay_status`
                when 1 then '待支付'
                when 2 then '已支付'
                when 3 then '未支付'
                end 支付状态
            -- ,opd.`cost_start_date`
        FROM `oa_production`.`ordinary_payment` op
        LEFT JOIN `oa_production`.`ordinary_payment_detail` opd on opd.`ordinary_payment_id`=op.`id`
        LEFT JOIN `oa_production`.`budget_object` bo on opd.`budget_id`=bo.`id`
        WHERE 1=1
        -- op.`approval_status`=3 and op.`pay_status`=2
            -- and op.`apply_company_name`='Flash Fullfillment'
            and left(op.`should_pay_date`, 7) >= '2023-11'

    ) a
) t0
    where 付款项 like'%劳务%' and left(创建时间,7)>='2025-04' and 申请业务线='Flash Fullfillment'
    /* and 备注 like'%March%' */
    order by 仓库

