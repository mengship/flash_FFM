

select -- 仓库+日期
    ''
    ,dt
    ,周
    ,warehouse_name 仓库名称
    ,仓租成本
    ,水电
    ,办公费
    ,设备折旧
    ,单均仓租成本
    ,单均水电
    ,单均办公费
    ,单均设备折旧
    ,基础耗材成本
    ,在职人效单目标
    ,在职人效件目标
    ,人力成本单目标
    ,人力成本件目标
    ,B2C出库单量
    ,B2C商品数量
    ,sum(B2C出库单量) over(partition by 周)/7 日均单量

    , 在职人效件天人
    , B2C发货及时率
    , 采购订单上架及时率

    , 销退订单入库单量
    , 采购订单入库件量
    , B2C件单比
    , 在职人数
    , 应出勤率
    , 出勤人效单天人
    , 在职人效单天人
    , 采购订单入库及时率
    , 销退订单上架及时率
    , 客诉率
    , 客诉成立率
    , 单均成本
    , 单均综合成本
    , 件均成本
    , 包材成本
    , 单均包材成本
    , 库存准确率
    , 入库费
    , 出库费
    , 操作费
    , 仓储费
    , 包材费
    , 增值服务
    , 销退拦截
    , 入库费单均
    , 出库费单均
    , 操作费单均
    , 仓储费单均
    , 包材费单均
    , 增值服务单均
    , 销退拦截单均
    from
(
    select
          dt.dt
        , dt.warehouse_name
        , dt.周
        , dt.WR 仓租成本
        , dt.E_W 水电
        , dt.office_fee 办公费
        , dt.equip_fee 设备折旧
        , dt.WR / B2C出库单量 单均仓租成本
        , dt.E_W / B2C出库单量 单均水电
        , dt.office_fee / B2C出库单量 单均办公费
        , dt.equip_fee / B2C出库单量 单均设备折旧
        , dt.MCO * B2C出库单量 基础耗材成本
        , dt.LEOtarget 在职人效单目标
        , dt.LEPtarget 在职人效件目标
        , dt.LCO 人力成本单目标
        , dt.LCP 人力成本件目标

        , t0.B2C出库单量
        , t0.B2C商品数量
        , t0.在职人效件天人
        , t0.B2C发货及时率
        , t0.采购订单上架及时率
        , t0.销退订单入库单量
        , t0.采购订单入库件量
        , t0.B2C件单比
        , t0.在职人数
        , t0.应出勤率
        , t0.出勤人效单天人
        , t0.在职人效单天人
        , t0.采购订单入库及时率
        , t0.销退订单上架及时率
        , t0.客诉率
        , t0.客诉成立率
        , t0.单均成本
        , t0.单均成本 + ifnull(dt.WR/t0.B2C出库单量, 0) + ifnull(dt.E_W/t0.B2C出库单量, 0) + ifnull(dt.equip_fee/t0.B2C出库单量, 0) 单均综合成本
        , t0.件均成本
        , t0.包材成本
        , t0.单均包材成本
        , t0.库存准确率
        , t0.入库费
        , t0.出库费
        , t0.操作费
        , t0.仓储费
        , t0.包材费
        , t0.增值服务
        , t0.销退拦截
        , t0.入库费 / t0.B2C出库单量 入库费单均
        , t0.出库费 / t0.B2C出库单量 出库费单均
        , t0.操作费 / t0.B2C出库单量 操作费单均
        , t0.仓储费 / t0.B2C出库单量 仓储费单均
        , t0.包材费 / t0.B2C出库单量 包材费单均
        , t0.增值服务 / t0.B2C出库单量 增值服务单均
        , t0.销退拦截 / t0.B2C出库单量 销退拦截单均
    from
    (
        select
            fwd.dt
          , concat('WEEK', week(fwd.dt + INTERVAL 1 day)) 周
          , fwd.warehouse_name
          , fc.office_fee
          , fc.equip_fee
          , fc.LEOtarget
          , fc.LEPtarget
          , fc.LCO
          , fc.LCP
          , fc.MCO
          , fc.WR
          , fc.E_W

        from dwm.dim_th_ffm_warehouse_day fwd
        left join dwm.dim_th_ffm_cost fc on fwd.warehouse_name = fc.warehouse_name
        where 1 = 1
          and fwd.dt >= date_sub(date(now() + interval -1 hour), interval 90 day)
          and fwd.dt >= '2025-04-01'
          and NULLIF(fwd.warehouse_name, 999) <> 'BPL3'
    ) dt
    left join
    (
       SELECT
            '发货单' 单据类型
          , 日期
          , concat('WEEK', week(日期 + INTERVAL 1 day)) 周
          , 仓库 仓库名称
          , sum(B2C出库单量) B2C出库单量
          , sum(B2C商品数量) B2C商品数量
          , cast(sum(B2C商品数量)/NULLIF((((sum(在职人数)-sum(B2B在职人数))*8 + ifnull(sum(加班时长),0) + ifnull(sum(临时工时),0))/8), 0)  as DECIMAL(26,4)) as 在职人效件天人
          ,IFNULL((sum(B2CShopee及时发货) + sum(B2CTikTok及时发货) + sum(B2CLAZADA及时发货) +sum(B2COther及时发货) ) / NULLIF((sum(B2CShopee应发货) + sum(B2CTikTok应发货) + sum(B2CLAZADA应发货) + sum(B2COther应发货)), 0), 1) B2C发货及时率
          ,ifnull(sum(采购订单及时上架件量) / NULLIF(sum(采购订单应上架件量), 0), 1) 采购订单上架及时率
          , sum(销退订单入库单量) 销退订单入库单量
          , sum(采购订单入库件量) 采购订单入库件量
          , sum(B2C商品数量) / NULLIF(sum(B2C出库单量), 0) B2C件单比
          , sum(在职人数) 在职人数
          , ifnull(round(sum(实际出勤)/NULLIF(sum(应出勤), 0), 4), 1)  应出勤率
          , cast(sum(B2C出库单量)/NULLIF((((sum(实际出勤)-sum(B2B实际出勤人数))*8 + ifnull(sum(加班时长),0) + ifnull(sum(临时工时),0))/8), 0)  as DECIMAL(26,4)) as 出勤人效单天人
          , cast(sum(B2C出库单量)/NULLIF((((sum(在职人数)-sum(B2B在职人数))*8 + ifnull(sum(加班时长),0) + ifnull(sum(临时工时),0))/8), 0) as DECIMAL(26,4)) as 在职人效单天人
          , ifnull(sum(采购订单及时入库件量) / NULLIF(sum(采购订单应入库件量), 0), 1) 采购订单入库及时率
          , ifnull(sum(销退订单及时上架) / NULLIF(sum(销退订单应上架), 0), 1) 销退订单上架及时率
          , IFNULL(sum(生成工单) / NULLIF(sum(B2C出库单量), 0), 0) as 客诉率
          , IFNULL(sum(有责客诉量) / NULLIF(sum(B2C出库单量), 0), 0) as 客诉成立率
          , sum(成本) / NULLIF(sum(B2C单量), 0) 单均成本
          , sum(成本) / NULLIF(sum(B2C件量), 0) 件均成本
          , sum(包材成本) 包材成本
          , sum(包材成本) / NULLIF(sum(B2C单量), 0) 单均包材成本
          , 1- sum(盘点差异) / sum(计划库存) 库存准确率
          , sum(人力成本) + sum(OT成本) + sum(提成成本) 正式工成本
          , sum(外协成本) 外协成本
          , sum(入库费) 入库费
          , sum(出库费) 出库费
          , sum(操作费) 操作费
          , sum(仓储费) 仓储费
          , sum(包材费) 包材费
          , sum(增值服务) 增值服务
          , sum(销退拦截) 销退拦截
        from dwm.dws_th_ffm_operateMonitor_day od
        where 1 = 1
          and 日期 >= date_sub(date(now() + interval -1 hour), interval 90 day)
        group by 1, 2, 3, 4
    ) t0 on dt.warehouse_name = t0.仓库名称 and dt.dt = t0.日期
) t1
where 1=1
and warehouse_name='${warehousename}'
and 周='${week}'
order by dt;

