  /*=====================================================================+
    表名称：  1676d_th_BPL3_zhihu_inventory
    功能描述： 直播仓每日植护库存与消耗

    需求来源：
    编写人员: lishuaijie
    设计日期：2023/8/27
      修改日期:
      修改人员:
      修改原因:
  -----------------------------------------------------------------------
  ---存在问题：
  -----------------------------------------------------------------------
  +=====================================================================*/
  /* with do as (
SELECT
	仓库
	,货主名称
	,SKU
	,SUM(goods_number*实物库存)  实物库存
FROM
	(
	SELECT
		仓库
		,货主名称
		,bar_code
		,IF(是否加工品=1,原材料,bar_code) SKU
		,IF(是否加工品=1,goods_number,1) goods_number
		,是否加工品
		,实物库存
	FROM
		(
		SELECT
			仓库
			,货主名称
			,a.bar_code
			,a.id
			,sg2.bar_code 原材料
			,scg.goods_number
			,是否加工品
			,实物库存
		FROM
			(
			SELECT
			    vp.physicalwarehouse_name 仓库
			    ,s.name 货主名称
			    ,sg.bar_code
			    ,sg.id
			    ,sg.is_new_combo 是否加工品
			    ,SUM(reset_number)+SUM(preoccupied_number) 实物库存
			FROM erp_wms_prod.seller_goods sg
			left join erp_wms_prod.in_warehouse_cost iwc on iwc.seller_goods_id =sg.id
			left join erp_wms_prod.seller s  on iwc.seller_id =s.id
			left join erp_wms_prod.warehouse w on w.id =iwc.warehouse_id
			left join tmpale.dim_th_ffm_virtualphysical vp on w.name = vp.virtualwarehouse_name
			where  1=1
				and iwc.quality_status =1
			    and iwc.is_stop_sale =0
			    and vp.physicalwarehouse_name='BPL3'
			    and s.name ='BOTARE（福建植护）'
			    and sg.status=3
			--         and sg.bar_code ='JYC-008-01'
			GROUP BY vp.physicalwarehouse_name
			    ,s.name
			    ,sg.bar_code
			    ,sg.id
			    ,sg.is_new_combo
			)a
		LEFT join erp_wms_prod.seller_combo_goods scg ON scg.combo_id=a.id
		LEFT JOIN erp_wms_prod.seller_goods sg2 on sg2.id =scg.seller_goods_id
	-- 	where a.bar_code='ZH2640N20TY0_13054110101_1_1'
		)a
	)a
GROUP BY 仓库
	,货主名称
	,SKU
)
SELECT
	*
    ,floor(今日库存/(日期当天消耗量*0.2+3日日均消耗量*0.2+5日日均消耗量*0.2+7日日均消耗量*0.2+15日日均消耗量*0.1+30日日均消耗量*0.1)) '可消耗天数(向下取整)'
    ,round(今日库存/(日期当天消耗量*0.2+3日日均消耗量*0.2+5日日均消耗量*0.2+7日日均消耗量*0.2+15日日均消耗量*0.1+30日日均消耗量*0.1),2)  '可消耗天数(四舍五入)'
FROM
	(
	SELECT
		a.日期
		,a.仓库
		,a.货主名称
		,a.SKU
		,IFNULL(b.消耗量,0) 日期当天消耗量
		,do.实物库存  今日库存
		,cast(avg(IFNULL(b.消耗量,0)) over(partition by a.仓库,a.货主名称,a.SKU order by a.日期 rows between 2 preceding and current row) as int) as 3日日均消耗量
		,cast(avg(IFNULL(b.消耗量,0)) over(partition by a.仓库,a.货主名称,a.SKU order by a.日期 rows between 4 preceding and current row) as int) as 5日日均消耗量
		,cast(avg(IFNULL(b.消耗量,0)) over(partition by a.仓库,a.货主名称,a.SKU order by a.日期 rows between 6 preceding and current row) as int) as 7日日均消耗量
		,cast(avg(IFNULL(b.消耗量,0)) over(partition by a.仓库,a.货主名称,a.SKU order by a.日期 rows between 14 preceding and current row) as int) as 15日日均消耗量
		,cast(avg(IFNULL(b.消耗量,0)) over(partition by a.仓库,a.货主名称,a.SKU order by a.日期 rows between 29 preceding and current row) as int) as 30日日均消耗量
	FROM
		(
		SELECT
			日期
			,仓库
			,货主名称
			,SKU
		FROM
			(
			SELECT
				`date` 日期
			FROM tmpale.ods_th_dim_date
			where `date` <date(NOW()-INTERVAL 1 HOUR)
			and `date`>=date(NOW()-INTERVAL 1 HOUR)-INTERVAL 35 day
			group by `date`
			)m
		left join do on 1=1
		GROUP BY 日期
			,仓库
			,货主名称
			,SKU
		)a
	left join do on do.仓库=a.仓库 and do.货主名称=a.货主名称 and do.SKU=a.SKU
	LEFT join
		(
		-- 消耗
		SELECT
			日期
			,仓库
			,货主名称
			,SKU
			,消耗量
		FROM
			(
			SELECT
				日期
				,仓库
				,货主名称
				,SKU
				,SUM(销量*goods_number) 消耗量
			FROM
				(
				SELECT
					a.日期
					,a.仓库
					,a.货主名称
					,a.bar_code
					,销量
					,SKU
					,goods_number
				FROM
					(
					select
						date(t.快递已签收时间) 日期
						,t.仓库
						,t.货主名称
				-- 		,t.发货单号
						,sg3.bar_code
						,SUM(dog.goods_number)  销量
					from test.th_ffm_outbound_total_detail_l t
					left join erp_wms_prod.delivery_order do2 on t.发货单号 =do2.delivery_sn
					left join erp_wms_prod.delivery_order_goods dog on dog.delivery_order_id =do2.id
					left join erp_wms_prod.seller_goods sg3 on sg3.id=dog.seller_goods_id
					where 1=1
						and t.货主名称 ='BOTARE（福建植护）'
						and t.仓库 ='BPL3'
						and t.类型='erp发货单'
					group by date(t.快递已签收时间)
						,t.仓库
						,t.货主名称
				-- 		,t.发货单号
						,sg3.bar_code
					)a
				left join
					(
					SELECT
						仓库
						,货主名称
						,bar_code
						,IF(是否加工品=1,原材料,bar_code) SKU
						,IF(是否加工品=1,goods_number,1) goods_number
						,是否加工品
						,实物库存
					FROM
						(
						SELECT
							仓库
							,货主名称
							,a.bar_code
							,a.id
							,sg2.bar_code 原材料
							,scg.goods_number
							,是否加工品
							,实物库存
						FROM
							(
							SELECT
							    vp.physicalwarehouse_name 仓库
							    ,s.name 货主名称
							    ,sg.bar_code
							    ,sg.id
							    ,sg.is_new_combo 是否加工品
							    ,SUM(reset_number)+SUM(preoccupied_number) 实物库存
							FROM erp_wms_prod.seller_goods sg
							left join erp_wms_prod.in_warehouse_cost iwc on iwc.seller_goods_id =sg.id
							left join erp_wms_prod.seller s  on iwc.seller_id =s.id
							left join erp_wms_prod.warehouse w on w.id =iwc.warehouse_id
							left join tmpale.dim_th_ffm_virtualphysical vp on w.name = vp.virtualwarehouse_name
							where  1=1
								and iwc.quality_status =1
							    and iwc.is_stop_sale =0
							    and vp.physicalwarehouse_name='BPL3'
							    and s.name ='BOTARE（福建植护）'
							    and sg.status=3
							--         and sg.bar_code ='JYC-008-01'
							GROUP BY vp.physicalwarehouse_name
							    ,s.name
							    ,sg.bar_code
							    ,sg.id
							    ,sg.is_new_combo
							)a
						LEFT join erp_wms_prod.seller_combo_goods scg ON scg.combo_id=a.id
						LEFT JOIN erp_wms_prod.seller_goods sg2 on sg2.id =scg.seller_goods_id
					-- 	where a.bar_code='ZH2640N20TY0_13054110101_1_1'
						)b
					)b on a.仓库=b.仓库 and a.货主名称=b.货主名称 and a.bar_code=b.bar_code
				)b
			GROUP BY 日期
				,仓库
				,货主名称
				,SKU
			)b
		)b on a.日期=b.日期 and a.仓库=b.仓库 and a.货主名称=b.货主名称 and a.SKU=b.SKU
	)a
WHERE 日期=date(NOW()-INTERVAL 25 HOUR);
 */

