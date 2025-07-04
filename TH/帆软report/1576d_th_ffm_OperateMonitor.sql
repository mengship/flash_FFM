select
	日期
	,仓库
	,asc1
	,在职人数
	,应出勤
	,实际出勤
	,在职出勤率
	,应出勤率
	,ifnull(临时工时,0) 临时工时
	,ifnull(加班时长,0) 加班时长
	,临时工时占常规工时比例
	,OT工时占常规工时比例
	,在职人效单天人
	,出勤人效单天人
	,在职人效件天人
	,出勤人效件天人
	,在职人效单小时人
	,在职人效件小时人
	,出勤人效单小时人
	,出勤人效件小时人
	,ifnull(采购订单到货件量,0) 采购订单到货件量
	,ifnull(销退订单到货单量,0) 销退订单到货单量
	,ifnull(采购订单入库件量,0) 采购订单入库件量
	,ifnull(销退订单入库单量,0) 销退订单入库单量
	,ifnull(采购订单及时入库件量,0) 采购订单及时入库件量
	,ifnull(销退订单及时入库,0) 销退订单及时入库
	,ifnull(采购订单应入库件量,0) 采购订单应入库件量
	,ifnull(销退订单应入库,0) 销退订单应入库
	,ifnull(采购订单入库及时率,1) 采购订单入库及时率
	,ifnull(销退订单入库及时率,1) 销退订单入库及时率
	,ifnull(采购订单未及时入库件量,0) 采购订单未及时入库件量
	,ifnull(销退订单未及时入库,0) 销退订单未及时入库
	,ifnull(采购订单及时上架件量,0) 采购订单及时上架件量
	,ifnull(销退订单及时上架,0) 销退订单及时上架
	,ifnull(采购订单应上架件量,0) 采购订单应上架件量
	,ifnull(销退订单应上架,0) 销退订单应上架
	,ifnull(采购订单上架及时率,1) 采购订单上架及时率
	,ifnull(销退订单上架及时率,1) 销退订单上架及时率
	,ifnull(采购订单未及时上架件量,0) 采购订单未及时上架件量
	,ifnull(销退订单未及时上架,0) 销退订单未及时上架
	,B2C流入单量
	,B2C已审核单量
	,B2C未审核单量
	,B2C预售单量
	,B2C缺货单量
	,B2B流入单量
	,B2B已审核单量
	,B2B未审核单量
	,B2C商品数量
	,B2C出库单量
	,B2C件单比
	,B2B出库单量
	,ifnull(B2C发货及时率,1) B2C发货及时率
	,B2CShopee及时发货
	,B2CShopee应发货
	,B2CShopee未及时发货
	,B2CShopee发货及时率
	,B2CTikTok及时发货
	,B2CTikTok应发货
	,B2CTikTok未及时发货
	,B2CTikTok发货及时率
	,B2CLAZADA及时发货
	,B2CLAZADA应发货
	,B2CLAZADA未及时发货
	,B2CLAZADA发货及时率
	,B2COther及时发货
	,B2COther应发货
	,B2COther未及时发货
	,B2COther发货及时率
	,未及时发货
	,ifnull(B2C交接及时率,1) B2C交接及时率
	,B2CShopee及时交接
	,B2CShopee应交接
	,B2CShopee未及时交接
	,B2CShopee交接及时率
	,B2CTikTok及时交接
	,B2CTikTok应交接
	,B2CTikTok未及时交接
	,B2CTikTok交接及时率
	,B2CLAZADA及时交接
	,B2CLAZADA应交接
	,B2CLAZADA未及时交接
	,B2CLAZADA交接及时率
	,B2COther及时交接
	,B2COther应交接
	,B2COther未及时交接
	,B2COther交接及时率
	,未及时交接
	,B2B未及时打包
	,ifnull(B2B打包及时率,1) B2B打包及时率
	,货主数
	,7D活跃货主
	,14D活跃货主
	,SKU数
	,小件
	,中件
	,大件
	,超大件
	,信息不全
	,其他
	,正品库存
	,小件库存
	,中件库存
	,大件库存
	,超大件库存
	,信息不全库存
	,其他库存
	,ifnull(残品库存,0) 残品库存
	,拣选区一品一位
	,拣选区一位一品
	,拣选区SKU覆盖率
	,规划库位
	,规划库位_轻型货架
	,规划库位_地堆
	,规划库位_高位货架
	,总使用库位
	,高位货架使用库位
	,轻型货架使用库位
	,地堆使用库位
	,库位利用率
	,轻型货架库位利用率
	,地堆库位利用率
	,高位货架库位利用率
	,规划库容
	,规划库容_轻型货架
	,规划库容_地堆
	,规划库容_高位货架
	,总使用库容
	,高位货架使用库容
	,轻型货架使用库容
	,地堆使用库容
	,库容利用率
	,轻型货架库容利用率
	,地堆库容利用率
	,高位货架库容利用率
	,ifnull(生成拦截单量,0) 生成拦截单量
	,ifnull(完成拦截单量,0) 完成拦截单量
	,ifnull(拦截归位及时率（24H）,1) 拦截归位及时率（24H）
	,ifnull(拦截单超时未完结,0) 拦截单超时未完结
	,ifnull(生成异常单量,0) 生成异常单量
	,ifnull(完成异常单量,0) 完成异常单量
	,ifnull(异常单及时率（24H）,1) 异常单及时率（24H）
	,ifnull(异常单超时未完结,0) 异常单超时未完结
	,ifnull(生成工单,0) 生成工单
	,ifnull(有责客诉量,0)  有责客诉量
	,ifnull(无责客诉量,0)  无责客诉量
	,ifnull(客诉成立率,0)  客诉成立率
	,ifnull(处理及时率,1)  处理及时率
	,应及时客诉量 - 及时客诉量 超时客诉量
	,单均成本
    ,件均成本
	,单均操作费
    ,件均操作费
	,人力损溢率
	,ifnull(盘点SKU,0) 盘点SKU
	,ifnull(盘点库存,0) 盘点库存
	,ifnull(库存准确率,1) 库存准确率
	,ifnull(盘盈差异率,0) 盘盈差异率
	,ifnull(盘盈SKU数量,0) 盘盈SKU数量
	,ifnull(盘盈商品数量,0) 盘盈商品数量
	,ifnull(盘亏差异率,0) 盘亏差异率
	,ifnull(盘亏SKU数量,0) 盘亏SKU数量
	,ifnull(盘亏商品数量,0) 盘亏商品数量
    ,t1.OTarrival_notice
    ,t1.OTrollback_order
    ,t1.OTshelf
    ,t1.OTB2C
    ,t1.OTB2B
    ,t1.OTintercept
    ,t1.OTabnormal
    ,t1.OTB2Ccreate
    ,t1.OTB2Cdelivery
    ,t1.loadunload_cnt
    ,t0.包裹数据误差累计值
  FROM dwm.dws_th_ffm_operateMonitor_day t0
  left join
  (
    select
        t0.仓库名称
        ,t0.OTarrival_notice
        ,t0.OTrollback_order
        ,t1.OTshelf
        ,t2.OTB2C
        ,t2.OTB2B
        ,t2.OTB2Ccreate
        ,t2.OTB2Cdelivery
        ,t3.OTintercept
        ,t3.OTabnormal
        ,t4.loadunload_cnt
    from
    (
        -- 采购与销退
        select
            仓库名称
            ,count(if(单据='采购订单' and is_OT48h=1, notice_number, null)) OTarrival_notice
            ,count(if(单据='销退订单' and is_OT48h=1, notice_number, null)) OTrollback_order
        from
        dwm.dwd_th_ffm_arrivalnotice_dayV2
        group by 1
    ) t0
    left join
    (
        -- 上架单
        select
            warehouse_name
            ,count(if(is_OT48h=1, order_sn, null)) OTshelf
        from
        dwm.dwd_th_ffm_shelf_detail
        group by 1
    ) t1 on t0.仓库名称 = t1.warehouse_name
    left join
    (
        -- 发货单 出库单
        select
            warehouse_name
            ,count(distinct if('B2C'=TYPE and is_OT48h=1, delivery_sn, null)) OTB2C
            ,count(distinct if('B2B'=TYPE and is_OT72h=1, delivery_sn, null)) OTB2B
		  ,count(distinct if('B2C'=TYPE and is_2CcreateOT48h=1, delivery_sn, null)) OTB2Ccreate
		  ,count(distinct if(delivery_time>='2025-02-26' and 'B2C'=TYPE and is_2CdeliveryOT48h=1, delivery_sn, null)) OTB2Cdelivery
        from
        dwm.dwd_th_ffm_outboundsku_day
        where is_visible=1
        group by 1
    ) t2 on t0.仓库名称 = t2.warehouse_name
    left join
    (
         -- 异常单 拦截单
        select
            warehouse_name
            ,count(distinct if('拦截单'=SUBSTRING(source, -3) and is_OT48h=1, intercept_sn, null)) OTintercept
            ,count(distinct if('异常单'=SUBSTRING(source, -3) and is_OT48h=1, intercept_sn, null)) OTabnormal
        from
        dwm.dwd_th_ffm_intercept_abnormal_day
        group by 1
    ) t3 on t0.仓库名称 = t3.warehouse_name
    left join (
        -- 装卸单
        select
            warehouse_shortname
            ,count(distinct sn) loadunload_cnt
        from
            dwm.dwd_th_ffm_loaduploadorder
        where created_format_dt>='2025-04-01'
        and status_name='待审核'
        group by 1
    )t4 on t0.仓库名称 = t4.warehouse_shortname
    where 仓库名称!='BPL3'
  ) t1 on t0.仓库 = t1.仓库名称
where 1=1
	and t0.日期='${dt}'
	and t0.仓库 not in('LCP', 'BPL3')

order by
	case t0.仓库
		when 'BST' then 1
		when 'AGV' then 2
		when 'LAS' then 3
		when 'BPL3' then 4
		when 'BPL-Return' then 5
	end asc
;