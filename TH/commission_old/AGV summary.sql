-- outer layer 1
-- five
    ,if(物理仓='AGV',case
    #when	1=1 then  奖惩提成 addby 王昱棋 20240412 道麟哥的修改建议
        when 旷工 < 1 then 奖惩提成
        # when 事病假>3 then 0
        # else 奖惩提成
        end,case when 旷工>0 then 0
        when 请假>3 then 0
        when 应出勤<=0 then 0
        when 请假>2 and 请假<=3 then 奖惩提成/应出勤*出勤*0.6
        when 请假>1 and 请假<=2 then 奖惩提成/应出勤*出勤*0.75
        when 请假<=1 then 奖惩提成/应出勤*出勤
        end
        ) 应发提成

-- outer layer 2
-- five
,if(提成-IFNULL(业务罚款,0) -IFNULL(现场管理罚款,0) -IFNULL(考勤罚款,0) +全勤奖+奖励>0,提成-IFNULL(业务罚款,0) -IFNULL(现场管理罚款,0) -IFNULL(考勤罚款,0) +全勤奖+奖励,0) 奖惩提成

-- outer layer 3
-- four
when 物理仓='AGV' then 基础提成*提成系数

-- outer layer 4
-- four
else if(人均工作量提成金额+超额提成金额+支援提成金额+KPI提成金额+阶梯提成金额>0,人均工作量提成金额+超额提成金额+支援提成金额+KPI提成金额+阶梯提成金额,0)
    end 基础提成

-- outer layer 5
-- four
,sr.人均工作量提成金额 人均工作量提成金额
,超额提成金额
,支援提成金额
,KPI提成金额
,阶梯提成金额

-- outer layer 6
-- three
,超额提成工作量*超额系数/部门人数 人均工作量提成金额
,case when 物理仓='AGV' and 部门='Inbound' and 超额提成工作量>0 then 超额提成工作量*入库超额系数
    when 物理仓='AGV' and 部门='Inbound' and 超额提成工作量<=0 then 超额提成工作量*入库支援系数
    when 物理仓='AGV' and 部门='Picking' and 超额提成工作量>0 then 超额提成工作量*拣货超额系数
    when 物理仓='AGV' and 部门='Picking' and 超额提成工作量<=0 then 超额提成工作量*拣货支援系数
    when 物理仓='AGV' and 部门='Packing' and 超额提成工作量>0  then 超额提成工作量*打包超额系数
    when 物理仓='AGV' and 部门='Packing' and 超额提成工作量<=0  then 超额提成工作量*打包支援系数
    when 物理仓='AGV' and 部门='Outbound' and 超额提成工作量>0  then 超额提成工作量*出库超额系数
    when 物理仓='AGV' and 部门='Outbound' and 超额提成工作量<=0  then 超额提成工作量*出库支援系数
    -- else if(超额提成工作量-超额提成目标>0,(超额提成工作量-超额提成目标)*超额系数,0) / 部门人数
    else 0
    end 超额提成金额
,case when 物理仓='AGV' and 部门='Inbound' and 超额提成工作量>0 then Picking*拣货超额系数+Packing*打包超额系数+Outbound*出库超额系数
    when 物理仓='AGV' and 部门='Inbound' and 超额提成工作量<=0 then  Picking*拣货支援系数+Packing*打包支援系数+Outbound*出库支援系数
    when 物理仓='AGV' and 部门='Picking' and 超额提成工作量>0 then Inbound*入库超额系数+Packing*打包超额系数+Outbound*出库超额系数
    when 物理仓='AGV' and 部门='Picking' and 超额提成工作量<=0 then Inbound*入库支援系数/2+Packing*打包支援系数+Outbound*出库支援系数
    when 物理仓='AGV' and 部门='Packing' and 超额提成工作量>0  then Inbound*入库超额系数+Picking*拣货超额系数+Outbound*出库超额系数
    when 物理仓='AGV' and 部门='Packing' and 超额提成工作量<=0  then Inbound*入库支援系数/2+Picking*拣货支援系数+Outbound*出库支援系数
    when 物理仓='AGV' and 部门='Outbound' and 超额提成工作量>0  then Inbound*入库超额系数+Picking*拣货超额系数+Packing*打包超额系数
    when 物理仓='AGV' and 部门='Outbound' and 超额提成工作量<=0  then Inbound*入库支援系数/2+Picking*拣货支援系数+Packing*打包支援系数
    when 物理仓='AGV' and 部门 in ('CS','QAQC','Admin','AGV maintance') and KPI>=3 then Inbound*入库超额系数/2+Picking*拣货超额系数+Packing*打包超额系数+Outbound*出库超额系数
    when 物理仓='AGV' and 部门 in ('Inventory') and KPI>='0.75' then Inbound*入库超额系数/2+Picking*拣货超额系数+Packing*打包超额系数+Outbound*出库超额系数
    else 0
    end 支援提成金额
