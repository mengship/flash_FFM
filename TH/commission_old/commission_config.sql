-- tmp_th_ffm_agv_stat1
select
left(date_sub(date_add(now(),interval -60 minute),interval 1 month),7) 月份
,'AGV' 物理仓
,ta.ID1 工号
,t_receive.inboundNum receive
,t_putaway.real_qty putaway
,t_pick.pickNum Pick
,t_pack.packNum pack
,t_out.cnt Outbound
,null B2B_
,null 备注
from
tmpale.tmp_th_AGVstafflistV2 ta
left join -- 上架
(
    SELECT
        left(rwb.gmt_modified, 7)date
        ,rwbd.user_id user_id
        ,bau.work_no
        ,bau.user_name
        -- ,case when action_type = 'PUTAWAY' and rwb.biz_type IN ( 'RESTORE' ) then '拦截上架'
        --     when action_type = 'PUTAWAY' and rwb.biz_type IN ( 'INBOUND' ) and rwb.source_order_type = '4' then '销退上架'
        --     when action_type = 'PUTAWAY' and rwb.biz_type IN ( 'REPLENISH' ) then '补货上架'
        --     when action_type = 'PUTDOWN' and rwb.biz_type IN ( 'REPLENISH') then '补货下架'
        --     when action_type = 'PUTDOWN' and rwb.biz_type IN ( 'TOC_PICK_REPICK' ) then '复检下架'
        --     when action_type = 'PUTDOWN' and rwb.biz_type IN ( 'TRANSFER' ) then '移库下架'
        --     when action_type = 'PUTAWAY' and rwb.biz_type IN ( 'TRANSFER' ) then '移库上架'
        -- end type
        ,'上架' type
        -- ,count( rwbd.item_id ) Sku_num
        ,sum(real_qty)  real_qty
    FROM was.robot_work_bill rwb
    left join was.robot_work_bill_detail rwbd on work_bill_id=rwb.id
    LEFT JOIN was.base_authority_user bau ON rwbd.user_id = bau.user_id
    WHERE rwb.group_id = 1180 -- AGV仓
    AND rwb.del_flag = 0 -- 正常未删除
    AND rwb.status = 'FINISH'-- 已完成
    and  action_type = 'PUTAWAY'
    and  rwb.biz_type IN ( 'INBOUND', 'RESTORE' )
    AND left(rwb.gmt_modified,7)=left(date_sub(date_add(now(),interval -60 minute),interval 1 month),7) -- @todo
    -- and bau.work_no='420015'
    GROUP BY 1,2,3,4,5
) t_putaway on ta.ID1 = t_putaway.work_no
left join -- 收货
(
    SELECT
        left(ircd.create_time, 7) # @todo1
        ,scan_person user_id
        ,bau.work_no # @todo2
        --    ,COUNT(DISTINCT ( ircd.item_id )) inboundSKU
        ,'收货' type
        ,sum(scan_qty) inboundNum
    FROM was.inb_receive_container_detail  ircd
    LEFT JOIN was.base_authority_user bau ON ircd.scan_person = bau.user_id # @todo3
    WHERE ircd.group_id = 1180
    AND left(ircd.create_time,7)=left(date_sub(date_add(now(),interval -60 minute),interval 1 month),7)
    AND ircd.is_deleted = 0
    GROUP BY 1,2,3,4 # @todo4
) t_receive on ta.ID1 = t_receive.work_no
left join  -- 拣选
(
    select
        left(date, 7) month
        ,work_no
        ,sum(pickNum) pickNum
    from
    (
        SELECT
            left(oobt.gmt_modified, 7) date
            ,oobt.operator user_id
            ,bau.work_no
            ,'拣选'type
            -- ,count(DISTINCT ( oobt.order_code )) pickOrder
            ,sum(case when  wobo.type in(1)  then actual_num end) pickNum -- 2,3是ToB
            -- ,sum(actual_num) pickNum
        FROM was.oub_out_bound_task oobt
        LEFT JOIN was.base_authority_user bau ON oobt.operator = bau.user_id
        LEFT JOIN was.was_out_bound_order wobo  on  wobo.order_code = CONVERT(oobt.order_code using gbk) and oobt.group_id = wobo.group_id
        WHERE oobt.del_flag = 0 -- 未删除
        AND oobt.status = 1
        AND oobt.group_id = 1180 -- AGV仓
        AND oobt.type in (1,5)
        and left(oobt.gmt_modified,7)=left(date_sub(date_add(now(),interval -60 minute),interval 1 month),7) -- @todo
        GROUP BY 1,2,3,4

        union all

        select
                date(created) created
                ,picker_id
                ,picker_id
                ,null type
                ,sum(num) sum_num
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
                    where 1=1
                    and left(created,7)=left(date_sub(date_add(now(),interval -60 minute),interval 1 month),7)
            ) t0
            where 1=1
            and warehouse_name is not null
            group by date(created)
                    ,picker_id
                    ,pick_sn
    ) t0
    group by 1,2
) t_pick on ta.ID1 = t_pick.work_no
left join -- 打包
(
    SELECT
        left(wsg.operation_time, 7)date
        ,wsg.creator user_id
        ,bau.work_no
        ,'打包' type
        -- ,count(DISTINCT ( wsg.relevance_code )) packOrder
        -- ,sum(item_num) packNum
        ,sum(case when wobo.type in(1) then item_num END)packNum
    FROM was.was_status_group wsg
    LEFT JOIN was.base_authority_user bau ON wsg.creator = bau.user_id
    left join was.was_package wp on wsg.relevance_code = wp.order_code
    left join was.was_out_bound_order wobo  on  wobo.order_code = wp.order_code and wp.group_id = wobo.group_id
    WHERE wsg.status = 'FINISH_PACK'
    AND wsg.del_flag = 0
    AND wsg.type = 1
    # AND wsg.group_id = 1180
    AND left(wsg.operation_time,7)=left(date_sub(date_add(now(),interval -60 minute),interval 1 month),7) -- @todo
    GROUP BY 1,2,3,4
) t_pack on ta.ID1 = t_pack.work_no
left join -- out
(
    select
        job_number work_no
        ,count(distinct delivery_sn) cnt
    from wms_production.delivery_order do
    left join wms_production.delivery_receipt_order_delivery_ref dror on do.id=dror.delivery_order_id
    left join wms_production.delivery_receipt_order dro on dro.id=dror.delivery_receipt_order_id
    LEFT JOIN `wms_production`.`member` mb on do.operator_id=mb.`id`
    where do.warehouse_id in('36', '78') and left (do.delivery_time,7)=left(date_sub(date_add(now(),interval -60 minute),interval 1 month),7) -- @todo
    group by 1
) t_out on ta.ID1 = t_out.work_no;