with do1 as
(
    SELECT
        w.name 仓库
        ,s.name 货主名称
        ,sg.bar_code
        ,sg.id
        ,SUM(inventory) 实物库存
    FROM wms_production.seller_goods sg
    left join wms_production.seller_goods_location_ref sglr on sglr.seller_goods_id =sg.id
    left join wms_production.seller s  on sglr.seller_id =s.id
    left join wms_production.warehouse w on w.id =sglr.warehouse_id
    where  1=1
        and sglr.quality_status ='normal'
        and sg.status=3
        and (w.name='AutoWarehouse-人工仓' or (s.name='Fuzhou canghai yunfan（福州沧海云帆）' and w.name='BKK-WH-LAS2电商仓'))
    GROUP BY
        w.name
        ,s.name
        ,sg.bar_code
        ,sg.id
)
  SELECT
	*
    ,floor(今日库存/(日期当天消耗量*0.2+3日日均消耗量*0.2+5日日均消耗量*0.2+7日日均消耗量*0.2+15日日均消耗量*0.1+30日日均消耗量*0.1)) '可消耗天数(向下取整)'
    ,round(今日库存/(日期当天消耗量*0.2+3日日均消耗量*0.2+5日日均消耗量*0.2+7日日均消耗量*0.2+15日日均消耗量*0.1+30日日均消耗量*0.1),2)  '可消耗天数(四舍五入)'
