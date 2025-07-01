-- 审账单
# 查看待审核账单
select
    distinct billing_sn
    ,s.name
    ,dd.billing_name 账单名称
    ,a.business_audit_time as 商务审核时间
    ,a.accounts_receivable/100 as 账单金额
    ,if( type=1,'仓储费','快递费') as type
    ,date(a.business_audit_time) dd
    ,date(a.data_audit_time)
from wms_production.billing  as a
left join
(
    select
        a.billing_name
        ,status
        ,b.seller_id
    from wms_production.warehouse_billing_rules as a
    left join wms_production.warehouse_billing_rules_ref  as b on a.id=b.warehouse_billing_rules_id
    where a.status =3
) as dd on dd.seller_id=a.seller_id
left join wms_production.seller s on s.id=a.seller_id
where 1=1
    and a.billing_end between date('2025-03-01') and  date('2025-04-01')
    and data_auditor_id=0
    and a.accounts_receivable/100>=0
    -- and date(a.business_audit_time)>='2024-05-01'
    and date(a.business_audit_time)>='2024-11-01'
    -- and date(a.business_audit_time) < '2024-12-06'
    and a.status not in (0,50)
  order by 4
;


-- 查看待审核账单 add bill rule -- review bill progress
select
    distinct billing_sn
    ,s.name
    ,dd.billing_name 账单名称
    ,a.business_audit_time as 商务审核时间
    ,a.accounts_receivable/100 as 账单金额
    ,if( type=1,'仓储费','快递费') as type
    ,date(a.business_audit_time) dd
    ,date(a.data_audit_time)
    ,rule.规则名称
    ,rule.计费名称
    ,rule.计费数据
    ,rule.免租期
