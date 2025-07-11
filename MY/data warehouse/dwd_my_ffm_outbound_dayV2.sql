
/*=====================================================================+
表名称：  dwd_my_ffm_outbound_dayV2
功能描述：  马来ffm出库明细数据表

需求来源：
编写人员: hmf
设计日期：2024/11/19
修改日期:
修改人员:
修改原因:

-----------------------------------------------------------------------
---存在问题：追了近90天的数据，也就是2024-11-26到现在的数据
-----------------------------------------------------------------------
+===================================================================== */

-- drop table if exists dwm.dwd_my_ffm_outbound_dayV2;
-- create table dwm.dwd_my_ffm_outbound_dayV2 as
# delete from dwm.dwd_my_ffm_outbound_dayV2 where created_date >= date_sub(CURRENT_DATE,interval 90 day); -- 先删除数据
# insert into dwm.dwd_my_ffm_outbound_dayV2 -- 再插入数据
select
	 do2.TYPE
	,do2.delivery_sn
	,do2.goods_num
	,do2.warehouse_id
	,do2.warehouse_name
	,do2.platform_source
	,do2.seller_id
	,do2.seller_name
	,do2.Created_Time
	,do2.created_date
	,do2.audit_time
	,do2.audit_date
	,do2.pick_time
	,do2.pack_time
	,do2.handover_time
	,do2.delivery_time
	,do2.created_time_mod
	,do2.pack_deadline
	,do2.deadline
     ,do2.cutoff_time
	,do2.ETL
	,do2.is_time
	,do2.no_istime_type
	,do2.audit_type
	,do2.express_name
	,do2.out_operator
	,do2.packtimetype
	,do2.outtimetype
	,do2.TimeoutNode
	,do2.status
	,do2.is_visible
	,do2.express_sn
	,do2.express_name_fixup
	,do2.total_price
	,do2.tmp_platform_source
	,do2.logistic_charge