FROM
	(
SELECT
		a.日期
		,a.仓库
		,a.货主名称
		,a.SKU
		,IFNULL(b.消耗量,0) 日期当天消耗量
		,do1.实物库存  今日库存
		,cast(avg(IFNULL(b.消耗量,0)) over(partition by a.仓库,a.货主名称,a.SKU order by a.日期 rows between 2 preceding and current row) as int) as 3日日均消耗量
		,cast(avg(IFNULL(b.消耗量,0)) over(partition by a.仓库,a.货主名称,a.SKU order by a.日期 rows between 4 preceding and current row) as int) as 5日日均消耗量
		,cast(avg(IFNULL(b.消耗量,0)) over(partition by a.仓库,a.货主名称,a.SKU order by a.日期 rows between 6 preceding and current row) as int) as 7日日均消耗量
		,cast(avg(IFNULL(b.消耗量,0)) over(partition by a.仓库,a.货主名称,a.SKU order by a.日期 rows between 14 preceding and current row) as int) as 15日日均消耗量
		,cast(avg(IFNULL(b.消耗量,0)) over(partition by a.仓库,a.货主名称,a.SKU order by a.日期 rows between 29 preceding and current row) as int) as 30日日均消耗量
	FROM
        (
            SELECT
                日期
                ,仓库
                ,货主名称
                , bar_code SKU
            FROM
                (
                SELECT
                    `date` 日期
                FROM tmpale.ods_th_dim_date
                where `date` <date(NOW()-INTERVAL 1 HOUR)
                and `date`>=date(NOW()-INTERVAL 1 HOUR)-INTERVAL 35 day
                group by `date`
                )m
            left join do1 on 1=1
            GROUP BY 日期
                ,仓库
                ,货主名称
                ,SKU
        ) a
        left join do1 on do1.仓库=a.仓库 and do1.货主名称=a.货主名称 and do1.bar_code=a.SKU
        left join (
            select
						date(t.delivery_time) 日期
						,w.name  仓库
						,t.seller_name 货主名称
						,sg3.bar_code
						,SUM(dog.goods_number)  消耗量
					from dwm.dwd_th_ffm_outbound_dayV2 t
					left join wms_production.delivery_order do2 on t.delivery_sn =do2.delivery_sn
                    left join wms_production.warehouse w on do2.warehouse_id = w.id
					left join wms_production.delivery_order_goods dog on dog.delivery_order_id =do2.id
					left join wms_production.seller_goods sg3 on sg3.id=dog.seller_goods_id
					where 1=1
						and t.TYPE='B2C'
                        and (t.warehouse_detailname = 'AGV-人工仓' or (t.seller_name='Fuzhou canghai yunfan（福州沧海云帆）' and t.warehouse_detailname='LAS' ) )-- 人工仓
					group by date(t.delivery_time)
						,w.name
						,t.seller_name
						,sg3.bar_code
        ) b on a.日期=b.日期 and a.仓库=b.仓库 and a.货主名称=b.货主名称 and a.SKU=b.bar_code
)a
WHERE 日期=date(NOW()-INTERVAL 25 HOUR)