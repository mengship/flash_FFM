select * from dwm.dwm_th_ffm_staffcommission_month
where 仓库 in ('BST', 'AGV', 'LAS', 'BPL-Return')
and 月份>='2025-05'
and 月份<='2025-05'
;


-- th_ffm_sumcommission_month
SELECT
    ''
    ,t0.月份
    ,t0.仓库
    ,t0.岗位
    ,t0.title
    ,db.人效目标
    ,db.成本价
    ,db.一阶目标
    ,db.一阶单价
    ,db.二阶目标
    ,db.二阶单价
    ,db.三阶目标
    ,db.三阶单价
    ,case when t0.岗位='Picking' then sum(t0.拣货件数)
        when t0.岗位='Packing' then sum(t0.打包件数)
        when t0.岗位='Handover' then sum(t0.出库包裹数)

        when t0.岗位='B2B' then max(t0.打包件数2B_组)
        when t0.岗位='Inbound' then max(t0.收货件数_组)
        when t0.岗位='Putaway' then max(t0.收货上架数量_组)
        when t0.岗位='Return' then max(t0.销退包裹量_组)
        when t0.岗位='Intercept' then max(t0.拦截件数_组)
        when t0.岗位='Replenish' then max(t0.补货上架_组)
        end as 业务量
    ,count(distinct ID) 人数
    ,case when t0.岗位='Picking' then sum(t0.拣货金额)
        when t0.岗位='Packing' then sum(t0.打包金额)
        when t0.岗位='Handover' then sum(t0.出库金额)
        end as 个人提成
    ,case when t0.岗位='B2B' then sum(t0.B2B)
        when t0.岗位='Inbound' then sum(t0.收货)
        when t0.岗位='Putaway' then sum(t0.上架)
        when t0.岗位='Return' then sum(t0.销退)
        when t0.岗位='Intercept' then sum(t0.拦截)
        when t0.岗位='Replenish' then sum(t0.补货)
        end as 组别提成
    ,sum(t0.支援提成合计) as 支援提成
    ,sum(t0.主管提成) 主管提成
    ,sum(t0.全勤奖) 全勤奖
    ,sum(t0.实发) 实发
    ,sum(t0.实发)/count(distinct t0.ID) 人均
from dwm.dwm_th_ffm_staffcommission_month t0
left join tmpale.tmp_th_dim_bonusparameter db on t0.岗位 = db.环节 and t0.仓库 = db.仓库
where t0.仓库 in ('BST', 'AGV', 'LAS', 'BPL-Return')
and t0.月份='2025-05'
group by 1,2,3,4
order by t0.title,t0.岗位;