from wms_production.billing  as a
left join
(
    select
        a.billing_name
        ,status
        ,b.seller_id
    from wms_production.warehouse_billing_rules as a
    left join wms_production.warehouse_billing_rules_ref  as b on a.id=b.warehouse_billing_rules_id
    where a.status =3
) as dd on dd.seller_id=a.seller_id
left join wms_production.seller s on s.id=a.seller_id
left join
(
    SELECT
         s.name '货主'
         ,w.name '仓库'
         ,wbr.billing_code '规则编号'
         ,wbr.billing_name '规则名称'
         ,case wbr.status
                   when 0 then '删除'
                   when 1 then '停用'
                   when 2 then '存盘'
                   when 3 then '启用'
         else wbr.status end '状态'
         ,wbr.created '创建时间'
         ,wbr.modified  '修改时间'
         ,wbrd.billing_projects_id '序号'
         ,case wbrd.billing_projects_id
                    when 1 then '仓储费'
                    when 2 then '操作费'
                    when 3 then '出库费'
                    when 4 then '装货费'
                    when 5 then '卸货费'
                    when 6 then '入库费'
                    when 7 then '销退入库费'
                    when 8 then '增值服务（全部）'
                    when 9 then '盘点费'
                    when 10 then '包材费'
                    when 12 then '拦截费'
                    when 14 then '短信费'
                    when 18 then '仓储费-按天/件'
                    when 19 then '入库费（有效期）'
                    when 21 then '出库费2'
                    when 22 then '理赔费'
                    when 23 then '租车费用'
                    when 24 then '发货包材费'
                    when 25 then '敏货操作费加价'
                    when 27 then '组装拆卸费'
                    when 28 then '仓储费（恒温仓）'
                    when 29 then '退款服务费用'
                    when 30 then '入库费（赠品）'
                    when 31 then '出库费（退仓）'
                    when 32 then '粘贴条码、标签费用'
                    when 33 then '商品包装费用'
                    when 34 then '销毁费'
                    when 35 then '条码打印费用'
                    when 36 then '商品换码费用'
                    when 37 then '商品组装费用'
                    when 39 then 'QC&商品加工费用'
                    when 40 then '商品附加费'
                    when 41 then '贵品保管费'
                    when 43 then '卸货费（按货柜）'
                    when 44 then '装货费（按货柜）'
                    when 45 then '入库费（SN）'
                    when 46 then '合并发货单'
                    when 47 then '包材费（合并发货）'
                    when 48 then '包材费（分摊）'
                    when 49 then '出库单（折扣商品）'
            else billing_projects_id end '计费名称'
        ,wbrd.billing_rules_code '计费规则代码'
        ,case wbrd.billing_order_type
                when 1 then '销售订单'
                when 2 then '出库单（普通出库）'
                when 3 then '入库单（全部）'
                when 4 then '销退订单'
                when 5 then '增值服务单（全部）'
                when 6 then '包材单'
                when 7 then '装货单'
                when 8 then '卸货单'
                when 9 then '盘点单'
                when 10 then '仓库租赁单'
                when 11 then '拦截归位单'
                when 12 then '组装拆卸单'
                when 13 then '短信'
                when 14 then '退款单'
                when 15 then '服务申请单'
                when 16 then '理赔单'
                when 21 then '默认包材单'
                when 35 then '报废单'
                when 39 then '出库单（退仓出库）'
                when 41 then '增值服务单（商品条码打印）'
                when 42 then '增值服务单（商品标签贴码）'
                when 43 then '增值服务单（商品加工）'
                when 44 then '增值服务单（商品包装）'
                when 45 then '增值服务单（商品组装）'
                when 46 then '增值服务单（商品换码）'
                when 47 then '合并发货单'
                when 48 then '包材单（合并发货）'
                when 49 then '包材单（合并发货）-按货主均摊'
        else wbrd.billing_order_type end '计费单据'
        ,case wbrd.billing_data
                when 'orderNum' then '订单数'
                when 'orderGoodsNum' then '商品件数'
                when 'orderTotalPrice' then '订单总金额'
                when 'orderGoodsByShelf' then '商品件数（保质期商品）'
                when 'orderGoodsNumBySN' then '商品件数（SN商品）'
                when 'goodsDeclaredValue' then '商品声明价值'
                when 'orderTotalVolume' then '订单总体积'
                when 'affixedCodeNum' then '增值服务数量'
                when 'goodsVolumeByConstantTemperature' then '商品体积（恒温仓）'
                when 'goodsVolumeByZZDays' then '商品体积（周转天数）'
                when 'orderGoodsNumByMu' then '商品件数（母件）'
                when 'messageNum' then '短信条数'
                when 'orderGoodsNumByUnitConversion' then '商品件数（单位换算）'
                when 'goodsVolume' then '商品体积'
                when 'rentedArea' then '租用面积'
                when 'locationAreaNoLocation' then '货位面积（按公摊系数-不区分货位）㎡'
                when 'orderContainerSize' then '订单货柜尺寸'
                when 'orderGoodsNumByUnit' then '商品件数（指定单位）'
                when 'locationArea' then '货位面积（按公摊系数-区分货位）㎡'
                when 'orderGoodsNumByUnitConversionZk' then '商品件数（单位换算）-折扣'
                when 'orderGoodsByMaxWeightSize' then '商品件数（最大重量尺寸）'
                when 'goodsVolumeByShare' then '商品体积（含公摊）'
                when 'orderGoodsNumByDays' then '商品库龄'
                when 'orderGoodsNumByDaysVolume' then '商品库龄体积'
                when 'orderGoodsNumByZi' then '商品件数（子件）'
                when 'orderGoodsByWeightSize' then '商品件数（平均重量尺寸）'
                when 'goodsVolumeByRoomTemperature' then '商品体积（常温仓）'
                when 'locationAreaNormal' then '货位面积（不含公摊系数）㎡'
                when 'hwRentedArea' then '恒温仓面积'
                when 'boxNum' then '箱单数'
                when 'orderGoodsTypeNum' then '商品品种数'
                when 'locationAreaByZZRate' then '货位面积（周转率）㎡'
                when 'orderGoodsNumByPrimary' then '商品件数（普通商品）'
                when 'goodsVolumeByZZDaysForDo' then '商品体积（周转天数-仅发货单）'
        else wbrd.billing_data end '计费数据'
        ,case wbrd.billing_rule
                when 'ladder' then '阶梯价'
                when 'unionLadder' then '组合阶梯价'
                when 'uunitLadder' then '单位阶梯价'
                when 'unitBySpec' then '指定计费单位'
                when 'num' then '按数值计费'
                when 'free' then '不计费'
                when 'rate' then '费率计费'
                when 'containerSize' then '按货柜尺寸计费'
        else wbrd.billing_rule end '计费规则'
        ,wbrd.cost_price '单价'
        ,wbrd.special_cost '阶梯价参数'
        ,wbrd.is_partial_discount '是否部分优惠'
        ,wbrd.days '免租期'
        ,wbrd.min_fee '最低收费 两位小数'
        ,wbrd.billing_projects_min_fee '计费项维度最低收费'
        ,wbrd.min_number '最低数值'
        ,wbrd.modified '修改时间'
    from wms_production.warehouse_billing_rules wbr
    left join wms_production.warehouse_billing_rules_detail wbrd on wbr.id = wbrd.warehouse_billing_rules_id
    left join wms_production.warehouse_billing_rules_ref wbrr on wbrr.warehouse_billing_rules_id = wbr.id
    left join wms_production.seller s on s.id = wbrr.seller_id
    left join wms_production.warehouse w on w.id = wbrr.warehouse_id
    where 1=1
    and s.disabled = 0
    -- and w.disabled = 0
    and wbr.billing_name <> '北京测试'
    and wbrd.billing_projects_id=1
    order by 3,8
) rule on s.name = rule.货主
where 1=1
    and a.billing_end between date('2025-04-01') and  date('2025-04-30')
    and data_auditor_id=0
    and a.accounts_receivable/100>=0
    -- and date(a.business_audit_time)>='2024-05-01'
    and date(a.business_audit_time)>='2024-11-01'
    -- and date(a.business_audit_time) < '2024-12-06'
    and a.status not in (0,50)
  order by 4;

