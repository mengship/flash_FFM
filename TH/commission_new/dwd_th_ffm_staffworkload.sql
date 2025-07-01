

select
    t0.上架人id staff_info_id
    ,t0.dt
    ,t0.warehouse_name
    ,staff.dept_3_name
    ,staff.dept_4_name
    ,staff.is_on_job 是否在职
    ,staff.attendance_days 出勤
    ,t_shelf.shelf_number 收货上架数量
    ,t_bhshelf.商品件数 补货上架
    ,t_rollback.cnt 销退包裹量
    ,t_intercept.goods_num 拦截件数
    ,t_pick.picknum 拣货件数
    ,t_pick.pickStickerLabel 拣货件数贴面单
    ,t_pick.pickBatchlittle 拣货件数批量小
    ,t_pick.pickBatchmiddle 拣货件数批量中
    ,t_pick.pickBatchbig 拣货件数批量大
    ,t_pick.pickBatchsuperbig 拣货件数批量超大
    ,t_pick.picklittle 拣货件数小
    ,t_pick.pickmiddle 拣货件数中
    ,t_pick.pickbig 拣货件数大
    ,t_pick.picksuperbig 拣货件数超大
    ,t_pick.pickIncomplete  拣货件数信息不全
    ,t_pack.packnum 打包件数
    ,t_pack.packStickerLabel 打包件数贴面单
    ,t_pack.packBatchlittle 打包件数批量小
    ,t_pack.packBatchmiddle 打包件数批量中
    ,t_pack.packBatchbig 打包件数批量大
    ,t_pack.packBatchsuperbig 打包件数批量超大
    ,t_pack.packPE 打包件数PE
    ,t_pack.packlittle 打包件数小
    ,t_pack.packmiddle 打包件数中
    ,t_pack.packbig 打包件数大
    ,t_pack.packsuperbig 打包件数超大
    ,t_pack.packIncomplete 打包件数信息不全
    ,t_handover.outnum 出库包裹数
    ,t_handover.outStickerLabel 出库包裹数贴面单
    ,t_handover.outPE 出库包裹数PE
    ,t_handover.outlittle 出库包裹数小
    ,t_handover.outmiddle 出库包裹数中
    ,t_handover.outbig 出库包裹数大
    ,t_handover.outsuperbig 出库包裹数超大
    ,t_handover.outIncomplete 出库包裹数信息不全
    ,t_in.in_num 收货件数
    ,t_pack2B.packnum 打包件数2B
