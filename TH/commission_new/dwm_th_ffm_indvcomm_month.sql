
# drop table if exists dwm.dwm_th_ffm_indvcomm_month;
# create table dwm.dwm_th_ffm_indvcomm_month as
-- delete from dwm.dwm_th_ffm_indvcomm_month where 月份 = '2025-02'; -- 先删除上个月数据
-- insert into dwm.dwm_th_ffm_indvcomm_month -- 再插入数据

-- individual commission_old
select
    t3.title
    ,t3.月份
    ,t3.仓库
    ,t3.ID
    ,t3.姓名
    ,t3.岗位
    ,t3.职级
    ,t3.KPI
    ,t3.收货上架数量
    ,t3.补货上架
    ,t3.销退包裹量
    ,t3.拦截件数
    ,拣货件数
    ,拣货件数贴面单
    ,拣货件数批量小
    ,拣货件数批量中
    ,拣货件数批量大
    ,拣货件数批量超大
    ,拣货件数小
    ,拣货件数中
    ,拣货件数大
    ,拣货件数超大
    ,拣货件数信息不全
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
    ,t3.收货件数
    ,t3.打包件数2B
    ,t3.类型
    ,t3.人效目标
    ,t3.成本价
    ,t3.一阶目标
    ,t3.一阶单价
    ,t3.二阶目标
    ,t3.二阶单价
    ,t3.三阶目标
    ,t3.三阶单价
    ,t3.提成
    ,t3.提成add组长
    ,1 拣货绩效系数
    ,eff.B2C交接及时率_权重绩效系数
    ,eff.B2C发货及时率_权重绩效系数
    ,case
        when t3.职级 in ('组长', '主管') and t3.岗位='Packing' then t3.提成add组长 * eff.B2C交接及时率_权重绩效系数
        when t3.职级 in ('组长', '主管') and t3.岗位='Handover' then t3.提成add组长 * eff.B2C发货及时率_权重绩效系数
        else t3.提成add组长
        end as 提成add组长add组长系数