,KPI奖金*KPI系数 KPI提成金额
,case when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-40000>0 then 7000
    when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-35000>0 then 5800
    when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-32000>0 then 5000
    when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-28000>0 then 4300
    when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-25000>0 then 3600
    when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-22000>0 then 3000
    when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-19000>0 then 2400
    when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-16000>0 then 1800
    when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-13000>0 then 1200
    when 物理仓='BST' and 部门='Picking' and 阶梯提成工作量-10000>0 then 500
    when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-38000>0 then 13200/分组人数
    when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-33000>0 then 11100/分组人数
    when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-31000>0 then 9600/分组人数
    when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-29000>0 then 8400/分组人数
    when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-27000>0 then 7200/分组人数
    when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-25000>0 then 6120/分组人数
    when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-23000>0 then 5100/分组人数
    when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-21000>0 then 4200/分组人数
    when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-19000>0 then 3210/分组人数
    when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-17000>0 then 2310/分组人数
    when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-15000>0 then 1410/分组人数
    when 物理仓='BST' and 部门='Packing' and 阶梯提成工作量-13000>0 then 600/分组人数
    else 0
    end 阶梯提成金额 -- AGV仓 阶梯提成金额=0 此处只针对BST仓


,超额提成工作量-超额提成目标 超额提成工作量

,case when 物理仓='AGV' and 部门='Inbound' then Inbound
    when 物理仓='AGV' and 部门='Picking' then Picking
    when 物理仓='AGV' and 部门='Packing' then Packing
    when 物理仓='AGV' and 部门='Outbound' then Outbound
    when 物理仓='LAS' and 部门='Inbound' then 仓库入库
    when 物理仓='LAS' and 部门='PickingPacking' then 仓库拣货打包
    when 物理仓='LAS' and 部门='Outbound' then 仓库出库
    when 物理仓='BPL-Return' and 部门='Inbound' then 部门入库
    when 物理仓='BPL-Return' and 部门='PickingPacking' then 部门拣货打包*2
    when 物理仓='BST' and 部门='Inbound' then 仓库入库
    when 物理仓='BST' and 部门='Outbound' then 仓库出库
    when 物理仓='BST' and 部门='B2B' then 部门B2B
    else 0
    end 超额提成工作量

-- outer layer 7
-- two


-- outer layer 8
      ,if(sr.物理仓='AGV',agv.Inbound,inbound.工作量) Inbound
      ,if(sr.物理仓='AGV',agv.Pick,picking.工作量) Picking
      ,if(sr.物理仓='AGV',agv.Pack,packing.工作量) Packing
      ,if(sr.物理仓='AGV',agv.Outbound,outbound.工作量) Outbound

    (
      SELECT
      月份
      ,物理仓
      ,工号
      ,`Receive`+`Putaway` Inbound
      ,Pick
      ,Pack
      ,Outbound
      FROM `tmpale`.`tmp_th_ffm_agv_stat1`
    ) agv ON sr.月份=agv.月份 AND sr.物理仓=agv.物理仓 AND sr.工号=agv.工号
-- tmp
select * from tmpale.tmp_th_ffm_staff_Mar
select substr(date_sub(now()+ interval -1 hour,interval 1 month), 1,7);

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
where t0.月份 = substr(date_sub(now()+ interval -1 hour,interval 1 month), 1,7)
group by 1,2,3,4,5
order by t0.title,t0.岗位;


select * from dwm.dwm_th_ffm_staffcommission_month t0
where t0.月份 = substr(date_sub(now()+ interval -1 hour,interval 1 month), 1,7)
order by t0.岗位