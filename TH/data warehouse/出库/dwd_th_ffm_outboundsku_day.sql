
/*=====================================================================+
表名称：  dwd_th_ffm_outboundsku_day
功能描述：  泰国ffm出库明细(sku)数据表

需求来源：
编写人员: wangdongchen
设计日期：2024/8/22
修改日期:
修改人员:
修改原因:

-----------------------------------------------------------------------
---存在问题：
-----------------------------------------------------------------------
+===================================================================== */

-- drop table if exists dwm.dwd_th_ffm_outboundsku_day;
-- create table dwm.dwd_th_ffm_outboundsku_day as
# delete from dwm.dwd_th_ffm_outboundsku_day where created_date >= date_sub(date(now() + interval -1 hour),interval 90 day); -- 先删除数据
# insert into dwm.dwd_th_ffm_outboundsku_day -- 再插入数据

-- 发货明细表
select
    TYPE
    ,do2.delivery_sn
    ,goods_num
    ,warehouse_id
    ,warehouse_name
    ,warehouse_name2
    ,platform_source
    ,seller_id
    ,seller_name
    ,Created_Time
    ,created_date
    ,audit_time
    ,audit_date
    ,pick_time
    ,pack_time
    ,handover_time
    ,delivery_time
    ,created_time_mod
    ,2Bpack_deadline
    ,2Chand_deadline
    ,2Cdeadline
    ,ETL
    ,is_time
    ,no_istime_type
    ,audit_type
    ,express_name
    ,out_operator
    ,if(nd.delivery_sn is not null, '邮件剔除时效', 2Bpacktimetype) 2Bpacktimetype
    ,if(nd.delivery_sn is not null, '邮件剔除时效', do2.handtimetype) handtimetype
    ,if(nd.delivery_sn is not null, '邮件剔除时效', do2.outtimetype) outtimetype --
    ,TimeoutNode
    ,status
    ,is_visible
    ,express_sn
    ,express_name_fixup
    ,total_price
    ,tmp_platform_source
    ,goods_number_sku
    ,bar_code
    ,length
    ,width
    ,height
    ,weight
    ,volume
    ,goods_name
    ,volume*goods_number_sku as total_volume
    ,TYPEsize

    ,sku_status
    ,logistic_charge
    ,is_OT48h
    ,is_OT72h
    ,is_2CcreateOT48h
    ,is_2CdeliveryOT48h
    ,buy_time
    ,payment_time
    ,payment_timeadd3h
    ,OrderPush_intime OrderPush_type
    ,express_time
    ,cutoff_time
    ,TYPEsizev2
    from
    (
        SELECT
             do.TYPE
            ,do.delivery_sn
            ,do.goods_num
            ,do.warehouse_id
            ,do.warehouse_name
            ,do.warehouse_name2
            ,do.platform_source
            ,do.seller_id
            ,do.seller_name
            ,do.Created_Time
            ,do.created_date
            ,do.audit_time
            ,do.audit_date
            ,do.pick_time
            ,do.pack_time
            ,do.handover_time
            ,do.delivery_time
            ,do.created_time_mod
            ,do.`2Bpack_deadline`
            ,do.`2Chand_deadline`
            ,do.`2Cdeadline`
            ,ETL
            /* ,if(TYPE='B2C' and express_name_fixup not in ('FLASH', 'SPX', 'LEX', 'J&T', 'LAZ-JIT'), 0 ,is_time) is_time */
            ,case when TYPE='B2C' and express_name_fixup not in ('FLASH', 'SPX', 'LEX', 'J&T', 'LAZ-JIT') then 0
                when naa.seller_name is not null and (handover_time is null or ( handover_time > 2Chand_deadline)) and Created_Time < cutoff_time and audit_time >= cutoff_time then  0
                else is_time end as is_time
            ,do.no_istime_type
            ,do.audit_type
            ,do.express_name
            ,do.out_operator
                /* -- 2B 2C 监控打包时间
            ,case when TYPE in ('B2C', 'B2B') and pack_time<pack_deadline then 1
                else 0
                end as 及时打包
            ,case when TYPE in ('B2C', 'B2B') and Created_Time is not null and (pack_time is not null OR pack_deadline< date_add(now(), interval -60 minute)) then 1
                else 0
                end as 应打包
                -- 2C监控发货时间，2B不监控发货时间
            ,case when TYPE='B2C' and delivery_time<deadline then 1
                else 0
                end as 及时发货
                -- 2C监控发货时间，2B不监控发货时间
            ,case when TYPE='B2C' and Created_Time is not null and (delivery_time is not null OR deadline< date_add(now(), interval -60 minute)) then 1
                else 0
                end as 应发货 */
            ,case when no_istime_type <> '正常时效单' then no_istime_type
                when order_id is not null then '系统商品报缺'
                when 2Bpack_deadline > date_add(now(), interval -60 minute) then 'notlatest packtime'
                when handover_time is null or ( handover_time > 2Bpack_deadline) then 'nopack intime'
                when handover_time <= 2Bpack_deadline then 'pack intime'
                end as 2Bpacktimetype

            ,case
                when 'B2C'=TYPE and express_name_fixup not in ('FLASH', 'SPX', 'LEX', 'J&T', 'LAZ-JIT') then '小体量快递不做考核'
                when 'B2C'=TYPE and order_id is not null then '系统商品报缺'
                when 'B2C'=TYPE and no_istime_type='获取面单失败' and (handover_time is null or ( handover_time > 2Chand_deadline)) and Created_Time < cutoff_time and express_time >= cutoff_time then '获取面单失败导致审单超时'  -- addby 2025-03-27 王昱棋  若发生获取面单失败 & 不及时 则，不参与时效考核
                when 'B2C'=TYPE and naa.seller_name is not null and (handover_time is null or ( handover_time > 2Chand_deadline)) and Created_Time < cutoff_time and audit_time >= cutoff_time then '没有自动审单货主单据超时'
                when 'B2C'=TYPE and no_istime_type not in ('正常时效单', '获取面单失败') then no_istime_type
                when 'B2C'=TYPE and 2Chand_deadline > date_add(now(), interval -60 minute) then 'notlatest handtime'
                when 'B2C'=TYPE and handover_time is null or ( handover_time > 2Chand_deadline) then 'nohand intime'
                when 'B2C'=TYPE and handover_time <= 2Chand_deadline then 'hand intime'
                end as handtimetype
            ,case
                when 'B2C'=TYPE and express_name_fixup not in ('FLASH', 'SPX', 'LEX', 'J&T', 'LAZ-JIT') then '小体量快递不做考核'
                when 'B2C'=TYPE and order_id is not null then '系统商品报缺'
                when 'B2C'=TYPE and no_istime_type='获取面单失败' and (delivery_time is null or ( delivery_time > 2Cdeadline)) and Created_Time < cutoff_time and express_time >= cutoff_time then '获取面单失败导致审单超时'  -- addby 2025-03-27 王昱棋  若发生获取面单失败 & 不及时 则，不参与时效考核
                when 'B2C'=TYPE and naa.seller_name is not null and (delivery_time is null or ( delivery_time > 2Cdeadline)) and Created_Time < cutoff_time and audit_time >= cutoff_time then '没有自动审单货主单据超时'
                when 'B2C'=TYPE and no_istime_type not in ('正常时效单', '获取面单失败') then no_istime_type -- addby 2025-03-27 王昱棋  若发生获取面单失败 & 及时 则，参与时效考核
                when 'B2C'=TYPE and 2Cdeadline > date_add(now(), interval -60 minute) then 'notlatest outboundtime'
                when 'B2C'=TYPE and (delivery_time is null or ( delivery_time > 2Cdeadline)) then 'nooutbound intime'
                when 'B2C'=TYPE and delivery_time <= 2Cdeadline then 'outbound intime'
                end as outtimetype
            ,case
                when express_name_fixup not in ('FLASH', 'SPX', 'LEX', 'J&T', 'LAZ-JIT') then '小体量快递不做考核'
                when order_id is not null then '系统商品报缺'
                when (audit_time > 2Chand_deadline) or ( audit_time is null and 2Chand_deadline< date_add(now(), interval -60 minute) ) then '审核超时'
                when (pick_time > 2Chand_deadline) or ( pick_time is null and 2Chand_deadline< date_add(now(), interval -60 minute) ) then '拣货超时'
                when (pack_time > 2Chand_deadline) or  ( pack_time is null and 2Chand_deadline< date_add(now(), interval -60 minute) ) then  '打包超时'
                when 'B2C'=TYPE and ((handover_time > 2Chand_deadline) or ( handover_time is null and 2Chand_deadline< date_add(now(), interval -60 minute) )) then  '交接超时'
                when 'B2C'=TYPE and ((delivery_time > 2Cdeadline) or ( delivery_time is null and 2Cdeadline< date_add(now(), interval -60 minute) )) then  '揽收超时'
                else '未超时'
                end as TimeoutNode
            ,status
            ,is_visible
            ,express_sn
            ,express_name_fixup
            ,CAST(total_price as decimal(26,6)) total_price
            ,tmp_platform_source
            ,goods_number_sku
            ,bar_code
            ,length
            ,width
            ,height
            ,weight
            ,volume
            ,goods_name
            ,volume*goods_number_sku as total_volume
            ,TYPEsize
            ,TYPEsizev2
            ,sku_status
            ,logistic_charge
            ,is_OT48h
            ,is_OT72h
            ,is_2CcreateOT48h
            ,is_2CdeliveryOT48h
            ,order_id
            ,buy_time
            ,payment_time
            ,payment_timeadd3h
            ,OrderPush_intime
            ,express_time
            ,cutoff_time
        FROM
        (
            SELECT
                TYPE
                ,delivery_sn
                ,goods_num
                ,warehouse_id
                ,case when warehouse_name in ('AutoWarehouse', 'AutoWarehouse-人工仓')   then 'AGV'
                    when warehouse_name='BPL-Return Warehouse'  then 'BPL-Return'
                    when warehouse_name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                    when warehouse_name in ('BangsaoThong','BST-FMCG')  then 'BST'
                    when warehouse_name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                     end warehouse_name
                ,case when warehouse_name in ('AutoWarehouse')   then 'AGV'
                    when warehouse_name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                    when warehouse_name='BPL-Return Warehouse'  then 'BPL-Return'
                    when warehouse_name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                    when warehouse_name='BangsaoThong'  then 'BST'
                    when warehouse_name='BST-FMCG'  then 'BST-FMCG'
                    when warehouse_name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                    end warehouse_name2
                ,do.platform_source
                ,CASE WHEN do.platform_source in ('Lazada-LGF', 'LAZADA-LGF') THEN 'LAZADA'
                        WHEN do.platform_source in ('Shopee','Tik Tok','LAZADA') THEN do.platform_source
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
                ,concat(date_format(created_time_mod,'%Y-%m-%d'),' ', t_out.cutoff) cutoff_time
                ,CASE WHEN TYPE ='B2B' THEN concat(date3,substr(created_time_mod,11,9))
                    END 2Bpack_deadline
                --     WHEN platform_source='Shopee' AND substr(created_time_mod,12,2)<16 THEN concat(LEFT(created_time_mod,10),' 23:59:59')
                --     WHEN platform_source='Shopee' AND substr(created_time_mod,12,2)>=16 THEN concat(date1,' 23:59:59')
                --     WHEN platform_source='Tik Tok' AND substr(created_time_mod,12,2)<18 THEN concat(LEFT(created_time_mod,10),' 23:59:59')
                --     WHEN platform_source='Tik Tok' AND substr(created_time_mod,12,2)>=18 THEN concat(date1,' 23:59:59')
                --     ELSE concat(date1,substr(created_time_mod,11,9)) END pack_deadline
                ,CASE
                	when  t_hand.cutoff=1 then concat(date_add(created_date, interval t_hand.befcutoffday day), ' ', t_out.befcutofftime)
                    # when t_hand.cutoff=1 and t_hand.befcutoffday=1 THEN concat(date1 , ' ', t_out.befcutofftime)
                    # when t_hand.cutoff=1 and t_hand.befcutoffday=2 THEN concat(date2 , ' ', t_out.befcutofftime)
                    # when t_hand.cutoff=1 and t_hand.befcutoffday=3 THEN concat(date3 , ' ', t_out.befcutofftime)
                    # when t_hand.cutoff=1 and t_hand.befcutoffday=4 THEN concat(date4 , ' ', t_out.befcutofftime)
                    # when t_hand.cutoff=1 and t_hand.befcutoffday=5 THEN concat(date5 , ' ', t_out.befcutofftime)
                    # when t_hand.cutoff=1 and t_hand.befcutoffday=6 THEN concat(date6 , ' ', t_out.befcutofftime)
                    # when t_hand.cutoff=1 and t_hand.befcutoffday=7 THEN concat(date7 , ' ', t_out.befcutofftime)
                    when time(created_time_mod) <= t_hand.cutoff and t_hand.befcutoffday=0 THEN concat(LEFT(created_time_mod,10),' ', t_hand.befcutofftime)
                    when time(created_time_mod) <= t_hand.cutoff and t_hand.befcutoffday=1 THEN concat(LEFT(date1,10),' ', t_hand.befcutofftime)
                    when time(created_time_mod) >  t_hand.cutoff and t_hand.aftcutoffday=1 THEN concat(LEFT(date1,10),' ', t_hand.befcutofftime)
                    when time(created_time_mod) >  t_hand.cutoff and t_hand.aftcutoffday=2 THEN concat(LEFT(date2,10),' ', t_hand.befcutofftime)
                    END 2Chand_deadline
                -- ,CASE WHEN TYPE ='B2B' THEN concat(date2,substr(created_time_mod,11,9))
                --     WHEN do.platform_source='Shopee' AND substr(created_time_mod,12,2)<16 THEN concat(LEFT(created_time_mod,10),' 23:59:59')
                --     WHEN do.platform_source='Shopee' AND substr(created_time_mod,12,2)>=16 THEN concat(date1,' 23:59:59')
                --     WHEN do.platform_source='Tik Tok' AND substr(created_time_mod,12,2)<18 THEN concat(LEFT(created_time_mod,10),' 23:59:59')
                --     WHEN do.platform_source='Tik Tok' AND substr(created_time_mod,12,2)>=18 THEN concat(date1,' 23:59:59')
                --     WHEN do.platform_source='LAZADA' THEN concat(date2,substr(created_time_mod,11,9))
                --     ELSE concat(date1,substr(created_time_mod,11,9)) END deadline
                ,CASE
                	when  t_out.cutoff=1 then concat(date_add(created_date, interval t_out.befcutoffday day), ' ', t_out.befcutofftime)
                    # when t_out.cutoff=0 and t_out.aftcutoffday=1 THEN concat(date1 ,substr(created_time_mod,11,9))
                    # when t_out.cutoff=0 and t_out.aftcutoffday=2 THEN concat(date2 ,substr(created_time_mod,11,9))
                    # when t_out.cutoff=1 and t_out.befcutoffday=1 THEN concat(date1 , ' ', t_out.befcutofftime)
                    # when t_out.cutoff=1 and t_out.befcutoffday=2 THEN concat(date2 , ' ', t_out.befcutofftime)
                    # when t_out.cutoff=1 and t_out.befcutoffday=3 THEN concat(date3 , ' ', t_out.befcutofftime)
                    # when t_out.cutoff=1 and t_out.befcutoffday=4 THEN concat(date4 , ' ', t_out.befcutofftime)
                    # when t_out.cutoff=1 and t_out.befcutoffday=5 THEN concat(date5 , ' ', t_out.befcutofftime)
                    # when t_out.cutoff=1 and t_out.befcutoffday=6 THEN concat(date6 , ' ', t_out.befcutofftime)
                    # when t_out.cutoff=1 and t_out.befcutoffday=7 THEN concat(date7 , ' ', t_out.befcutofftime)
                    when time(created_time_mod) <= t_out.cutoff and t_out.befcutoffday=0 THEN concat(LEFT(created_time_mod,10),' ', t_out.befcutofftime)
                    when time(created_time_mod) <= t_out.cutoff and t_out.befcutoffday=1 THEN concat(LEFT(date1,10),' ', t_out.befcutofftime)
                    when time(created_time_mod) >  t_out.cutoff and t_out.aftcutoffday=1 THEN concat(LEFT(date1,10),' ', t_out.befcutofftime)
                    when time(created_time_mod) >  t_out.cutoff and t_out.aftcutoffday=2 THEN concat(LEFT(date2,10),' ', t_out.befcutofftime)
                    END 2Cdeadline
                ,date_add(now(),interval -60 minute) ETL
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
                ,goods_number_sku
                ,bar_code
                ,length
                ,width
                ,height
                ,weight
                ,volume
                ,goods_name
                ,TYPEsize
                ,TYPEsizev2
                ,sku_status
                ,logistic_charge
                ,if(delivery_time is null and now() + interval -1 hour > audit_time48h, 1, 0 ) is_OT48h -- 积压单逻辑
                ,if(delivery_time is null and now() + interval -1 hour > audit_time72h, 1, 0 ) is_OT72h
                ,if(audit_time is null and no_istime_type not in ('预售单', '曾缺货订单') and is_visible=1 and now() + interval -1 hour > created_time48h, 1, 0 ) is_2CcreateOT48h
                ,if(status='发货完成' and platform_status='准备发货' and now() + interval -1 hour > delivery_time48h, 1, 0 ) is_2CdeliveryOT48h
                ,order_id
                ,buy_time
                ,payment_time
                ,payment_timeadd3h
                ,case when payment_time is null then 'nopayment_time'
                    when created_time < payment_timeadd3h then 'intime'
                    when created_time >= payment_timeadd3h then 'notintime'
                    end as OrderPush_intime
                ,express_time
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
                        when platform_source in ('Tik Tok', 'TikTok') then 'Tik Tok'
                        when platform_source in ('Shopee') then 'Shopee'
                        when platform_source in ('LAZADA', 'Lazada') then 'LAZADA'
                        ELSE 'Other' end as platform_source
                    ,do.seller_name
                    ,do.seller_id
                    ,do.created_time
                    ,do.created_date
                    ,do.audit_time
                    ,date_add(do.`audit_time`, interval 48 hour) audit_time48h
                    ,date_add(do.`audit_time`, interval 72 hour) audit_time72h
                    ,date_add(do.`created_time`, interval 48 hour) created_time48h
                    ,date_add(do.`delivery_time`, interval 48 hour) delivery_time48h
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
                    ,calendar.date5
                    ,calendar.date6
                    ,calendar.date7
                    ,case when calendar.if_day_off='是' then concat(calendar.created_mod,' 00:00:00') else concat(calendar.created_mod,substr(do.created_time,11,9)) end created_time_mod
                    ,status
                    ,is_visible
                    ,express_sn
                    ,express_name_fixup
                    ,total_price
                    ,order_sn
                    ,goods_number_sku
                    ,bar_code
                    ,goods_name
                    ,length
                    ,width
                    ,height
                    ,weight
                    ,volume
                    ,CASE WHEN greatest(LENGTH, width, height)<=250 AND weight <= 3000 AND weight>0 THEN '小件'
                        WHEN greatest(LENGTH, width, height)<=500 AND weight <= 5000 AND weight>0 THEN '中件'
                        WHEN greatest(LENGTH, width, height)<=1000 AND weight <= 15000 AND weight>0 THEN '大件'
                        WHEN (greatest(LENGTH, width, height)>1000 AND weight>0) OR (weight > 15000 and LENGTH>0 and width>0 and height>0 ) THEN '超大件'
                        WHEN seller_name ='Flash -Thailand' then '其他'
                        else '信息不全'
                        END TYPEsize
                    ,CASE WHEN greatest(LENGTH, width, height)<=250 AND weight <= 10000 AND weight>0 THEN '小件'
                        WHEN greatest(LENGTH, width, height)<=500 AND weight <= 10000 AND weight>0 THEN '中件'
                        WHEN greatest(LENGTH, width, height)<=1000 AND weight <= 10000 AND weight>0 THEN '大件'
                        WHEN (greatest(LENGTH, width, height)>1000 AND weight>0) OR (weight > 10000 and LENGTH>0 and width>0 and height>0 ) THEN '超大件'
                        WHEN seller_name ='Flash -Thailand' then '其他'
                        else '信息不全'
                        END TYPEsizev2
                    ,sku_status
                    ,logistic_charge
                    ,platform_status
                    ,order_id
                    ,buy_time
                    ,payment_time
                    ,date_add(payment_time, interval 3 hour) payment_timeadd3h
                    ,express_time
                FROM
                (
                    -- wms平台
                    SELECT
                        'B2C' TYPE
                        ,if(locate('-1', do.delivery_sn)>0 ,left(do.delivery_sn, 13), do.delivery_sn) delivery_sn
                        ,goods_num
                        ,do.warehouse_id
                        ,w.name warehouse_name
                        ,if(left(date_add(do.`created`, interval -60 minute), 10) <'2024-10-31', ps.`name`, i18.th) platform_source -- 20241031新上的功能，修改取数逻辑
                        ,sl.`name` seller_name
                        ,do.seller_id
                        ,date_add(do.`created`, interval -60 minute) created_time
                        ,left(date_add(do.`created`, interval -60 minute), 10) created_date
                        ,date_add(do.`audit_time`, interval -60 minute) audit_time
                        ,left(date_add(do.`audit_time`, interval -60 minute), 10) audit_date
                        ,do.`succ_pick` pick_time
                        ,do.`pack_time` pack_time
                        ,do.`start_receipt ` handover_time
                        ,date_add(do.`delivery_time`, interval -60 minute) delivery_time
                        ,if(locate('DO',do.express_sn)>0 or substring(do.express_sn,1,3)='LBX' or do.is_presale=1 or (w.name='BPL-Return Warehouse' and substring(do.express_name,1,3)='SPX') or left(ifnull(express_name, 'nulldata'), 8)='Drop-off', 0, 1) is_time -- do.is_presale=1 预售单不参与时效考核
                        ,case when do.is_presale=1 then '预售单'
                            when t0.order_sn is not null then '获取面单失败' -- 曾缺货订单
                            when t1.order_sn is not null then '撤回成功'
                            when locate('DO',do.express_sn)>0 then 'DO快递单号'
                            when substring(do.express_sn,1,3)='LBX' then 'LBX快递单号'
                            when (w.name='BPL-Return Warehouse' and substring(do.express_name,1,3)='SPX') then 'SPX快递单号'
                            when left(ifnull(express_name, 'nulldata'), 8)='Drop-off' then 'DropOff单'
                            else '正常时效单'
                            end as no_istime_type
                        ,case when do.is_presale=1 then '预售单'
                            when t0.order_sn is not null then '曾获取面单失败订单'
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
                        ,case when left(do.express_sn, 2)='TH' and pi.pno is not null then 'FLASH'
                            when left(do.express_sn, 2)='TH' and pi.pno is null then 'SPX'
                            when left(do.express_sn, 2)='66' then 'BEST'
                            when left(do.express_sn, 2)='BS' then 'BEST'
                            when left(do.express_sn, 2)='59' then 'DHL'
                            when left(do.express_sn, 2)='90' then 'FLASH'
                            when left(do.express_sn, 2)='FE' then 'FLASH'
                            when left(do.express_sn, 2)='76' then 'J&T'
                            when left(do.express_sn, 2)='75' then 'J&T'
                            when left(do.express_sn, 2)='61' then 'J&T'
                            when left(do.express_sn, 2)='52' then 'J&T'
                            when left(do.express_sn, 2)='KE' then 'Kerry'
                            when left(do.express_sn, 2)='OD' then 'Kerry'
                            when left(do.express_sn, 2)='ON' then 'Kerry'
                            when left(do.express_sn, 2)='SH' then 'Kerry'
                            when left(do.express_sn, 2)='TI' then 'Kerry'
                            when left(do.express_sn, 2)='LE' then 'LEX'
                            when left(do.express_sn, 2)='LB' then 'LAZ-JIT'
                            when left(do.express_sn, 2)='JA' then 'Post'
                            when left(do.express_sn, 2)='DO' then '自提'
                            else '其他' end as   express_name_fixup
                        ,round(do.total_price/100, 2) total_price
                        ,do.order_sn
                        ,do.logistic_charge/100 logistic_charge
                        ,dog.seller_goods_id
                        ,dog.goods_number goods_number_sku
                        ,sg.bar_code
                        ,sg.length
                        ,sg.width
                        ,sg.height
                        ,sg.weight
                        ,sg.volume
                        ,sg.name goods_name
                        ,case dog.status
                            when 1 then '系统报缺'
                            when 2 then '待补货'
                            when 3 then '待上架'
                            end as sku_status
                         ,case do.platform_status
                          when 1 then '待处理'
                          when 2 then '准备发货'
                          when 3 then '已发货'
                          when 4 then '已签收'
                          when 5 then '交付失败'
                          when 6 then '被快递丢失'
                          when 7 then '退货'
                          when 8 then '被快递损坏'
                          when 9 then '取消'
                          end as platform_status -- addby 王昱棋 20250226 只针对2C
                        ,asl.order_id
                        ,do.buy_time
                        ,do.payment_time
                        ,do.express_time -- 获取面单时间

                    FROM `wms_production`.`delivery_order` do
                    left join wms_production.delivery_order_goods dog on do.id = dog.delivery_order_id
                    left join wms_production.seller_goods sg on dog.seller_goods_id  =sg.id
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
                            and status_after in('1035' ) -- 缺货  获取电子面单号失败 分配库存失败 ('1010', '1035', '2005')
                            and `created` >= convert_tz(date_sub(date(now() + interval -1 hour),interval 90 day), '+07:00', '+08:00')
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
					left join (

                        SELECT
                            convert_tz(pi.created_at, '+00:00', '+07:00') created_at
                            ,pno
                        FROM fle_staging.parcel_info pi
                        where
                        pi.created_at >= date_sub(date_sub(current_date, interval 100 day), interval 7 hour)
                    ) pi on do.express_sn = pi.pno
                    left join
                    ( -- addby 王昱棋 20250228 commit:发货单下面有商品会出现超发导致的发货单不及时，不是仓库原因，不考核时效
                        select
                        id
                        ,warehouse_id
                        ,seller_goods_id
                        ,type
                        ,status
                        ,create_time
                        ,order_id
                        from
                        wms_production.allocate_stock_log asl
                    ) asl on do.id=asl.order_id
                    WHERE 1=1
                        and do.`created` >= convert_tz(date_sub(date(now() + interval -1 hour),interval 90 day), '+07:00', '+08:00')
                        and do.`created` >= '2023-06-01'
                        -- AND do.`status` NOT IN ('1000','1010') -- 取消单
                        -- AND do.`platform_status` != 9
                        -- AND do.prompt NOT in (1,2,3,4) -- 剔除拦截
                        -- and sl.name not in ('FFM-TH', 'Flash -Thailand') -- 剔除物料和资产
                    UNION

                    SELECT
                        'B2B' TYPE
                        ,return_warehouse_sn
                        ,total_goods_num
                        ,do.warehouse_id
                        ,w.name warehouse_name
                        ,'B2B'platform_source
                        ,sl.name seller_name
                        ,do.`seller_id` seller_id
                        ,date_add(do.`created`, interval -60 minute) created_time
                        ,left(date_add(do.`created`, interval -60 minute), 10) created_date
                        ,date_add(do.`verify_time`, interval -60 minute) audit_time
                        ,left(date_add(do.`verify_time`, interval -60 minute), 10) audit_date
                        ,do.picking_end_time
                        ,do.pack_time + interval -1 hour pack_time
                        ,date_add(do.`out_warehouse_time`, interval -60 minute) handover_time
                        ,date_add(do.`out_warehouse_time`, interval -60 minute) delivery_time
                        ,if(locate('DO',do.express_sn)>0 or substring(do.express_sn,1,3)='LBX', 0, 1) is_time
                        ,case
                            when locate('DO',do.express_sn)>0 then 'DO快递单号'
                            when substring(do.express_sn,1,3)='LBX' then 'LBX快递单号'
                            else '正常时效单'
                            end as no_istime_type
                        ,null as audit_type
                        ,ulc.name
                        ,null is_tiktok
                        ,do.out_warehouse_id out_operator
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
                        ,case when prompt ='0' AND do.status>='1020' and sl.name not in ('FFM-TH', 'Flash -Thailand') then 1
                            else 0 end as is_visible
                        ,do.express_sn
                        ,case when left(do.express_sn, 4)='TH24' then 'SPX'
                            when left(do.express_sn, 2)='TH' then 'FLASH'
                            when left(do.express_sn, 2)='66' then 'BEST'
                            when left(do.express_sn, 2)='BS' then 'BEST'
                            when left(do.express_sn, 2)='59' then 'DHL'
                            when left(do.express_sn, 2)='90' then 'FLASH'
                            when left(do.express_sn, 2)='FE' then 'FLASH'
                            when left(do.express_sn, 2)='75' then 'J&T'
                            when left(do.express_sn, 2)='61' then 'J&T'
                            when left(do.express_sn, 2)='52' then 'J&T'
                            when left(do.express_sn, 2)='KE' then 'Kerry'
                            when left(do.express_sn, 2)='OD' then 'Kerry'
                            when left(do.express_sn, 2)='ON' then 'Kerry'
                            when left(do.express_sn, 2)='SH' then 'Kerry'
                            when left(do.express_sn, 2)='TI' then 'Kerry'
                            when left(do.express_sn, 2)='LE' then 'LEX'
                            when left(do.express_sn, 2)='LB' then 'LAZ-JIT'
                            when left(do.express_sn, 2)='JA' then 'Post'
                            when left(do.express_sn, 2)='DO' then '自提'
                            else '其他' end as   express_name_fixup
                        ,null total_price
                        ,null order_sn
                        ,null logistic_charge
                        ,dog.seller_goods_id
                        ,dog.out_num goods_number_sku
                        ,sg.bar_code
                        ,sg.length
                        ,sg.width
                        ,sg.height
                        ,sg.weight
                        ,sg.volume
                        ,sg.name goods_name
                        ,case dog.status
                            when 1 then '系统报缺'
                            when 2 then '待补货'
                            when 3 then '待上架'
                            end as sku_status
                         ,null platform_status
                         ,asl.order_id
                        ,null buy_time
                        ,null payment_time
                        ,null express_time
                    from  wms_production.return_warehouse do
                    left join wms_production.return_warehouse_goods dog on do.id = dog.return_warehouse_id
                    left join wms_production.seller_goods sg on dog.seller_goods_id  =sg.id
                    LEFT JOIN wms_production.warehouse w ON do.warehouse_id=w.id
                    LEFT JOIN `wms_production`.`seller` sl on do.`seller_id`=sl.`id`
                    left join wms_production.logistic_company ul on do.logistic_company_id = ul.id
                    left join wms_production.usable_logistic_company ulc on ul.usable_logistic_company_id  = ulc.id
                    left join
                    ( -- addby 王昱棋 20250228 commit:发货单下面有商品会出现超发导致的发货单不及时，不是仓库原因，不考核时效
                        select
                        id
                        ,warehouse_id
                        ,seller_goods_id
                        ,type
                        ,status
                        ,create_time
                        ,order_id
                        from
                        wms_production.allocate_stock_log asl
                    ) asl on do.id=asl.order_id
                    WHERE 1=1
                        -- and prompt ='0'
                        -- AND status>='1020'
                        and do.`created` >= convert_tz(date_sub(date(now() + interval -1 hour),interval 90 day), '+07:00', '+08:00')
                        and do.`created` >= '2023-06-01'
                        -- and sl.name not in ('FFM-TH', 'Flash -Thailand') -- 剔除物料和资产
                    UNION
                            -- erp平台
                    select
                        'B2C' TYPE
                        ,do.`delivery_sn`
                        ,goods_num
                        ,do.warehouse_id
                        ,w.name warehouse_name
                        ,ps.`name` platform_source
                        ,sl.`name` seller_name
                        ,do.`seller_id`
                        ,date_add(do.`created`, interval -60 minute) created_time
                        ,left(date_add(do.`created`, interval -60 minute), 10) created_date
                        ,date_add(do.`created`, interval -60 minute) audit_time
                        ,left(date_add(do.`created`, interval -60 minute), 10) audit_date
                        ,do.succ_pick + interval + 7 hour pick_time
                        ,do.pack_time + interval + 7 hour pack_time
                        ,do.delivery_time + interval -1 hour handover_time
                        ,do.delivery_time + interval -1 hour delivery_time
                        ,if(locate('DO',do.express_sn)>0 or substring(do.express_sn,1,3)='LBX' or t0.order_sn is not null, 0, 1) is_time -- do.is_presale=1 预售单不参与时效考核 is_time
                        ,case -- when do.is_presale=1 then '预售单'
                            when t0.order_sn is not null then '曾缺货订单'
                            when locate('DO',do.express_sn)>0 then 'DO快递单号'
                            when substring(do.express_sn,1,3)='LBX' then 'LBX快递单号'
                            else '正常时效单'
                            end as no_istime_type
                        ,case when  t0.order_sn is not null then '曾缺货订单'
                            end as audit_type
                        ,do.express_name
                        ,p.obj_id is_tiktok
                        ,ol.operation_id out_operator
                        ,case do.status when 1007 then '已分仓'
                            when 1010 then '缺货'
                            when 2016 then '生成波次成功'
                            when 2020 then '等待拣货'
                            when 2030 then '拣货完成'
                            when 2040 then '打包完成'
                            when 2060 then '发货完成'
                            when 3010 then '配送中'
                            when 3020 then '已签收'
                            when 3030 then '订单关闭'
                            else do.status
                        end as status
                        ,case when do.`status` NOT IN ('1000','1010') AND w.name='BPL3-LIVESTREAM'and do.status <> '3030' and sl.name not in ('FFM-TH', 'Flash -Thailand') then 1
                        else 0 end as is_visible
                        ,do.express_sn
                        ,case when left(do.express_sn, 4)='TH24' then 'SPX'
                            when left(do.express_sn, 2)='TH' then 'FLASH'
                            when left(do.express_sn, 2)='66' then 'BEST'
                            when left(do.express_sn, 2)='BS' then 'BEST'
                            when left(do.express_sn, 2)='59' then 'DHL'
                            when left(do.express_sn, 2)='90' then 'FLASH'
                            when left(do.express_sn, 2)='FE' then 'FLASH'
                            when left(do.express_sn, 2)='75' then 'J&T'
                            when left(do.express_sn, 2)='61' then 'J&T'
                            when left(do.express_sn, 2)='52' then 'J&T'
                            when left(do.express_sn, 2)='KE' then 'Kerry'
                            when left(do.express_sn, 2)='OD' then 'Kerry'
                            when left(do.express_sn, 2)='ON' then 'Kerry'
                            when left(do.express_sn, 2)='SH' then 'Kerry'
                            when left(do.express_sn, 2)='TI' then 'Kerry'
                            when left(do.express_sn, 2)='LE' then 'LEX'
                            when left(do.express_sn, 2)='LB' then 'LAZ-JIT'
                            when left(do.express_sn, 2)='JA' then 'Post'
                            when left(do.express_sn, 2)='DO' then '自提'
                            else '其他' end as   express_name_fixup
                        ,round(total_price/100, 100) total_price
                        ,do.order_sn
                        ,do.logistic_charge/100 logistic_charge
                        ,dog.seller_goods_id
                        ,dog.goods_number goods_number_sku
                        ,sg.bar_code
                        ,sg.length
                        ,sg.width
                        ,sg.height
                        ,sg.weight
                        ,sg.volume
                        ,sg.name goods_name
                        ,case dog.status
                            when 1 then '系统报缺'
                            when 2 then '待补货'
                            when 3 then '待上架'
                            end as sku_status
                        ,null platform_status
                        ,null order_id
                        ,null buy_time
                        ,null payment_time
                        ,null express_time
                    from `erp_wms_prod`.`delivery_order` do
                    left join erp_wms_prod.delivery_order_goods dog on do.id = dog.delivery_order_id
                    left join erp_wms_prod.seller_goods sg on dog.seller_goods_id  =sg.id
                    left join erp_wms_prod.platform_source ps on do.platform_source_id = ps.id
                    LEFT JOIN erp_wms_prod.seller sl on do.`seller_id`=sl.`id`
                    LEFT JOIN erp_wms_prod.warehouse w ON do.warehouse_id=w.id
                    left join
                    (
                        select
                            order_sn
                        from
                        `erp_wms_prod`.operation_log
                        where 1=1
                            and status_after='1010'
                            and `created` >= convert_tz(date_sub(date(now() + interval -1 hour),interval 90 day), '+07:00', '+08:00')
                            and `created` >='2023-06-01'
                    ) t0 on do.delivery_sn = t0.order_sn
                    left join
                    (select obj_id from erp_wms_prod.prompts where type = 1 and prompts in (13, 14) and warehouse_id = 312) p on p.obj_id = do.id
                    left join
                    (
                        select
                            t_in.order_sn
                            ,t_in.operation_id
                            ,t_in.real_name
                        from
                        (
                            select
                                ol.order_sn
                                ,ol.operation_id
                                ,m.real_name real_name
                                ,ol.created
                                ,row_number() over(partition by ol.order_sn order by ol.created desc) rn
                            from
                            erp_wms_prod.operation_log ol
                            left join erp_wms_prod.member m on ol.operation_id = m.id
                            where 1=1
                                and order_type = 'DeliveryOrder' -- 发货单
                                and status_after=2060 -- 拣货完成
                                and operation='delivery'
                                and ol.`created` >= convert_tz(date_sub(date(now() + interval -1 hour),interval 90 day), '+07:00', '+08:00')
                                and ol.`created` >='2023-06-01'
                        ) t_in
                        where rn = 1
                    ) ol on do.delivery_sn = ol.order_sn
                    WHERE 1=1
                        and do.`created` >= convert_tz(date_sub(date(now() + interval -1 hour),interval 90 day), '+07:00', '+08:00')
                        and do.`created` >='2023-06-01'
                        -- AND do.`status` NOT IN ('1000','1010') -- 取消单
                        -- AND w.name='BPL3-LIVESTREAM'
                        -- and do.status <> '3030'
                        -- and sl.name not in ('FFM-TH', 'Flash -Thailand') -- 剔除物料和资产

                    UNION
                    -- erp平台
                    SELECT
                        'B2B' TYPE
                        ,outbound_sn
                        ,sum(dog.out_num) over(partition by outbound_sn)  goods_number
                        ,warehouse_id
                        ,w.name warehouse_name
                        ,'B2B'platform_source
                        ,s.name seller_name
                        ,do.seller_id
                        ,date_add(do.`created`, interval -60 minute) created_time
                        ,left(date_add(do.`created`, interval -60 minute), 10) created_date
                        ,date_add(do.`created`, interval -60 minute) audit_time
                        ,left(date_add(do.confirm_time , interval + 7 hour), 10) audit_date
                        ,do.confirm_time + interval + 7 hour    pick_time
                        ,do.confirm_time + interval + 7 hour    pack_time
                        ,date_add(do.confirm_time , interval + 7 hour) handover_time
                        ,date_add(do.confirm_time , interval + 7 hour) delivery_time
                        ,1 is_time
                        ,null no_istime_type
                        ,null audit_type
                        ,or1.carrier
                        ,null is_tiktok
                        ,null out_operator
                        ,case do.status when 0 then '取消'
                            when 1 then '已创建'
                            when 2 then '分配库存成功'
                            when 3 then '分配库存失败'
                            when 4 then '已出库'
                            when 5 then '已完成'
                            else do.status
                        end as status
                        ,case when do.status > '0' AND w.name='BPL3-LIVESTREAM' and s.name not in ('FFM-TH', 'Flash -Thailand') then 1
                        else 0 end as is_visible
                        ,null express_sn
                        , null express_name_fixup
                        , null total_price
                        , null order_sn
                        , null logistic_charge
                        ,dog.seller_goods_id
                        ,dog.out_num goods_number_sku
                        ,sg.bar_code
                        ,sg.length
                        ,sg.width
                        ,sg.height
                        ,sg.weight
                        ,sg.volume
                        ,sg.name goods_name
                        ,sku_status
                        ,null platform_status
                        ,null order_id
                        ,null buy_time
                        ,null payment_time
                        ,null express_time
                    from  erp_wms_prod.outbound_order do
                    left join
                    (
                        select
                        outbound_id
                        ,seller_goods_id
                        ,sum(in_num) out_num
                        ,null sku_status
                        from
                        erp_wms_prod.outbound_order_detail
                        group by 1,2
                    ) dog on do.id = dog.outbound_id
                    left join erp_wms_prod.seller_goods sg on dog.seller_goods_id = sg.id
                    LEFT JOIN erp_wms_prod.warehouse w ON do.warehouse_id=w.id
                    left join `erp_wms_prod`.`seller` s on do.seller_id = s.id
                    left join erp_wms_prod.outbound_register or1 on do.id = or1.outbound_id
                    WHERE 1=1
                        -- and do.status > '0'
                        AND w.name='BPL3-LIVESTREAM'
                        and do.`created` >= convert_tz(date_sub(date(now() + interval -1 hour),interval 90 day), '+07:00', '+08:00')
                        and do.`created` >='2023-06-01'
                        -- and s.name not in ('FFM-TH', 'Flash -Thailand') -- 剔除物料和资产
                ) do
                left join
                -- 日历调整// created_mod 是节假日顺延后首日,date1是节假日顺延后第二天
                dwm.dim_th_default_timeV2 calendar on calendar.created=do.created_date
                where created_date>='2023-09-04'
            )do
            left join
            (
                select
                    country
                    ,platform_source
                    ,dt
                    ,operation
                    ,cutoff
                    ,befcutoffday
                    ,befcutofftime
                    ,aftcutoffday
                    ,aftcutofftime
                from
                dwm.dim_th_ffm_timeconfig
                where operation='交接'
            ) t_hand on do.platform_source = t_hand.platform_source and do.created_date = t_hand.dt
            left join
            (
                select
                    country
                    ,platform_source
                    ,dt
                    ,operation
                    ,cutoff
                    ,befcutoffday
                    ,befcutofftime
                    ,aftcutoffday
                    ,aftcutofftime
                from
                dwm.dim_th_ffm_timeconfig
                where operation='出库'
            ) t_out on do.platform_source = t_out.platform_source and do.created_date = t_out.dt
        ) do
        left join dwm.th_ffm_noautoaudit naa on do.warehouse_name = naa.warehouse and do.seller_name = naa.seller_name -- addby 王昱棋 20241227 未开启自动审单
        where warehouse_name in ('AGV', 'BPL-Return', 'BPL3', 'BST', 'LAS')
    ) do2
    -- left join
    -- dwm.th_ffm_lateexpress_day led on do2.warehouse_name = led.warehouse and do2.dateline_format = led.dt and do2.express_name_fixup = led.express_name;
    left join (select delivery_sn from dwm.tmp_th_ffm_notimesn_detail where type in ('Outbound2C', 'Outbound2B') ) nd on do2.delivery_sn = nd.delivery_sn;


