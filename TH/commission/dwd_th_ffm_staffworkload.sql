/*=====================================================================+
表名称：  dwd_th_ffm_staffworkload
功能描述：泰国发货单 交接单量 情况

需求来源：
编写人员: 王昱棋
设计日期：2024/10/22
        修改日期:
        修改人员:
        修改原因:
-----------------------------------------------------------------------
---存在问题：
-----------------------------------------------------------------------
+=====================================================================*/

-- drop table if exists dwm.dwd_th_ffm_staffworkload;
-- create table dwm.dwd_th_ffm_staffworkload as
# delete from dwm.dwd_th_ffm_staffworkload where dt >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month) and dt < date_add(curdate() ,interval -day(curdate())+1 day); -- 先删除数据
# insert into dwm.dwd_th_ffm_staffworkload -- 再插入数据

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
    ,t_pack.packnum 打包件数
    ,t_handover.outnum 出库包裹数
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
            ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓')   then 'AGV'
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
        and so.shelf_on_end >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
        and so.shelf_on_end < date_add(curdate() ,interval -day(curdate())+1 day)
        and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        and s.name<>'FFM-TH'
        group by 1,2,3,4

        union all -- 补货上架
        select
            m1.job_number 上架人id
            ,m1.real_name 上架人
            ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓')   then 'AGV'
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
            and ms.action_end >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
            and ms.action_end < date_add(curdate() ,interval -day(curdate())+1 day)
            and s.name<>'FFM-TH'
            and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        group by 1,2,3,4

        union all -- 销退
        SELECT
            m.job_number
            ,m.real_name
            ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓')   then 'AGV'
                when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                when w.name='BangsaoThong'  then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
            ,date(complete_time) dt
        FROM wms_production.delivery_rollback_order dro
        left join wms_production.warehouse w ON dro.warehouse_id=w.id
        LEFT JOIN `wms_production`.`seller` sl on dro.`seller_id`=sl.`id`
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
            and create_time >= convert_tz(date_sub(date(now() + interval -1 hour),interval 130 day), '+07:00', '+08:00')
        )irb on dro.back_sn = irb.receive_external_no
        WHERE arrival_time IS NOT NULL
            AND status >= '1045'
            AND STATUS<>'9000'
            AND back_express_status NOT IN('20','30')
            AND complete_time >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
            AND complete_time <  date_add(curdate() ,interval -day(curdate())+1 day)
            and sl.name<>'FFM-TH'
            and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        group by 1,2,3,4

        union all -- 拦截
        SELECT
            m.job_number
            ,m.real_name
            ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓')   then 'AGV'
                when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                when w.name='BangsaoThong'  then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
            ,date(ip.shelf_on_end_time) dt
        FROM wms_production.intercept_place ip
        left join wms_production.warehouse w ON ip.warehouse_id=w.id
        left join wms_production.`member` m on ip.member_id = m.id
        WHERE 1=1
        and (w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')) -- BST
        AND (ip.shelf_on_end_time >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month))
        AND (ip.shelf_on_end_time <  date_add(curdate() ,interval -day(curdate())+1 day))
        GROUP BY 1,2,3,4

        union all -- 拣货
        select
            m.job_number picker_id
            ,m.real_name
            ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓')   then 'AGV'
                when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                when w.name='BangsaoThong'  then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
            ,date(jg.created + interval -1 hour) dt
        from `wms_production`.`pick_order` po
        left join (select from_order_id,task_sn from wms_production.task where task_type=3) t on po.id = t.from_order_id
        left join wms_production.job j on t.task_sn = j.task_sn
        left join wms_production.job_goods jg on jg.job_id = j.id
        left join `wms_production`.`warehouse` w on po.warehouse_id = w.id
        LEFT JOIN `wms_production`.`member` m on po.picker_id = m.id
        where 1=1
            and jg.created + interval -1 hour >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
            and jg.created + interval -1 hour <  date_add(curdate() ,interval -day(curdate())+1 day)
            and po.type = 1
            and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        group by 1,2,3,4

        union all -- 打包复核
        SELECT
            `job_number`
            ,'' real_name
            ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓')   then 'AGV'
                    when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                    when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                    when w.name='BangsaoThong'  then 'BST'
                    when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                    when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
            ,date(end_time) now_date
        FROM wms_production.workload_report wr
        left join `wms_production`.`warehouse` w on wr.warehouse_id = w.id
        WHERE 1=1
        AND w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        AND (wr.`type` = 3)
        AND (`end_time` >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month))
        AND (`end_time` <= date_add(curdate() ,interval -day(curdate())+1 day))
        AND (`order_type` in ('DO', 'RW') )
        GROUP BY 1,2,3,4
        -- ORDER BY  `order_num` DESC

        union all -- 出库
        select
            mb.job_number out_operator
            ,mb.real_name
            ,do.warehouse_name
            ,date(do.handover_time) dt
        from dwm.dwd_th_ffm_outbound_dayV2 do
        LEFT JOIN `wms_production`.`member` mb on do.out_operator=mb.`id`
        where 1=1
            and do.warehouse_name in ('BST', 'AGV', 'LAS', 'BPL-Return')
            and 'B2C'=do.TYPE
            and is_visible=1
            and do.handover_time >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
            and do.handover_time <  date_add(curdate() ,interval -day(curdate())+1 day)
        group by 1,2,3,4

        union all -- 收货
        SELECT
            m.job_number in_staff
            ,m.real_name
            ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓')    then 'AGV'
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
        WHERE 1=1
        and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        AND (`an`.`complete_time` >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month))
        AND (`an`.`complete_time` < date_add(curdate() ,interval -day(curdate())+1 day))
        GROUP BY 1,2,3,4
        -- ORDER BY `order_num` DESC
    )
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
            ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓') then 'AGV'
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
        and so.shelf_on_end >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
        and so.shelf_on_end <  date_add(curdate() ,interval -day(curdate())+1 day)
        and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        and s.name<>'FFM-TH'
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
            ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓') then 'AGV'
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
        and ms.action_end >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
        and ms.action_end <  date_add(curdate() ,interval -day(curdate())+1 day)
        and s.name<>'FFM-TH'
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
            ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓') then 'AGV'
                when w.name='BPL-Return Warehouse' then 'BPL-Return'
                when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                when w.name='BangsaoThong' then 'BST'
                when w.name IN ('BKK-WH-LAS2电商仓')         then 'LAS' # ,'PMD-WH','BKK-WH-Ecommerce','BKK-WH-LAS物料仓'
                when w.name='LCP Warehouse' then 'LCP' end 仓库名称
            ,sl.name seller_name
            ,dro.seller_id
            ,dro.complete_time
            ,dro.complete_id
            ,m.job_number
            ,if(w.name='AutoWarehouse', irb.finish_date, dro.shelf_end_time) shelf_end_time
            ,'销退订单' 入库类型
        FROM wms_production.delivery_rollback_order dro
        left join wms_production.warehouse w ON dro.warehouse_id=w.id
        LEFT JOIN `wms_production`.`seller` sl on dro.`seller_id`=sl.`id`
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
            and create_time >= convert_tz(date_sub(date(now() + interval -1 hour),interval 130 day), '+07:00', '+08:00')
        )irb on dro.back_sn = irb.receive_external_no
        WHERE arrival_time IS NOT NULL
            AND status >= '1045'
            AND STATUS<>'9000'
            AND back_express_status NOT IN('20','30')
            AND complete_time >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
            AND complete_time <  date_add(curdate() ,interval -day(curdate())+1 day)
            and sl.name<>'FFM-TH'
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
        ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓') then 'AGV'
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
    WHERE 1=1
    and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
    AND (ip.shelf_on_end_time >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month))
    AND (ip.shelf_on_end_time <  date_add(curdate() ,interval -day(curdate())+1 day))
    GROUP BY 1,2,3,4
) t_intercept on t0.上架人id = t_intercept.job_number and t0.dt = t_intercept.dt and t0.warehouse_name = t_intercept.仓库名称
left join -- 拣货
(
    select
        t_out.title_name
        ,warehouse_name
        ,t_out.now_date
        ,t_out.picker_id
        ,t_out.picknum
    from
    (
        select
            '拣货' title_name
            ,warehouse_name
            ,picker_id
            ,date(created ) now_date
            ,sum(picknum) picknum
        from
        (
            select
                '拣货' title_name
                ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓')   then 'AGV'
                    when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                    when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                    when w.name='BangsaoThong'  then 'BST'
                    when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                    when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
                ,m.job_number picker_id
                -- ,do.goods_num picknum
                ,jg.num picknum
                ,po.pick_sn
                ,jg.created + interval -1 hour created
                ,po.type
            from `wms_production`.`pick_order` po
            left join (select from_order_id,task_sn from wms_production.task where task_type=3) t on po.id = t.from_order_id
            left join wms_production.job j on t.task_sn = j.task_sn
            left join wms_production.job_goods jg on jg.job_id = j.id
            left join `wms_production`.`warehouse` w on po.warehouse_id = w.id
            LEFT JOIN `wms_production`.`member` m on po.picker_id = m.id
            where 1=1
                and jg.created + interval -1 hour >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
                and jg.created + interval -1 hour <= date_add(curdate() ,interval -day(curdate())+1 day)
                and po.type = 1
                and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        ) t0
        group by 1,2,3,4
    ) t_out
    where 1=1
) t_pick on t0.上架人id = t_pick.picker_id and t0.dt = t_pick.now_date and t0.warehouse_name = t_pick.warehouse_name
left join -- 复核2C
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
            ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓')    then 'AGV'
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
        WHERE 1=1
        AND w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        AND (wr.`type` = 3)
        AND (`end_time` >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month))
        AND (`end_time` <= date_add(curdate() ,interval -day(curdate())+1 day))
        AND (`order_type` = 'DO')
        GROUP BY 1,2,3
        -- ORDER BY  `order_num` DESC
    )t_out where 1=1
) t_pack on t0.上架人id = t_pack.creator_id and t0.dt = t_pack.now_date and t0.warehouse_name = t_pack.warehouse_name
left join -- 出库
(
    select
        out.warehouse_name
        ,out.now_date
        ,out.title_name
        ,out.out_operator
        ,out.outnum
    from
    (
        select
            '出库' title_name
            ,warehouse_name
            ,mb.job_number out_operator
            ,date(do.delivery_time) now_date
            ,count(distinct do.delivery_sn) outnum
        from dwm.dwd_th_ffm_outbound_dayV2 do
        join wms_production.`delivery_order` do1 on do.delivery_sn = do1.delivery_sn
        JOIN wms_production.`delivery_box` `db` ON `do1`.`id` = `db`.`delivery_order_id`
        LEFT JOIN `wms_production`.`member` mb on do1.operator_id=mb.`id`
        where 1=1
            and do.warehouse_name in ('BST', 'AGV', 'LAS')
            and 'B2C'=do.TYPE
            and do.delivery_time >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)
            and do.delivery_time <  date_add(curdate() ,interval -day(curdate())+1 day)
        group by 1,2,3,4
    ) out
) t_handover on t0.上架人id = t_handover.out_operator and t0.dt = t_handover.now_date and t0.warehouse_name = t_handover.warehouse_name
left join -- 收货
(
    -- 收货
    SELECT
        m.job_number in_staff
        ,date(`an`.`complete_time`) dt
        ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓')    then 'AGV'
                        when w.name='BPL-Return Warehouse'  then 'BPL-Return'
                        when w.name in ('BPL3-LIVESTREAM', 'BPL3- Bangphli3 Livestream Warehouse') then 'BPL3'
                        when w.name='BangsaoThong'  then 'BST'
                        when w.name IN ('BKK-WH-LAS2电商仓')    then 'LAS'
                        when w.name ='LCP Warehouse' then 'LCP' end warehouse_name
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
    WHERE 1=1
    and w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
    AND (`an`.`complete_time` >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month))
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
            ,case when w.name in ('AutoWarehouse', 'AutoWarehouse-人工仓')    then 'AGV'
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
        WHERE 1=1
        AND w.name in ('BangsaoThong', 'AutoWarehouse', 'AutoWarehouse-人工仓', 'BKK-WH-LAS2电商仓', 'BPL-Return Warehouse')
        AND (wr.`type` = 3)
        AND (`end_time` >= date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month))
        AND (`end_time` <  date_add(curdate() ,interval -day(curdate())+1 day))
        AND (`order_type` = 'RW') -- 这里是2B出库单
        GROUP BY 1,2,3
        -- ORDER BY  `order_num` DESC
    )t_out where 1=1
) t_pack2B on t0.上架人id = t_pack2B.creator_id and t0.dt = t_pack2B.now_date and t0.warehouse_name = t_pack2B.warehouse_name
left join dwm.dwd_th_ffm_staff_dayV3 staff on t0.上架人id = staff.staff_info_id and t0.dt = staff.stat_date