-- 飞书文档 review bill progress summarize
select
    '马来' 国家
    ,if( a.type=1,'仓储费','快递费') as 账单类型
    ,count(distinct a.billing_sn) billing_cnt
    ,count(distinct if(a.business_audit_time is not null, a.billing_sn, null)) 商务审核
    ,count(distinct if(a.data_audit_time is not null, a.billing_sn, null)) 数据审核
from wms_production.billing  as a
left join
(
    select
        a.billing_name
        ,status
        ,b.seller_id
    from wms_production.warehouse_billing_rules as a
    left join wms_production.warehouse_billing_rules_ref  as b on a.id=b.warehouse_billing_rules_id
    where a.status =3
) as dd on dd.seller_id=a.seller_id
left join wms_production.seller s on s.id=a.seller_id
left join `wms_production`.`member` mb on a.`business_auditor_id` = mb.id
left join
(
    select
        d.billing_id
        ,sum(settlement_amount/100) as settlement_amount
    from wms_production.billing_detail as d  -- 账单明细表
    left join wms_production.billing_projects as e on e.id = d.billing_projects_id
    where e.id  in (10, 17) -- 10 包材费
        /* and d.charge_sn ='AR2409015451' */
    group by  d.billing_id
)as d on d.billing_id = a.id
left join
(
    select
        '销退入库单量'
        ,d.billing_id
        ,count(distinct d.business_sn) xt_cnt
        -- ,sum(settlement_amount/100) as settlement_amount
    from wms_production.billing_detail as d  -- 账单明细表
    left join wms_production.billing_projects as e on e.id = d.billing_projects_id
    where left(e.billing_name_zh, 4)='销退入库'
        /* and d.charge_sn ='AR2409015451' */
    group by 1,2
) xt on xt.billing_id = a.id
left join
(
    select
        '入库单量'
        ,d.billing_id
        ,count(distinct d.from_order_sn) rk_cnt
        -- ,sum(settlement_amount/100) as settlement_amount
    from wms_production.billing_detail as d  -- 账单明细表
    left join wms_production.billing_projects as e on e.id = d.billing_projects_id
    where left(e.billing_name_zh, 2)='入库'
        /* and d.charge_sn ='AR2409015451' */
    group by 1,2
) rk on rk.billing_id = a.id
left join
(
    select
        '发货单量'
        ,d.billing_id
        ,count(distinct business_sn) fh_cnt
        -- ,sum(settlement_amount/100) as settlement_amount
    from wms_production.billing_detail as d  -- 账单明细表
    left join wms_production.billing_projects as e on e.id = d.billing_projects_id
    where left(e.billing_name_zh, 2)='操作'
        /* and d.charge_sn ='AR2409015451' */
    group by 1,2
) fh on fh.billing_id = a.id
left join
(
    select
        '出库单量'
        ,d.billing_id
        ,count(distinct d.from_order_sn) ck_cnt
        -- ,sum(settlement_amount/100) as settlement_amount
    from wms_production.billing_detail as d  -- 账单明细表
    left join wms_production.billing_projects as e on e.id = d.billing_projects_id
    where left(e.billing_name_zh, 2)='出库'
        -- and d.charge_sn ='AR2410013742'
    group by 1,2
) ck on ck.billing_id = a.id
left join
(
        select
                bdd.`billing_id`,
                sum(bdd.`settlement_amount`/100) as 运费
        from `wms_production`.`billing_detail` bdd
        left join `wms_production`.`billing_projects` bp on bp.`id` =bdd.`billing_projects_id`
        left join `wms_production`.`seller` s on s.`id` =bdd.`seller_id`
        where bp.id=11
        and bdd.business_date>='2024-09-01'
        group by 1
) bdkd on bdkd.`billing_id` =a.`id`
where 1=1
    and a.billing_end between date ('2025-02-01') and  date('2025-02-28')
    -- and data_auditor_id=0
    and a.accounts_receivable/100>0
    -- and date(a.business_audit_time)>='2024-05-01'
    and a.status not in (0,50)