select * from tmpale.tmp_th_ffm_cost;

select
    wo.id id
    ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓') then 'AGV'
        when w.name='BPL-Return Warehouse' then 'BPL-Return'
        when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
        when w.name='BangsaoThong' then 'BST'
        when w.name IN ('BKK-WH-LAS2电商仓','PMD-WH','BKK-WH-Ecommerce','BKK-WH-LAS物料仓') then 'LAS'
        when w.name='LCP Warehouse' then 'LCP'
        else w.name
        end 仓库名称
    ,LEFT(wo.created - interval 1 hour,10) 创建日期
	,wo.created - interval 1 hour as 创建时间
    ,wo.created + interval 23 hour as created_24_deadline
    ,week(wo.created + interval 23 hour) 周
    ,case when RESULT =2 then '有责投诉'
          when RESULT =1 then '无责投诉'
		  else '未知' end 仓责判断
    ,wo.complete_time
	,FROM_UNIXTIME(jm.first_judgment_time) - interval 1 hour as first_judgment_time
    ,IF(FROM_UNIXTIME(jm.first_judgment_time) <= wo.created + INTERVAL 24 HOUR,1,0) 是否及时
    ,case when (FROM_UNIXTIME(jm.first_judgment_time) is null or left(FROM_UNIXTIME(jm.first_judgment_time),10) = '1970-01-01')  and date_add(now(), interval -60 minute) <= wo.created + INTERVAL 24 HOUR then '未到考核时间'
        when  left(FROM_UNIXTIME(jm.first_judgment_time),10) <> '1970-01-01' and FROM_UNIXTIME(jm.first_judgment_time) <= wo.created + INTERVAL 24 HOUR then '及时'

        when (left(FROM_UNIXTIME(jm.first_judgment_time),10) <> '1970-01-01' and FROM_UNIXTIME(jm.first_judgment_time) > wo.created + INTERVAL 24 HOUR)
              or ((FROM_UNIXTIME(jm.first_judgment_time) is null or left(FROM_UNIXTIME(jm.first_judgment_time),10) = '1970-01-01')  and date_add(now(), interval -60 minute) > wo.created + INTERVAL 24 HOUR) then '不及时'
        end as timely_type       -- modified by hmf in 20241219：时效判断改为用"首次判责时间"进行判断
    ,case when status = 1000 then '已作废'
        when status = 1050 then '已解决'
        when status = 1010 then '已创建'
        end as status_name
from  wms_production.work_order wo
left join wms_production.warehouse w on w.id=WO.warehouse_id
LEFT JOIN wms_production.seller sl on wo.seller_id =sl.id
left join wms_production.judgement jm on wo.id = jm.work_order_id;
;