from
(
	SELECT
		do1.TYPE
		,do1.delivery_sn
		,goods_num
		,warehouse_id
		,do1.warehouse_name
		,platform_source
		,seller_id
		,do1.seller_name
		,Created_Time
		,created_date
		,audit_time
		,audit_date
		,pick_time
		,pack_time
		,handover_time
		,delivery_time
		,created_time_mod
		,pack_deadline
		,deadline
	     ,cutoff_time
		,date(deadline) dateline_format
		,ETL
		,is_time
		,no_istime_type
		,audit_type
		,express_name
		,out_operator
		,case
		    when tmp.delivery_sn is not null then '手工剔除'
		    when order_id is not null then '系统商品报缺'
		    when 'B2C'=do1.TYPE and no_istime_type='获取面单失败' and (handover_time is null or ( handover_time > pack_deadline)) and Created_Time < cutoff_time and audit_time >= cutoff_time then '获取面单失败导致审单超时'  -- addby 2025-03-27 王昱棋  若发生获取面单失败 & 不及时 则，不参与时效考核
		    when 'B2C'=do1.TYPE and ((delivery_time is null and now()>= pack_deadline) or (delivery_time is not null and delivery_time>=pack_deadline) ) and Created_Time < cutoff_time and (audit_time >= cutoff_time or audit_time is null ) then '审核时间过晚导致不及时'
		    when 'B2C'=do1.TYPE and ((delivery_time is null and now()>= pack_deadline) or (delivery_time is not null and delivery_time>=pack_deadline) ) and Created_Time >= cutoff_time and audit_time >= cutoff_time and audit_time >= date_add(cutoff_time_add1, interval 30 minute)  then '审核时间过晚导致不及时'
		    when 'B2C'=do1.TYPE and ((delivery_time is null and now()>= pack_deadline) or (delivery_time is not null and delivery_time>=pack_deadline) ) and Created_Time >= cutoff_time and audit_time is null then '审核时间过晚导致不及时'
		    when no_istime_type not in ('正常时效单','获取面单失败') then no_istime_type
			when pack_deadline > now() then 'notlatest packtime'
			when handover_time is null or ( handover_time > pack_deadline) then 'nopack intime'
			when handover_time <= pack_deadline then 'pack intime'
			end as packtimetype

		,case
		    when tmp.delivery_sn is not null then '手工剔除'
		    when order_id is not null then '系统商品报缺'
		    when 'B2C'=do1.TYPE and no_istime_type='获取面单失败' and (delivery_time is null or ( delivery_time > deadline)) and Created_Time < cutoff_time and audit_time >= cutoff_time then '获取面单失败导致审单超时'  -- addby 2025-03-27 王昱棋  若发生获取面单失败 & 不及时 则，不参与时效考核
		    when 'B2C'=do1.TYPE and ((delivery_time is null and now()>= deadline) or (delivery_time is not null and delivery_time>=deadline) ) and Created_Time < cutoff_time and (audit_time >= cutoff_time or audit_time is null ) then '审核时间过晚导致不及时'
		    when 'B2C'=do1.TYPE and ((delivery_time is null and now()>= deadline) or (delivery_time is not null and delivery_time>=deadline) ) and Created_Time >= cutoff_time and audit_time >= cutoff_time and audit_time >= date_add(cutoff_time_add1, interval 30 minute)  then '审核时间过晚导致不及时'
		    when 'B2C'=do1.TYPE and ((delivery_time is null and now()>= deadline) or (delivery_time is not null and delivery_time>=deadline) ) and Created_Time >= cutoff_time and audit_time is null then '审核时间过晚导致不及时'
		    when 'B2C'=do1.TYPE and no_istime_type not in ('正常时效单','获取面单失败')  then no_istime_type
			when 'B2C'=do1.TYPE and deadline > now() then 'notlatest outboundtime'
			when 'B2C'=do1.TYPE and delivery_time is null or ( delivery_time > deadline) then 'nooutbound intime'
			when 'B2C'=do1.TYPE and delivery_time <= deadline then 'outbound intime'
			end as outtimetype
		,case
		    when tmp.delivery_sn is not null then '手工剔除'
		    when order_id is not null then '系统商品报缺'
			when (audit_time > pack_deadline) or ( audit_time is null and pack_deadline< now() ) then '审核超时'
			when (pick_time > pack_deadline) or ( pick_time is null and pack_deadline< now() ) then '拣货超时'
			when (pack_time > pack_deadline) or  ( pack_time is null and pack_deadline< now() ) then  '打包超时'
			when 'B2C'=do1.TYPE and ((handover_time > deadline) or ( handover_time is null and deadline< now() )) then  '交接超时'
			when 'B2C'=do1.TYPE and ((delivery_time > deadline) or ( delivery_time is null and deadline< now() )) then  '揽收超时'
			else '未超时'
			end as TimeoutNode
		,status
		,is_visible
		,express_sn
		,express_name_fixup
		,CAST(total_price as decimal(26,6)) total_price
		,tmp_platform_source
		,cast(logistic_charge as decimal(26,6)) logistic_charge
	FROM
	(
		SELECT
			TYPE
			,delivery_sn
			,goods_num
			,warehouse_id
			,warehouse_name
			,CASE WHEN platform_source in('Shopee','Tik Tok','LAZADA') THEN platform_source
				ELSE 'Other' END platform_source
			,CASE WHEN platform_source in ('Lazada-LGF', 'LAZADA-LGF') THEN 'LAZADA'
					WHEN platform_source in ('Shopee','Tik Tok','LAZADA') THEN platform_source
					when left(order_sn, 1)='9' then 'LAZADA'
					when left(order_sn, 1)='5' then 'Tik Tok'
					when left(order_sn, 2)='24' then 'Shopee'
					ELSE 'Other' END tmp_platform_source
			,seller_id
			,seller_name
			,created_time Created_Time
			,created_date
			,audit_time
			,audit_date
			,pick_time
			,pack_time
			,handover_time
			,delivery_time
			,created_time_mod
			,CASE WHEN TYPE ='B2B' THEN concat(date2,substr(created_time_mod,11,9))
				-- WHEN TYPE ='B2C' THEN concat(date1,substr(created_time_mod,11,9))
                when TYPE ='B2C' and time(created_time_mod) <= do.cutoff and do.befcutoffday=0 THEN concat(LEFT(created_time_mod,10),' ', do.befcutofftime)
                when TYPE ='B2C' and time(created_time_mod) <= do.cutoff and do.befcutoffday=1 THEN concat(LEFT(date1,10),' ', do.befcutofftime)
                when TYPE ='B2C' and time(created_time_mod) >  do.cutoff and do.aftcutoffday=1 THEN concat(LEFT(date1,10),' ', do.befcutofftime)
                when TYPE ='B2C' and time(created_time_mod) >  do.cutoff and do.aftcutoffday=2 THEN concat(LEFT(date2,10),' ', do.befcutofftime)
				END pack_deadline

			,CASE WHEN TYPE ='B2B' THEN concat(date2,substr(created_time_mod,11,9))
				-- WHEN TYPE ='B2C' THEN concat(date1,substr(created_time_mod,11,9))
                when TYPE ='B2C' and time(created_time_mod) <= do.cutoff and do.befcutoffday=0 THEN concat(LEFT(created_time_mod,10),' ', do.befcutofftime)
                when TYPE ='B2C' and time(created_time_mod) <= do.cutoff and do.befcutoffday=1 THEN concat(LEFT(date1,10),' ', do.befcutofftime)
                when TYPE ='B2C' and time(created_time_mod) >  do.cutoff and do.aftcutoffday=1 THEN concat(LEFT(date1,10),' ', do.befcutofftime)
                when TYPE ='B2C' and time(created_time_mod) >  do.cutoff and do.aftcutoffday=2 THEN concat(LEFT(date2,10),' ', do.befcutofftime)
				END deadline
			,now() ETL
			,is_time
			,no_istime_type
			,audit_type
			,express_name
			,out_operator
			,status
			,is_visible
			,express_sn
			,express_name_fixup
			,total_price
			,order_sn
			,logistic_charge
		    ,concat(date_format(created_time_mod,'%Y-%m-%d'),' ', do.cutoff) cutoff_time
            ,concat(date_format(date1,'%Y-%m-%d'),' ', do.cutoff) cutoff_time_add1
		    ,order_id
		FROM
		(
			select
				do.TYPE
				,do.delivery_sn
				,do.goods_num
				,do.warehouse_id
				,do.warehouse_name
				-- ,if(do.is_tiktok is not null, 'Tik Tok',do.platform_source) platform_source
				,case when do.is_tiktok is not null then 'Tik Tok'
					when do.platform_source in ('Tik Tok', 'TikTok') then 'Tik Tok'
					when do.platform_source in ('Shopee') then 'Shopee'
					when do.platform_source in ('LAZADA', 'Lazada') then 'LAZADA'
					else do.platform_source end as platform_source
				,do.seller_name
				,do.seller_id
				,do.created_time
				,do.created_date
				,do.audit_time
				,do.audit_date
				,do.pick_time
				,do.pack_time
				,do.handover_time
				,do.delivery_time
				,do.is_time
				,do.no_istime_type
				-- ,do.audit_type
				,case when do.audit_time is not null then '已审核'
					when do.audit_time is null and do.audit_type is not null then audit_type
					when do.audit_time is null and do.audit_type is null then '未审核'
					end as audit_type
				,do.express_name
				,do.out_operator
				,calendar.created
				,calendar.if_day_off
				,calendar.created_mod
				,calendar.date1
				,calendar.date2
				,calendar.date3
				,calendar.date4
				,case when calendar.if_day_off='是' then concat(calendar.created_mod,' 00:00:00') else concat(calendar.created_mod,substr(do.created_time,11,9)) end created_time_mod
				,status
				,is_visible
				,express_sn
				,express_name_fixup
				,total_price
				,order_sn
				,logistic_charge
                ,ttlc.cutoff
                ,ttlc.aftcutoffday
                ,ttlc.befcutoffday
                ,ttlc.aftcutofftime
                ,ttlc.befcutofftime
			    ,do.order_id
			FROM
			(
				-- B2C
				SELECT
					'B2C' TYPE
					,if(locate('-1', do.delivery_sn)>0 ,left(do.delivery_sn, 13), do.delivery_sn) delivery_sn
					,goods_num
					,warehouse_id
					,w.name warehouse_name
					,if(left(do.`created`, 10) <'2024-10-31', ps.`name`, i18.zh) platform_source -- 20241031新上的功能，修改取数逻辑
					,sl.`name` seller_name
					,do.seller_id
					,do.`created` created_time
					,left(do.`created`, 10) created_date
					,do.`audit_time` audit_time
					,left(do.`audit_time`, 10) audit_date
					,do.`succ_pick` pick_time
					,do.`pack_time` pack_time
					,do.`start_receipt ` handover_time
					,do.`delivery_time` delivery_time
					,if(locate('DO',do.express_sn)>0 or substring(do.express_sn,1,3)='LBX' or do.is_presale=1 or t0.order_sn is not null or (w.name='BPL-Return Warehouse' and substring(do.express_name,1,3)='SPX'), 0, 1) is_time -- do.is_presale=1 预售单不参与时效考核
					,case when do.is_presale=1 then '预售单'
						when t0.order_sn is not null then '获取面单失败'
					    when t1.order_sn is not null then '撤回成功'
						when locate('DO',do.express_sn)>0 then 'DO快递单号'
						when substring(do.express_sn,1,3)='LBX' then 'LBX快递单号'
						when (w.name='BPL-Return Warehouse' and substring(do.express_name,1,3)='SPX') then 'SPX快递单号'
                        when do.express_name = 'Same Day Delivery' then 'Same Day Delivery'
					    when do.express_name ='Self-collection' then 'Self-collection'
						else '正常时效单'
						end as no_istime_type
					,case when do.is_presale=1 then '预售单'
						when t0.order_sn is not null then '获取面单失败'
						end as audit_type
					,do.express_name
					, wd.id is_tiktok
					,do.operator_id out_operator
					,case do.`status`
					when 1000 then '取消发货'
					when 1002 then '等待激活'
					when 1003 then '预售订单'
					when 1005 then '待分仓'
					when 1007 then '已分仓'
					-- 货主审核订单前，已经知道系统缺货进行的状态提示。正常状态客户不应该审核通过这些订单
					when 1010 then '缺货'
					when 1015 then '已分仓(废弃)'
					when 1020 then '等待审核'
					when 1030 then '审核完成'
					-- 调用快递系统。多长时间提示? 金额是否有小数点？收件人，寄件人，电话是否有？ 号单是否匹配？  超过30分钟获取面单失败的数据
					when 1035 then '获取电子面单号失败'
					when 1040 then '获取电子面单号成功'
					-- 审核通过且获取面单成功后，系统分配库存失败
					when 2000 then '库存分配暂停'
					-- 审核通过且获取面单成功后，系统分配库存失败
					when 2005 then '分配库存失败'
					when 2010 then '分配库存成功'
					when 2015 then '分配预打包成功'
					when 2016 then '生成波次成功'
					when 2020 then '等待拣货'
					when 2030 then '拣货完成'
					when 2035 then '换单待打印'
					when 2040 then '打包完成'
					when 2050 then '开始交接'
					when 2060 then '发货完成'
					when 3010 then '配送中'
					when 3013 then '配送异常'
					when 3015 then '已拒收'
					when 3018 then '部分拒收'
					when 3020 then '已签收'
					when 3050 then '虚拟发货'
					else '其他'
					end as status
					,case when do.`status` NOT IN ('1000','1010') and do.`platform_status` != 9 and do.prompt NOT in (1,2,3,4) and sl.name not in ('FFM-TH', 'Flash -Thailand') and locate('-1', do.delivery_sn)=0 then 1
							else 0
					end as is_visible
					,do.express_sn
					,do.express_name as   express_name_fixup
					,round(total_price/100, 2) total_price
					,do.order_sn
					,do.logistic_charge/100 logistic_charge
				    ,asl.order_id
				FROM `wms_production`.`delivery_order` do
				LEFT JOIN `wms_production`.`seller_platform_source` sps on do.`platform_source_id`=sps.`id`
				LEFT JOIN `wms_production`.`platform_source` ps on sps.`platform_source_id`=ps.`id`
				LEFT JOIN `wms_production`.`seller` sl on do.`seller_id`=sl.`id`
				LEFT JOIN wms_production.warehouse w ON do.warehouse_id=w.id
				left join
				( -- 获取面单失败
					select
						order_sn
					from
					`wms_production`.operation_log
					where 1=1
						and status_after='1035'
						and `created` >= date_sub(current_date,interval 90 day)
						and `created`>='2023-06-01'
					group by 1
				) t0 on do.delivery_sn = t0.order_sn
                left join
                ( -- 撤回成功
                    select
                        order_sn
                    from
                    `wms_production`.operation_log
                    where 1=1
                        and operation='back'
                        and `created` >= convert_tz(date_sub(date(now() + interval -1 hour),interval 90 day), '+07:00', '+08:00')
                        and `created`>='2023-06-01'
                    group by 1
                ) t1 on do.delivery_sn = t1.order_sn
				left join (select delivery_order_id,mark_id from wms_production.`delivery_order_mark_relation` where mark_id in (201, 200)) domr on domr.delivery_order_id = do.id
				left join (select id from wms_production.wordbook_detail where `wordbook_id` = 10 and (zh = 'TT3' or zh='TT')) wd on domr.mark_id=wd.id
				left join wms_production.delivery_order_extra doe on do.id = doe.delivery_order_id
				left join wms_production.i18 on concat('deliveryOrder.salesPlatform.',doe.platform_from) = i18.key
                left join
                ( -- addby 王昱棋 20250228 commit:发货单下面有商品会出现超发导致的发货单不及时，不是仓库原因，不考核时效
                    select
                    id
#                     ,warehouse_id
                    ,seller_goods_id
                    ,type
                    ,status
                    ,create_time
                    ,order_id
                    from
                    wms_production.allocate_stock_log asl
                ) asl on do.id=asl.order_id
				WHERE 1=1
					and do.`created` >= date_sub(current_date,interval 90 day)
					and do.`created` >= '2023-06-01'

				UNION ALL
				-- B2B
				SELECT
					'B2B' TYPE
					,return_warehouse_sn
					,total_goods_num
					,do.warehouse_id
					,w.name warehouse_name
					,'B2B' platform_source
					,sl.name seller_name
					,do.`seller_id` seller_id
					,do.`created` created_time
					,left(do.`created`, 10) created_date
					,do.`verify_time` audit_time
					,left(do.`verify_time`, 10) audit_date
					,do.picking_end_time
					,do.pack_time
					,do.`out_warehouse_time` handover_time
					,do.`out_warehouse_time` delivery_time
					,if(locate('DO',do.express_sn)>0 or substring(do.express_sn,1,3)='LBX', 0, 1) is_time
					,case
						when locate('DO',do.express_sn)>0 then 'DO快递单号'
						when substring(do.express_sn,1,3)='LBX' then 'LBX快递单号'
						else '正常时效单'
						end as no_istime_type
					,null as audit_type
					,ulc.name
					,null is_tiktok
					,null out_operator
					,case do.status
						when 1000 then '已作废'
						when 1005 then '草稿'
						when 1010 then '待审核'
						when 1015 then '审核不通过'
						when 1020 then '已审核'
						when 2000 then '库存分配暂停'
						when 2005 then '分配库存失败'
						when 2010 then '分配库存成功'
						when 2020 then '已确认'
						when 2025 then '拣货中'
						when 2028 then '拣货完成'
						when 2030 then '已打包'
						when 2040 then '出库进行中'
						when 3010 then '已出库'
						when 3020 then '已完成'
						else do.status
					end as status
					,case when prompt ='0' AND status>='1020' and sl.name not in ('FFM-TH', 'Flash -Thailand') then 1
						else 0 end as is_visible
					,do.express_sn
					,null as   express_name_fixup
					,null total_price
					,null order_sn
					,null logistic_charge
				,null order_id
				from  wms_production.return_warehouse do
				LEFT JOIN wms_production.warehouse w ON do.warehouse_id=w.id
				LEFT JOIN `wms_production`.`seller` sl on do.`seller_id`=sl.`id`
				left join wms_production.logistic_company ul on do.logistic_company_id = ul.id
				left join wms_production.usable_logistic_company ulc on ul.usable_logistic_company_id  = ulc.id
				WHERE 1=1
					-- and prompt ='0'
					-- AND status>='1020'
					and do.`created` >= date_sub(current_date,interval 90 day)
					and do.`created` >= '2023-06-01'
					-- and sl.name not in ('FFM-TH', 'Flash -Thailand') -- 剔除物料和资产
			) do
			left join
			-- 日历调整// created_mod 是节假日顺延后首日,date1是节假日顺延后第二天
			dwm.dim_my_default_timeV2 calendar on calendar.created=do.created_date
            left join
            dwm.dim_tmp_my_FFM_TTLconfig ttlc on 1=1
			where created_date>='2023-09-04'
		)do
	)do1
	left join
    (
        select
            warehouse_name,
            seller_name,
            delivery_sn,
            type,
            commit
        from
            dwm.tmp_my_ffm_notimesn_detail
        where type in ('Outbound2C', 'Outbound2B')
    ) tmp on do1.delivery_sn = tmp.delivery_sn
# 	where do1.delivery_sn='DO25061421193'
) do2