group by 1,2;

-- 飞书文档 review bill progress
select
    month
    ,账单类型
    ,count(distinct billing_sn)
    ,count(distinct if(商务审核情况='完成', billing_sn, null)) 商务已审核
    ,count(distinct if(数据审核情况='完成', billing_sn, null)) 数据已审核
from
    (
        select
            a.billing_sn
            ,left(a.billing_end, 7) month
            ,if( a.type=1,'仓储费','快递费') as 账单类型
            ,if(a.business_audit_time is not null, '完成', '未审核') 商务审核情况
            ,if(a.data_audit_time is not null, '完成', '未审核') 数据审核情况
            ,a.accounts_receivable/100 as 账单金额
        from wms_production.billing  as a
        where 1=1
#             and a.billing_end between '2025-04-01' and '2025-04-30'
            and a.billing_end between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
            and  date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
    ) t0
where 1=1
    and 账单金额>0
group by 1,2;

-- 飞书文档 review bill progress Detail
select
    date(a.data_audit_time) 数据审核日期
    ,'马来' 国家
    ,s.name 货主
    ,case a.charge_currency
          when 1 then 'USD'
          when 5 then '比索'
          when 2 then 'CNY'
          when 7 then '越南盾VND'
          when 4 then '林吉特MYR'
     end 币种
    ,if( a.type=1,'仓储费','快递费') as 账单类型
    ,a.billing_sn
    ,if(a.business_audit_time is not null, '完成', '未审核') 商务审核情况
    ,mb.job_number 商务审核人
    ,if(a.data_audit_time is not null, '完成', '未审核') 数据审核情况
    ,a.accounts_receivable/100 as 账单金额
        ,0 COD款金额
    ,d.settlement_amount 包材金额
    ,fh.fh_cnt 发货单量
    ,ck.ck_cnt 出库单量
    ,rk.rk_cnt 入库单量
    ,xt.xt_cnt 销退单量
