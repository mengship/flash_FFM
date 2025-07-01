/*=====================================================================+
表名称：  dws_th_ffm_operateMonitor_day
功能描述：泰国运维监控报表
   
需求来源：
编写人员: 王昱棋
设计日期：2024/11/11
        修改日期: 
        修改人员:   
        修改原因: 
-----------------------------------------------------------------------
---存在问题：
-----------------------------------------------------------------------
+=====================================================================*/ 

-- drop table if exists dwm.dws_th_ffm_operateMonitor_day;
-- create table dwm.dws_th_ffm_operateMonitor_day as
# delete from dwm.dws_th_ffm_operateMonitor_day where 日期 >= date_sub(date(now() + interval -1 hour),interval 90 day); -- 先删除数据
# insert into dwm.dws_th_ffm_operateMonitor_day
-- dwm.dws_th_ffm_operateMonitor_day
select
        '' type
        ,date(t0.日期) 日期
        ,t0.仓库
        ,case t0.仓库
            when 'BST' then 1
            when 'AGV' then 2
            when 'LAS' then 3
            when 'BPL3' then 4
            when 'BPL-Return' then 5
        end as asc1
        ,t0.B2B在职人数
        ,t0.B2B实际出勤人数 # add by 王昱棋 20250624 需要新加字段
        ,t0.在职人数
        ,t0.应出勤
        ,t0.实际出勤
        ,ifnull(round(t0.实际出勤/nullif(t0.在职人数, 0), 4), 1)  在职出勤率
        ,ifnull(round(t0.实际出勤/NULLIF(t0.应出勤, 0), 4), 1)  应出勤率
        ,t5.临时工时
        ,t0.加班时长
        , t5.临时工时 / ((t0.在职人数-t0.B2B在职人数)*8) 临时工时占常规工时比例
        , t0.加班时长 / ((t0.在职人数-t0.B2B在职人数)*8) OT工时占常规工时比例
        ,cast(t25.B2C出库单量/NULLIF((((t0.在职人数-t0.B2B在职人数)*8 + ifnull(t0.加班时长,0) + ifnull(t5.临时工时,0))/8), 0) as DECIMAL(26,4)) as 在职人效单天人
        ,cast(t25.B2C出库单量/NULLIF((((t0.实际出勤-t0.B2B实际出勤人数)*8 + ifnull(t0.加班时长,0) + ifnull(t5.临时工时,0))/8), 0)  as DECIMAL(26,4)) as 出勤人效单天人
        ,cast(t25.B2C商品数量/NULLIF((((t0.在职人数-t0.B2B在职人数)*8 + ifnull(t0.加班时长,0) + ifnull(t5.临时工时,0))/8), 0)  as DECIMAL(26,4)) as 在职人效件天人
        ,cast(t25.B2C商品数量/NULLIF((((t0.实际出勤-t0.B2B实际出勤人数)*8 + ifnull(t0.加班时长,0) + ifnull(t5.临时工时,0))/8), 0)  as DECIMAL(26,4)) as 出勤人效件天人
         ,cast(t25.B2C出库单量/NULLIF((((t0.在职人数-t0.B2B在职人数)*8 + ifnull(t0.加班时长,0) + ifnull(t5.临时工时,0))), 0) as DECIMAL(26,4)) as 在职人效单小时人
         ,cast(t25.B2C商品数量/NULLIF((((t0.在职人数-t0.B2B在职人数)*8 + ifnull(t0.加班时长,0) + ifnull(t5.临时工时,0))), 0) as DECIMAL(26,4)) as 在职人效件小时人
         ,cast(t25.B2C出库单量/NULLIF((((t0.实际出勤-t0.B2B实际出勤人数)*8 + ifnull(t0.加班时长,0) + ifnull(t5.临时工时,0))), 0)  as DECIMAL(26,4)) as 出勤人效单小时人
         ,cast(t25.B2C商品数量/NULLIF((((t0.实际出勤-t0.B2B实际出勤人数)*8 + ifnull(t0.加班时长,0) + ifnull(t5.临时工时,0))), 0)  as DECIMAL(26,4)) as 出勤人效件小时人
        ,t7.采购订单到货件量
        ,t7.销退订单到货单量
        ,t9.采购订单入库件量
        ,t9.销退订单入库单量
        ,t11.采购订单及时入库件量
        ,t11.销退订单及时入库
        ,t11.采购订单应入库件量
        ,t11.销退订单应入库
        ,ifnull(t11.采购订单及时入库件量 / NULLIF(t11.采购订单应入库件量, 0), 1) 采购订单入库及时率
        ,ifnull(t11.销退订单及时入库 / NULLIF(t11.销退订单应入库, 0), 1) 销退订单入库及时率
        ,t11.采购订单未及时入库件量
        ,t11.销退订单未及时入库
        ,t11.采购订单及时上架件量
        ,t11.销退订单及时上架
        ,t11.采购订单应上架件量
        ,t11.销退订单应上架
        ,ifnull(t11.采购订单及时上架件量 / NULLIF(t11.采购订单应上架件量, 0), 1) 采购订单上架及时率
        ,ifnull(t11.销退订单及时上架 / NULLIF(t11.销退订单应上架, 0), 1) 销退订单上架及时率
        ,t11.采购订单未及时上架件量
        ,t11.销退订单未及时上架
        ,t23.B2C流入单量
        ,t23.B2C已审核单量
        ,t23.B2C未审核单量
        ,t23.B2C预售单量
        ,t23.B2C缺货单量
        ,t23.B2B流入单量
        ,t23.B2B已审核单量
        ,t23.B2B未审核单量
        ,t25.B2C商品数量
        ,t25.B2C出库单量
        ,t25.B2C商品数量 / NULLIF(t25.B2C出库单量, 0) B2C件单比
        ,t26.B2B出库单量
        ,IFNULL((t27.B2CShopee及时发货 + t27.B2CTikTok及时发货 + t27.B2CLAZADA及时发货 +t27.B2COther及时发货 ) / NULLIF((t27.B2CShopee应发货 + t27.B2CTikTok应发货 + t27.B2CLAZADA应发货 + t27.B2COther应发货), 0), 1) B2C发货及时率
        ,t27.B2CShopee及时发货
        ,t27.B2CShopee应发货
        ,t27.B2CShopee未及时发货
        ,t27.B2CShopee及时发货 / NULLIF(t27.B2CShopee应发货, 0) B2CShopee发货及时率
        ,t27.B2CTikTok及时发货
        ,t27.B2CTikTok应发货
        ,t27.B2CTikTok未及时发货
        ,t27.B2CTikTok及时发货 / NULLIF(t27.B2CTikTok应发货, 0) B2CTikTok发货及时率
        ,t27.B2CLAZADA及时发货
        ,t27.B2CLAZADA应发货
        ,t27.B2CLAZADA未及时发货
        ,t27.B2CLAZADA及时发货 / NULLIF(t27.B2CLAZADA应发货, 0) B2CLAZADA发货及时率
        ,t27.B2COther及时发货
        ,t27.B2COther应发货
        ,t27.B2COther未及时发货
        ,t27.B2COther及时发货 / NULLIF(t27.B2COther应发货, 0) B2COther发货及时率
        ,t27.B2CShopee未及时发货 + t27.B2CTikTok未及时发货 + t27.B2CLAZADA未及时发货 + t27.B2COther未及时发货 未及时发货
        ,IFNULL((t27.B2CShopee及时交接 + t27.B2CTikTok及时交接 + t27.B2CLAZADA及时交接 + t27.B2COther及时交接) / NULLIF((t27.B2CShopee应交接 + t27.B2CTikTok应交接 + t27.B2CLAZADA应交接 + t27.B2COther应交接), 0), 1) B2C交接及时率
        ,t27.B2CShopee及时交接
        ,t27.B2CShopee应交接
        ,t27.B2CShopee未及时交接
        ,t27.B2CShopee及时交接 / NULLIF(t27.B2CShopee应交接, 0) B2CShopee交接及时率
        ,t27.B2CTikTok及时交接
        ,t27.B2CTikTok应交接
        ,t27.B2CTikTok未及时交接
        ,t27.B2CTikTok及时交接 / NULLIF(t27.B2CTikTok应交接, 0) B2CTikTok交接及时率
        ,t27.B2CLAZADA及时交接
        ,t27.B2CLAZADA应交接
        ,t27.B2CLAZADA未及时交接
        ,t27.B2CLAZADA及时交接 / NULLIF(t27.B2CLAZADA应交接, 0) B2CLAZADA交接及时率
        ,t27.B2COther及时交接
        ,t27.B2COther应交接
        ,t27.B2COther未及时交接
        ,t27.B2COther及时交接 / NULLIF(t27.B2COther应交接, 0) B2COther交接及时率
        ,t27.B2CShopee未及时交接 + t27.B2CTikTok未及时交接 + t27.B2CLAZADA未及时交接 + t27.B2COther未及时交接 未及时交接
        ,t27.B2B未及时打包
        ,t27.B2B及时打包
        ,t27.B2B应打包
        ,IFNULL(t27.B2B及时打包 / NULLIF(t27.B2B应打包, 0), 1) B2B打包及时率
        ,t30.货主数
        ,t30.`7D活跃货主`
        ,t30.`14D活跃货主`
        ,t30.SKU数
        ,t30.小件
        ,t30.中件
        ,t30.大件
        ,t30.超大件
        ,t30.信息不全
        ,t30.其他
        ,t30.正品库存
        ,t30.小件库存
        ,t30.中件库存
        ,t30.大件库存
        ,t30.超大件库存
        ,t30.信息不全库存
        ,t30.其他库存
        ,t30.残品库存
        ,t30.拣选区一品一位
        ,t30.拣选区一位一品
        ,t30.拣选区SKU覆盖率
        ,t30.规划库位
        ,t30.规划库位_轻型货架
        ,t30.规划库位_地堆
        ,t30.规划库位_高位货架
        ,t30.总使用库位
        ,t30.高位货架使用库位
        ,t30.轻型货架使用库位
        ,t30.地堆使用库位
        ,t30.库位利用率
        ,t30.轻型货架库位利用率
        ,t30.地堆库位利用率
        ,t30.高位货架库位利用率
        ,t30.规划库容
        ,t30.规划库容_轻型货架
        ,t30.规划库容_地堆
        ,t30.规划库容_高位货架
        ,t30.总使用库容
        ,t30.高位货架使用库容
        ,t30.轻型货架使用库容
        ,t30.地堆使用库容
        ,t30.库容利用率
        ,t30.轻型货架库容利用率
        ,t30.地堆库容利用率
        ,t30.高位货架库容利用率
        ,t31.生成拦截单量
        ,t31.完成拦截单量
        ,t31.拦截单及时拦截单量
        ,t31.拦截单应拦截单量
        ,IFNULL(t31.拦截归位及时率（24H）, 1) 拦截归位及时率（24H）
        ,t31.拦截单超时未完结
        ,t32.生成异常单量
        ,t32.完成异常单量
        ,t32.异常单及时拦截单量
        ,t32.异常单应拦截单量
        ,IFNULL(t32.异常单及时率（24H）, 1) 异常单及时率（24H）
        ,t32.异常单超时未完结
        ,t33.生成工单
        ,t33.有责客诉量
        ,t33.无责客诉量
        ,t33.及时客诉量
        ,t33.应及时客诉量
        ,IFNULL(t33.有责客诉量 / NULLIF(t25.B2C出库单量, 0), 0) as 客诉成立率
        ,IFNULL(t33.处理及时率, 1) as 处理及时率
        ,t34.amount / NULLIF(t35.B2Chandovercnt, 0) 单均成本
        ,t34.amount 成本
        ,t34.人力成本
        ,t34.OT成本
        ,t34.提成成本
        ,t34.外协成本
        ,t342.成本 包材成本
        ,t342.成本 / NULLIF(t35.B2Chandovercnt, 0) 单均包材成本
        ,t35.B2Chandovercnt B2C单量
        ,NULLIF(t35.B2Chandoverpcscnt, 0) B2C件量
        ,t34.amount / NULLIF(t35.B2Chandoverpcscnt, 0) 件均成本 -- 20241213 addby 王昱棋
        ,t36.操作费 / NULLIF(t25.B2C出库单量, 0) 单均操作费
        ,t36.操作费 / NULLIF(t25.B2C商品数量, 0) 件均操作费 -- 20241224 addby 王昱棋
        ,(t36.操作费 / NULLIF(t25.B2C出库单量, 0) - t34.amount / NULLIF(t35.B2Chandovercnt, 0)) / NULLIF((t34.amount / NULLIF(t35.B2Chandovercnt, 0)), 0) 人力损溢率
        ,t36.入库费
        , t36.出库费
        , t36.操作费
        , t36.仓储费
        , t36.包材费
        , t36.增值服务
        , t36.销退拦截
        ,t37.盘点SKU
        ,t37.盘点库存
        ,t37.盘点差异
        ,t37.计划库存
        ,IFNULL(t37.库存准确率, 1) 库存准确率
        ,t37.盘盈差异率
        ,t37.盘盈SKU数量
        ,t37.盘盈商品数量
        ,t37.盘亏差异率
        ,t37.盘亏SKU数量
        ,t37.盘亏商品数量
        ,IFNULL(t38.商品审核及时率, 1) 商品审核及时率
        ,t39.cnt 包裹数据误差累计值
    from
    -- 出勤情况 已固化到dwm
    dwm.dwm_th_ffm_staff_day t0
    left join
    ( -- 临时工时
         select
            left(dt,10) 日期
            ,warehouse 仓库
            ,'临时工工时' type
            ,sum(ifnull(num_people, 0)*8+ifnull(num_ot, 0)) 临时工时
        FROM dwm.th_ffm_tempworker_inputV2 WHERE dt >= left(NOW() - interval 90 day,10)
            and warehouse is not null
        GROUP BY 1,2,3
    ) t5 on t0.日期 = t5.日期 and t0.仓库 = t5.仓库

    -- 入库 已经固化到dwm层
    -- 采购订单 销退订单 到货单量
    left join
    (
        select
            日期
            ,仓库
            ,sum(采购订单到货单量) 采购订单到货单量
            ,sum(采购订单到货件量) 采购订单到货件量
            ,sum(销退订单到货单量) 销退订单到货单量
            ,sum(销退订单到货件量) 销退订单到货件量
        from
        dwm.dwm_th_ffm_arrivalnoticereg_day
        where 日期 >= left(NOW() - interval 90 day,10)
        group by 日期
            ,仓库
    ) t7 on t0.日期 = t7.日期 and t0.仓库 = t7.仓库

    -- 采购订单 销退订单 入库单量
    left join
    (   select
            dt 日期
            ,warehouse_name 仓库
            ,sum(采购订单入库单量) 采购订单入库单量
            ,sum(采购订单入库件量) 采购订单入库件量
            ,sum(销退订单入库单量) 销退订单入库单量
        from
        dwm.dwm_th_ffm_arrivalnoticein_day
        WHERE dt >= left(NOW() - interval 90 day,10)
        group by 1,2
    ) t9 on t0.日期 = t9.日期 and t0.仓库 = t9.仓库

    -- 采购订单 销退订单 及时入库 应入库 未及时入库
    left join
    (
        select
            日期
            ,仓库
            -- ,TYPE
            ,sum(采购订单及时入库件量) 采购订单及时入库件量
            ,sum(销退订单及时入库) 销退订单及时入库
            ,sum(采购订单应入库件量) 采购订单应入库件量
            ,sum(销退订单应入库) 销退订单应入库
            ,sum(采购订单未及时入库件量) 采购订单未及时入库件量
            ,sum(销退订单未及时入库) 销退订单未及时入库
            ,sum(采购订单及时上架件量) 采购订单及时上架件量
            ,sum(销退订单及时上架) 销退订单及时上架
            ,sum(采购订单应上架件量) 采购订单应上架件量
            ,sum(销退订单应上架) 销退订单应上架
            ,sum(采购订单未及时上架件量) 采购订单未及时上架件量
            ,sum(销退订单未及时上架) 销退订单未及时上架
        from
        dwm.dwm_th_ffm_arrivalnoticetimely_day
        WHERE 日期 >= left(NOW() - interval 90 day,10)
        group by 1,2
    )t11 on t0.日期 = t11.日期 and t0.仓库 = t11.仓库

    -- 出库
    -- B2C  已审核单量 未审核单量
    left join dwm.dwm_th_ffm_orderaudit_day t23 on t0.日期 = t23.日期 and t0.仓库 = t23.warehouse_name

    -- B2C 商品数量 出库单量 固化到 dwm
    left join
    (
        select
            日期
            ,warehouse_name
            ,sum(B2C商品数量) B2C商品数量
            ,sum(B2C出库单量) B2C出库单量
        from
        dwm.dwm_th_ffm_orderout_day
        where 日期 >= left(NOW() - interval 90 day,10)
        group by 日期
            ,warehouse_name
    ) t25 on t0.日期 = t25.日期 and t0.仓库 = t25.warehouse_name

    -- B2B 打包 单量
    left join dwm.dwm_th_ffm_orderpack_day t26 on t0.日期 = t26.日期 and t0.仓库 = t26.warehouse_name

    left join
    (
        SELECT
        warehouse_name
        ,dt
        ,sum(B2B及时打包) B2B及时打包
        ,sum(B2B应打包) B2B应打包
        ,sum(B2B未及时打包) B2B未及时打包
        ,sum(B2CShopee及时交接) B2CShopee及时交接
        ,sum(B2CShopee应交接) B2CShopee应交接
        ,sum(B2CShopee未及时交接) B2CShopee未及时交接
        ,sum(B2CTikTok及时交接) B2CTikTok及时交接
        ,sum(B2CTikTok应交接) B2CTikTok应交接
        ,sum(B2CTikTok未及时交接) B2CTikTok未及时交接
        ,sum(B2CLAZADA及时交接) B2CLAZADA及时交接
        ,sum(B2CLAZADA应交接) B2CLAZADA应交接
        ,sum(B2CLAZADA未及时交接) B2CLAZADA未及时交接
        ,sum(B2COther及时交接) B2COther及时交接
        ,sum(B2COther应交接) B2COther应交接
        ,sum(B2COther未及时交接) B2COther未及时交接
        ,sum(B2CShopee及时发货) B2CShopee及时发货
        ,sum(B2CShopee应发货) B2CShopee应发货
        ,sum(B2CShopee未及时发货) B2CShopee未及时发货
        ,sum(B2CTikTok及时发货) B2CTikTok及时发货
        ,sum(B2CTikTok应发货) B2CTikTok应发货
        ,sum(B2CTikTok未及时发货) B2CTikTok未及时发货
        ,sum(B2CLAZADA及时发货) B2CLAZADA及时发货
        ,sum(B2CLAZADA应发货) B2CLAZADA应发货
        ,sum(B2CLAZADA未及时发货) B2CLAZADA未及时发货
        ,sum(B2COther及时发货) B2COther及时发货
        ,sum(B2COther应发货) B2COther应发货
        ,sum(B2COther未及时发货) B2COther未及时发货
        from
        dwm.dwm_th_ffm_ordertimelyout_day
        WHERE dt >= left(NOW() - interval 90 day,10)
        group by 1,2
    )
    t27 on t0.日期 = t27.dt and t0.仓库 = t27.warehouse_name

    left join dwm.dwm_th_ffm_sellergoodslocation_day t30 on t0.日期 = t30.statc_date and t0.仓库 = t30.warehouse_name

    -- 拦截单
    left join
    (
        select
            statc_date
            ,warehouse_name
            ,title
            ,sum(生成拦截单量)  生成拦截单量
            ,sum(完成拦截单量)  完成拦截单量
            ,sum(及时拦截单量) 拦截单及时拦截单量
            ,sum(应拦截单量) 拦截单应拦截单量
            ,sum(及时拦截单量)/nullif(sum(应拦截单量), 0) 拦截归位及时率（24H）
            ,sum(超时未完结) 拦截单超时未完结
        from
        dwm.dwm_th_ffm_intercept_abnormaltimely_day
        where '拦截单'=title
            and statc_date >= left(NOW() - interval 90 day,10)
        group by 1,2,3
    ) t31 on t0.日期 = t31.statc_date and t0.仓库 = t31.warehouse_name

    -- 异常单
    left join
    (
        select
        statc_date
        ,warehouse_name
        ,title
        ,sum(生成拦截单量) 生成异常单量
        ,sum(完成拦截单量)   完成异常单量
        ,sum(及时拦截单量) 异常单及时拦截单量
        ,sum(应拦截单量) 异常单应拦截单量
        ,sum(及时拦截单量)/nullif(sum(应拦截单量), 0) 异常单及时率（24H）
        ,sum(超时未完结) 异常单超时未完结
        from
        dwm.dwm_th_ffm_intercept_abnormaltimely_day
        where '异常单'=title
            and statc_date >= left(NOW() - interval 90 day,10)
        group by 1,2,3
    ) t32 on t0.日期 = t32.statc_date and t0.仓库 = t32.warehouse_name

    -- 客诉
    left join
    (
        select
            日期
            ,仓库名称
            ,sum(生成工单) 生成工单
            ,sum(有责客诉量) 有责客诉量
            ,sum(无责客诉量) 无责客诉量
            ,sum(及时客诉量) 及时客诉量
            ,sum(应及时客诉量) 应及时客诉量
            ,sum(及时客诉量)/nullif(sum(应及时客诉量), 0) 处理及时率
        from
        dwm.dwm_th_ffm_complaint_day
        group by 1,2
        )t33 on t0.日期 = t33.日期 and t0.仓库 = t33.仓库名称

    -- 成本
    left join
    (
        select
            日期
            ,周
            ,仓库名称
            ,sum(amount) amount
            ,sum(if(收入类型2='人力成本', amount, 0)) 人力成本
            ,sum(if(收入类型2='OT成本', amount, 0)) OT成本
            ,sum(if(收入类型2='提成成本', amount, 0)) 提成成本
            ,sum(if(收入类型2='外协成本', amount, 0)) 外协成本
        from
        dwm.dwm_th_ffm_cost_day
        where 收入类型2 <> '管理成本'
        and 日期 >= left(NOW() - interval 90 day,10)
        group by 1,2,3
    )
    t34 on t0.日期 = t34.日期 and t0.仓库 = t34.仓库名称
    -- 包材成本
    left join
    (
        select
             业务日期
            , 仓库
            , sum(成本) 成本
            , sum(数量) 数量
        from
        dwm.dwm_th_ffm_materialuse_day
        where 业务日期 >= left(NOW() - interval 90 day,10)
        group by 1,2
    ) t342 on t0.日期 = t342.业务日期 and t0.仓库 = t342.仓库
    -- 出库 交接日期汇总
    left join dwm.dwm_th_ffm_orderhandover_day t35 on t0.日期 = t35.dt and t0.仓库 = t35.warehouse_name

    -- 收入 操作费
    left join
    (
        select
            日期
            , 仓库名称
            , sum(入库费) 入库费
            , sum(出库费) 出库费
            , sum(操作费) 操作费
            , sum(仓储费) 仓储费
            , sum(包材费) 包材费
            , sum(增值服务) 增值服务
            , sum(销退拦截) 销退拦截
            from
        dwm.dwm_th_ffm_income_day
        where 日期 >= left(NOW() - interval 90 day,10)
        group by 1,2
    ) t36 on t0.日期 = t36.日期 and t0.仓库 = t36.仓库名称

    -- 盘点
    left join (
        select
            result_confirm_date
            ,warehouse_short_name
            ,SUM(计划行数) as 盘点SKU
            ,SUM(计划库存) as 盘点库存
            ,CASE WHEN seller_name<>'AA0636(Giikin)' then IFNULL(1-((SUM(盘盈库存)+ABS(SUM(盘亏库存))) / NULLIF(SUM(计划库存), 0)), 1)  -- 货主Giikin不参与考核
                  END	as 库存准确率
            ,SUM(盘盈库存)/ NULLIF(SUM(计划库存), 0) as 盘盈差异率
            ,SUM(盘盈行数) as 盘盈SKU数量
            ,盘盈库存 as 盘盈商品数量
            ,ABS(SUM(盘亏库存))/ NULLIF(SUM(计划库存), 0) as 盘亏差异率
            ,SUM(盘亏行数) as 盘亏SKU数量
            ,ABS(SUM(盘亏库存)) as 盘亏商品数量
            ,if(seller_name<>'AA0636(Giikin)', SUM(盘盈库存)+ABS(SUM(盘亏库存)), 0) 盘点差异
            ,if(seller_name<>'AA0636(Giikin)', sum(计划库存), 0) 计划库存
        from dwm.dwm_th_ffm_invcount_day
        where result_confirm_date >= left(NOW() - interval 90 day,10)
        group by 1,2
    )
    t37 on t0.日期 = t37.result_confirm_date and t0.仓库 = t37.warehouse_short_name

    -- 商品审核
    left join dwm.dwm_th_ffm_goodsaudit_day t38 on t0.日期 = t38.audit_deadline_date and t0.仓库 = t38.warehouse_short_name

    -- 包裹数据误差累计值
    left join dwm.dwm_th_ffm_PkgDataErr_aggr t39 on t0.仓库 = t39.warehouse_name
    where t0.日期 >= '2025-06-30'