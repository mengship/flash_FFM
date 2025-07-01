/*=====================================================================+
表名称：  dwm_th_ffm_teamcomm_month
功能描述：  泰国ffm 仓库组提成

需求来源：
编写人员: 王昱棋
设计日期：2025/03/18
修改日期:
修改人员:
修改原因:

-----------------------------------------------------------------------
---存在问题：
-----------------------------------------------------------------------
+===================================================================== */

# drop table if exists dwm.dwm_th_ffm_teamcomm_month;
# create table dwm.dwm_th_ffm_teamcomm_month as
-- delete from dwm.dwm_th_ffm_teamcomm_month where 月份 = substr(date_sub(now()+ interval -1 hour,interval 1 month), 1,7); -- 先删除上个月数据 '2025-02'
-- insert into dwm.dwm_th_ffm_teamcomm_month -- 再插入数据

-- team commission_old
-- 针对主管计算绩效系数提成
select
    t4.title
    ,t4.月份
    ,t4.仓库
    ,t4.ID
    ,t4.姓名
    ,t4.岗位
    ,t4.职级
    ,t4.KPI
    ,t4.收货上架数量
    ,t4.收货上架数量_组
    ,t4.收货上架数量_人数_组
    ,t4.补货上架
    ,t4.补货上架_组
    ,t4.补货上架_人数_组
    ,t4.销退包裹量
    ,t4.销退包裹量_组
    ,t4.销退包裹量_人数_组
    ,t4.拦截件数
    ,t4.拦截件数_组
    ,t4.拦截件数_人数_组
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
    ,t4.收货件数_组
    ,t4.收货件数_人数_组
    ,t4.打包件数2B
    ,t4.打包件数2B_组
    ,t4.打包件数2B_人数_组
    ,t4.类型
    ,t4.人效目标
    ,t4.成本价
    ,t4.一阶目标
    ,t4.一阶单价
    ,t4.二阶目标
    ,t4.二阶单价
    ,t4.三阶目标
    ,t4.三阶单价
    ,t4.组提成
    ,t4.组内人均提成
    ,t4.组内人均提成add组长
    ,t4.pick_charge
    ,t4.pack_charge
    ,t4.out_charge
    ,t4.拣货支援提成
    ,t4.打包支援提成
    ,t4.出库支援提成
    ,t4.拣货支援提成上限
    ,t4.打包支援提成上限
    ,t4.出库支援提成上限
    ,t4.组内人均提成add组长add支援提成
    ,eff.收货及时率_采购权重绩效系数
    ,eff.上架及时率_采购权重绩效系数
    ,eff.上架及时率_销退权重绩效系数
    ,eff.B2B打包及时率_权重绩效系数
    ,eff.拦截归位及时率（24H）_权重绩效系数
    ,case
        when t4.职级 in ('组长', '主管') and t4.岗位='Putaway' then t4.组内人均提成add组长add支援提成 * eff.上架及时率_采购权重绩效系数
        when t4.职级 in ('组长', '主管') and t4.岗位='Replenish' then t4.组内人均提成add组长add支援提成 * 1
        when t4.职级 in ('组长', '主管') and t4.岗位='Return' then t4.组内人均提成add组长add支援提成 * eff.上架及时率_销退权重绩效系数
        when t4.职级 in ('组长', '主管') and t4.岗位='Intercept' then t4.组内人均提成add组长add支援提成 * eff.拦截归位及时率（24H）_权重绩效系数
        when t4.职级 in ('组长', '主管') and t4.岗位='Inbound' then t4.组内人均提成add组长add支援提成 * eff.收货及时率_采购权重绩效系数
        when t4.职级 in ('组长', '主管') and t4.岗位='B2B' then t4.组内人均提成add组长add支援提成 * eff.B2B打包及时率_权重绩效系数
        else t4.组内人均提成add组长add支援提成
        end as 组内人均提成add组长add支援提成add组长系数
    ,支援提成合计