from wms_production.billing  as a
left join
(
    select
        a.billing_name
        ,status
        ,b.seller_id
    from wms_production.warehouse_billing_rules as a
    left join wms_production.warehouse_billing_rules_ref  as b on a.id=b.warehouse_billing_rules_id
    where a.status =3
) as dd on dd.seller_id=a.seller_id
left join wms_production.seller s on s.id=a.seller_id
left join `wms_production`.`member` mb on a.`business_auditor_id` = mb.id
left join
(
    select
        d.billing_id
        ,sum(settlement_amount/100) as settlement_amount
    from wms_production.billing_detail as d  -- 账单明细表
    left join wms_production.billing_projects as e on e.id = d.billing_projects_id
    where e.id  in (10, 17) -- 10 包材费
        /* and d.charge_sn ='AR2409015451' */
    group by  d.billing_id
)as d on d.billing_id = a.id
left join
(
    select
        '销退入库单量'
        ,d.billing_id
        ,count(distinct d.business_sn) xt_cnt
        -- ,sum(settlement_amount/100) as settlement_amount
    from wms_production.billing_detail as d  -- 账单明细表
    left join wms_production.billing_projects as e on e.id = d.billing_projects_id
    where left(e.billing_name_zh, 4)='销退入库'
        /* and d.charge_sn ='AR2409015451' */
    group by 1,2
) xt on xt.billing_id = a.id
left join
(
    select
        '入库单量'
        ,d.billing_id
        ,count(distinct d.from_order_sn) rk_cnt
        -- ,sum(settlement_amount/100) as settlement_amount
    from wms_production.billing_detail as d  -- 账单明细表
    left join wms_production.billing_projects as e on e.id = d.billing_projects_id
    where left(e.billing_name_zh, 2)='入库'
        /* and d.charge_sn ='AR2409015451' */
    group by 1,2
) rk on rk.billing_id = a.id
left join
(
    select
        '发货单量'
        ,d.billing_id
        ,count(distinct business_sn) fh_cnt
        -- ,sum(settlement_amount/100) as settlement_amount
    from wms_production.billing_detail as d  -- 账单明细表
    left join wms_production.billing_projects as e on e.id = d.billing_projects_id
    where left(e.billing_name_zh, 2)='操作'
        /* and d.charge_sn ='AR2409015451' */
    group by 1,2
) fh on fh.billing_id = a.id
left join
(
    select
        '出库单量'
        ,d.billing_id
        ,count(distinct d.from_order_sn) ck_cnt
        -- ,sum(settlement_amount/100) as settlement_amount
    from wms_production.billing_detail as d  -- 账单明细表
    left join wms_production.billing_projects as e on e.id = d.billing_projects_id
    where left(e.billing_name_zh, 2)='出库'
        -- and d.charge_sn ='AR2410013742'
    group by 1,2
) ck on ck.billing_id = a.id
left join
(
        select
                bdd.`billing_id`,
                sum(bdd.`settlement_amount`/100) as 运费
        from `wms_production`.`billing_detail` bdd
        left join `wms_production`.`billing_projects` bp on bp.`id` =bdd.`billing_projects_id`
        left join `wms_production`.`seller` s on s.`id` =bdd.`seller_id`
        where bp.id=11
        and bdd.business_date>='2024-09-01'
        group by 1
) bdkd on bdkd.`billing_id` =a.`id`
where 1=1
#     and a.billing_end between '2025-04-01' and '2025-04-30'
    -- default
    and a.billing_end between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
        and  date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
    -- and data_auditor_id=0
    and a.accounts_receivable/100>0
    -- and date(a.business_audit_time)>='2024-05-01'
    and a.status not in (0,50);



-- 仓库分析表
-- 飞书文档 analysis report
select
    sum(入库费)*0.24 入库费 ,
    sum(存储费)*0.24 存储费 ,
    sum(操作费)*0.24 操作费 ,
    sum(包材费)*0.24 包材费 ,
    sum(运费)*0.24 运费 ,
    sum(其他)*0.24 其他
