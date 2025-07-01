-- 提成计算
select
    月份
    ,仓库
    ,'考勤信息' title1
    ,t8.title
    ,ID
    ,姓名
    ,岗位
    ,hire_date 入职日期
    ,leave_date 离职日期
    ,职级
    ,fact_required_attend_flag 排班天数
    ,attendance_days 出勤
    ,skipwork_days 旷工
    ,leave_days 请假
    ,'作业量' title2
    ,拣货件数
    ,拣货件数贴面单
    ,拣货件数批量小
    ,拣货件数批量中
    ,拣货件数批量大
    ,拣货件数批量超大
    ,拣货件数信息不全
    ,拣货件数小
    ,拣货件数中
    ,拣货件数大
    ,拣货件数超大
    ,打包件数
    ,打包件数贴面单
    ,打包件数批量小
    ,打包件数批量中
    ,打包件数批量大
    ,打包件数批量超大
    ,打包件数PE
    ,打包件数小
    ,打包件数中
    ,打包件数大
    ,打包件数超大
    ,打包件数信息不全
    ,出库包裹数
    ,出库包裹数贴面单
    ,出库包裹数PE
    ,出库包裹数小
    ,出库包裹数中
    ,出库包裹数大
    ,出库包裹数超大
    ,出库包裹数信息不全
    ,打包件数2B B2B出库
    ,收货件数
    ,收货上架数量
    ,销退包裹量
    ,拦截件数
    ,补货上架
    ,收货上架数量_组
    ,补货上架_组
    ,销退包裹量_组
    ,拦截件数_组
    ,收货件数_组
    ,打包件数2B_组
    ,'null' 盘点件数
    ,'个人计件' title3
    ,if(岗位='Picking', 提成, 0) 拣货金额
    ,if(岗位='Packing', 提成, 0) 打包金额
    ,if(岗位='Handover', 提成, 0) 出库金额
    ,'支援提成' title4
    ,拣货支援提成 拣货支援提成金额
    ,打包支援提成 打包支援提成金额
    ,出库支援提成 出库支援提成金额
    ,cast(支援提成合计 as DECIMAL(40,0))支援提成合计
    ,'组别提成' title5
    ,if(岗位='B2B', 组内人均提成, 0) B2B
    ,if(岗位='Inbound', 组内人均提成, 0) 收货
    ,if(岗位='Putaway', 组内人均提成, 0) 上架
    ,if(岗位='Return', 组内人均提成, 0) 销退
    ,if(岗位='Intercept', 组内人均提成, 0) 拦截
    ,if(岗位='Replenish', 组内人均提成, 0) 补货
    ,'null' 盘点
    ,'职能部门提成' title6
    ,case when 职级 in ('组长', '主管') and title='组提成' then 组内人均提成add组长 when 职级 in ('组长', '主管') and title='个人提成' then 组内人均提成add组长add支援提成 end as  组长提成
    ,if(职级 in ('组长', '主管'), 组内人均提成add组长add支援提成add组长系数, 0) 主管提成
    ,'null' 职能提成
    ,'实发' title7
    ,组内人均提成add组长add支援提成add组长系数 应发提成
    ,if(fact_required_attend_flag = attendance_days and (is_on_job=1 or leave_days >= DATE_ADD(concat(月份, '-01'), interval 1 month) ) and hire_date <= concat(月份, '-01'), 800, 0)全勤奖
    ,case when 岗位='Picking' then 拣货绩效系数
        when 岗位='Packing' then B2C交接及时率_权重绩效系数
        when 岗位='Handover' then B2C发货及时率_权重绩效系数
        when 岗位='Putaway' then 上架及时率_采购权重绩效系数
        when 岗位='Replenish' then 1
        when 岗位='Return' then 上架及时率_销退权重绩效系数
        when 岗位='Intercept' then 拦截归位及时率（24H）_权重绩效系数
        when 岗位='Inbound' then 收货及时率_采购权重绩效系数
        when 岗位='B2B' then B2B打包及时率_权重绩效系数
        end as 绩效系数
    ,KPI
    ,旷工请假折算系数 考勤系数
    ,(组内人均提成add组长add支援提成add组长系数addkpi提成 + if(fact_required_attend_flag = attendance_days, 800, 0)) * 旷工请假折算系数 实发