select * from tmpale.tmp_th_ffm_agv_stat1
-- tmp_th_ffm_staff_rule1
select
*
from
(
    select
        left(date_sub(date_add(now(),interval -60 minute),interval 1 month),7) 月份
        ,null 序号
        ,'AGV' 物理仓
        ,Postion2 部门
        ,null 部门v2
        ,ID1 工号
        ,null 分组
        ,null KPI
        ,if(Postion2 in ('Abnormal','AGV maintance','CS','Inventory','Supervisor','Admin'), 1, null) KPI系数
        ,if(Postion2 in ('Supervisor'), 1.5, 1) 提成系数
        ,null 备注
    from
    tmpale.tmp_th_AGVstafflistV2

    union all

    select
        left(date_sub(date_add(now(),interval -60 minute),interval 1 month),7) 月份
        ,null 序号
        ,'BST' 物理仓
        ,Postion3 部门
        ,Postion2 部门v2
        ,ID1 工号
        ,if(Postion3='Packing', SUBSTRING_INDEX(SUBSTRING_INDEX(Postion1,' ', 2),' ', -1), null) 分组
        ,null KPI
        ,null KPI系数
        ,1 提成系数
        ,null 备注
    from
    tmpale.tmp_th_BSTstafflistV2
) t0
order by 物理仓, 部门, 分组;

-- datagrip_tmp_th_ffm_bst_stat1
select
    left(date_sub(date_add(now(),interval -60 minute),interval 1 month),7) 月份
    ,'BST' 物理仓
    ,null 员工序号
    ,null 部门序号
    ,Postion3 部门
    ,ID1 工号
    ,t_pick.cnt Picking
    ,t_pack.cnt Packing
from
tmpale.tmp_th_BSTstafflistV2 tbs
left join -- 打包
(
    select
        复核人ID
        ,count(发货单号) cnt
    from dwm.dwd_th_ffm_outbound_day dtfod
    where 类型='wms发货单'
    # and 仓库='BST'
    AND left(打包完成时间,7) = left(date_sub(date_add(now(),interval -60 minute),interval 1 month),7)
    and 货主名称 not in ('FFM-TH', 'Flash -Thailand')
    group by 1 order by 2 desc
) t_pack on tbs.ID1 = t_pack.复核人ID
left join -- 拣货
(
    select
        pick_id
        ,count(发货单号) cnt
    from dwm.dwd_th_ffm_outbound_day dtfod
    where 类型='wms发货单'
    # and 仓库='BST'
    AND left(拣货完成时间,7) = left(date_sub(date_add(now(),interval -60 minute),interval 1 month),7)
    and 货主名称 not in ('FFM-TH', 'Flash -Thailand')
    group by 1 order by 2 desc
) t_pick on tbs.ID1 = t_pick.pick_id
order by Postion3 desc, ID1;


# verify data accuracy
select * from tmpale.tmp_th_AGVstafflistV2;

select * from tmpale.tmp_th_BSTstafflistV2;

select * from tmpale.tmp_th_ffm_agv_stat1;

select * from tmpale.tmp_th_ffm_bst_stat1;

select * from tmpale.tmp_th_ffm_staff_goal1;

select * from tmpale.tmp_th_ffm_staff_rule1;