from
(
    select
        bd. 包材费 ,
        bdr.入库费,
        bds.存储费,
        bdp.操作费,
        bdkd.运费,
        bdo.其他
    from wms_production.billing  as b
    left join
    #包材费
        (
            select
                bdd.`billing_id`,
                sum(bdd.`settlement_amount`/100) as 包材费
            from `wms_production`.`billing_detail` bdd
            left join `wms_production`.`billing_projects` bp on bp.`id` =bdd.`billing_projects_id`
            left join `wms_production`.`seller` s on s.`id` =bdd.`seller_id`
            where bp.id=10
            and bdd.business_date>='2024-09-01'
            group by 1
        ) bd on bd.`billing_id` =b.`id`
    left join
    #入库费
        (
            select
                bdd.`billing_id`,
                sum(bdd.`settlement_amount`/100) as 入库费
            from `wms_production`.`billing_detail` bdd
            left join `wms_production`.`billing_projects` bp on bp.`id` =bdd.`billing_projects_id`
            left join `wms_production`.`seller` s on s.`id` =bdd.`seller_id`
            where bp.id=6
            and bdd.business_date>='2024-09-01'
            group by 1
        ) bdr on bdr.`billing_id` =b.`id`
    left join
    #存储费
        (
            select
                bdd.`billing_id`,
                sum(bdd.`settlement_amount`/100) as 存储费
            from `wms_production`.`billing_detail` bdd
            left join `wms_production`.`billing_projects` bp on bp.`id` =bdd.`billing_projects_id`
            left join `wms_production`.`seller` s on s.`id` =bdd.`seller_id`
            where bp.id=1
            and bdd.business_date>='2024-09-01'
            group by 1
        ) bds on bds.`billing_id` =b.`id`
    left join
    #操作费
        (
            select
                bdd.`billing_id`,
                sum(bdd.`settlement_amount`/100) as 操作费
            from `wms_production`.`billing_detail` bdd
            left join `wms_production`.`billing_projects` bp on bp.`id` =bdd.`billing_projects_id`
            left join `wms_production`.`seller` s on s.`id` =bdd.`seller_id`
            where bp.id=2
            and bdd.business_date>='2024-09-01'
            group by 1
        ) bdp on bdp.`billing_id` =b.`id`
    left join
    #运费费
        (
            select
                bdd.`billing_id`,
                sum(bdd.`settlement_amount`/100) as 运费
            from `wms_production`.`billing_detail` bdd
            left join `wms_production`.`billing_projects` bp on bp.`id` =bdd.`billing_projects_id`
            left join `wms_production`.`seller` s on s.`id` =bdd.`seller_id`
            where bp.id=11
            and bdd.business_date>='2024-09-01'
            group by 1
        ) bdkd on bdkd.`billing_id` =b.`id`
    left join
    #其他
        (
            select
                bdd.`billing_id`,
                sum(bdd.`settlement_amount`/100) as 其他
            from `wms_production`.`billing_detail` bdd
            left join `wms_production`.`billing_projects` bp on bp.`id` =bdd.`billing_projects_id`
            left join `wms_production`.`seller` s on s.`id` =bdd.`seller_id`
            where bp.id not in (1,2,6,10,11)
            and bdd.business_date>='2024-09-01'
            group by 1
        ) bdo on bdo.`billing_id` =b.`id`
    where 1=1
    and b.billing_end between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
        and  date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
    and b.accounts_receivable>0
) t

;

-- 工作量
# 工作量 马来
select
sum(delivery_cnt)
,sum(return_cnt)
from
(
    select
        t0.delivery_cnt
        ,t1.return_cnt
    from
    (
        select
            d.warehouse_id,
            w.name warehouse_name,
            count(d.id) delivery_cnt
        from wms_production.delivery_order d
        left join wms_production.warehouse w on d.warehouse_id = w.id
        where date(d.delivery_time) between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
        and  date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
        and d.warehouse_id in (2, 10, 4, 5)
        group by 1,2
    ) t0
    left join
    (
        select
            r.warehouse_id,
            w.name,
            count(r.id) return_cnt
        from wms_production.return_warehouse  r
        left join wms_production.warehouse w on r.warehouse_id = w.id
        where date(r.out_warehouse_time) between date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
        and  date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)
        and r.type=1
        and r.warehouse_id in (2, 10, 4, 5)
        group by 1,2
    ) t1
    on t0.warehouse_id = t1.warehouse_id
) t;

-- 人数