select
    dt
    , warehouse_name
    , count(id) cnt
from
(
    select
         asl.id
        , asl.warehouse_id
        , asl.seller_goods_id
        , asl.type
        , asl.status
        , asl.create_time
        , date(asl.create_time) dt
        , asl.order_id
        , w.name warehouse_name
    from
    wms_production.allocate_stock_log asl
    left join wms_production.warehouse w on asl.warehouse_id = w.id
    where asl.create_time >='2025-06-01'
) t0
group by 1,2
order by 1,2;



select
    *
from
    dwm.dwd_th_ffm_outbound_dayV2 where delivery_sn in ('DO25070485431', 'DO25070489789');

select
    *
from
dwm.dim_th_ffm_warehousedetailseller_day
where dt>='2025-07-01';

select
    *
from
dwm.dwm_th_ffm_ttordertimelyout_day
where dt >='2025-07-01'
and warehouse_detailname='AutoWarehouse-2'
order by dt;

select
    distinct platform_source
from
    dwm.dwd_th_ffm_outbound_dayV2
where created_date >='2025-01-01';


    select
    distinct i18.th
 FROM `wms_production`.`delivery_order` do
left join wms_production.delivery_order_extra doe on do.id = doe.delivery_order_id
left join wms_production.i18 on concat('deliveryOrder.salesPlatform.',doe.platform_from) = i18.key
#     where i18.th in ('Line', )
;


select
    delivery_sn
from
    dwm.dwd_th_ffm_outbound_dayV2
where created_date ='2025-07-07'
and seller_name=''
;

select * from wms_production.seller where name='AGVxiamenyingchao（厦门映超）'