from
(
    select
        上架人id
        ,warehouse_name
        ,dt
    from
    ( -- 收货上架
        select
            m.job_number 上架人id
            ,m.real_name 上架人
            ,case when w.name in ('AutoWarehouse')   then 'AGV'
                when w.name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                when w.name='BangsaoThong'  then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
            ,date(so.shelf_on_end) dt
        from wms_production.shelf_on_order so
        left join wms_production.seller s on so.seller_id =s.id
        left join wms_production.repository r on so.repository_id =r.id
        left join wms_production.location l on so.location_id = l.id
        left join wms_production.`member` m on so.shelf_on_man_id = m.id
        left join wms_production.`member` m1 on so.creator_id  = m1.id
        left join wms_production.shelf_on_order_goods soog on so.id = soog.shelf_on_order_id
        left join wms_production.seller_goods sg on soog.seller_goods_id = sg.id
        left join wms_production.warehouse w on so.warehouse_id = w.id
        where 1=1
        -- and so.from_business_type=1 -- 收货上架
#         and so.shelf_on_end >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
        and so.shelf_on_end >= '2025-01-01'
        and so.shelf_on_end < date_add(curdate() ,interval -day(curdate())+1 day)
        and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        and ifnull(s.name, 999)<>'FFM-TH'
        group by 1,2,3,4

        union all -- 补货上架
        select
            m1.job_number 上架人id
            ,m1.real_name 上架人
            ,case when w.name in ('AutoWarehouse')   then 'AGV'
                when w.name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                when w.name='BangsaoThong'  then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
            ,date(ms.action_end) dt
        from wms_production.move_stock ms
            left join wms_production.seller s on ms.seller_id  =s.id
            left join wms_production.repository r on ms.from_repository_id  =r.id
            left join wms_production.repository r1 on ms.to_repository_id  =r1.id
            left join
            (
                select
                    move_stock_id
                    ,count(distinct from_location_id) from_location_num
                    ,count(distinct location_id) location_num
                from wms_production.move_stock_goods
                group by 1
            ) msg on ms.id = msg.move_stock_id
            left join wms_production.`member` m on ms.auditor  = m.id
            left join wms_production.`member` m1 on ms.creator_id  = m1.id
            left join wms_production.warehouse w ON ms.warehouse_id=w.id
            where ms.type=2 -- 补货移库
#             and ms.action_end >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
            and ms.action_end >= '2025-01-01'
            and ms.action_end < date_add(curdate() ,interval -day(curdate())+1 day)
            and ifnull(s.name, 999)<>'FFM-TH'
            and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        group by 1,2,3,4

        union all -- 销退
        SELECT
            m.job_number
            ,m.real_name
            ,case when w.name in ('AutoWarehouse')   then 'AGV'
                when w.name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                when w.name='BangsaoThong'  then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
            ,date(complete_time) dt
        FROM wms_production.delivery_rollback_order dro
        left join wms_production.warehouse w ON dro.warehouse_id=w.id
        LEFT JOIN `wms_production`.`seller` s on dro.`seller_id`=s.`id`
        left join wms_production.`member` m on dro.complete_id = m.id
        left join
        (
            select
            receive_external_no
            ,finish_date
            from
            was.inb_receive_bill
            where
            is_deleted=0
            and create_time >= convert_tz(date_sub(date(now() + interval -1 hour),interval 330 day), '+07:00', '+08:00')
        )irb on dro.back_sn = irb.receive_external_no
        WHERE arrival_time IS NOT NULL
            AND status >= '1045'
            AND STATUS<>'9000'
            AND back_express_status NOT IN('20','30')
#             AND complete_time >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
            and complete_time >= '2025-01-01'
            AND complete_time <  date_add(curdate() ,interval -day(curdate())+1 day)
            and ifnull(s.name, 999)<>'FFM-TH'
            and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        group by 1,2,3,4

        union all -- 拦截
        SELECT
            m.job_number
            ,m.real_name
            ,case when w.name in ('AutoWarehouse')   then 'AGV'
                when w.name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                when w.name='BangsaoThong'  then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
            ,date(ip.shelf_on_end_time) dt
        FROM wms_production.intercept_place ip
        left join wms_production.warehouse w ON ip.warehouse_id=w.id
        left join wms_production.`member` m on ip.member_id = m.id
        LEFT JOIN `wms_production`.`seller` s on ip.`seller_id`=s.`id`
        WHERE 1=1
        and (w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')) -- BST
#         AND (ip.shelf_on_end_time >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month))
        and ip.shelf_on_end_time >= '2025-01-01'
        AND (ip.shelf_on_end_time <  date_add(curdate() ,interval -day(curdate())+1 day))
        and ifnull(s.name, 999)<>'FFM-TH'
        GROUP BY 1,2,3,4

        union all -- wms系统拣货
        select
            m.job_number picker_id
            ,m.real_name
            ,case when w.name in ('AutoWarehouse')   then 'AGV'
                when w.name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                when w.name='BangsaoThong'  then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
            ,date(po.created) dt
        from
            wms_production.pick_order po
        LEFT JOIN wms_production.pick_order_delivery_ref podr ON podr.pick_order_id = po.id
        LEFT JOIN wms_production.delivery_order_pick_goods dopg ON dopg.delivery_order_id = podr.delivery_order_id and podr.times = dopg.times
        LEFT JOIN wms_production.delivery_order do ON podr.delivery_order_id = do.id
        left join `wms_production`.`seller_goods_location_ref` sglr on sglr.id = dopg.seller_goods_location_ref_id
        left join wms_production.backup_seller_goods_location_ref bsglr on bsglr.id = dopg.seller_goods_location_ref_id
        left join wms_production.seller_goods sg on IFNULL(sglr.seller_goods_id,bsglr.seller_goods_id) = sg.id
        left join wms_production.repository r on IFNULL(sglr.repository_id,bsglr.repository_id) = r.id
        left join wms_production.warehouse w on po.warehouse_id = w.id
        LEFT JOIN `wms_production`.`member` m on po.picker_id = m.id
        left join wms_production.seller s on do.seller_id = s.id
        where 1=1
#             and jg.created + interval -1 hour >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
            and po.created >= '2025-01-01'
            and po.created <  date_add(curdate() ,interval -day(curdate())+1 day)
            and po.type = 1
            and ifnull(s.name, 999)<>'FFM-TH'
            and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        group by 1,2,3,4

        union all -- was 拣货
        select
            trim(operator) operator
            ,user_name
            ,'AGV' warehouse_name
            ,now_date dt
        from
        (
            SELECT
                -- left(oobt.gmt_modified,10) date
                '拣货' title_name
                -- ,oobt.operator user_id
                -- ,mo.job_number
                -- ,si.name
                ,bau.work_no operator
                ,bau.user_name
                ,date(oobt.gmt_modified) now_date
                ,hour(oobt.gmt_modified) now_hour
                -- ,count(DISTINCT ( oobt.order_code )) pickOrder
                ,sum(case when  wobo.type in(1)  then actual_num end)pickNum -- 2,3是ToB
                -- ,sum(actual_num) pickNum
            FROM was.oub_out_bound_task oobt
            LEFT JOIN was.base_authority_user bau ON oobt.operator = bau.user_id
            LEFT JOIN was.was_out_bound_order wobo  on  wobo.order_code = CONVERT(oobt.order_code using gbk) and oobt.group_id = wobo.group_id
            left join wms_production.member mo on oobt.operator = mo.id
            LEFT JOIN `fle_staging`.`staff_info` si on si.`id` =oobt.operator
            LEFT JOIN wms_production.seller s on oobt.owner_id=s.id
            WHERE 1=1
                and oobt.del_flag = 0 -- 未删除
                AND oobt.status = 1
                AND oobt.group_id = 1180 -- AGV仓
                AND oobt.type in (1,5)
                and ifnull(s.name, 999)<>'FFM-TH'
#                 and oobt.gmt_modified + interval -1 hour >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
                and oobt.gmt_modified + interval -1 hour >= '2025-01-01'
                and oobt.gmt_modified + interval -1 hour <  date_add(curdate() ,interval -day(curdate())+1 day)
                /* and oobt.gmt_modified >= convert_tz(CURRENT_DATE, '+07:00', '+08:00') */
            GROUP BY 1,2,3,4,5
        ) pick

        union all -- 打包复核
        SELECT
            `job_number`
            ,'' real_name
            ,case when w.name in ('AutoWarehouse')   then 'AGV'
                when w.name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                    when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                    when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                    when w.name='BangsaoThong'  then 'BST'
                    when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                    when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
            ,date(end_time) now_date
        FROM wms_production.workload_report wr
        left join `wms_production`.`warehouse` w on wr.warehouse_id = w.id
        left join wms_production.seller s on wr.seller_id = s.id
        WHERE 1=1
        AND w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        AND (wr.`type` = 3)
#         AND (`end_time` >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month))
        and `end_time` >= '2025-01-01'
        AND (`end_time` <= date_add(curdate() ,interval -day(curdate())+1 day))
        AND (`order_type` in ('DO', 'RW') )
        and ifnull(s.name, 999)<>'FFM-TH'
        GROUP BY 1,2,3,4
        -- ORDER BY  `order_num` DESC

        union all -- 出库
        select
            mb.job_number out_operator
            ,mb.real_name
            ,do.warehouse_detailname warehouse_name
            ,date(do.handover_time) dt
        from dwm.dwd_th_ffm_outbound_dayV2 do
        LEFT JOIN `wms_production`.`member` mb on do.out_operator=mb.`id`
        where 1=1
            and do.warehouse_name in ('BST', 'AGV', 'LAS', 'BPL-Return')
            and 'B2C'=do.TYPE
            and is_visible=1
            and ifnull(seller_name, 999)<>'FFM-TH'
#             and do.handover_time >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
            and  do.handover_time >= '2025-01-01'
            and do.handover_time <  date_add(curdate() ,interval -day(curdate())+1 day)
        group by 1,2,3,4

        union all -- 收货
        SELECT
            m.job_number in_staff
            ,m.real_name
            ,case when w.name in ('AutoWarehouse')   then 'AGV'
                when w.name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                    when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                    when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                    when w.name='BangsaoThong'  then 'BST'
                    when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                    when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
            ,date(`an`.`complete_time`) dt
        FROM
        wms_production.arrival_notice `an`
        JOIN
        (
            SELECT
            `arrival_notice_id`
            ,SUM(`total_price`) total_price
            ,SUM(`in_num`) in_num
            FROM wms_production.`arrival_notice_goods`
            GROUP BY `arrival_notice_id`
        ) ang ON `an`.`id` = `ang`.`arrival_notice_id`
        left join `wms_production`.`warehouse` w on an.warehouse_id = w.id
        LEFT JOIN `wms_production`.`member` m on an.complete_id = m.id
        left join wms_production.seller s on an.seller_id = s.id
        WHERE 1=1
        and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        and ifnull(s.name, 999)<>'FFM-TH'
#         AND (`an`.`complete_time` >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month))
        and `an`.`complete_time` >= '2025-01-01'
        AND (`an`.`complete_time` < date_add(curdate() ,interval -day(curdate())+1 day))
        GROUP BY 1,2,3,4
        -- ORDER BY `order_num` DESC
    ) t_in
  -- where 上架人id='602549'
    where warehouse_name is not null
    group by 1,2,3
) t0
left join -- 收货上架
(
    select
        '收货上架'
        ,上架人id
        ,仓库名称
        ,date(上架结束时间) dt
        ,sum(number) shelf_number
    from
    (
        select
            case so.status
                when 1000 then '已创建'
                when 1020 then '上架中'
                when 1030 then '上架完成'
                else so.status  end 状态
            ,so.shelf_on_order_sn 上架单号
            ,case so.from_business_type
                when 1 then '收货上架'
                when 2 then '补货上架'
                when 4 then '销退上架'
                when 5 then '拦截上架'
                when 7 then '组装上架'
                else so.from_business_type end 业务类型
            ,s.name 货主
            ,r.name 来源库区
            ,l.location_code  来源货位
            ,so.from_order_sn 来源单号
            ,case so.from_order_type
            when 'arrivalNotice' then '到货通知单'
            when 'deliveryRollbackOrder' then '销退单'
            when 'interceptPlace' then '拦截归位单'
            when 'replenishmentBill' then '下架单'
            else so.from_order_type         end 来源单据类型
            ,so.remark 备注
            ,m.real_name 上架人
            ,m.job_number 上架人id
            ,so.shelf_on_start  上架开始时间
            ,so.shelf_on_end  上架结束时间
            ,m1.real_name 创建人
            ,if(so.is_rf=1,'是','否') 是否PDA作业
            ,so.created+interval -1 hour 创建时间
            ,soog.seller_goods_id
            ,sg.bar_code
            ,sg.name
            ,soog.number
            ,case when w.name in ('AutoWarehouse')   then 'AGV'
                when w.name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                when w.name='BPL-Return Warehouse' then 'BPL-Return'
                when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                when w.name='BangsaoThong' then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓')         then 'LAS' # ,'PMD-WH','BKK-WH-Ecommerce','BKK-WH-LAS物料仓'
                when w.name='LCP Warehouse' then 'LCP' end 仓库名称
        from wms_production.shelf_on_order so
        left join wms_production.seller s on so.seller_id =s.id
        left join wms_production.repository r on so.repository_id =r.id
        left join wms_production.location l on so.location_id = l.id
        left join wms_production.`member` m on so.shelf_on_man_id = m.id
        left join wms_production.`member` m1 on so.creator_id  = m1.id
        left join wms_production.shelf_on_order_goods soog on so.id = soog.shelf_on_order_id
        left join wms_production.seller_goods sg on soog.seller_goods_id = sg.id
        left join wms_production.warehouse w on so.warehouse_id = w.id
        where 1=1
        -- and so.from_business_type=1 -- 收货上架
#         and so.shelf_on_end >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
        and so.shelf_on_end >= '2025-01-01'
        and so.shelf_on_end <  date_add(curdate() ,interval -day(curdate())+1 day)
        and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        and ifnull(s.name, 999)<>'FFM-TH'
    ) t0
    group by 1,2,3,4
) t_shelf on t0.上架人id = t_shelf.上架人id and t0.dt = t_shelf.dt and t0.warehouse_name = t_shelf.仓库名称
left join -- 补货上架
(
    select
        '补货上架'
        ,上架人id
        ,仓库名称
        ,date(action_end) dt
        ,sum(商品件数) 商品件数
    from
    (
        select
            case ms.status
                when 1000 then '已取消'
                when 1010 then '待确认'
                when 1020 then '已确认'
                when 1030 then '下架完成'
                when 1040 then '移库完成'
                else ms.status
                end 状态
            ,ms.move_stock_sn  移库单号
            ,s.name 货主
            ,r.name 来源库区
            ,r1.name 目标库区
            ,case ms.move_status
                when 1 then '正品>残品'
                when 2 then '残品>正品'
                when 3 then '正品>正品'
                when 4 then '残品>残品'
                else ms.move_status  end 质量转移状态说明
            ,ms.remark  备注
            ,case ms.type
            when 1 then '日常移库'
            when 2 then '补货移库'
            when 3 then 'AGV移库'
            else ms.type end 移库类型
            ,msg.from_location_num  来源货位
            ,msg.location_num  目标货位
            ,ms.goods_type_number 品种数
            ,ms.`number` 商品件数
            ,case ms.audit_status
                when 10 then '待审核'
                when 20 then '已驳回'
                when 30 then '已审核'
                else ms.audit_status end 审核状态
            ,m1.job_number 上架人id
            ,m1.real_name 上架人
            ,ms.created  +interval -1 hour 创建时间
            ,m.real_name 审核人
            ,ms.audit_time 审核时间
            ,ms.action_start
            ,ms.action_end
            ,case when w.name in ('AutoWarehouse')   then 'AGV'
                when w.name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                when w.name='BPL-Return Warehouse' then 'BPL-Return'
                when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                when w.name='BangsaoThong' then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓')         then 'LAS' # ,'PMD-WH','BKK-WH-Ecommerce','BKK-WH-LAS物料仓'
                when w.name='LCP Warehouse' then 'LCP' end 仓库名称
        from wms_production.move_stock ms
        left join wms_production.seller s on ms.seller_id  =s.id
        left join wms_production.repository r on ms.from_repository_id  =r.id
        left join wms_production.repository r1 on ms.to_repository_id  =r1.id
        left join
        (
            select
                move_stock_id
                ,count(distinct from_location_id) from_location_num
                ,count(distinct location_id) location_num
            from wms_production.move_stock_goods
            group by 1
        ) msg on ms.id = msg.move_stock_id
        left join wms_production.`member` m on ms.auditor  = m.id
        left join wms_production.`member` m1 on ms.creator_id  = m1.id
        left join wms_production.warehouse w ON ms.warehouse_id=w.id
        where ms.type=2 -- 补货移库
#         and ms.action_end >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
        and ms.action_end >= '2025-01-01'
        and ms.action_end <  date_add(curdate() ,interval -day(curdate())+1 day)
        and ifnull(s.name, 999)<>'FFM-TH'
        and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
    ) t0
    where 1=1
    group by 1,2,3,4
)t_bhshelf on t0.上架人id = t_bhshelf.上架人id and t0.dt = t_bhshelf.dt and t0.warehouse_name = t_bhshelf.仓库名称
left join -- 销退
(
    selecT
        '销退'
        ,job_number
        ,仓库名称
        ,date(complete_time) dt
        ,count(distinct back_sn) cnt
    from
    (
        SELECT
            dro.back_sn
            ,'销退订单' 单据
            ,dro.warehouse_id
            ,case when w.name in ('AutoWarehouse')   then 'AGV'
                when w.name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                when w.name='BPL-Return Warehouse' then 'BPL-Return'
                when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                when w.name='BangsaoThong' then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓')         then 'LAS' # ,'PMD-WH','BKK-WH-Ecommerce','BKK-WH-LAS物料仓'
                when w.name='LCP Warehouse' then 'LCP' end 仓库名称
            ,s.name seller_name
            ,dro.seller_id
            ,dro.complete_time
            ,dro.complete_id
            ,m.job_number
            ,if(w.name='AutoWarehouse', irb.finish_date, dro.shelf_end_time) shelf_end_time
            ,'销退订单' 入库类型
        FROM wms_production.delivery_rollback_order dro
        left join wms_production.warehouse w ON dro.warehouse_id=w.id
        LEFT JOIN `wms_production`.`seller` s on dro.`seller_id`=s.`id`
        left join wms_production.`member` m on dro.complete_id = m.id
        left join
        (
            select
            receive_external_no
            ,finish_date
            from
            was.inb_receive_bill
            where
            is_deleted=0
            and create_time >= convert_tz(date_sub(date(now() + interval -1 hour),interval 330 day), '+07:00', '+08:00')
        )irb on dro.back_sn = irb.receive_external_no
        WHERE 1=1 # arrival_time IS NOT NULL
            AND status >= '1045'
            AND STATUS<>'9000'
            AND back_express_status NOT IN('20','30')
#             AND complete_time >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
            AND complete_time >= '2025-01-01'
            AND complete_time <  date_add(curdate() ,interval -day(curdate())+1 day)
            and ifnull(s.name, 999)<>'FFM-TH'
            and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
    ) t0
    where 1=1
    group by 1,2,3,4
) t_rollback on t0.上架人id = t_rollback.job_number and t0.dt = t_rollback.dt and t0.warehouse_name = t_rollback.仓库名称
left join -- 拦截
(
    SELECT
        '拦截' title
        ,m.job_number
        ,case when w.name in ('AutoWarehouse')   then 'AGV'
                when w.name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                when w.name='BPL-Return Warehouse' then 'BPL-Return'
                when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                when w.name='BangsaoThong' then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓')         then 'LAS' # ,'PMD-WH','BKK-WH-Ecommerce','BKK-WH-LAS物料仓'
                when w.name='LCP Warehouse' then 'LCP' end 仓库名称
        ,date(ip.shelf_on_end_time) dt
        ,SUM(ip.goods_num) goods_num
    FROM wms_production.intercept_place ip
    left join wms_production.`member` m on ip.member_id = m.id
    left join wms_production.warehouse w ON ip.warehouse_id=w.id
    LEFT JOIN `wms_production`.`seller` s on ip.`seller_id`=s.`id`
    WHERE 1=1
    and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
    and ifnull(s.name, 999)<>'FFM-TH'
#     AND (ip.shelf_on_end_time >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month))
    and ip.shelf_on_end_time >= '2025-01-01'
    AND (ip.shelf_on_end_time <  date_add(curdate() ,interval -day(curdate())+1 day))
    GROUP BY 1,2,3,4
) t_intercept on t0.上架人id = t_intercept.job_number and t0.dt = t_intercept.dt and t0.warehouse_name = t_intercept.仓库名称
left join -- 拣货
(
    select
        title_name
        ,warehouse_name
        ,picker_id
        ,created
        ,sum(sum_num) picknum
        ,sum(if(pick_type='贴面单', sum_num, 0)) pickStickerLabel
        ,sum(if(pick_type='批量单-小件', sum_num, 0)) pickBatchlittle
        ,sum(if(pick_type='批量单-中件', sum_num, 0)) pickBatchmiddle
        ,sum(if(pick_type='批量单-大件', sum_num, 0)) pickBatchbig
        ,sum(if(pick_type='批量单-超大件', sum_num, 0)) pickBatchsuperbig
        ,sum(if(pick_type='小件', sum_num, 0)) picklittle
        ,sum(if(pick_type='中件', sum_num, 0)) pickmiddle
        ,sum(if(pick_type='大件', sum_num, 0)) pickbig
        ,sum(if(pick_type='超大件', sum_num, 0)) picksuperbig
        ,sum(if(pick_type='信息不全', sum_num, 0)) pickIncomplete
    from
    (
        select
            title_name
            ,created
            ,warehouse_name
            ,picker_id
            ,pick_sn
            ,sum(num) sum_num
            ,case when warehouse_name='AGV-人工仓' then '贴面单'
                when warehouse_name='LAS' and seller_name='Fuzhou canghai yunfan（福州沧海云帆）' then '贴面单'
                when warehouse_name='AGV' and repository_code='Pick-FFM-Zone' then '批量单-小件'
                when warehouse_name in ('BST', 'LAS') and kinds_num=1 and TYPEsize='小件' and sum(num) >=20 then '批量单-小件'
                when warehouse_name in ('BST', 'LAS') and kinds_num=1 and TYPEsize='中件' and sum(num) >=18 then '批量单-中件'
                when warehouse_name in ('BST', 'LAS') and kinds_num=1 and TYPEsize='大件' and sum(num) >=9 then '批量单-大件'
                when warehouse_name in ('BST', 'LAS') and kinds_num=1 and TYPEsize='超大件' and sum(num) >=5 then '批量单-超大件'
                else TYPEsize
                end as pick_type
        from
        (
            SELECT
                '拣货' title_name
                ,'wms' source
                ,created
                ,warehouse_name
                ,picker_id
                ,pick_sn
                 ,delivery_sn
                 ,good_name
                 ,bar_code
                ,TYPEsize
                 ,seller_name
                ,repository_code
                ,kinds_num
                ,num
            FROM
                dwm.dwd_th_ffm_wms_pickworkload
        ) t0
        where 1=1
        and warehouse_name is not null
        group by title_name
                ,created
                ,warehouse_name
                ,picker_id
                ,pick_sn


        union all
             -- AGV 拣货
        select
            '拣货' title_name
             ,now_date
            ,'AGV' warehouse_name
            ,trim(operator) operator
            , null pick_sn
            ,pickNum
            ,TYPEsize
        from
        (
            SELECT
                -- left(oobt.gmt_modified,10) date
                '拣货' title_name
                -- ,oobt.operator user_id
                -- ,mo.job_number
                -- ,si.name
                ,operator
                ,user_name
                 ,seller_name
                ,date(now_date) now_date
                 ,TYPEsize
                ,sum(pickNum) pickNum -- 2,3是ToB
            from
                dwm.dwd_th_ffm_was_pickworkload
            GROUP BY 1,2,3,4,5,6
        ) pick
    ) t1
    group by 1,2,3,4
) t_pick on t0.上架人id = t_pick.picker_id and t0.dt = t_pick.created and t0.warehouse_name = t_pick.warehouse_name
left join -- 复核2C
(
    select
        warehouse_name
        ,t_out.now_date
        -- ,t_out.title_name
        ,t_out.job_number creator_id
        ,sum(t_out.goods_number) packnum
        ,sum(if(TYPEsize='贴面单', goods_number, 0)) packStickerLabel
        ,sum(if(TYPEsize='批量单-小件', goods_number, 0)) packBatchlittle
        ,sum(if(TYPEsize='批量单-中件', goods_number, 0)) packBatchmiddle
        ,sum(if(TYPEsize='批量单-大件', goods_number, 0)) packBatchbig
        ,sum(if(TYPEsize='批量单-超大件', goods_number, 0)) packBatchsuperbig
        ,sum(if(TYPEsize='PE袋', goods_number, 0)) packPE
        ,sum(if(TYPEsize='小件', goods_number, 0)) packlittle
        ,sum(if(TYPEsize='中件', goods_number, 0)) packmiddle
        ,sum(if(TYPEsize='大件', goods_number, 0)) packbig
        ,sum(if(TYPEsize='超大件', goods_number, 0)) packsuperbig
        ,sum(if(TYPEsize='信息不全', goods_number, 0)) packIncomplete
    from
    (
        SELECT
            `job_number`
            ,date(end_time) now_date
            ,case when w.name in ('AutoWarehouse')   then 'AGV'
                when w.name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                    when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                    when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                    when w.name='BangsaoThong'  then 'BST'
                    when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                    when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
#              ,CASE WHEN greatest(sg.LENGTH, sg.width, sg.height)<=250 AND sg.weight <= 10000 AND sg.weight>0 THEN '小件'
#                         WHEN greatest(sg.LENGTH, sg.width, sg.height)<=500 AND sg.weight <= 10000 AND sg.weight>0 THEN '中件'
#                         WHEN greatest(sg.LENGTH, sg.width, sg.height)<=1000 AND sg.weight <= 10000 AND sg.weight>0 THEN '大件'
#                         WHEN (greatest(sg.LENGTH, sg.width, sg.height)>1000 AND sg.weight>0) OR (sg.weight > 10000 and sg.LENGTH>0 and sg.width>0 and sg.height>0 ) THEN '超大件'
#                         WHEN s.name ='Flash -Thailand' then '其他'
#                         else '信息不全'
#                         END TYPEsize
             ,case when pick_wms.pick_type is not null then pick_wms.pick_type
                    when f.bar_code in ('A5', 'A4', 'A3', 'A4w', 'A4new', 'FEX03896', 'A3new', 'FEX04108', '3', '4') then 'PE袋'
                    WHEN greatest(sg.LENGTH, sg.width, sg.height)<=250 AND sg.weight <= 10000 AND sg.weight>0 THEN '小件'
                    WHEN greatest(sg.LENGTH, sg.width, sg.height)<=500 AND sg.weight <= 10000 AND sg.weight>0 THEN '中件'
                    WHEN greatest(sg.LENGTH, sg.width, sg.height)<=1000 AND sg.weight <= 10000 AND sg.weight>0 THEN '大件'
                    WHEN (greatest(sg.LENGTH, sg.width, sg.height)>1000 AND sg.weight>0) OR (sg.weight > 10000 and sg.LENGTH>0 and sg.width>0 and sg.height>0 ) THEN '超大件'
                    WHEN s.name ='Flash -Thailand' then '其他'
                    else '信息不全'
                    END TYPEsize
            ,COUNT(`order_id`) order_num
#             ,SUM(`kinds_num`) kinds_num
            ,SUM(dog.`goods_number`) goods_number
            ,SUM(sg.`volume`) volume
            ,SUM(sg.`weight`) weight
            ,SUM(`box_num`) box_num
            ,SUM(`express_num`) express_num
            ,SUM(TIMESTAMPDIFF(SECOND, `start_time`, `end_time`)) total_time
        FROM wms_production.workload_report wr
        left join wms_production.delivery_order_goods dog on wr.order_id = dog.delivery_order_id
        left join wms_production.delivery_order do ON wr.order_id = do.id
        left join
        (
            select
                title_name
                ,created
                ,warehouse_name
                ,picker_id
                ,pick_sn
                ,delivery_sn
                ,pick_type
            from
            (
                select
                    title_name
                    ,created
                    ,warehouse_name
                    ,picker_id
    #                 ,sum(num) sum_num
                     ,pick_sn
                     ,delivery_sn
                    ,case when warehouse_name='AGV-人工仓' then '贴面单'
                        when warehouse_name='LAS' and seller_name='Fuzhou canghai yunfan（福州沧海云帆）' then '贴面单'
                        when warehouse_name='AGV' and repository_code='Pick-FFM-Zone' then '批量单-小件'
                        when warehouse_name in ('BST', 'LAS') and kinds_num=1 and TYPEsize='小件' and sum(num) over(partition by warehouse_name,picker_id,pick_sn) >=20 then '批量单-小件'
                        when warehouse_name in ('BST', 'LAS') and kinds_num=1 and TYPEsize='中件' and sum(num) over(partition by warehouse_name,picker_id,pick_sn) >=18 then '批量单-中件'
                        when warehouse_name in ('BST', 'LAS') and kinds_num=1 and TYPEsize='大件' and sum(num) over(partition by warehouse_name,picker_id,pick_sn) >=9 then '批量单-大件'
                        when warehouse_name in ('BST', 'LAS') and kinds_num=1 and TYPEsize='超大件' and sum(num) over(partition by warehouse_name,picker_id,pick_sn) >=5 then '批量单-超大件'
#                         else TYPEsize
                        end as pick_type
                from
                (
                    SELECT
                        '拣货' title_name
                        ,'wms' source
                        ,created
                        ,warehouse_name
                        ,picker_id
                        ,pick_sn
                         ,delivery_sn
                         ,good_name
                         ,bar_code
                        ,TYPEsize
                         ,seller_name
                        ,repository_code
                        ,kinds_num
                        ,num
                    FROM
                        dwm.dwd_th_ffm_wms_pickworkload
                ) t0
                where 1=1
                and warehouse_name is not null
#                 group by 1,2,3,4,5,6,7
            ) t1
            where pick_type is not null
            group by 1,2,3,4,5,6,7
        ) pick_wms on do.delivery_sn = pick_wms.delivery_sn
#       left join
        left join wms_production.seller_goods sg on dog.seller_goods_id  =sg.id
        left join `wms_production`.`warehouse` w on wr.warehouse_id = w.id
        left join wms_production.seller s on wr.seller_id = s.id
        left join wms_production.container_order as b on do.id = b.business_id
        left join wms_production.container_inventory_log as g on g.container_order_id=b.id
        left join wms_production.container as f on f.id=g.container_id
        WHERE 1=1
        AND w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        AND (wr.`type` = 3)
#         AND (`end_time` >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month))
        and `end_time` >= '2025-01-01'
        AND (`end_time` <= date_add(curdate() ,interval -day(curdate())+1 day))
        AND (`order_type` = 'DO')
        and ifnull(s.name, 999)<>'FFM-TH'
        GROUP BY 1,2,3,4
        -- ORDER BY  `order_num` DESC
    )t_out where 1=1
    group by 1,2,3
) t_pack on t0.上架人id = t_pack.creator_id and t0.dt = t_pack.now_date and t0.warehouse_name = t_pack.warehouse_name
left join -- 出库
(
    select
         t_out.warehouse_name
        ,t_out.now_date
        ,t_out.title_name
        ,t_out.out_operator
        ,sum(t_out.outnum) outnum
         ,sum(if(TYPEsize='贴面单', outnum, 0)) outStickerLabel
         ,sum(if(TYPEsize='PE袋', outnum, 0)) outPE
        ,sum(if(TYPEsize='小件', outnum, 0)) outlittle
        ,sum(if(TYPEsize='中件', outnum, 0)) outmiddle
        ,sum(if(TYPEsize='大件', outnum, 0)) outbig
        ,sum(if(TYPEsize='超大件', outnum, 0)) outsuperbig
        ,sum(if(TYPEsize='信息不全', outnum, 0)) outIncomplete
    from
    (
        select
            '出库' title_name
            ,warehouse_detailname warehouse_name
            ,mb.job_number out_operator
            ,date(do.delivery_time) now_date
            ,case
                when do.warehouse_detailname ='AGV-人工仓' then '贴面单'
                when do.warehouse_name='LAS' and do.seller_name='Fuzhou canghai yunfan（福州沧海云帆）' then '贴面单'
                when f.bar_code in ('L', 'L1', 'L2') then '大件'
                when f.bar_code in ('M', 'M1', 'FM1') then '中件'
                when f.bar_code in ('S','S1','MINI','MINI1') then '小件'
                when f.bar_code in ('A5', 'A4', 'A3', 'A4w', 'A4new') then 'PE袋'
                when db.height*db.width*db.length > 60000000 then '大件'
                when db.height*db.width*db.length >  23220000 then '中件'
                when db.height*db.width*db.length <= 23220000 then '小件'
                else '信息不全'
                    end as TYPEsize
            ,count(distinct do.delivery_sn) outnum
        from dwm.dwd_th_ffm_outbound_dayV2 do
        join wms_production.`delivery_order` do1 on do.delivery_sn = do1.delivery_sn
        left join wms_production.delivery_box db on do1.id = db.delivery_order_id
        left join wms_production.container_order as b on db.id = b.box_id # do1.id = b.business_id
        left join wms_production.container_inventory_log as g on g.container_order_id=b.id
        left join wms_production.container as f on f.id=g.container_id
#         JOIN wms_production.`delivery_box` `db` ON `do1`.`id` = `db`.`delivery_order_id`
        LEFT JOIN `wms_production`.`member` mb on do1.operator_id=mb.`id`
        where 1=1
            and do.warehouse_name in ('BST', 'AGV', 'LAS')
            and 'B2C'=do.TYPE
            and ifnull(do.seller_name, 999)<>'FFM-TH'
#             and do.delivery_time >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
            and do.delivery_time >= '2025-01-01'
            and do.delivery_time <  date_add(curdate() ,interval -day(curdate())+1 day)
        group by 1,2,3,4,5
    ) t_out
    group by 1,2,3,4
) t_handover on t0.上架人id = t_handover.out_operator and t0.dt = t_handover.now_date and t0.warehouse_name = t_handover.warehouse_name
left join -- 收货
(
    -- 收货
    SELECT
        m.job_number in_staff
        ,date(`an`.`complete_time`) dt
        ,case when w.name in ('AutoWarehouse')   then 'AGV'
                when w.name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                when w.name='BangsaoThong'  then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                end warehouse_name
        ,COUNT(DISTINCT `an`.`id`) order_num
        ,SUM(`an`.kinds_num) kinds_num
        ,SUM(`an`.goods_num) goods_num
        ,SUM(`ang`.in_num) in_num
        ,SUM(`ang`.total_price) money
    FROM
    wms_production.arrival_notice `an`
    JOIN
    (
        SELECT
        `arrival_notice_id`
        ,SUM(`total_price`) total_price
        ,SUM(`in_num`) in_num
        FROM wms_production.`arrival_notice_goods`
        GROUP BY `arrival_notice_id`
    ) ang ON `an`.`id` = `ang`.`arrival_notice_id`
    left join `wms_production`.`warehouse` w on an.warehouse_id = w.id
    LEFT JOIN `wms_production`.`member` m on an.complete_id = m.id
    left join wms_production.seller s on an.seller_id = s.id
    WHERE 1=1
    and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
    and ifnull(s.name, 999)<>'FFM-TH'
#     AND (`an`.`complete_time` >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month))
    and `an`.`complete_time` >= '2025-01-01'
    AND (`an`.`complete_time` <  date_add(curdate() ,interval -day(curdate())+1 day))
    GROUP BY 1,2,3
    -- ORDER BY `order_num` DESC
) t_in on t0.上架人id = t_in.in_staff and t0.dt = t_in.dt and t0.warehouse_name = t_in.warehouse_name
left join -- 复核2B
(
    select
        warehouse_name
        ,t_out.now_date
        -- ,t_out.title_name
        ,t_out.job_number creator_id
        ,t_out.goods_num packnum
    from
    (
        SELECT
            `job_number`
            ,date(end_time) now_date
            ,case when w.name in ('AutoWarehouse')   then 'AGV'
                when w.name in ('AutoWarehouse-人工仓')   then 'AGV-人工仓'
                    when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                    when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                    when w.name='BangsaoThong'  then 'BST'
                    when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                    when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
            ,COUNT(`order_id`) order_num
            ,SUM(`kinds_num`) kinds_num
            ,SUM(`goods_num`) goods_num
            ,SUM(`volume`) volume
            ,SUM(`weight`) weight
            ,SUM(`box_num`) box_num
            ,SUM(`express_num`) express_num
            ,SUM(TIMESTAMPDIFF(SECOND, `start_time`, `end_time`)) total_time
        FROM wms_production.workload_report wr
        left join `wms_production`.`warehouse` w on wr.warehouse_id = w.id
        left join wms_production.seller s on wr.seller_id = s.id
        WHERE 1=1
        AND w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        AND (wr.`type` = 3)
#         AND (`end_time` >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month))
        and `end_time` >= '2025-01-01'
        AND (`end_time` <  date_add(curdate() ,interval -day(curdate())+1 day))
        AND (`order_type` = 'RW') -- 这里是2B出库单
        and ifnull(s.name, 999)<>'FFM-TH'
        GROUP BY 1,2,3
        -- ORDER BY  `order_num` DESC
    )t_out where 1=1
) t_pack2B on t0.上架人id = t_pack2B.creator_id and t0.dt = t_pack2B.now_date and t0.warehouse_name = t_pack2B.warehouse_name
left join dwm.dwd_th_ffm_staff_dayV3 staff on t0.上架人id = staff.staff_info_id and t0.dt = staff.stat_date