# 员工数
select
  left(统计日期, 7)
  ,count(人员信息)
  from
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
        ,在职
        ,职位类别
        ,职位
        ,上班打卡时间
        ,班次开始
        ,下班打卡时间
        ,班次结束
        ,公休日
        ,休息日
        ,if(出勤>0, 出勤, 应出勤) 应出勤
        ,出勤
        --    ,应出勤-请假-旷工 出勤
        -- ,未出勤
        ,请假
        -- ,请假时段
        ,if(迟到>0,floor(迟到),0) 迟到
        ,旷工
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
    ,OT类型
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
        ,OT类型
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
            ,OT类型
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
                ,OT类型
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
                    ,case when sd.二级部门='AGV Warehouse' then 'AGV'
                        when sd.二级部门='BPL2-Bangphli Return Warehouse' then 'BPL-Return'
                        when sd.二级部门='Bangphli Livestream Warehouse' then 'BPL3'
                        when sd.二级部门='BST-Bang Sao Thong Warehouse' then 'BST'
                        when sd.二级部门 in ('LAS-Lasalle Material Warehouse', 'BKK-WH-LAS2 E-Commerce Warehouse') then 'LAS'
                        when sd.二级部门='LCP Warehouse' then 'LCP'
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
                    ,ot.OT类型
                FROM `my_bi`.`attendance_data_v2` ad
                LEFT JOIN `my_staging`.`staff_info` si on si.`id` =ad.`staff_info_id`
                LEFT JOIN `my_staging`.`sys_store` ss on ss.`id` =si.`organization_id`
                LEFT JOIN `my_bi`.`hr_job_title` hjt on hjt.`id` =si.`job_title`
                LEFT JOIN `dwm`.`dwd_hr_organizational_structure_detail` sd ON sd.`id`=si.`department_id`
                left join my_bi.hr_staff_transfer hst on ad.staff_info_id = hst.staff_info_id and ad.`stat_date` = hst.stat_date
                left join
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
                        ,case when 二级部门 in ('AGV Warehouse', 'AutoWarehouse-人工仓') then 'AGV'
                            when 二级部门='BPL2-Bangphli Return Warehouse' then 'BPL-Return'
                            when 二级部门 in ('BPL3-LIVESTREAM', 'Bangphli Livestream Warehouse') then 'BPL3'
                            when 二级部门='BST-Bang Sao Thong Warehouse' then 'BST'
                            when 二级部门 in ('LAS-Lasalle Material Warehouse', 'BKK-WH-LAS2 E-Commerce Warehouse') then 'LAS'
                            when 二级部门='LCP Warehouse' then 'LCP'
                        end 仓库
                        ,case
                            when left(三级部门,4)='Pack' then 'Packing'
                            when left(三级部门,4)='Pick' then 'Picking'
                            when left(三级部门,3)='Out' then 'Outbound'
                            when left(三级部门,3)='Inb' then 'Inbound'
                            when left(三级部门,3)='B2B' then 'B2B'
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
                    FROM my_backyard.hr_overtime ho
                    LEFT JOIN my_bi.hr_staff_info hsi on ho.staff_id =hsi.staff_info_id
                    LEFT JOIN my_bi.hr_staff_transfer ht on ho.staff_id =ht.staff_info_id and ho.date_at =ht.stat_date
                    left join my_staging.sys_department sd2 on sd2.id =hsi.node_department_id
                    left join my_staging.sys_store ss on ss.id =hsi.sys_store_id
                    left join dwm.dwd_hr_organizational_structure_detail sd  on sd.id =hsi.node_department_id
                    left join my_bi.hr_job_title hjt on hjt.id =hsi.job_title
                    left join tmpale.ods_my_dim_date o on o.`date` =ho.date_at
                    left join my_bi.attendance_data_v2 adv on adv.stat_date =ho.date_at and adv.staff_info_id =ho.staff_id
                    WHERE ho.state =2 -- 审核通过
                    and ho.date_at >= '2023-12-01'
                    and sd.一级部门='Fulfillment'
                    -- and ho.date_at >= date_sub(date(now() + interval -1 hour),interval 30 day)
                ) ot on ad.`staff_info_id` = ot.员工ID and ad.stat_date = ot.申请日期
                WHERE sd.`一级部门`='Fulfillment'
                    -- AND ad.`stat_date`>= date_sub(date(now() + interval -1 hour),interval 30 day)
                    AND ad.`stat_date`>='2024-06-01'
            ) ad
        ) ad
    ) ad
) ad

  ) t
group by 1