from
(
    select
        t7.title
        ,t7.月份
        ,t7.仓库
        ,t7.ID
        ,t7.姓名
        ,t7.岗位
        ,t7.职级
        ,t7.KPI
        ,t71.fact_required_attend_flag
        ,t71.attendance_days
        ,t71.skipwork_days
        ,t71.leave_days
        ,t71.is_on_job
        ,t7.收货上架数量
        ,t7.收货上架数量_组
        ,t7.收货上架数量_人数_组
        ,t7.补货上架
        ,t7.补货上架_组
        ,t7.补货上架_人数_组
        ,t7.销退包裹量
        ,t7.销退包裹量_组
        ,t7.销退包裹量_人数_组
        ,t7.拦截件数
        ,t7.拦截件数_组
        ,t7.拦截件数_人数_组
        ,t7.拣货件数
        ,t7.拣货件数贴面单
        ,t7.拣货件数批量小
        ,t7.拣货件数批量中
        ,t7.拣货件数批量大
        ,t7.拣货件数批量超大
        ,t7.拣货件数信息不全
        ,t7.拣货件数小
        ,t7.拣货件数中
        ,t7.拣货件数大
        ,t7.拣货件数超大
        ,t7.打包件数
        ,t7.打包件数贴面单
        ,t7.打包件数批量小
        ,t7.打包件数批量中
        ,t7.打包件数批量大
        ,t7.打包件数批量超大
        ,t7.打包件数PE
        ,t7.打包件数小
        ,t7.打包件数中
        ,t7.打包件数大
        ,t7.打包件数超大
        ,t7.打包件数信息不全
        ,t7.出库包裹数
        ,t7.出库包裹数贴面单
        ,t7.出库包裹数PE
        ,t7.出库包裹数小
        ,t7.出库包裹数中
        ,t7.出库包裹数大
        ,t7.出库包裹数超大
        ,t7.出库包裹数信息不全
        ,t7.收货件数
        ,t7.收货件数_组
        ,t7.收货件数_人数_组
        ,t7.打包件数2B
        ,t7.打包件数2B_组
        ,t7.打包件数2B_人数_组
        ,t7.类型
        ,t7.人效目标
        ,t7.成本价
        ,t7.一阶目标
        ,t7.一阶单价
        ,t7.二阶目标
        ,t7.二阶单价
        ,t7.三阶目标
        ,t7.三阶单价
        ,t7.提成
        ,t7.提成add组长
        ,t7.拣货绩效系数
        ,t7.B2C交接及时率_权重绩效系数
        ,t7.B2C发货及时率_权重绩效系数
        ,t7.组提成
        ,t7.组内人均提成
    	,t7.组内人均提成add组长
        ,t7.pick_charge
        ,t7.pack_charge
        ,t7.out_charge
        ,t7.拣货支援提成
        ,t7.打包支援提成
        ,t7.出库支援提成
        ,t7.拣货支援提成上限
        ,t7.打包支援提成上限
        ,t7.出库支援提成上限
        ,t7.组内人均提成add组长add支援提成
        ,t7.收货及时率_采购权重绩效系数
        ,t7.上架及时率_采购权重绩效系数
        ,t7.上架及时率_销退权重绩效系数
        ,t7.B2B打包及时率_权重绩效系数
        ,t7.拦截归位及时率（24H）_权重绩效系数
        ,t7.组内人均提成add组长add支援提成add组长系数
        ,t7.组内人均提成add组长add支援提成add组长系数addkpi
        ,t7.组内人均提成add组长add支援提成add组长系数addkpi求和
        ,(t7.组内人均提成add组长add支援提成add组长系数addkpi / NULLIF(t7.组内人均提成add组长add支援提成add组长系数addkpi求和, 0)) * t7.组内人均提成add组长add支援提成add组长系数求和 组内人均提成add组长add支援提成add组长系数addkpi提成
        ,t71.旷工请假折算系数
        ,t71.hire_date
        ,t71.leave_date
        ,t7.支援提成合计
        -- ,(t7.个人KPI金额 / t7.个人KPI金额求和) * t7.提成组长绩效系数提成求和 实发提成
    from
    (
        select
            t6.title
            ,t6.月份
            ,t6.仓库
            ,t6.ID
            ,t6.姓名
            ,t6.岗位
            ,t6.职级
            ,t6.KPI
            ,t6.收货上架数量
            ,t6.收货上架数量_组
            ,t6.收货上架数量_人数_组
            ,t6.补货上架
            ,t6.补货上架_组
            ,t6.补货上架_人数_组
            ,t6.销退包裹量
            ,t6.销退包裹量_组
            ,t6.销退包裹量_人数_组
            ,t6.拦截件数
            ,t6.拦截件数_组
            ,t6.拦截件数_人数_组
            ,t6.拣货件数
            ,t6.拣货件数贴面单
            ,t6.拣货件数批量小
            ,t6.拣货件数批量中
            ,t6.拣货件数批量大
            ,t6.拣货件数批量超大
            ,t6.拣货件数信息不全
            ,t6.拣货件数小
            ,t6.拣货件数中
            ,t6.拣货件数大
            ,t6.拣货件数超大
            ,t6.打包件数
            ,t6.打包件数贴面单
            ,t6.打包件数批量小
            ,t6.打包件数批量中
            ,t6.打包件数批量大
            ,t6.打包件数批量超大
            ,t6.打包件数PE
            ,t6.打包件数小
            ,t6.打包件数中
            ,t6.打包件数大
            ,t6.打包件数超大
            ,t6.打包件数信息不全
            ,t6.出库包裹数
            ,t6.出库包裹数贴面单
            ,t6.出库包裹数PE
            ,t6.出库包裹数小
            ,t6.出库包裹数中
            ,t6.出库包裹数大
            ,t6.出库包裹数超大
            ,t6.出库包裹数信息不全
            ,t6.收货件数
            ,t6.收货件数_组
            ,t6.收货件数_人数_组
            ,t6.打包件数2B
            ,t6.打包件数2B_组
            ,t6.打包件数2B_人数_组
            ,t6.类型
            ,t6.人效目标
            ,t6.成本价
            ,t6.一阶目标
            ,t6.一阶单价
            ,t6.二阶目标
            ,t6.二阶单价
            ,t6.三阶目标
            ,t6.三阶单价
            ,t6.提成
            ,t6.提成add组长
            ,t6.拣货绩效系数
            ,t6.B2C交接及时率_权重绩效系数
            ,t6.B2C发货及时率_权重绩效系数
            ,t6.组提成
            ,t6.组内人均提成
	        ,t6.组内人均提成add组长
            ,t6.pick_charge
            ,t6.pack_charge
            ,t6.out_charge
            ,t6.拣货支援提成
            ,t6.打包支援提成
            ,t6.出库支援提成
            ,t6.拣货支援提成上限
            ,t6.打包支援提成上限
            ,t6.出库支援提成上限
            ,t6.组内人均提成add组长add支援提成
            ,t6.收货及时率_采购权重绩效系数
            ,t6.上架及时率_采购权重绩效系数
            ,t6.上架及时率_销退权重绩效系数
            ,t6.B2B打包及时率_权重绩效系数
            ,t6.拦截归位及时率（24H）_权重绩效系数
            ,t6.组内人均提成add组长add支援提成add组长系数
            ,t6.组内人均提成add组长add支援提成add组长系数addkpi
            ,sum(t6.组内人均提成add组长add支援提成add组长系数addkpi) over(partition by t6.仓库) 组内人均提成add组长add支援提成add组长系数addkpi求和
            ,sum(t6.组内人均提成add组长add支援提成add组长系数) over(partition by t6.仓库) 组内人均提成add组长add支援提成add组长系数求和
            ,t6.支援提成合计
        from
        (
            select
                title
                ,t4.月份
                ,t4.仓库
                ,t4.ID
                ,t4.姓名
                ,t4.岗位
                ,t4.职级
                ,t4.KPI
                ,t4.收货上架数量
                ,null 收货上架数量_组
                ,null 收货上架数量_人数_组
                ,t4.补货上架
                ,null 补货上架_组
                ,null 补货上架_人数_组
                ,t4.销退包裹量
                ,null 销退包裹量_组
                ,null 销退包裹量_人数_组
                ,t4.拦截件数
                ,null 拦截件数_组
                ,null 拦截件数_人数_组
                ,t4.拣货件数
                ,t4.拣货件数贴面单
                ,t4.拣货件数批量小
                ,t4.拣货件数批量中
                ,t4.拣货件数批量大
                ,t4.拣货件数批量超大
                ,t4.拣货件数信息不全
                ,t4.拣货件数小
                ,t4.拣货件数中
                ,t4.拣货件数大
                ,t4.拣货件数超大
                ,t4.打包件数
                ,t4.打包件数贴面单
                ,t4.打包件数批量小
                ,t4.打包件数批量中
                ,t4.打包件数批量大
                ,t4.打包件数批量超大
                ,t4.打包件数PE
                ,t4.打包件数小
                ,t4.打包件数中
                ,t4.打包件数大
                ,t4.打包件数超大
                ,t4.打包件数信息不全
                ,t4.出库包裹数
                ,t4.出库包裹数贴面单
                ,t4.出库包裹数PE
                ,t4.出库包裹数小
                ,t4.出库包裹数中
                ,t4.出库包裹数大
                ,t4.出库包裹数超大
                ,t4.出库包裹数信息不全
                ,t4.收货件数
                ,null 收货件数_组
                ,null 收货件数_人数_组
                ,t4.打包件数2B
                ,null 打包件数2B_组
                ,null 打包件数2B_人数_组
                ,t4.类型
                ,t4.人效目标
                ,t4.成本价
                ,t4.一阶目标
                ,t4.一阶单价
                ,t4.二阶目标
                ,t4.二阶单价
                ,t4.三阶目标
                ,t4.三阶单价
                ,t4.提成
                ,t4.提成add组长
                ,t4.拣货绩效系数
                ,t4.B2C交接及时率_权重绩效系数
                ,t4.B2C发货及时率_权重绩效系数
                ,null 组提成
                ,null 组内人均提成
		        ,null 组内人均提成add组长
                ,null pick_charge
                ,null pack_charge
                ,null out_charge
                ,null 拣货支援提成
                ,null 打包支援提成
                ,null 出库支援提成
                ,null 拣货支援提成上限
                ,null 打包支援提成上限
                ,null 出库支援提成上限
                ,t4.提成add组长 组内人均提成add组长add支援提成
                ,null 收货及时率_采购权重绩效系数
                ,null 上架及时率_采购权重绩效系数
                ,null 上架及时率_销退权重绩效系数
                ,null B2B打包及时率_权重绩效系数
                ,null 拦截归位及时率（24H）_权重绩效系数
                ,t4.提成add组长add组长系数 组内人均提成add组长add支援提成add组长系数
                ,t4.提成add组长add组长系数 * t4.KPI 组内人均提成add组长add支援提成add组长系数addkpi -- 个人提成组长没有支援提成，组队提成有支援提成
                ,null 支援提成合计
            from
            dwm.dwm_th_ffm_indvcomm_month t4
            where 月份>='2025-01'
            union all
            select
                t5.title
                ,t5.月份
                ,t5.仓库
                ,t5.ID
                ,t5.姓名
                ,t5.岗位
                ,t5.职级
                ,t5.KPI
                ,t5.收货上架数量
                ,t5.收货上架数量_组
                ,t5.收货上架数量_人数_组
                ,t5.补货上架
                ,t5.补货上架_组
                ,t5.补货上架_人数_组
                ,t5.销退包裹量
                ,t5.销退包裹量_组
                ,t5.销退包裹量_人数_组
                ,t5.拦截件数
                ,t5.拦截件数_组
                ,t5.拦截件数_人数_组
                ,t5.拣货件数
                ,t5.拣货件数贴面单
                ,t5.拣货件数批量小
                ,t5.拣货件数批量中
                ,t5.拣货件数批量大
                ,t5.拣货件数批量超大
                ,t5.拣货件数信息不全
                ,t5.拣货件数小
                ,t5.拣货件数中
                ,t5.拣货件数大
                ,t5.拣货件数超大
                ,t5.打包件数
                ,t5.打包件数贴面单
                ,t5.打包件数批量小
                ,t5.打包件数批量中
                ,t5.打包件数批量大
                ,t5.打包件数批量超大
                ,t5.打包件数PE
                ,t5.打包件数小
                ,t5.打包件数中
                ,t5.打包件数大
                ,t5.打包件数超大
                ,t5.打包件数信息不全
                ,t5.出库包裹数
                ,t5.出库包裹数贴面单
                ,t5.出库包裹数PE
                ,t5.出库包裹数小
                ,t5.出库包裹数中
                ,t5.出库包裹数大
                ,t5.出库包裹数超大
                ,t5.出库包裹数信息不全
                ,t5.收货件数
                ,t5.收货件数_组
                ,t5.收货件数_人数_组
                ,t5.打包件数2B
                ,t5.打包件数2B_组
                ,t5.打包件数2B_人数_组
                ,t5.类型
                ,t5.人效目标
                ,t5.成本价
                ,t5.一阶目标
                ,t5.一阶单价
                ,t5.二阶目标
                ,t5.二阶单价
                ,t5.三阶目标
                ,t5.三阶单价
                ,null 提成
                ,null 提成组长
                ,null 拣货绩效系数
                ,null B2C交接及时率_权重绩效系数
                ,null B2C发货及时率_权重绩效系数
                ,t5.组提成
                ,t5.组内人均提成
		        ,t5.组内人均提成add组长
                ,t5.pick_charge
                ,t5.pack_charge
                ,t5.out_charge
                ,t5.拣货支援提成
                ,t5.打包支援提成
                ,t5.出库支援提成
                ,t5.拣货支援提成上限
                ,t5.打包支援提成上限
                ,t5.出库支援提成上限
                ,t5.组内人均提成add组长add支援提成
                ,t5.收货及时率_采购权重绩效系数
                ,t5.上架及时率_采购权重绩效系数
                ,t5.上架及时率_销退权重绩效系数
                ,t5.B2B打包及时率_权重绩效系数
                ,t5.拦截归位及时率（24H）_权重绩效系数
                ,t5.组内人均提成add组长add支援提成add组长系数
                ,t5.组内人均提成add组长add支援提成add组长系数 * t5.KPI 组内人均提成add组长add支援提成add组长系数addkpi
                ,支援提成合计
            from
            dwm.dwm_th_ffm_teamcomm_month t5
            where 月份>='2025-01'
        ) t6
    ) t7
    left join
    (
        select
            staff_info_id
            ,hire_date
            ,leave_date
            ,mth
            ,case
                when skipwork_days > 0 then 0
                when leave_days > 3 then 0
                when fact_required_attend_flag <= 0 then 0
                when leave_days > 2 and leave_days <= 3 then 0.6
                when leave_days > 1 and leave_days <= 2 then 0.75
                when leave_days <= 1 then 1
            end 旷工请假折算系数
            ,fact_required_attend_flag
            ,attendance_days
            ,skipwork_days
            ,leave_days
            ,is_on_job
        from
        (
            select
                staff_info_id
                ,hire_date
                ,left(stat_date, 7) mth
                ,min(is_on_job) is_on_job
                ,max(leave_date) leave_date
                ,sum(skipwork_days) skipwork_days
                ,sum(leave_days) leave_days
                ,sum(fact_required_attend_flag) fact_required_attend_flag
                ,sum(attendance_days) attendance_days
            from
            dwm.dwd_th_ffm_staff_dayV3
            where 1=1
#                 and left(stat_date, 7) = '2025-02'
            group by 1,2,3
        ) t_staff
    ) t71 on t7.ID = t71.staff_info_id and t7.月份 = t71.mth
) t8
order by t8.title,t8.岗位,t8.职级;