from
(
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
        ,补货上架
        ,销退包裹量
        ,拦截件数
        ,拣货件数
        ,拣货件数贴面单
        ,拣货件数批量小
        ,拣货件数批量中
        ,拣货件数批量大
        ,拣货件数批量超大
        ,拣货件数小
        ,拣货件数中
        ,拣货件数大
        ,拣货件数超大
        ,拣货件数信息不全
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
        ,类型
        ,人效目标
        ,成本价
        ,一阶目标
        ,一阶单价
        ,二阶目标
        ,二阶单价
        ,三阶目标
        ,三阶单价
        ,提成
        ,if(职级 in ('组长', '主管'), (sum(t2.提成) over(partition by t2.仓库,t2.岗位)) / (count(t2.ID) over(partition by t2.仓库,t2.岗位)) *1.5, 提成) 提成add组长 -- 组长提成是平均的1.5倍
    from
    (
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
            ,补货上架
            ,销退包裹量
            ,拦截件数
            ,拣货件数
            ,拣货件数贴面单
            ,拣货件数批量小
            ,拣货件数批量中
            ,拣货件数批量大
            ,拣货件数批量超大
            ,拣货件数小
            ,拣货件数中
            ,拣货件数大
            ,拣货件数超大
            ,拣货件数信息不全
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
            ,类型
            ,人效目标
            ,成本价
            ,一阶目标
            ,一阶单价
            ,二阶目标
            ,二阶单价
            ,三阶目标
            ,三阶单价
            ,case when 岗位='Picking' and 拣货件数 < 一阶目标 then 0
                when 岗位='Picking' and 拣货件数 < 二阶目标 then (拣货件数 - 一阶目标) * 一阶单价
                when 岗位='Picking' and 拣货件数 < 三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (拣货件数 - 二阶目标) * 二阶单价
                when 岗位='Picking' and 拣货件数 >= 三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (拣货件数 - 三阶目标) * 三阶单价

                when 岗位='Packing' and 打包件数 < 一阶目标 then 0
                when 岗位='Packing' and 打包件数 < 二阶目标 then (打包件数 - 一阶目标) * 一阶单价
                when 岗位='Packing' and 打包件数 < 三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (打包件数 - 二阶目标) * 二阶单价
                when 岗位='Packing' and 打包件数 >= 三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (打包件数 - 三阶目标) * 三阶单价

                when 岗位='Handover' and 出库包裹数 < 一阶目标 then 0
                when 岗位='Handover' and 出库包裹数 < 二阶目标 then (出库包裹数 - 一阶目标) * 一阶单价
                when 岗位='Handover' and 出库包裹数 < 三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (出库包裹数 - 二阶目标) * 二阶单价
                when 岗位='Handover' and 出库包裹数 >= 三阶目标 then (二阶目标 - 一阶目标) * 一阶单价 + (三阶目标 - 二阶目标) * 二阶单价 + (出库包裹数 - 三阶目标) * 三阶单价
            end as 提成
        from
        (
            select
                title
                ,t0.月份
                ,t0.仓库
                ,t0.ID
                ,t0.姓名
                ,t0.岗位
                ,t0.职级
                ,t0.KPI
                ,ifnull(t_m.收货上架数量, 0) 收货上架数量
                ,ifnull(t_m.补货上架, 0) 补货上架
                ,ifnull(t_m.销退包裹量, 0) 销退包裹量
                ,ifnull(t_m.拦截件数, 0) 拦截件数
                ,ifnull(t_m.拣货件数, 0) 拣货件数
                ,ifnull(t_m.拣货件数贴面单, 0) 拣货件数贴面单
                ,ifnull(t_m.拣货件数批量小, 0) 拣货件数批量小
                ,ifnull(t_m.拣货件数批量中, 0) 拣货件数批量中
                ,ifnull(t_m.拣货件数批量大, 0) 拣货件数批量大
                ,ifnull(t_m.拣货件数批量超大, 0) 拣货件数批量超大
                ,ifnull(t_m.拣货件数信息不全, 0) 拣货件数信息不全
                ,ifnull(t_m.拣货件数小, 0) 拣货件数小
                ,ifnull(t_m.拣货件数中, 0) 拣货件数中
                ,ifnull(t_m.拣货件数大, 0) 拣货件数大
                ,ifnull(t_m.拣货件数超大, 0) 拣货件数超大
                ,ifnull(t_m.打包件数, 0) 打包件数
                ,ifnull(t_m.打包件数贴面单, 0) 打包件数贴面单
                ,ifnull(t_m.打包件数批量小, 0) 打包件数批量小
                ,ifnull(t_m.打包件数批量中, 0) 打包件数批量中
                ,ifnull(t_m.打包件数批量大, 0) 打包件数批量大
                ,ifnull(t_m.打包件数批量超大, 0) 打包件数批量超大
                ,ifnull(t_m.打包件数PE, 0) 打包件数PE
                ,ifnull(t_m.打包件数小, 0) 打包件数小
                ,ifnull(t_m.打包件数中, 0) 打包件数中
                ,ifnull(t_m.打包件数大, 0) 打包件数大
                ,ifnull(t_m.打包件数超大, 0) 打包件数超大
                ,ifnull(t_m.打包件数信息不全, 0) 打包件数信息不全
                ,ifnull(t_m.出库包裹数, 0) 出库包裹数
                ,ifnull(t_m.出库包裹数贴面单, 0) 出库包裹数贴面单
                ,ifnull(t_m.出库包裹数PE, 0) 出库包裹数PE
                ,ifnull(t_m.出库包裹数小, 0) 出库包裹数小
                ,ifnull(t_m.出库包裹数中, 0) 出库包裹数中
                ,ifnull(t_m.出库包裹数大, 0) 出库包裹数大
                ,ifnull(t_m.出库包裹数超大, 0) 出库包裹数超大
                ,ifnull(t_m.出库包裹数信息不全, 0) 出库包裹数信息不全
                ,ifnull(t_m.收货件数, 0) 收货件数
                ,ifnull(t_m.打包件数2B, 0) 打包件数2B
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
                    '个人提成' title
                    ,月份
                    ,仓库
                    ,ID
                    ,姓名
                    ,岗位
                    ,职级
                    ,p_date
                    ,KPI
                from dwm.tmp_th_ffm_staff_comm
                where 岗位 in ('Picking' ,'Packing' ,'Handover')
                and id='699280'
            ) t0
            left join dwm.dwm_th_ffm_staffworkload_month t_m on t0.ID = t_m.staff_info_id and t0.仓库 = t_m.warehouse_name and t0.月份 = t_m.month
            left join tmpale.tmp_th_dim_bonusparameter dim_p on t0.岗位 = dim_p.环节 and t0.仓库 = dim_p.仓库
        ) t1
    ) t2
) t3
left join dwm.dws_th_ffm_coefficient_month eff on t3.仓库 = eff.仓库 and t3.月份 = eff.month
;


select
    *
from
dwm.dwm_th_ffm_staffworkload_month t_m
where staff_info_id='699280';

select
    *
from
dwm.dwm_th_ffm_indvcomm_month
where id='699280';



select *
from
    dwm.dwd_th_ffm_staff_dayV3
where staff_info_id='699280'