from
( -- 组内人的支援提成
    select
        title
        ,月份
        ,仓库
        ,ID
        ,姓名
        ,岗位
        ,职级
        ,KPI
        ,收货上架数量
        ,收货上架数量_组
        ,收货上架数量_人数_组
        ,补货上架
        ,补货上架_组
        ,补货上架_人数_组
        ,销退包裹量
        ,销退包裹量_组
        ,销退包裹量_人数_组
        ,拦截件数
        ,拦截件数_组
        ,拦截件数_人数_组
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
        ,收货件数
        ,收货件数_组
        ,收货件数_人数_组
        ,打包件数2B
        ,打包件数2B_组
        ,打包件数2B_人数_组
        ,类型
        ,人效目标
        ,成本价
        ,一阶目标
        ,一阶单价
        ,二阶目标
        ,二阶单价
        ,三阶目标
        ,三阶单价
        ,组提成
        ,组内人均提成
        ,组内人均提成add组长
        ,pick_charge
        ,pack_charge
        ,out_charge
        ,cast(ifnull(拣货件数, 0) * pick_charge as decimal) 拣货支援提成
        ,cast(ifnull(打包件数, 0) * pack_charge as decimal) 打包支援提成
        ,cast(ifnull(出库包裹数, 0) * out_charge as decimal) 出库支援提成
        ,if(拣货件数*pick_charge>1500, 1500, 拣货件数*pick_charge) 拣货支援提成上限
        ,if(打包件数*pack_charge>1500, 1500, 打包件数*pack_charge) 打包支援提成上限
        ,if(出库包裹数*out_charge>1500, 1500, 出库包裹数*out_charge) 出库支援提成上限
        ,IFNULL(if(ifnull(拣货件数, 0)*pick_charge + ifnull(打包件数, 0)*pack_charge + ifnull(出库包裹数, 0)*out_charge >1500, 1500, ifnull(拣货件数, 0)*pick_charge + ifnull(打包件数, 0)*pack_charge + ifnull(出库包裹数, 0)*out_charge), 0) 支援提成合计
        ,IFNULL(组内人均提成add组长, 0) + IFNULL(if(ifnull(拣货件数, 0)*pick_charge + ifnull(打包件数, 0)*pack_charge + ifnull(出库包裹数, 0)*out_charge >1500, 1500, ifnull(拣货件数, 0)*pick_charge + ifnull(打包件数, 0)*pack_charge + ifnull(出库包裹数, 0)*out_charge), 0) 组内人均提成add组长add支援提成
    from
    (
        select -- 组内组长提成*1.5
            title
            ,月份
            ,t2.仓库
            ,ID
            ,姓名
            ,岗位
            ,职级
            ,KPI
            ,收货上架数量
            ,收货上架数量_组
            ,收货上架数量_人数_组
            ,补货上架
            ,补货上架_组
            ,补货上架_人数_组
            ,销退包裹量
            ,销退包裹量_组
            ,销退包裹量_人数_组
            ,拦截件数
            ,拦截件数_组
            ,拦截件数_人数_组
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
            ,收货件数
            ,收货件数_组
            ,收货件数_人数_组
            ,打包件数2B
            ,打包件数2B_组
            ,打包件数2B_人数_组
            ,类型
            ,人效目标
            ,成本价
            ,一阶目标
            ,一阶单价
            ,二阶目标
            ,二阶单价
            ,三阶目标
            ,三阶单价
            ,组提成
            ,组内人均提成
            ,if(职级 in ('组长', '主管'), 组内人均提成*1.5, 组内人均提成) 组内人均提成add组长 -- 组长提成是平均的1.5倍
            ,t21.pick_charge
            ,t21.pack_charge
            ,t21.out_charge
        from
        ( -- 每个组的工作量计算提成 呈阶梯分布，并均分到组内的每个人
            select
                title
                ,月份
                ,仓库
                ,ID
                ,姓名
                ,岗位
                ,职级
                ,KPI
                ,收货上架数量
                ,收货上架数量_组
                ,收货上架数量_人数_组
                ,补货上架
                ,补货上架_组
                ,补货上架_人数_组
                ,销退包裹量
                ,销退包裹量_组
                ,销退包裹量_人数_组
                ,拦截件数
                ,拦截件数_组
                ,拦截件数_人数_组
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
                ,收货件数
                ,收货件数_组
                ,收货件数_人数_组
                ,打包件数2B
                ,打包件数2B_组
                ,打包件数2B_人数_组
                ,类型
                ,人效目标
                ,成本价
                ,一阶目标
                ,一阶单价
                ,二阶目标
                ,二阶单价
                ,三阶目标
                ,三阶单价
                ,case when 岗位='Putaway' and 收货上架数量_组 < 一阶目标 then 0
                    when 岗位='Putaway' and 收货上架数量_组 < 二阶目标 then (收货上架数量_组 - 一阶目标) * 一阶单价
                    when 岗位='Putaway' and 收货上架数量_组 < 三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (收货上架数量_组 - 二阶目标) * 二阶单价
                    when 岗位='Putaway' and 收货上架数量_组 >= 三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (收货上架数量_组 - 三阶目标) * 三阶单价

                    when 岗位='Replenish' and 补货上架_组 <  一阶目标 then 0
                    when 岗位='Replenish' and 补货上架_组 <  二阶目标 then (补货上架_组 - 一阶目标) * 一阶单价
                    when 岗位='Replenish' and 补货上架_组 <  三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (补货上架_组 - 二阶目标) * 二阶单价
                    when 岗位='Replenish' and 补货上架_组 >= 三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (补货上架_组 - 三阶目标) * 三阶单价

                    when 岗位='Return' and 销退包裹量_组 < 一阶目标 then 0
                    when 岗位='Return' and 销退包裹量_组 < 二阶目标 then (销退包裹量_组 - 一阶目标) * 一阶单价
                    when 岗位='Return' and 销退包裹量_组 < 三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (销退包裹量_组 - 二阶目标) * 二阶单价
                    when 岗位='Return' and 销退包裹量_组 >= 三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (销退包裹量_组 - 三阶目标) * 三阶单价

                    when 岗位='Intercept' and 拦截件数_组 <  一阶目标 then 0
                    when 岗位='Intercept' and 拦截件数_组 <  二阶目标 then (拦截件数_组 - 一阶目标) * 一阶单价
                    when 岗位='Intercept' and 拦截件数_组 <  三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (拦截件数_组 - 二阶目标) * 二阶单价
                    when 岗位='Intercept' and 拦截件数_组 >= 三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (拦截件数_组 - 三阶目标) * 三阶单价

                    when 岗位='Inbound' and 收货件数_组 <  一阶目标 then 0
                    when 岗位='Inbound' and 收货件数_组 <  二阶目标 then (收货件数_组 - 一阶目标) * 一阶单价
                    when 岗位='Inbound' and 收货件数_组 <  三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (收货件数_组 - 二阶目标) * 二阶单价
                    when 岗位='Inbound' and 收货件数_组 >= 三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (收货件数_组 - 三阶目标) * 三阶单价

                    when 岗位='B2B' and 打包件数2B_组 <  一阶目标 then 0
                    when 岗位='B2B' and 打包件数2B_组 <  二阶目标 then (打包件数2B_组 - 一阶目标) * 一阶单价
                    when 岗位='B2B' and 打包件数2B_组 <  三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (打包件数2B_组 - 二阶目标) * 二阶单价
                    when 岗位='B2B' and 打包件数2B_组 >= 三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (打包件数2B_组 - 三阶目标) * 三阶单价

                end as 组提成
                ,case
                    when 岗位='Putaway' and 收货上架数量_组 < 一阶目标 then 0/收货上架数量_人数_组
                    when 岗位='Putaway' and 收货上架数量_组 <  二阶目标 then (收货上架数量_组 - 一阶目标) * 一阶单价/收货上架数量_人数_组
                    when 岗位='Putaway' and 收货上架数量_组 <  三阶目标 then ((二阶目标 - 一阶目标) * 一阶单价 + (收货上架数量_组 - 二阶目标) * 二阶单价) / 收货上架数量_人数_组
                    when 岗位='Putaway' and 收货上架数量_组 >= 三阶目标 then ((二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (收货上架数量_组 - 三阶目标) * 三阶单价) / 收货上架数量_人数_组

                    when 岗位='Replenish' and 补货上架_组 <  一阶目标 then 0 / 补货上架_人数_组
                    when 岗位='Replenish' and 补货上架_组 <  二阶目标 then (补货上架_组 - 一阶目标) * 一阶单价 / 补货上架_人数_组
                    when 岗位='Replenish' and 补货上架_组 <  三阶目标 then ((二阶目标 - 一阶目标) * 一阶单价 + (补货上架_组 - 二阶目标) * 二阶单价) / 补货上架_人数_组
                    when 岗位='Replenish' and 补货上架_组 >= 三阶目标 then ((二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (补货上架_组 - 三阶目标) * 三阶单价) / 补货上架_人数_组

                    when 岗位='Return' and 销退包裹量_组 <  一阶目标 then 0 / 销退包裹量_人数_组
                    when 岗位='Return' and 销退包裹量_组 <  二阶目标 then (销退包裹量_组 - 一阶目标) * 一阶单价 / 销退包裹量_人数_组
                    when 岗位='Return' and 销退包裹量_组 <  三阶目标 then ((二阶目标 - 一阶目标) * 一阶单价 + (销退包裹量_组 - 二阶目标) * 二阶单价) / 销退包裹量_人数_组
                    when 岗位='Return' and 销退包裹量_组 >= 三阶目标 then ((二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (销退包裹量_组 - 三阶目标) * 三阶单价) / 销退包裹量_人数_组

                    when 岗位='Intercept' and 拦截件数_组 <  一阶目标 then 0 / 拦截件数_人数_组
                    when 岗位='Intercept' and 拦截件数_组 <  二阶目标 then (拦截件数_组 - 一阶目标) * 一阶单价 / 拦截件数_人数_组
                    when 岗位='Intercept' and 拦截件数_组 <  三阶目标 then ((二阶目标 - 一阶目标) * 一阶单价 + (拦截件数_组 - 二阶目标) * 二阶单价) / 拦截件数_人数_组
                    when 岗位='Intercept' and 拦截件数_组 >= 三阶目标 then ((二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (拦截件数_组 - 三阶目标) * 三阶单价) / 拦截件数_人数_组

                    when 岗位='Inbound' and 收货件数_组 <  一阶目标 then 0 / 收货件数_人数_组
                    when 岗位='Inbound' and 收货件数_组 <  二阶目标 then (收货件数_组 - 一阶目标) * 一阶单价 / 收货件数_人数_组
                    when 岗位='Inbound' and 收货件数_组 <  三阶目标 then ((二阶目标 - 一阶目标) * 一阶单价 + (收货件数_组 - 二阶目标) * 二阶单价) / 收货件数_人数_组
                    when 岗位='Inbound' and 收货件数_组 >= 三阶目标 then ((二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (收货件数_组 - 三阶目标) * 三阶单价) / 收货件数_人数_组

                    when 岗位='B2B' and 打包件数2B_组 <  一阶目标 then 0 / 打包件数2B_人数_组
                    when 岗位='B2B' and 打包件数2B_组 <  二阶目标 then (打包件数2B_组 - 一阶目标) * 一阶单价 / 打包件数2B_人数_组
                    when 岗位='B2B' and 打包件数2B_组 <  三阶目标 then ((二阶目标 - 一阶目标) * 一阶单价 + (打包件数2B_组 - 二阶目标) * 二阶单价) / 打包件数2B_人数_组
                    when 岗位='B2B' and 打包件数2B_组 >= 三阶目标 then ((二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (打包件数2B_组 - 三阶目标) * 三阶单价) / 打包件数2B_人数_组
                end as 组内人均提成
            from
            ( -- 每个组的工作量求和
                select
                    '组提成' title
                    ,tw.月份
                    ,tw.仓库
                    ,tw.ID
                    ,tw.姓名
                    ,tw.岗位
                    ,tw.职级
                    ,tw.KPI
                    ,ifnull(tw.收货上架数量, 0) 收货上架数量
                    ,if(tw.岗位='Putaway', sum(ifnull(tw.收货上架数量, 0)) over(partition by tw.仓库,tw.月份), 0) 收货上架数量_组 -- 把其他组的工作量，也算到上架组，其他逻辑类似
                    ,if(tw.岗位='Putaway', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0) 收货上架数量_人数_组
                    ,ifnull(tw.补货上架, 0) 补货上架
                    ,if(tw.岗位='Replenish', sum(ifnull(tw.补货上架, 0)) over(partition by tw.仓库,tw.月份), 0) 补货上架_组
                    ,if(tw.岗位='Replenish', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0) 补货上架_人数_组
                    ,ifnull(tw.销退包裹量, 0) 销退包裹量
                    ,if(tw.岗位='Return', sum(ifnull(tw.销退包裹量, 0)) over(partition by tw.仓库,tw.月份), 0) 销退包裹量_组
                    ,if(tw.岗位='Return', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0) 销退包裹量_人数_组
                    ,ifnull(tw.拦截件数, 0) 拦截件数
                    ,if(tw.岗位='Intercept', sum(ifnull(tw.拦截件数, 0)) over(partition by tw.仓库,tw.月份), 0) 拦截件数_组
                    ,if(tw.岗位='Intercept', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0) 拦截件数_人数_组
                    ,ifnull(tw.拣货件数, 0) 拣货件数
                    ,ifnull(tw.拣货件数贴面单, 0) 拣货件数贴面单
                    ,ifnull(tw.拣货件数批量小, 0) 拣货件数批量小
                    ,ifnull(tw.拣货件数批量中, 0) 拣货件数批量中
                    ,ifnull(tw.拣货件数批量大, 0) 拣货件数批量大
                    ,ifnull(tw.拣货件数批量超大, 0) 拣货件数批量超大
                    ,ifnull(tw.拣货件数信息不全, 0) 拣货件数信息不全
                    ,ifnull(tw.拣货件数小, 0) 拣货件数小
                    ,ifnull(tw.拣货件数中, 0) 拣货件数中
                    ,ifnull(tw.拣货件数大, 0) 拣货件数大
                    ,ifnull(tw.拣货件数超大, 0) 拣货件数超大
                    ,ifnull(tw.打包件数, 0) 打包件数
                    ,ifnull(tw.打包件数贴面单, 0) 打包件数贴面单
                    ,ifnull(tw.打包件数批量小, 0) 打包件数批量小
                    ,ifnull(tw.打包件数批量中, 0) 打包件数批量中
                    ,ifnull(tw.打包件数批量大, 0) 打包件数批量大
                    ,ifnull(tw.打包件数批量超大, 0) 打包件数批量超大
                    ,ifnull(tw.打包件数PE, 0) 打包件数PE
                    ,ifnull(tw.打包件数小, 0) 打包件数小
                    ,ifnull(tw.打包件数中, 0) 打包件数中
                    ,ifnull(tw.打包件数大, 0) 打包件数大
                    ,ifnull(tw.打包件数超大, 0) 打包件数超大
                    ,ifnull(tw.打包件数信息不全, 0) 打包件数信息不全
                    ,ifnull(tw.出库包裹数, 0) 出库包裹数
                    ,ifnull(tw.出库包裹数贴面单, 0) 出库包裹数贴面单
                    ,ifnull(tw.出库包裹数PE, 0) 出库包裹数PE
                    ,ifnull(tw.出库包裹数小, 0) 出库包裹数小
                    ,ifnull(tw.出库包裹数中, 0) 出库包裹数中
                    ,ifnull(tw.出库包裹数大, 0) 出库包裹数大
                    ,ifnull(tw.出库包裹数超大, 0) 出库包裹数超大
                    ,ifnull(tw.出库包裹数信息不全, 0) 出库包裹数信息不全
                    ,ifnull(tw.收货件数, 0) 收货件数
                    ,if(tw.岗位='Inbound', sum(ifnull(tw.收货件数, 0)) over(partition by tw.仓库,tw.月份), 0) 收货件数_组
                    ,if(tw.岗位='Inbound', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0) 收货件数_人数_组
                    ,ifnull(tw.打包件数2B, 0) 打包件数2B
                    ,if(tw.岗位='B2B', sum(ifnull(tw.打包件数2B, 0)) over(partition by tw.仓库,tw.月份), 0) 打包件数2B_组
                    ,if(tw.岗位='B2B', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0) 打包件数2B_人数_组
                    ,tw.类型
                    ,tw.人效目标
                    ,tw.成本价
                    -- ,dim_p.一阶目标*8*26 一阶目标
                    ,case
                        when tw.岗位='Putaway' then tw.一阶目标*if(tw.岗位='Putaway', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='Replenish' then tw.一阶目标*if(tw.岗位='Replenish', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='Return' then tw.一阶目标*if(tw.岗位='Return', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='Intercept' then tw.一阶目标*if(tw.岗位='Intercept', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='Inbound' then tw.一阶目标*if(tw.岗位='Inbound', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='B2B' then tw.一阶目标*if(tw.岗位='B2B', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        end as 一阶目标
                    ,tw.一阶单价
                    -- ,tw.二阶目标
                    ,case
                        when tw.岗位='Putaway' then tw.二阶目标*if(tw.岗位='Putaway', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='Replenish' then tw.二阶目标*if(tw.岗位='Replenish', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='Return' then tw.二阶目标*if(tw.岗位='Return', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='Intercept' then tw.二阶目标*if(tw.岗位='Intercept', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='Inbound' then tw.二阶目标*if(tw.岗位='Inbound', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='B2B' then tw.二阶目标*if(tw.岗位='B2B', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        end as 二阶目标
                    ,tw.二阶单价
                    -- ,tw.三阶目标
                    ,case
                        when tw.岗位='Putaway' then tw.三阶目标*if(tw.岗位='Putaway', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='Replenish' then tw.三阶目标*if(tw.岗位='Replenish', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='Return' then tw.三阶目标*if(tw.岗位='Return', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='Intercept' then tw.三阶目标*if(tw.岗位='Intercept', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='Inbound' then tw.三阶目标*if(tw.岗位='Inbound', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        when tw.岗位='B2B' then tw.三阶目标*if(tw.岗位='B2B', count(tw.ID) over(partition by tw.仓库,tw.月份,tw.岗位), 0)
                        end as 三阶目标
                    ,tw.三阶单价
                from
                (
                    select
                        '组提成' title
                        ,ifnull(t_m.month,t0.月份) 月份
                        ,ifnull(t_m.warehouse_name,t0.仓库) 仓库
                        ,ifnull(t_m.staff_info_id,t0.id) ID
                        ,t0.姓名
                        ,t0.岗位
                        ,t0.职级
                        ,t0.KPI
                        ,t_m.收货上架数量
                        ,t_m.补货上架
                        ,t_m.销退包裹量
                        ,t_m.拦截件数
                        ,t_m.拣货件数
                        ,t_m.拣货件数贴面单
                        ,t_m.拣货件数批量小
                        ,t_m.拣货件数批量中
                        ,t_m.拣货件数批量大
                        ,t_m.拣货件数批量超大
                        ,t_m.拣货件数信息不全
                        ,t_m.拣货件数小
                        ,t_m.拣货件数中
                        ,t_m.拣货件数大
                        ,t_m.拣货件数超大
                        ,t_m.打包件数
                        ,t_m.打包件数贴面单
                        ,t_m.打包件数批量小
                        ,t_m.打包件数批量中
                        ,t_m.打包件数批量大
                        ,t_m.打包件数批量超大
                        ,t_m.打包件数PE
                        ,t_m.打包件数小
                        ,t_m.打包件数中
                        ,t_m.打包件数大
                        ,t_m.打包件数超大
                        ,t_m.打包件数信息不全
                        ,t_m.出库包裹数
                        ,t_m.出库包裹数贴面单
                        ,t_m.出库包裹数PE
                        ,t_m.出库包裹数小
                        ,t_m.出库包裹数中
                        ,t_m.出库包裹数大
                        ,t_m.出库包裹数超大
                        ,t_m.出库包裹数信息不全
                        ,t_m.收货件数
                        ,t_m.打包件数2B
                        ,dim_p.类型
                        ,dim_p.人效目标
                        ,dim_p.成本价
                        ,dim_p.一阶目标*8*26 一阶目标
                        ,dim_p.一阶单价
                        ,dim_p.二阶目标*8*26 二阶目标
                        ,dim_p.二阶单价
                        ,dim_p.三阶目标*8*26 三阶目标
                        ,dim_p.三阶单价
                    from
                    (
                        select
                            staff_info_id
                            ,warehouse_name
                            ,month
                            ,收货上架数量
                            ,补货上架
                            ,销退包裹量
                            ,拦截件数
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
                            ,收货件数
                            ,打包件数2B
                        from
                        dwm.dwm_th_ffm_staffworkload_month
                        -- where month= substr(date_sub(now()+ interval -1 hour,interval 1 month), 1,7) -- '2025-02'
                    ) t_m
                    full join
                    (
                        select
                            '组提成' title
                            ,月份
                            ,仓库
                            ,ID
                            ,姓名
                            ,岗位
                            ,职级
                            ,KPI
                            ,p_date
                        from dwm.tmp_th_ffm_staff_comm
                        -- where 岗位 in ('B2B','Inbound','Putaway','Return','Intercept','Replenish')
                    ) t0 on t0.ID = t_m.staff_info_id and t0.仓库 = t_m.warehouse_name and t0.月份 = t_m.month
                    left join tmpale.tmp_th_dim_bonusparameter dim_p on t0.岗位 = dim_p.环节 and ifnull(t_m.warehouse_name,t0.仓库) = dim_p.仓库
                ) tw

            ) t1
            where 岗位 in ('B2B','Inbound','Putaway','Return','Intercept','Replenish','仓经理','HO','Counting')
        ) t2
        left join -- 挂载 支援提成参数
        (
            select
                pick.仓库
                ,pick.pick_charge
                ,pack.pack_charge
                ,out.out_charge
            from
            (select 成本价 pick_charge,仓库 from tmpale.tmp_th_dim_bonusparameter where 环节='Picking') pick
            join
            (select 成本价 pack_charge,仓库 from tmpale.tmp_th_dim_bonusparameter where 环节='Packing') pack on pick.仓库=pack.仓库
            left join -- Handover没人，暂时用left join
            (select 成本价 out_charge,仓库 from tmpale.tmp_th_dim_bonusparameter where 环节='Handover') out on pick.仓库=out.仓库
        ) t21 on t2.仓库 = t21.仓库
    ) t3
) t4
left join dwm.dws_th_ffm_coefficient_month eff on t4.仓库 = eff.仓库 and t4.月份 = eff.month